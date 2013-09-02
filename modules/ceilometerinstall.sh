#!/bin/bash
#
# Instalador desatendido para Openstack sobre DEBIAN
# Reynaldo R. Martinez P.
# E-Mail: TigerLinux@Gmail.com
# Agosto del 2013
#
# Script de instalacion y preparacion de ceilometer
#

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

if [ -f ./configs/main-config.rc ]
then
	source ./configs/main-config.rc
	mkdir -p /etc/openstack-control-script-config
else
	echo "No puedo acceder a mi archivo de configuración"
	echo "Revise que esté ejecutando el instalador/módulos en el directorio correcto"
	echo "Abortando !!!!."
	echo ""
	exit 0
fi

if [ -f /etc/openstack-control-script-config/db-installed ]
then
	echo ""
	echo "Proceso de BD verificado - continuando"
	echo ""
else
	echo ""
	echo "Este módulo depende de que el proceso de base de datos"
	echo "haya sido exitoso, pero aparentemente no lo fue"
	echo "Abortando el módulo"
	echo ""
	exit 0
fi

if [ -f /etc/openstack-control-script-config/keystone-installed ]
then
	echo ""
	echo "Proceso principal de Keystone verificado - continuando"
	echo ""
else
	echo ""
	echo "Este módulo depende del proceso principal de keystone"
	echo "pero no se pudo verificar que dicho proceso haya sido"
	echo "completado exitosamente - se abortará el proceso"
	echo ""
	exit 0
fi

if [ -f /etc/openstack-control-script-config/ceilometer-installed ]
then
	echo ""
	echo "Este módulo ya fue ejecutado de manera exitosa - saliendo"
	echo ""
	exit 0
fi

echo ""
echo "Instalando paquetes para Ceilometer"
echo ""

echo "Instalando y configurando backend de base de datos MongoDB"
echo ""
aptitude -y install mongodb mongodb-clients mongodb-dev mongodb-server

/etc/init.d/mongodb restart
chkconfig mongodb on


echo "ceilometer-api ceilometer/register-endpoint boolean false" > /tmp/ceilometer-seed.txt
echo "ceilometer-api ceilometer/region-name string $endpointsregion" >> /tmp/ceilometer-seed.txt
echo "ceilometer-api ceilometer/endpoint-ip string $ceilometerhost" >> /tmp/ceilometer-seed.txt
echo "ceilometer-api ceilometer/keystone-ip string $keystonehost" >> /tmp/ceilometer-seed.txt

debconf-set-selections /tmp/ceilometer-seed.txt

echo ""
echo "Instalando paquetes de Ceilometer"
echo ""

aptitude -y install ceilometer-agent-central ceilometer-agent-compute ceilometer-api \
	ceilometer-collector ceilometer-common python-ceilometer python-ceilometerclient

echo "Listo"
echo ""

/etc/init.d/ceilometer-agent-central stop
/etc/init.d/ceilometer-agent-compute stop
/etc/init.d/ceilometer-api stop
/etc/init.d/ceilometer-collector stop

source $keystone_admin_rc_file

rm /tmp/ceilometer-seed.txt

echo ""
echo "Configurando Ceilometer"
echo ""

openstack-config --set /etc/ceilometer/ceilometer.conf keystone_authtoken auth_host $keystonehost
openstack-config --set /etc/ceilometer/ceilometer.conf keystone_authtoken auth_port 35357
openstack-config --set /etc/ceilometer/ceilometer.conf keystone_authtoken auth_protocol http
openstack-config --set /etc/ceilometer/ceilometer.conf keystone_authtoken admin_tenant_name $keystoneservicestenant
openstack-config --set /etc/ceilometer/ceilometer.conf keystone_authtoken admin_user $ceilometeruser
openstack-config --set /etc/ceilometer/ceilometer.conf keystone_authtoken admin_password $ceilometerpass

openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT os_auth_url "http://$keystonehost:35357/v2.0"
openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT os_tenant_name $keystoneservicestenant
openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT os_password $ceilometerpass
openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT os_username $ceilometeruser

openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT metering_api_port 8777
openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT auth_strategy keystone
openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT logdir /var/log/ceilometer

openstack-config --del /etc/ceilometer/ceilometer.conf DEFAULT sql_connection

kvm_possible=`grep -E 'svm|vmx' /proc/cpuinfo|uniq|wc -l`
if [ $kvm_possible == "0" ]
then
	openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT libvirt_type qemu
else
	openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT libvirt_type kvm
fi

openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT debug false
openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT verbose false
openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT database_connection "mongodb://$mondbhost:$mondbport/$mondbname"
openstack-config --set /etc/ceilometer/ceilometer.conf publisher_meter metering_secret $metering_secret

case $brokerflavor in
"qpid")
	openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT rpc_backend ceilometer.openstack.common.rpc.impl_qpid
	openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT qpid_hostname $messagebrokerhost
	openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT qpid_port 5672
	openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT qpid_username $brokeruser
	openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT qpid_password $brokerpass
	openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT qpid_heartbeat 60
	openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT qpid_protocol tcp
	openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT qpid_tcp_nodelay true
	;;

"rabbitmq")
	openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT rpc_backend ceilometer.openstack.common.rpc.impl_kombu
	openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT rabbit_host $messagebrokerhost
	openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT rabbit_port 5672
	openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT rabbit_use_ssl false
	openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT rabbit_userid $brokeruser
	openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT rabbit_password $brokerpass
	openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT rabbit_virtual_host $brokervhost
	openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT rabbit_retry_interval 1
	openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT rabbit_retry_backoff 2
	openstack-config --set /etc/ceilometer/ceilometer.conf DEFAULT rabbit_max_retries 0
	;;
esac

grep -v format_string /etc/nova/nova.conf > /etc/ceilometer-collector.conf

echo ""
echo "Aplicando reglas de IPTABLES"

iptables -A INPUT -p tcp -m multiport --dports 8777,$mondbport -j ACCEPT
/etc/init.d/iptables-persistent save

echo "Listo"

/etc/init.d/mongodb stop

sync
sleep 5
sync

/etc/init.d/mongodb start

sync
sleep 5
sync
chkconfig mongodb on

/etc/init.d/ceilometer-agent-compute start
chkconfig ceilometer-agent-compute on

/etc/init.d/ceilometer-agent-central start
chkconfig ceilometer-agent-central on

/etc/init.d/ceilometer-api start
chkconfig ceilometer-api on

/etc/init.d/ceilometer-collector start
chkconfig ceilometer-collector on

echo "Dormiré por 10 segundos y reiniciaré el servicio de collector de datos"
sync
sleep 10
sync

# Nota: Esto no es paranoia... a veces la primera vez que arranca el collector,
# el servicio se cae. Por si acaso, lo bajamos, esperamos 5 segundos, y lo subimos
# de nuevo

service ceilometer-collector stop
sync
sleep 5
sync
service ceilometer-collector start

testceilometer=`dpkg -l ceilometer-api 2>/dev/null|tail -n 1|grep -ci ^ii`
if [ $testceilometer == "0" ]
then
	echo ""
	echo "Falló la instalación de ceilometer - abortando el resto de la instalación"
	echo ""
	exit 0
else
	date > /etc/openstack-control-script-config/ceilometer-installed
	date > /etc/openstack-control-script-config/ceilometer
fi

echo ""
echo "Ceilometer Instalado"
echo ""



