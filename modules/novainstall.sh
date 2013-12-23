#!/bin/bash
#
# Instalador desatendido para Openstack sobre DEBIAN
# Reynaldo R. Martinez P.
# E-Mail: TigerLinux@Gmail.com
# Agosto del 2013
#
# Script de instalacion y preparacion de Nova
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

if [ -f /etc/openstack-control-script-config/nova-installed ]
then
	echo ""
	echo "Este módulo ya fue ejecutado de manera exitosa - saliendo"
	echo ""
	exit 0
fi

echo ""
echo "Instalando paquetes para Nova"

echo "keystone keystone/auth-token password $SERVICE_TOKEN" > /tmp/keystone-seed.txt
echo "keystone keystone/admin-password password $keystoneadminpass" >> /tmp/keystone-seed.txt
echo "keystone keystone/admin-password-confirm password $keystoneadminpass" >> /tmp/keystone-seed.txt
echo "keystone keystone/admin-user string admin" >> /tmp/keystone-seed.txt
echo "keystone keystone/admin-tenant-name string $keystoneadminuser" >> /tmp/keystone-seed.txt
echo "keystone keystone/region-name string $endpointsregion" >> /tmp/keystone-seed.txt
echo "keystone keystone/endpoint-ip string $keystonehost" >> /tmp/keystone-seed.txt
echo "keystone keystone/register-endpoint boolean false" >> /tmp/keystone-seed.txt
echo "keystone keystone/admin-email string $keystoneadminuseremail" >> /tmp/keystone-seed.txt
echo "keystone keystone/admin-role-name string $keystoneadmintenant" >> /tmp/keystone-seed.txt
echo "keystone keystone/configure_db boolean false" >> /tmp/keystone-seed.txt
echo "keystone keystone/create-admin-tenant boolean false" >> /tmp/keystone-seed.txt

debconf-set-selections /tmp/keystone-seed.txt

echo "glance-common glance/admin-password password $glancepass" > /tmp/glance-seed.txt
echo "glance-common glance/auth-host string $keystonehost" >> /tmp/glance-seed.txt
echo "glance-api glance/keystone-ip string $keystonehost" >> /tmp/glance-seed.txt
echo "glance-common glance/paste-flavor select keystone" >> /tmp/glance-seed.txt
echo "glance-common glance/admin-tenant-name string $keystoneadmintenant" >> /tmp/glance-seed.txt
echo "glance-api glance/endpoint-ip string $glancehost" >> /tmp/glance-seed.txt
echo "glance-api glance/region-name string $endpointsregion" >> /tmp/glance-seed.txt
echo "glance-api glance/register-endpoint boolean false" >> /tmp/glance-seed.txt
echo "glance-common glance/admin-user	string $keystoneadminuser" >> /tmp/glance-seed.txt
echo "glance-common glance/configure_db boolean false" >> /tmp/glance-seed.txt

debconf-set-selections /tmp/glance-seed.txt

echo "cinder-common cinder/admin-password password $cinderpass" > /tmp/cinder-seed.txt
echo "cinder-api cinder/region-name string $endpointsregion" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/configure_db boolean false" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/admin-tenant-name string $keystoneadmintenant" >> /tmp/cinder-seed.txt
echo "cinder-api cinder/register-endpoint boolean false" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/auth-host string $keystonehost" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/start_services boolean false" >> /tmp/cinder-seed.txt
echo "cinder-api cinder/endpoint-ip string $cinderhost" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/volume_group string cinder-volumes" >> /tmp/cinder-seed.txt
echo "cinder-api cinder/keystone-ip string $keystonehost" >> /tmp/cinder-seed.txt
echo "cinder-common cinder/admin-user string $keystoneadminuser" >> /tmp/cinder-seed.txt

debconf-set-selections /tmp/cinder-seed.txt

echo "quantum-common quantum/admin-password password $keystoneadminpass" > /tmp/quantum-seed.txt
echo "quantum-metadata-agent quantum/admin-password password $keystoneadminpass" >> /tmp/quantum-seed.txt
echo "quantum-server quantum/keystone-ip string $keystonehost" >> /tmp/quantum-seed.txt
echo "quantum-plugin-openvswitch quantum-plugin-openvswitch/local_ip string $quantumhost" >> /tmp/quantum-seed.txt
echo "quantum-plugin-openvswitch quantum-plugin-openvswitch/configure_db boolean false" >> /tmp/quantum-seed.txt
echo "quantum-metadata-agent quantum/region-name string $endpointsregion" >> /tmp/quantum-seed.txt
echo "quantum-server quantum/region-name string $endpointsregion" >> /tmp/quantum-seed.txt
echo "quantum-server quantum/register-endpoint boolean false" >> /tmp/quantum-seed.txt
echo "quantum-plugin-openvswitch quantum-plugin-openvswitch/tenant_network_type select vlan" >> /tmp/quantum-seed.txt
echo "quantum-common quantum/admin-user string $keystoneadminuser" >> /tmp/quantum-seed.txt
echo "quantum-metadata-agent quantum/admin-user string $keystoneadminuser" >> /tmp/quantum-seed.txt
echo "quantum-plugin-openvswitch quantum-plugin-openvswitch/tunnel_id_ranges string 0" >> /tmp/quantum-seed.txt
echo "quantum-plugin-openvswitch quantum-plugin-openvswitch/enable_tunneling boolean false" >> /tmp/quantum-seed.txt
echo "quantum-common quantum/auth-host string $keystonehost" >> /tmp/quantum-seed.txt
echo "quantum-metadata-agent quantum/auth-host string $keystonehost" >> /tmp/quantum-seed.txt
echo "quantum-server quantum/endpoint-ip string $quantumhost" >> /tmp/quantum-seed.txt
echo "quantum-common quantum/admin-tenant-name string $keystoneadmintenant" >> /tmp/quantum-seed.txt
echo "quantum-metadata-agent quantum/admin-tenant-name string $keystoneadmintenant" >> /tmp/quantum-seed.txt

debconf-set-selections /tmp/quantum-seed.txt

echo "nova-common nova/admin-password password $keystoneadminpass" > /tmp/nova-seed.txt
echo "nova-common nova/configure_db boolean false" >> /tmp/nova-seed.txt
echo "nova-consoleproxy nova-consoleproxy/daemon_type select spicehtml5" >> /tmp/nova-seed.txt
echo "nova-common nova/rabbit-host string 127.0.0.1" >> /tmp/nova-seed.txt
echo "nova-api nova/register-endpoint boolean false" >> /tmp/nova-seed.txt
echo "nova-common nova/my-ip string $novahost" >> /tmp/nova-seed.txt
echo "nova-common nova/start_services boolean false" >> /tmp/nova-seed.txt
echo "nova-common nova/admin-user string $keystoneadminuser" >> /tmp/nova-seed.txt
echo "nova-api nova/region-name string $endpointsregion" >> /tmp/nova-seed.txt
echo "nova-common nova/admin-tenant-name string $keystoneadmintenant" >> /tmp/nova-seed.txt
echo "nova-api nova/endpoint-ip string $novahost" >> /tmp/nova-seed.txt
echo "nova-api nova/keystone-ip string $keystonehost" >> /tmp/nova-seed.txt
echo "nova-common nova/active-api multiselect ec2, osapi_compute, metadata" >> /tmp/nova-seed.txt
echo "nova-common nova/auth-host string $keystonehost" >> /tmp/nova-seed.txt

debconf-set-selections /tmp/nova-seed.txt


# Verificamos si este servidor va a poder soportar KVM - Si no, mas adelante
# configuraremos NOVA para usar qemu en lugar de kvm
# Si esta variable da cero, habrá que configurar la máquina para QEMU.
kvm_possible=`grep -E 'svm|vmx' /proc/cpuinfo|uniq|wc -l`

if [ $kvm_possible == "0" ]
then
	nova_kvm_or_qemu="nova-compute-qemu"
else
	nova_kvm_or_qemu="nova-compute-kvm"
fi

if [ $nova_in_compute_node = "no" ]
then
	aptitude -y install $nova_kvm_or_qemu \
		nova-api \
		nova-cert \
		nova-common \
		nova-compute \
		nova-conductor \
		nova-console \
		nova-consoleauth \
		nova-consoleproxy \
		nova-doc \
		nova-scheduler \
		nova-volume \
		python-novaclient \
		liblapack3gf \
		python-gtk-vnc \
		novnc
else
	aptitude -y install $nova_kvm_or_qemu
fi

echo "Listo"
echo ""


source $keystone_admin_rc_file

rm -f /tmp/nova-seed.txt
rm -f /tmp/quantum-seed.txt
rm -f /tmp/cinder-seed.txt
rm -f /tmp/glance-seed.txt
rm -f /tmp/keystone-seed.txt

echo ""
echo "Aplicando Reglas de IPTABLES"

iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 6080 -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 6081 -j ACCEPT
iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 6082 -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 5900:5999 -j ACCEPT
iptables -A INPUT -p tcp -m multiport --dports 8773,8774,8775 -j ACCEPT
/etc/init.d/iptables-persistent save
echo ""
echo "Listo"
echo ""

echo "Configurando NOVA"

if [ $nova_in_compute_node = "no" ]
then
	openstack-config --set /etc/nova/api-paste.ini filter:authtoken paste.filter_factory "keystoneclient.middleware.auth_token:filter_factory"
	openstack-config --set /etc/nova/api-paste.ini filter:authtoken service_protocol http
	openstack-config --set /etc/nova/api-paste.ini filter:authtoken service_host $keystonehost
	openstack-config --set /etc/nova/api-paste.ini filter:authtoken auth_version v2.0
	openstack-config --set /etc/nova/api-paste.ini filter:authtoken admin_tenant_name $keystoneservicestenant
	openstack-config --set /etc/nova/api-paste.ini filter:authtoken auth_port 35357
	openstack-config --set /etc/nova/api-paste.ini filter:authtoken admin_password $novapass
	openstack-config --set /etc/nova/api-paste.ini filter:authtoken admin_user $novauser
fi

openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_host $keystonehost
openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_port 35357
openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_protocol http
openstack-config --set /etc/nova/nova.conf keystone_authtoken admin_tenant_name $keystoneservicestenant
openstack-config --set /etc/nova/nova.conf keystone_authtoken admin_user $novauser
openstack-config --set /etc/nova/nova.conf keystone_authtoken admin_password $novapass
openstack-config --set /etc/nova/nova.conf keystone_authtoken signing_dir /tmp/keystone-signing-nova


#
# Configuración principal
#

openstack-config --set /etc/nova/nova.conf DEFAULT logdir /var/log/nova
openstack-config --set /etc/nova/nova.conf DEFAULT state_path /var/lib/nova
openstack-config --set /etc/nova/nova.conf DEFAULT lock_path /var/lib/nova/tmp
openstack-config --set /etc/nova/nova.conf DEFAULT volumes_dir /etc/nova/volumes
openstack-config --set /etc/nova/nova.conf DEFAULT dhcpbridge /usr/bin/nova-dhcpbridge
openstack-config --set /etc/nova/nova.conf DEFAULT dhcpbridge_flagfile /etc/nova/nova.conf
openstack-config --set /etc/nova/nova.conf DEFAULT force_dhcp_release True
openstack-config --set /etc/nova/nova.conf DEFAULT injected_network_template /usr/share/nova/interfaces.template
openstack-config --set /etc/nova/nova.conf DEFAULT libvirt_nonblocking True
openstack-config --set /etc/nova/nova.conf DEFAULT libvirt_inject_partition -1
openstack-config --set /etc/nova/nova.conf DEFAULT network_manager nova.network.manager.FlatDHCPManager
openstack-config --set /etc/nova/nova.conf DEFAULT iscsi_helper tgtadm

#
# Base de datos
#

case $dbflavor in
"mysql")
	openstack-config --set /etc/nova/nova.conf DEFAULT sql_connection mysql://$novadbuser:$novadbpass@$dbbackendhost:$mysqldbport/$novadbname
	;;
"postgres")
	openstack-config --set /etc/nova/nova.conf DEFAULT sql_connection postgresql://$novadbuser:$novadbpass@$dbbackendhost:$psqldbport/$novadbname
	;;
esac

#
# Sigue configuración principal
#

osapiworkers=`grep processor.\*: /proc/cpuinfo |wc -l`

openstack-config --set /etc/nova/nova.conf DEFAULT compute_driver libvirt.LibvirtDriver
openstack-config --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
openstack-config --set /etc/nova/nova.conf DEFAULT rootwrap_config /etc/nova/rootwrap.conf
openstack-config --set /etc/nova/nova.conf DEFAULT osapi_volume_listen 0.0.0.0
openstack-config --set /etc/nova/nova.conf DEFAULT auth_strategy keystone
openstack-config --set /etc/nova/nova.conf DEFAULT verbose False
openstack-config --set /etc/nova/nova.conf DEFAULT ec2_listen 0.0.0.0
openstack-config --set /etc/nova/nova.conf DEFAULT service_down_time 60
openstack-config --set /etc/nova/nova.conf DEFAULT image_service nova.image.glance.GlanceImageService
openstack-config --set /etc/nova/nova.conf DEFAULT libvirt_use_virtio_for_bridges True
openstack-config --set /etc/nova/nova.conf DEFAULT osapi_compute_listen 0.0.0.0
openstack-config --set /etc/nova/nova.conf DEFAULT quantum_metadata_proxy_shared_secret $metadata_shared_secret
openstack-config --set /etc/nova/nova.conf DEFAULT metadata_listen 0.0.0.0
openstack-config --set /etc/nova/nova.conf DEFAULT osapi_compute_workers $osapiworkers
openstack-config --set /etc/nova/nova.conf DEFAULT libvirt_vif_driver nova.virt.libvirt.vif.LibvirtHybridOVSBridgeDriver
openstack-config --set /etc/nova/nova.conf DEFAULT quantum_region_name $endpointsregion
openstack-config --set /etc/nova/nova.conf DEFAULT network_api_class nova.network.quantumv2.api.API
openstack-config --set /etc/nova/nova.conf DEFAULT debug False
openstack-config --set /etc/nova/nova.conf DEFAULT my_ip $novahost
openstack-config --set /etc/nova/nova.conf DEFAULT quantum_auth_strategy keystone
openstack-config --set /etc/nova/nova.conf DEFAULT quantum_admin_password $quantumpass
openstack-config --set /etc/nova/nova.conf DEFAULT api_paste_config /etc/nova/api-paste.ini
openstack-config --set /etc/nova/nova.conf DEFAULT glance_api_servers $glancehost:9292
openstack-config --set /etc/nova/nova.conf DEFAULT quantum_admin_tenant_name $keystoneservicestenant
openstack-config --set /etc/nova/nova.conf DEFAULT iscsi_helper tgtadm
openstack-config --set /etc/nova/nova.conf DEFAULT metadata_host $novahost
openstack-config --set /etc/nova/nova.conf DEFAULT security_group_api quantum
openstack-config --set /etc/nova/nova.conf DEFAULT quantum_admin_auth_url "http://$keystonehost:35357/v2.0"
openstack-config --set /etc/nova/nova.conf DEFAULT enabled_apis "ec2,osapi_compute,metadata"
openstack-config --set /etc/nova/nova.conf DEFAULT quantum_admin_username $quantumuser
openstack-config --set /etc/nova/nova.conf DEFAULT service_quantum_metadata_proxy True
openstack-config --set /etc/nova/nova.conf DEFAULT volume_api_class nova.volume.cinder.API
openstack-config --set /etc/nova/nova.conf DEFAULT quantum_url "http://$quantumhost:9696"
openstack-config --set /etc/nova/nova.conf DEFAULT libvirt_type kvm
openstack-config --set /etc/nova/nova.conf DEFAULT instance_name_template $instance_name_template
openstack-config --set /etc/nova/nova.conf DEFAULT start_guests_on_host_boot $start_guests_on_host_boot
openstack-config --set /etc/nova/nova.conf DEFAULT resume_guests_state_on_host_boot $resume_guests_state_on_host_boot
openstack-config --set /etc/nova/nova.conf DEFAULT instance_name_template $instance_name_template
openstack-config --set /etc/nova/nova.conf DEFAULT allow_resize_to_same_host $allow_resize_to_same_host
openstack-config --set /etc/nova/nova.conf DEFAULT ram_allocation_ratio $ram_allocation_ratio
openstack-config --set /etc/nova/nova.conf DEFAULT cpu_allocation_ratio $cpu_allocation_ratio
openstack-config --set /etc/nova/nova.conf DEFAULT connection_type libvirt
openstack-config --set /etc/nova/nova.conf DEFAULT scheduler_default_filters "RetryFilter,AvailabilityZoneFilter,RamFilter,ComputeFilter,ComputeCapabilitiesFilter,ImagePropertiesFilter,CoreFilter"
openstack-config --set /etc/nova/nova.conf DEFAULT force_config_drive true
openstack-config --set /etc/nova/nova.conf DEFAULT config_drive_format iso9660
openstack-config --set /etc/nova/nova.conf DEFAULT config_drive_cdrom true
openstack-config --set /etc/nova/nova.conf DEFAULT config_drive_inject_password True
openstack-config --set /etc/nova/nova.conf DEFAULT mkisofs_cmd genisoimage
openstack-config --set /etc/nova/nova.conf DEFAULT dhcp_domain $dhcp_domain

openstack-config --del /etc/nova/nova.conf DEFAULT rabbit_host
openstack-config --del /etc/nova/nova.conf DEFAULT linuxnet_interface_driver
openstack-config --del /etc/nova/nova.conf DEFAULT allow_admin_api

case $brokerflavor in
"qpid")
	openstack-config --set /etc/nova/nova.conf DEFAULT rpc_backend nova.openstack.common.rpc.impl_qpid
	openstack-config --set /etc/nova/nova.conf DEFAULT qpid_reconnect_interval_min 0
	openstack-config --set /etc/nova/nova.conf DEFAULT qpid_username $brokeruser
	openstack-config --set /etc/nova/nova.conf DEFAULT qpid_reconnect True
	openstack-config --set /etc/nova/nova.conf DEFAULT qpid_tcp_nodelay True
	openstack-config --set /etc/nova/nova.conf DEFAULT qpid_protocol tcp
	openstack-config --set /etc/nova/nova.conf DEFAULT qpid_hostname $messagebrokerhost
	openstack-config --set /etc/nova/nova.conf DEFAULT qpid_password $brokerpass
	openstack-config --set /etc/nova/nova.conf DEFAULT qpid_port 5672
	openstack-config --set /etc/nova/nova.conf DEFAULT qpid_reconnect_limit 0
	openstack-config --set /etc/nova/nova.conf DEFAULT qpid_reconnect_interval 0
	openstack-config --set /etc/nova/nova.conf DEFAULT qpid_reconnect_timeout 0
	openstack-config --set /etc/nova/nova.conf DEFAULT qpid_heartbeat 60
	openstack-config --set /etc/nova/nova.conf DEFAULT qpid_reconnect_interval_max 0
	;;

"rabbitmq")
	openstack-config --set /etc/nova/nova.conf DEFAULT rpc_backend nova.openstack.common.rpc.impl_kombu
	openstack-config --set /etc/nova/nova.conf DEFAULT rabbit_host $messagebrokerhost
	openstack-config --set /etc/nova/nova.conf DEFAULT rabbit_userid $brokeruser
	openstack-config --set /etc/nova/nova.conf DEFAULT rabbit_password $brokerpass
	openstack-config --set /etc/nova/nova.conf DEFAULT rabbit_port 5672
	openstack-config --set /etc/nova/nova.conf DEFAULT rabbit_use_ssl false
	openstack-config --set /etc/nova/nova.conf DEFAULT rabbit_virtual_host $brokervhost
	;;
esac


# Para la versión de DEBIAN, se usará SPICE - NoVNC-OpenStack parece estar BROKEN en Debian 7.
#
openstack-config --del /etc/nova/nova.conf novncproxy_host
openstack-config --del /etc/nova/nova.conf vncserver_proxyclient_address
openstack-config --del /etc/nova/nova.conf novncproxy_base_url
openstack-config --del /etc/nova/nova.conf novncproxy_port
openstack-config --del /etc/nova/nova.conf vncserver_listen
openstack-config --del /etc/nova/nova.conf vnc_keymap

openstack-config --set /etc/nova/nova.conf DEFAULT vnc_enabled False
openstack-config --set /etc/nova/nova.conf DEFAULT novnc_enabled False

openstack-config --set /etc/nova/nova.conf spice html5proxy_base_url "http://$spiceserver_controller_address:6082/spice_auto.html"
openstack-config --set /etc/nova/nova.conf spice server_listen 0.0.0.0
openstack-config --set /etc/nova/nova.conf spice server_proxyclient_address $novahost
openstack-config --set /etc/nova/nova.conf spice enabled True
openstack-config --set /etc/nova/nova.conf spice agent_enabled True
openstack-config --set /etc/nova/nova.conf spice keymap en-us


sed -r -i 's/NOVA_ENABLE\=false/NOVA_ENABLE\=true/' /etc/default/nova-common

sync
sleep 5
sync

if [ $kvm_possible == "0" ]
then
	echo ""
	echo "ALERTA !!! - Este servidor NO SOPORTA KVM - Se reconfigurará NOVA"
	echo "para usar virtualización por software vía QEMU"
	echo "El rendimiento será pobre"
	echo ""
	source $keystone_admin_rc_file
	openstack-config --set /etc/nova/nova.conf DEFAULT libvirt_type qemu
	echo ""
else
	openstack-config --set /etc/nova/nova.conf DEFAULT libvirt_cpu_mode $libvirt_cpu_mode
fi

sync
sleep 5
sync

if [ $nova_in_compute_node = "no" ]
then
	su nova -s /bin/sh -c "nova-manage db sync"
fi

sync
sleep 5
sync

echo "Listo"

echo "Activando Servicios de Nova"

if [ $nova_in_compute_node = "no" ]
then
	/etc/init.d/nova-api start
	chkconfig nova-api on

	/etc/init.d/nova-cert start
	chkconfig nova-cert on

	/etc/init.d/nova-scheduler start
	chkconfig nova-scheduler on

	/etc/init.d/nova-conductor start
	chkconfig nova-conductor on

	/etc/init.d/nova-console start
	chkconfig nova-console on

	/etc/init.d/nova-consoleauth start
	chkconfig nova-consoleauth on

	/etc/init.d/nova-spicehtml5proxy start
	chkconfig nova-spicehtml5proxy on

	if [ $nova_without_compute = "no" ]
	then
		/etc/init.d/nova-compute start
		chkconfig nova-compute on
	else
		/etc/init.d/nova-compute stop
		chkconfig nova-compute off
	fi

	chkconfig nova-spicehtml5proxy on
	chkconfig nova-novncproxy off
	chkconfig nova-xenvncproxy off
else
	/etc/init.d/nova-compute start
	chkconfig nova-compute on
fi

echo ""
echo "Listo"

echo ""
echo "Voy a dormir por 10 segundos - Me encanta dormir y hacerles perder tiempo"
echo ""

sync
sleep 10
sync

/etc/init.d/iptables-persistent save

echo ""
echo "Ya me desperté... sonaría el despertador ??"
echo ""

if [ $nova_in_compute_node = "no" ]
then
	if [ $vm_default_access == "yes" ]
	then
		echo ""
		echo "Creando accesos de seguridad para las VM's"
		echo "Puertos: ssh e ICMP"
		echo ""
		source $keystone_admin_rc_file
		nova secgroup-add-rule default tcp 22 22 0.0.0.0/0
		nova secgroup-add-rule default icmp -1 -1 0.0.0.0/0
		echo "Listo"
		echo ""
	fi

	for vmport in $vm_extra_ports_tcp
	do
		echo ""
		echo "Creando acceso de seguridad para el puerto $vmport tcp"
		source $keystone_admin_rc_file
		nova secgroup-add-rule default tcp $vmport $vmport 0.0.0.0/0
	done

	for vmport in $vm_extra_ports_udp
	do
		echo ""
		echo "Creando acceso de seguridad para el puerto $vmport udp"
		source $keystone_admin_rc_file
		nova secgroup-add-rule default udp $vmport $vmport 0.0.0.0/0
	done
fi

testnova=`dpkg -l nova-common 2>/dev/null|tail -n 1|grep -ci ^ii`
if [ $testnova == "0" ]
then
	echo ""
	echo "Falló la instalación de nova - abortando el resto de la instalación"
	echo ""
	exit 0
else
	date > /etc/openstack-control-script-config/nova-installed
	date > /etc/openstack-control-script-config/nova
	if [ $nova_in_compute_node = "no" ]
	then
		date > /etc/openstack-control-script-config/nova-full-installed
	fi
	if [ $nova_without_compute = "yes" ]
	then
		if [ $nova_in_compute_node = "no" ]
		then
			date > /etc/openstack-control-script-config/nova-without-compute
		fi
	fi
fi

echo ""
echo "Nova Instalado y Configurado"
echo ""








