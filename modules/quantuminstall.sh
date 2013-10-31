#!/bin/bash
#
# Instalador desatendido para Openstack sobre DEBIAN
# Reynaldo R. Martinez P.
# E-Mail: TigerLinux@Gmail.com
# Agosto del 2013
#
# Script de instalacion y preparacion de quantum
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

if [ -f /etc/openstack-control-script-config/quantum-installed ]
then
	echo ""
	echo "Este módulo ya fue ejecutado de manera exitosa - saliendo"
	echo ""
	exit 0
fi

echo "Instalando Paquetes para QUANTUM"

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

echo ""

if [ $quantum_in_compute_node == "yes" ]
then
	aptitude -y install quantum-common \
		python-quantum \
		python-quantumclient \
		quantum-plugin-openvswitch \
		quantum-plugin-openvswitch-agent
else
	echo "Instalando haproxy"
	dpkg -i ./libs/haproxy*.deb

	aptitude -y install quantum-server \
		quantum-common quantum-dhcp-agent \
		quantum-l3-agent quantum-lbaas-agent \
		quantum-metadata-agent python-quantum \
		python-quantumclient \
		quantum-plugin-openvswitch \
		quantum-plugin-openvswitch-agent
fi

# aptitude -y install quantum-server quantum-common quantum-dhcp-agent quantum-l3-agent quantum-lbaas-agent quantum-metadata-agent python-quantum python-quantumclient quantum-plugin-openvswitch quantum-plugin-openvswitch-agent

echo ""
echo "Listo"

echo ""
echo "Preparando configuración inicial de Quantum"

ln -s /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini /etc/quantum/plugin.ini

rm -f /tmp/quantum-seed.txt
rm -f /tmp/cinder-seed.txt
rm -f /tmp/glance-seed.txt
rm -f /tmp/keystone-seed.txt

if [ $quantum_in_compute_node == "yes" ]
then
	/etc/init.d/quantum-plugin-openvswitch-agent stop
else
	/etc/init.d/quantum-plugin-openvswitch-agent stop
	/etc/init.d/quantum-dhcp-agent stop
	/etc/init.d/quantum-lbaas-agent stop
	/etc/init.d/quantum-metadata-agent stop
	/etc/init.d/quantum-l3-agent stop
	/etc/init.d/quantum-server stop
fi

echo "Listo"


if [ $quantum_in_compute_node == "no" ]
then

	echo ""
	echo "Configurando dnsmasq para Quantum"

	sleep 5
	cat /etc/dnsmasq.conf > $dnsmasq_config_file
	mkdir -p /etc/dnsmasq-quantum.d
	echo "user=quantum" >> $dnsmasq_config_file
	echo "group=quantum" >> $dnsmasq_config_file
	echo "conf-dir=/etc/dnsmasq-quantum.d" >> $dnsmasq_config_file
	echo "# Extra options for Quantum-DNSMASQ" > /etc/dnsmasq-quantum.d/quantum-dnsmasq-extra.conf
	echo "# Samples:" >> /etc/dnsmasq-quantum.d/quantum-dnsmasq-extra.conf
	echo "# dhcp-option=option:ntp-server,192.168.1.1" >> /etc/dnsmasq-quantum.d/quantum-dnsmasq-extra.conf
	echo "# dhcp-option = tag:tag0, option:ntp-server, 192.168.1.1" >> /etc/dnsmasq-quantum.d/quantum-dnsmasq-extra.conf
	echo "# dhcp-option = tag:tag1, option:ntp-server, 192.168.1.1" >> /etc/dnsmasq-quantum.d/quantum-dnsmasq-extra.conf
	echo "# expand-hosts"  >> /etc/dnsmasq-quantum.d/quantum-dnsmasq-extra.conf
	echo "# domain=dominio-interno-uno.home,192.168.1.0/24"  >> /etc/dnsmasq-quantum.d/quantum-dnsmasq-extra.conf
	echo "# domain=dominio-interno-dos.home,192.168.100.0/24"  >> /etc/dnsmasq-quantum.d/quantum-dnsmasq-extra.conf
	sync
	sleep 5

	echo "Listo"
	echo ""
fi

source $keystone_admin_rc_file

echo ""
echo "Aplicando Reglas de IPTABLES"
iptables -A INPUT -p tcp -m multiport --dports 9696 -j ACCEPT
iptables -A INPUT -p udp -m state --state NEW -m udp --dport 67 -j ACCEPT
iptables -A INPUT -p udp -m state --state NEW -m udp --dport 68 -j ACCEPT
iptables -t mangle -A POSTROUTING -p udp -m udp --dport 67 -j CHECKSUM --checksum-fill
iptables -t mangle -A POSTROUTING -p udp -m udp --dport 68 -j CHECKSUM --checksum-fill
/etc/init.d/iptables-persistent save
echo "Listo"

echo ""
echo "Configurando Quantum"

openstack-config --set /etc/quantum/quantum.conf DEFAULT auth_strategy keystone
openstack-config --set /etc/quantum/quantum.conf keystone_authtoken auth_host $keystonehost
openstack-config --set /etc/quantum/quantum.conf keystone_authtoken admin_tenant_name $keystoneservicestenant
openstack-config --set /etc/quantum/quantum.conf keystone_authtoken admin_user $quantumuser
openstack-config --set /etc/quantum/quantum.conf keystone_authtoken admin_password $quantumpass

sync
sleep 2
sync

openstack-config --set /etc/quantum/quantum.conf DEFAULT notification_driver quantum.openstack.common.notifier.rpc_notifier
openstack-config --set /etc/quantum/quantum.conf DEFAULT default_notification_level INFO
openstack-config --set /etc/quantum/quantum.conf DEFAULT notification_topics notifications
openstack-config --set /etc/quantum/quantum.conf DEFAULT log_dir /var/log/quantum
openstack-config --set /etc/quantum/quantum.conf DEFAULT qpid_reconnect True
openstack-config --set /etc/quantum/quantum.conf DEFAULT core_plugin quantum.plugins.openvswitch.ovs_quantum_plugin.OVSQuantumPluginV2
openstack-config --set /etc/quantum/quantum.conf DEFAULT debug False
openstack-config --set /etc/quantum/quantum.conf DEFAULT verbose False
openstack-config --set /etc/quantum/quantum.conf DEFAULT state_path /var/lib/quantum
openstack-config --set /etc/quantum/quantum.conf DEFAULT lock_path /var/lib/quantum/lock
openstack-config --set /etc/quantum/quantum.conf DEFAULT bind_host 0.0.0.0
openstack-config --set /etc/quantum/quantum.conf DEFAULT bind_port 9696
openstack-config --set /etc/quantum/quantum.conf DEFAULT service_plugins quantum.plugins.services.agent_loadbalancer.plugin.LoadBalancerPlugin
openstack-config --set /etc/quantum/quantum.conf DEFAULT api_paste_config api-paste.ini
openstack-config --set /etc/quantum/quantum.conf DEFAULT base_mac "$basemacspec"
openstack-config --set /etc/quantum/quantum.conf DEFAULT mac_generation_retries 16
openstack-config --set /etc/quantum/quantum.conf DEFAULT dhcp_lease_duration 120
openstack-config --set /etc/quantum/quantum.conf DEFAULT allow_bulk True
openstack-config --set /etc/quantum/quantum.conf DEFAULT allow_overlapping_ips False
openstack-config --set /etc/quantum/quantum.conf DEFAULT control_exchange quantum
openstack-config --set /etc/quantum/quantum.conf AGENT root_helper "sudo quantum-rootwrap /etc/quantum/rootwrap.conf"

case $brokerflavor in
"qpid")
	openstack-config --set /etc/quantum/quantum.conf DEFAULT rpc_backend quantum.openstack.common.rpc.impl_qpid
	openstack-config --set /etc/quantum/quantum.conf DEFAULT qpid_hostname $messagebrokerhost
	openstack-config --set /etc/quantum/quantum.conf DEFAULT qpid_port 5672
	openstack-config --set /etc/quantum/quantum.conf DEFAULT qpid_username $brokeruser
	openstack-config --set /etc/quantum/quantum.conf DEFAULT qpid_password $brokerpass
	openstack-config --set /etc/quantum/quantum.conf DEFAULT qpid_heartbeat 60
	openstack-config --set /etc/quantum/quantum.conf DEFAULT qpid_protocol tcp
	openstack-config --set /etc/quantum/quantum.conf DEFAULT qpid_tcp_nodelay True
	openstack-config --set /etc/quantum/quantum.conf DEFAULT qpid_reconnect_interval 0
	openstack-config --set /etc/quantum/quantum.conf DEFAULT qpid_reconnect_interval_min 0
	openstack-config --set /etc/quantum/quantum.conf DEFAULT qpid_reconnect_interval_max 0
	openstack-config --set /etc/quantum/quantum.conf DEFAULT qpid_reconnect_timeout 0
	openstack-config --set /etc/quantum/quantum.conf DEFAULT qpid_reconnect_limit 0
	openstack-config --set /etc/quantum/quantum.conf DEFAULT qpid_reconnect True
	;;

"rabbitmq")
	openstack-config --set /etc/quantum/quantum.conf DEFAULT rpc_backend quantum.openstack.common.rpc.impl_kombu
	openstack-config --set /etc/quantum/quantum.conf DEFAULT rabbit_host $messagebrokerhost
	openstack-config --set /etc/quantum/quantum.conf DEFAULT rabbit_password $brokerpass
	openstack-config --set /etc/quantum/quantum.conf DEFAULT rabbit_userid $brokeruser
	openstack-config --set /etc/quantum/quantum.conf DEFAULT rabbit_port 5672
	openstack-config --set /etc/quantum/quantum.conf DEFAULT rabbit_use_ssl false
	openstack-config --set /etc/quantum/quantum.conf DEFAULT rabbit_virtual_host $brokervhost
	openstack-config --set /etc/quantum/quantum.conf DEFAULT rabbit_max_retries 0
	openstack-config --set /etc/quantum/quantum.conf DEFAULT rabbit_retry_interval 1
	openstack-config --set /etc/quantum/quantum.conf DEFAULT rabbit_ha_queues false
	;;
esac

sync
sleep 2
sync

if [ $quantum_in_compute_node == "no" ]
then
	openstack-config --set /etc/quantum/l3_agent.ini DEFAULT debug False
	openstack-config --set /etc/quantum/l3_agent.ini DEFAULT interface_driver quantum.agent.linux.interface.OVSInterfaceDriver
	openstack-config --set /etc/quantum/l3_agent.ini DEFAULT ovs_use_veth True
	openstack-config --set /etc/quantum/l3_agent.ini DEFAULT use_namespaces True
	openstack-config --set /etc/quantum/l3_agent.ini DEFAULT handle_internal_only_routers True
	openstack-config --set /etc/quantum/l3_agent.ini DEFAULT external_network_bridge ""
	openstack-config --set /etc/quantum/l3_agent.ini DEFAULT metadata_port 9697

	sync
	sleep 2
	sync

	openstack-config --set /etc/quantum/dhcp_agent.ini DEFAULT debug False
	openstack-config --set /etc/quantum/dhcp_agent.ini DEFAULT resync_interval 30
	openstack-config --set /etc/quantum/dhcp_agent.ini DEFAULT interface_driver quantum.agent.linux.interface.OVSInterfaceDriver
	openstack-config --set /etc/quantum/dhcp_agent.ini DEFAULT ovs_use_veth True
	openstack-config --set /etc/quantum/dhcp_agent.ini DEFAULT dhcp_driver quantum.agent.linux.dhcp.Dnsmasq
	openstack-config --set /etc/quantum/dhcp_agent.ini DEFAULT use_namespaces True
	openstack-config --set /etc/quantum/dhcp_agent.ini DEFAULT state_path /var/lib/quantum
	openstack-config --set /etc/quantum/dhcp_agent.ini DEFAULT dnsmasq_config_file $dnsmasq_config_file
	openstack-config --set /etc/quantum/dhcp_agent.ini DEFAULT dhcp_domain $dhcp_domain

	sync
	sleep 2
	sync
fi

openstack-config --set /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini DATABASE sql_max_retries 10
openstack-config --set /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini DATABASE reconnect_interval 2

case $dbflavor in
"mysql")
	openstack-config --set /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini DATABASE sql_connection mysql://$quantumdbuser:$quantumdbpass@$dbbackendhost:$mysqldbport/$quantumdbname
	;;
"postgres")
	openstack-config --set /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini DATABASE sql_connection postgresql://$quantumdbuser:$quantumdbpass@$dbbackendhost:$psqldbport/$quantumdbname
	;;
esac

openstack-config --del /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini OVS tunnel_id_ranges
openstack-config --del /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini OVS local_ip
openstack-config --del /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini OVS enable_tunneling
openstack-config --del /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini OVS tenant_network_type
sync
sleep 5
sync
openstack-config --set /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini OVS integration_bridge $integration_bridge
openstack-config --set /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini OVS bridge_mappings $bridge_mappings
openstack-config --set /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini OVS enable_tunneling False
openstack-config --set /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini OVS network_vlan_ranges $network_vlan_ranges
openstack-config --set /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini OVS tenant_network_type vlan

openstack-config --set /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini AGENT polling_interval 2

openstack-config --set /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini SECURITYGROUP firewall_driver quantum.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver

sync
sleep 2
sync

ln -f -s /etc/quantum/plugins/openvswitch/ovs_quantum_plugin.ini /etc/quantum/plugin.ini

openstack-config --set /etc/quantum/api-paste.ini filter:authtoken paste.filter_factory "keystoneclient.middleware.auth_token:filter_factory"
openstack-config --set /etc/quantum/api-paste.ini filter:authtoken auth_protocol http
openstack-config --set /etc/quantum/api-paste.ini filter:authtoken auth_host $keystonehost
openstack-config --set /etc/quantum/api-paste.ini filter:authtoken admin_tenant_name $keystoneservicestenant
openstack-config --set /etc/quantum/api-paste.ini filter:authtoken admin_user $quantumuser
openstack-config --set /etc/quantum/api-paste.ini filter:authtoken admin_password $quantumpass
openstack-config --set /etc/quantum/api-paste.ini filter:authtoken auth_port 35357


if [ $quantum_in_compute_node == "no" ]
then
	openstack-config --set /etc/quantum/metadata_agent.ini DEFAULT debug False
	openstack-config --set /etc/quantum/metadata_agent.ini DEFAULT auth_url "http://$keystonehost:35357/v2.0"
	openstack-config --set /etc/quantum/metadata_agent.ini DEFAULT auth_region $endpointsregion
	openstack-config --set /etc/quantum/metadata_agent.ini DEFAULT admin_tenant_name $keystoneservicestenant
	openstack-config --set /etc/quantum/metadata_agent.ini DEFAULT admin_user $quantumuser
	openstack-config --set /etc/quantum/metadata_agent.ini DEFAULT admin_password $quantumpass
	openstack-config --set /etc/quantum/metadata_agent.ini DEFAULT nova_metadata_ip $novahost
	openstack-config --set /etc/quantum/metadata_agent.ini DEFAULT nova_metadata_port 8775
	openstack-config --set /etc/quantum/metadata_agent.ini DEFAULT metadata_proxy_shared_secret $metadata_shared_secret

	sync
	sleep 2
	sync

	openstack-config --set /etc/quantum/lbaas_agent.ini DEFAULT periodic_interval 10
	openstack-config --set /etc/quantum/lbaas_agent.ini DEFAULT interface_driver quantum.agent.linux.interface.OVSInterfaceDriver
	openstack-config --set /etc/quantum/lbaas_agent.ini DEFAULT ovs_use_veth True
	openstack-config --set /etc/quantum/lbaas_agent.ini DEFAULT device_driver quantum.plugins.services.agent_loadbalancer.drivers.haproxy.namespace_driver.HaproxyNSDriver
	openstack-config --set /etc/quantum/lbaas_agent.ini DEFAULT use_namespaces True
	openstack-config --set /etc/quantum/lbaas_agent.ini DEFAULT user_group quantum

	sync
	sleep 2
	sync

	mkdir -p /etc/quantum/plugins/services/agent_loadbalancer
	cp -v /etc/quantum/lbaas_agent.ini /etc/quantum/plugins/services/agent_loadbalancer/
	chown root.quantum /etc/quantum/plugins/services/agent_loadbalancer/lbaas_agent.ini
	sync
fi

case $brokerflavor in
"qpid")
	openstack-config --set /etc/quantum/quantum.conf DEFAULT rpc_backend quantum.openstack.common.rpc.impl_qpid
	openstack-config --set /etc/quantum/quantum.conf DEFAULT qpid_hostname $messagebrokerhost
	openstack-config --set /etc/quantum/quantum.conf DEFAULT qpid_port 5672
	openstack-config --set /etc/quantum/quantum.conf DEFAULT qpid_username $brokeruser
	openstack-config --set /etc/quantum/quantum.conf DEFAULT qpid_password $brokerpass
	openstack-config --set /etc/quantum/quantum.conf DEFAULT qpid_heartbeat 60
	openstack-config --set /etc/quantum/quantum.conf DEFAULT qpid_protocol tcp
	openstack-config --set /etc/quantum/quantum.conf DEFAULT qpid_tcp_nodelay True
	openstack-config --set /etc/quantum/quantum.conf DEFAULT qpid_reconnect_interval 0
	openstack-config --set /etc/quantum/quantum.conf DEFAULT qpid_reconnect_interval_min 0
	openstack-config --set /etc/quantum/quantum.conf DEFAULT qpid_reconnect_interval_max 0
	openstack-config --set /etc/quantum/quantum.conf DEFAULT qpid_reconnect_timeout 0
	openstack-config --set /etc/quantum/quantum.conf DEFAULT qpid_reconnect_limit 0
	openstack-config --set /etc/quantum/quantum.conf DEFAULT qpid_reconnect True
	;;

"rabbitmq")
	openstack-config --set /etc/quantum/quantum.conf DEFAULT rpc_backend quantum.openstack.common.rpc.impl_kombu
	openstack-config --set /etc/quantum/quantum.conf DEFAULT rabbit_host $messagebrokerhost
	openstack-config --set /etc/quantum/quantum.conf DEFAULT rabbit_password $brokerpass
	openstack-config --set /etc/quantum/quantum.conf DEFAULT rabbit_userid $brokeruser
	openstack-config --set /etc/quantum/quantum.conf DEFAULT rabbit_port 5672
	openstack-config --set /etc/quantum/quantum.conf DEFAULT rabbit_use_ssl false
	openstack-config --set /etc/quantum/quantum.conf DEFAULT rabbit_virtual_host $brokervhost
	openstack-config --set /etc/quantum/quantum.conf DEFAULT rabbit_max_retries 0
	openstack-config --set /etc/quantum/quantum.conf DEFAULT rabbit_retry_interval 1
	openstack-config --set /etc/quantum/quantum.conf DEFAULT rabbit_ha_queues false
	;;
esac

# ovs-vsctl del-port br-int patch-tun
# ovs-vsctl del-br br-tun

sync
sleep 2
sync

echo ""
echo "Listo"
echo ""

echo "Activando Servicios de Quantum"
 
if [ $quantum_in_compute_node == "yes" ]
then
	/etc/init.d/quantum-server stop
	chkconfig quantum-server off

	/etc/init.d/quantum-dhcp-agent stop
	chkconfig quantum-dhcp-agent off

	/etc/init.d/quantum-l3-agent stop
	chkconfig quantum-l3-agent off

	/etc/init.d/quantum-lbaas-agent stop
	chkconfig quantum-lbaas-agent off

	/etc/init.d/quantum-metadata-agent stop
	chkconfig quantum-metadata-agent off

	/etc/init.d/quantum-plugin-openvswitch-agent start
	chkconfig quantum-plugin-openvswitch-agent on
else
	/etc/init.d/quantum-server start
	chkconfig quantum-server on

	/etc/init.d/quantum-dhcp-agent start
	chkconfig quantum-dhcp-agent on

	/etc/init.d/quantum-l3-agent start
	chkconfig quantum-l3-agent on

	/etc/init.d/quantum-lbaas-agent start
	chkconfig quantum-lbaas-agent on

	/etc/init.d/quantum-metadata-agent start
	chkconfig quantum-metadata-agent on

	/etc/init.d/quantum-plugin-openvswitch-agent start
	chkconfig quantum-plugin-openvswitch-agent on
fi

echo "Listo"

echo ""
echo "Voy a dormir por 10 segundos"
sync
sleep 10
sync
echo ""
echo "Ya desperté - continuando"
echo ""

# quantum net-create publica --shared --provider:network_type flat --provider:physical_network publica
if [ $quantum_in_compute_node == "no" ]
then
	if [ $network_create == "yes" ]
	then
		source $keystone_admin_rc_file

		for MyNet in $network_create_list
		do
			echo ""
			echo "Creando red $MyNet"
			quantum net-create $MyNet --shared --provider:network_type flat --provider:physical_network $MyNet
			echo ""
			echo "Red $MyNet creada !"
			echo ""
		done
	fi
fi

echo ""
echo "Voy a dormir otros 10 segundos - soy un dormilon"
echo ""
sync
sleep 10
sync
/etc/init.d/iptables-persistent save

echo "ya desperté"

testquantum=`dpkg -l quantum-common 2>/dev/null|tail -n 1|grep -ci ^ii`
if [ $testquantum == "0" ]
then
	echo ""
	echo "Falló la instalación de quantum - abortando el resto de la instalación"
	echo ""
	exit 0
else
	date > /etc/openstack-control-script-config/quantum-installed
	date > /etc/openstack-control-script-config/quantum
	if [ $quantum_in_compute_node == "no" ]
	then
		date > /etc/openstack-control-script-config/quantum-full-installed
	fi
fi

echo ""
echo "Servicio Quantum Configurado y operativo"
echo ""









