#!/bin/bash
#
# Instalador desatendido para Openstack sobre CENTOS
# Reynaldo R. Martinez P.
# E-Mail: TigerLinux@Gmail.com
#
# Script de control de servicios para OpenStack
#
#

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

if [ ! -d /etc/openstack-control-script-config ]
then
	echo ""
	echo "No encuento mi directorio de control: /etc/openstack-control-script-config"
	echo "Abortando !"
	echo ""
	exit 0
fi

keystone_svc_start='keystone'

swift_svc_start='
	swift-account
	swift-account-auditor
	swift-account-reaper
	swift-account-replicator
	swift-container
	swift-container-auditor
	swift-container-replicator
	swift-container-updater
	swift-object
	swift-object-auditor
	swift-object-replicator
	swift-object-updater
	swift-proxy
'

glance_svc_start='
	glance-registry
	glance-api
'

cinder_svc_start='
	cinder-api
	cinder-scheduler
	cinder-volume
'

if [ -f /etc/openstack-control-script-config/quantum-full-installed ]
then
	quantum_svc_start='
		quantum-server
		quantum-dhcp-agent
		quantum-l3-agent
		quantum-lbaas-agent
		quantum-metadata-agent
		quantum-plugin-openvswitch-agent
	'
else
	quantum_svc_start='
		quantum-plugin-openvswitch-agent
	'
fi

if [ -f /etc/openstack-control-script-config/nova-full-installed ]
then
	if [ -f /etc/openstack-control-script-config/nova-without-compute ]
	then
		nova_svc_start='
			nova-api
			nova-cert
			nova-scheduler
			nova-conductor
			nova-console
			nova-consoleauth
			nova-spicehtml5proxy
		'
	else
		nova_svc_start='
			nova-api
			nova-cert
			nova-scheduler
			nova-conductor
			nova-console
			nova-consoleauth
			nova-spicehtml5proxy
			nova-compute
		'
	fi
else
	nova_svc_start='
		nova-compute
	'
fi

ceilometer_svc_start='
	ceilometer-agent-compute
	ceilometer-agent-central
	ceilometer-api
	ceilometer-collector
'



service_status_stop=`echo $service_status_start_enable_disable|tac -s' '`

keystone_svc_stop='keystone'
swift_svc_stop=`echo $swift_svc_start|tac -s' '`
glance_svc_stop=`echo $glance_svc_start|tac -s' '`
cinder_svc_stop=`echo $cinder_svc_start|tac -s' '`
quantum_svc_stop=`echo $quantum_svc_start|tac -s' '`
nova_svc_stop=`echo $nova_svc_start|tac -s' '`
ceilometer_svc_stop=`echo $ceilometer_svc_start|tac -s' '`


case $1 in

start)

	echo ""
	echo "Arrancando Servicios de Openstack"
	echo ""

	if [ -f /etc/openstack-control-script-config/keystone ]
	then
		for i in $keystone_svc_start
		do
			service $i start
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/swift ]
	then
		for i in $swift_svc_start
		do
			service $i start
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/glance ]
	then
		for i in $glance_svc_start
		do
			service $i start
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/cinder ]
	then
		for i in $cinder_svc_start
		do
			service $i start
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/quantum ]
	then
		for i in $quantum_svc_start
		do
			service $i start
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/nova ]
	then
		for i in $nova_svc_start
		do
			service $i start
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/ceilometer ]
	then
		for i in $ceilometer_svc_start
		do
			service $i start
			#sleep 1
		done
	fi

	echo ""

	;;

stop)

	echo ""
	echo "Deteniendo Servicios de OpenStack"
	echo ""

	if [ -f /etc/openstack-control-script-config/ceilometer ]
	then
		for i in $ceilometer_svc_stop
		do
			service $i stop
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/nova ]
	then
		for i in $nova_svc_stop
		do
			service $i stop
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/quantum ]
	then
		for i in $quantum_svc_stop
		do
			service $i stop
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/cinder ]
	then
		for i in $cinder_svc_stop
		do
			service $i stop
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/glance ]
	then
		for i in $glance_svc_stop
		do
			service $i stop
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/swift ]
	then
		for i in $swift_svc_stop
		do
			service $i stop
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/keystone ]
	then
		for i in $keystone_svc_stop
		do
			service $i stop
			#sleep 1
		done
	fi

	rm -rf /tmp/keystone-signing-*
	rm -rf /tmp/cd_gen_*	

	echo ""

	;;

status)

	echo ""
	echo "Verificando estado de los servicios de OpenStack"
	echo ""


	if [ -f /etc/openstack-control-script-config/keystone ]
	then
		for i in $keystone_svc_start
		do
			service $i status
		done
	fi

	if [ -f /etc/openstack-control-script-config/swift ]
	then
		for i in $swift_svc_start
		do
			service $i status
		done
	fi

	if [ -f /etc/openstack-control-script-config/glance ]
	then
		for i in $glance_svc_start
		do
			service $i status
		done
	fi

	if [ -f /etc/openstack-control-script-config/cinder ]
	then
		for i in $cinder_svc_start
		do
			service $i status
		done
	fi

	if [ -f /etc/openstack-control-script-config/quantum ]
	then
		for i in $quantum_svc_start
		do
			service $i status
		done
	fi

	if [ -f /etc/openstack-control-script-config/nova ]
	then
		for i in $nova_svc_start
		do
			service $i status
		done
	fi

	if [ -f /etc/openstack-control-script-config/ceilometer ]
	then
		for i in $ceilometer_svc_start
		do
			service $i status
		done
	fi

	echo ""
	;;

enable)

	echo ""
	echo "Activando arranque automatico de servicios de OpenStack"
	echo ""

	if [ -f /etc/openstack-control-script-config/keystone ]
	then
		for i in $keystone_svc_start
		do
			chkconfig $i on
		done
	fi

	if [ -f /etc/openstack-control-script-config/swift ]
	then
		for i in $swift_svc_start
		do
			chkconfig $i on
		done
	fi

	if [ -f /etc/openstack-control-script-config/glance ]
	then
		for i in $glance_svc_start
		do
			chkconfig $i on
		done
	fi

	if [ -f /etc/openstack-control-script-config/cinder ]
	then
		for i in $cinder_svc_start
		do
			chkconfig $i on
		done
	fi

	if [ -f /etc/openstack-control-script-config/quantum ]
	then
		for i in $quantum_svc_start
		do
			chkconfig $i on
		done
	fi

	if [ -f /etc/openstack-control-script-config/nova ]
	then
		for i in $nova_svc_start
		do
			chkconfig $i on
		done
	fi

	if [ -f /etc/openstack-control-script-config/ceilometer ]
	then
		for i in $ceilometer_svc_start
		do
			chkconfig $i on
		done
	fi


	echo ""
	;;

disable)

	echo ""
        echo "Desactivando arranque automatico de servicios de OpenStack"
        echo ""

	if [ -f /etc/openstack-control-script-config/keystone ]
	then
		for i in $keystone_svc_start
		do
			chkconfig $i off
		done
	fi

	if [ -f /etc/openstack-control-script-config/swift ]
	then
		for i in $swift_svc_start
		do
			chkconfig $i off
		done
	fi

	if [ -f /etc/openstack-control-script-config/glance ]
	then
		for i in $glance_svc_start
		do
			chkconfig $i off
		done
	fi

	if [ -f /etc/openstack-control-script-config/cinder ]
	then
		for i in $cinder_svc_start
		do
			chkconfig $i off
		done
	fi

	if [ -f /etc/openstack-control-script-config/quantum ]
	then
		for i in $quantum_svc_start
		do
			chkconfig $i off
		done
	fi

	if [ -f /etc/openstack-control-script-config/nova ]
	then
		for i in $nova_svc_start
		do
			chkconfig $i off
		done
	fi

	if [ -f /etc/openstack-control-script-config/ceilometer ]
	then
		for i in $ceilometer_svc_start
		do
			chkconfig $i off
		done
	fi

        echo ""
	;;

restart)

	echo ""
	echo "Reiniciando Servicios de OpenStack"
	echo ""


	if [ -f /etc/openstack-control-script-config/ceilometer ]
	then
		for i in $ceilometer_svc_stop
		do
			service $i stop
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/nova ]
	then
		for i in $nova_svc_stop
		do
			service $i stop
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/quantum ]
	then
		for i in $quantum_svc_stop
		do
			service $i stop
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/cinder ]
	then
		for i in $cinder_svc_stop
		do
			service $i stop
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/glance ]
	then
		for i in $glance_svc_stop
		do
			service $i stop
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/swift ]
	then
		for i in $swift_svc_stop
		do
			service $i stop
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/keystone ]
	then
		for i in $keystone_svc_stop
		do
			service $i stop
			#sleep 1
		done
	fi

	rm -rf /tmp/keystone-signing-*
	rm -rf /tmp/cd_gen_*

	if [ -f /etc/openstack-control-script-config/keystone ]
	then
		for i in $keystone_svc_start
		do
			service $i start
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/swift ]
	then
		for i in $swift_svc_start
		do
			service $i start
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/glance ]
	then
		for i in $glance_svc_start
		do
			service $i start
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/cinder ]
	then
		for i in $cinder_svc_start
		do
			service $i start
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/quantum ]
	then
		for i in $quantum_svc_start
		do
			service $i start
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/nova ]
	then
		for i in $nova_svc_start
		do
			service $i start
			#sleep 1
		done
	fi

	if [ -f /etc/openstack-control-script-config/ceilometer ]
	then
		for i in $ceilometer_svc_start
		do
			service $i start
			#sleep 1
		done
	fi

	echo ""

	;;

*)
	echo ""
	echo "Modo de uso: $0 start, stop, status, restart, enable, o disable:"
	echo "start:    Arranca todos los servicios de OpenStack"
	echo "stop:     Detiene todos los servicios de OpenStack"
	echo "restart:  Reinicia en orden todos los servicios de OpenStack"
	echo "enable:   Activa el arranque automatico de todos los servicios de OpenStack"
	echo "disable:  Desactiva el arranque automatico de todos los servicios de OpenStack"
	echo ""
	;;

esac
