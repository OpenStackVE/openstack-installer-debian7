#!/bin/bash
#
# Instalador desatendido para Openstack sobre DEBIAN
# Reynaldo R. Martinez P.
# E-Mail: TigerLinux@Gmail.com
# Julio del 2013
#
# Script de desinstalacion de OpenStack para Debian 7
#

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

if [ -f ./configs/main-config.rc ]
then
	source ./configs/main-config.rc
else
	echo "No puedo acceder a mi archivo de configuración"
	echo "Revise que esté ejecutando el instalador en su directorio"
	echo "Abortando !!!!."
	echo ""
	exit 0
fi

clear

echo "Bajando y desactivando Servicios de OpenStack"

/usr/local/bin/openstack-control.sh stop
/usr/local/bin/openstack-control.sh disable

chkconfig tgtd off

rm -rf /tmp/keystone-signing-*
rm -rf /tmp/cd_gen_*


if [ $ceilometerinstall == "yes" ]
then
	/etc/init.d/mongodb force-stop
	/etc/init.d/mongodb force-stop
	chkconfig mongodb off
	killall -9 -u mongodb
	aptitude -y purge mongodb mongodb-clients mongodb-dev mongodb-server
	userdel -f -r mongodb
	rm -rf 	/var/lib/mongodb /var/log/mongodb
fi

killall -9 dnsmasq

echo ""
echo "Eliminando Paquetes de OpenStack"
echo ""


if [ $horizoninstall == "yes" ]
then
	echo ""
	echo "Limpiando Apache de referencias del Dashboard"
	echo ""
	a2dissite openstack-dashboard.conf
	a2dissite openstack-dashboard-ssl.conf
	a2dissite openstack-dashboard-ssl-redirect.conf
	a2ensite default

	a2dismod wsgi

	service apache2 restart

	cp -v ./libs/openstack-dashboard* /etc/apache2/sites-available/
	chmod 644 /etc/apache2/sites-available/openstack-dashboard*

	aptitude -y purge memcached openstack-dashboard openstack-dashboard-apache

	rm -f /etc/apache2/sites-available/openstack-dashboard*
	rm -f /etc/apache2/sites-enabled/openstack-dashboard*

	service apache2 restart

	echo ""
	echo "Listo"
	echo ""
fi

echo ""
echo "Purgando paquetes"
echo ""

aptitude -y purge virt-top ceilometer-agent-central ceilometer-agent-compute ceilometer-api \
	ceilometer-collector ceilometer-common python-ceilometer python-ceilometerclient nova-api \
	nova-cert nova-common nova-compute nova-conductor nova-console nova-consoleauth \
	nova-consoleproxy nova-doc nova-scheduler nova-volume nova-compute-qemu nova-compute-kvm \
	python-novaclient liblapack3gf python-gtk-vnc novnc quantum-server quantum-common \
	quantum-dhcp-agent quantum-l3-agent quantum-lbaas-agent quantum-metadata-agent python-quantum \
	python-quantumclient quantum-plugin-openvswitch quantum-plugin-openvswitch-agent haproxy \
	cinder-api cinder-common cinder-scheduler cinder-volume python-cinderclient tgt open-iscsi \
	glance glance-api glance-common glance-registry swift swift-account swift-container swift-doc \
	swift-object swift-plugin-s3 swift-proxy memcached python-swift keystone keystone-doc \
	python-keystone python-keystoneclient python-psycopg2 python-sqlalchemy python-sqlalchemy-ext \
	python-psycopg2 python-mysqldb dnsmasq dnsmasq-utils qpidd libqpidbroker2 libqpidclient2 \
	libqpidcommon2 libqpidtypes1 python-cqpid python-qpid python-qpid-extras-qmf qpid-client \
	qpid-tools qpid-doc qemu kvm qemu-kvm libvirt-bin libvirt-doc rabbitmq-server

apt-get -y autoremove


if [ $cleanundeviceatuninstall == "yes" ]
then
	rm -rf /srv/node/$swiftdevice/accounts
	rm -rf /srv/node/$swiftdevice/containers
	rm -rf /srv/node/$swiftdevice/objects
	rm -rf /srv/node/$swiftdevice/tmp
	chown -R root:root /srv/node/
fi

echo "Eliminando Usuarios de Servicios de OpenStack"

userdel -f -r qpidd
userdel -f -r keystone
userdel -f -r glance
userdel -f -r cinder
userdel -f -r quantum
userdel -f -r nova
userdel -f -r ceilometer
userdel -f -r swift
userdel -r -f rabbitmq

echo "Eliminando Archivos remanentes"

rm -fr  /etc/qpid \
	/var/run/qpid \
	/var/log/qpid \
	/var/spool/qpid \
	/var/spool/qpidd \
	/usr/local/bin/openstack-config \
	/var/lib/libvirt \
	/etc/glance \
	/etc/keystone \
	/var/log/glance \
	/var/log/keystone \
	/var/lib/glance \
	/var/lib/keystone \
	/etc/cinder \
	/var/lib/cinder \
	/var/log/cinder \
	/etc/sudoers.d/cinder \
	/etc/tgt \
	/etc/quantum \
	/var/lib/quantum \
	/var/log/quantum \
	/etc/sudoers.d/quantum \
	/etc/nova \
	/var/log/nova \
	/var/lib/nova \
	/etc/sudoers.d/nova \
	/etc/openstack-dashboard \
	/var/log/horizon \
	/etc/ceilometer \
	/var/log/ceilometer \
	/var/lib/ceilometer \
	/etc/ceilometer-collector.conf \
	/etc/swift/ \
	/var/lib/swift \
	/var/cache/swift \
	/tmp/keystone-signing-swift \
	/var/lib/rabbitmq \
	/etc/openstack-control-script-config \
	/var/lib/keystone-signing-swift \
	$dnsmasq_config_file \
	/etc/dnsmasq-quantum.d \
	/etc/init.d/tgtd




rm -f /root/keystonerc_admin
rm -f /root/ks_admin_token

rm -f /usr/local/bin/openstack-control.sh
rm -f /usr/local/bin/openstack-log-cleaner.sh

if [ $snmpinstall == "yes" ]
then
	if [ -f /etc/snmp/snmpd.conf.pre-openstack ]
	then
		rm -f /etc/snmp/snmpd.conf
		mv /etc/snmp/snmpd.conf.pre-openstack /etc/snmp/snmpd.conf
		service snmpd restart
	else
		service snmpd stop
		aptitude -y purge snmpd snmp-mibs-downloader snmp virt-top
		rm -rf /etc/snmp/snmpd.*
	fi
	rm -f /etc/cron.d/openstack-monitor.crontab \
	/var/tmp/node-cpu.txt \
	/var/tmp/node-memory.txt \
	/var/tmp/packstack \
	/var/tmp/vm-cpu-ram.txt \
	/var/tmp/vm-disk.txt \
	/var/tmp/vm-number-by-states.txt \
	/usr/local/bin/vm-number-by-states.sh \
	/usr/local/bin/vm-total-cpu-and-ram-usage.sh \
	/usr/local/bin/vm-total-disk-bytes-usage.sh \
	/usr/local/bin/node-cpu.sh \
	/usr/local/bin/node-memory.sh

	service cron restart
fi

echo "Limpiando IPTABLES"

/etc/init.d/iptables-persistent flush
/etc/init.d/iptables-persistent save

if [ $dbinstall == "yes" ]
then

	echo ""
	echo "Desinstalando software de Base de Datos"
	echo ""
	case $dbflavor in
	"mysql")
		/etc/init.d/mysql stop
		sync
		sleep 5
		sync
		aptitude -y purge mysql-server-5.5 mysql-server mysql-server-core-5.5 mysql-common \
			libmysqlclient18 mysql-client-5.5
		userdel -f -r mysql
		rm -rf /var/lib/mysql
		rm -rf /root/.my.cnf
		rm -rf /etc/mysql
		rm -rf /var/log/mysql
		;;
	"postgres")
		/etc/init.d/postgresql stop
		sync
		sleep 5
		sync
		apt-get -y purge postgresql postgresql-client  postgresql-9.1 postgresql-client-9.1 \
			postgresql-client-common postgresql-common postgresql-doc postgresql-doc-9.1
		userdel -f -r postgres
		rm -f /root/.pgpass
		rm -rf /etc/postgresql
		rm -rf /etc/postgresql-common
		rm -rf /var/log/postgresql
		;;
	esac
	apt-get -y autoremove
fi

echo ""
echo "Desinstalación completada"
echo ""

