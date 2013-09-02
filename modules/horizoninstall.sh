#!/bin/bash
#
# Instalador desatendido para Openstack sobre DEBIAN
# Reynaldo R. Martinez P.
# E-Mail: TigerLinux@Gmail.com
# Agosto del 2013
#
# Script de instalacion y preparacion de Horizon
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

if [ -f /etc/openstack-control-script-config/horizon-installed ]
then
	echo ""
	echo "Este módulo ya fue ejecutado de manera exitosa - saliendo"
	echo ""
	exit 0
fi

echo ""
echo "Instalando paquetes para Horizon"

aptitude -y install apache2

a2dismod ssl
service apache2 restart

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


echo "openstack-dashboard-apache horizon/activate_vhost boolean false" > /tmp/dashboard-seed.txt
echo "openstack-dashboard-apache horizon/use_ssl boolean false" >> /tmp/dashboard-seed.txt

debconf-set-selections /tmp/dashboard-seed.txt

aptitude -y install memcached openstack-dashboard openstack-dashboard-apache

echo ""
echo "Listo"
echo ""

source $keystone_admin_rc_file

rm -f /tmp/dashboard-seed.txt
rm -f /tmp/nova-seed.txt
rm -f /tmp/quantum-seed.txt
rm -f /tmp/cinder-seed.txt
rm -f /tmp/glance-seed.txt
rm -f /tmp/keystone-seed.txt

echo "Configurando el Dashboard"

mkdir -p /etc/openstack-dashboard
cat ./libs/local_settings.py > /etc/openstack-dashboard/local_settings.py
chmod 644 /etc/openstack-dashboard/local_settings.py


mkdir /var/log/horizon
chown -R www-data.www-data /var/log/horizon

sed -r -i "s/CUSTOM_DASHBOARD_dashboard_timezone/$dashboard_timezone/" /etc/openstack-dashboard/local_settings.py
sed -r -i "s/CUSTOM_DASHBOARD_memcached_spec/$memcached_spec/" /etc/openstack-dashboard/local_settings.py
sed -r -i "s/CUSTOM_DASHBOARD_keystonehost/$keystonehost/" /etc/openstack-dashboard/local_settings.py
sed -r -i "s/CUSTOM_DASHBOARD_SERVICE_TOKEN/$SERVICE_TOKEN/" /etc/openstack-dashboard/local_settings.py
sed -r -i "s/CUSTOM_DASHBOARD_keystonememberrole/$keystonememberrole/" /etc/openstack-dashboard/local_settings.py

sync
sleep 5
sync
echo "" >> /etc/openstack-dashboard/local_settings.py
echo "SITE_BRANDING = '$brandingname'" >> /etc/openstack-dashboard/local_settings.py
echo "" >> /etc/openstack-dashboard/local_settings.py

if [ $horizondbusage == "yes" ]
then
	case $dbflavor in
	"postgres")
		echo "SESSION_ENGINE = 'django.contrib.sessions.backends.cached_db'" >> /etc/openstack-dashboard/local_settings.py
		echo "DATABASES = {" >> /etc/openstack-dashboard/local_settings.py
		echo "               'default': {" >> /etc/openstack-dashboard/local_settings.py
		echo "               'ENGINE': 'django.db.backends.postgresql_psycopg2'," >> /etc/openstack-dashboard/local_settings.py
		echo "               'NAME': '$horizondbname'," >> /etc/openstack-dashboard/local_settings.py
		echo "               'USER': '$horizondbuser'," >> /etc/openstack-dashboard/local_settings.py
		echo "               'PASSWORD': '$horizondbpass'," >> /etc/openstack-dashboard/local_settings.py
		echo "               'HOST': '$dbbackendhost'," >> /etc/openstack-dashboard/local_settings.py
		echo "               'default-character-set': 'utf8'" >> /etc/openstack-dashboard/local_settings.py
		echo "            }" >> /etc/openstack-dashboard/local_settings.py
		echo "}" >> /etc/openstack-dashboard/local_settings.py
		;;
	"mysql")
		echo "SESSION_ENGINE = 'django.contrib.sessions.backends.cached_db'" >> /etc/openstack-dashboard/local_settings.py
		echo "DATABASES = {" >> /etc/openstack-dashboard/local_settings.py
		echo "               'default': {" >> /etc/openstack-dashboard/local_settings.py
		echo "               'ENGINE': 'django.db.backends.mysql'," >> /etc/openstack-dashboard/local_settings.py
		echo "               'NAME': '$horizondbname'," >> /etc/openstack-dashboard/local_settings.py
		echo "               'USER': '$horizondbuser'," >> /etc/openstack-dashboard/local_settings.py
		echo "               'PASSWORD': '$horizondbpass'," >> /etc/openstack-dashboard/local_settings.py
		echo "               'HOST': '$dbbackendhost'," >> /etc/openstack-dashboard/local_settings.py
		echo "               'default-character-set': 'utf8'" >> /etc/openstack-dashboard/local_settings.py
		echo "            }" >> /etc/openstack-dashboard/local_settings.py
		echo "}" >> /etc/openstack-dashboard/local_settings.py
		;;
	esac

	echo "yes"|/usr/share/openstack-dashboard/manage.py syncdb
	echo "yes"|/usr/share/openstack-dashboard/manage.py syncdb
	mkdir -p /var/lib/dash/.blackhole
	echo "yes"|/usr/share/openstack-dashboard/manage.py syncdb
else
	echo "CACHES = {" >> /etc/openstack-dashboard/local_settings.py
	echo "    'default': {" >> /etc/openstack-dashboard/local_settings.py
	echo "        'BACKEND' : 'django.core.cache.backends.locmem.LocMemCache'" >> /etc/openstack-dashboard/local_settings.py
	echo "    }" >> /etc/openstack-dashboard/local_settings.py
	echo "}" >> /etc/openstack-dashboard/local_settings.py
fi

echo "Listo"

echo ""

echo "Listo"
echo ""
echo "Aplicando reglas de IPTABLES"
echo ""

iptables -A INPUT -p tcp -m multiport --dports 80,443 -j ACCEPT
/etc/init.d/iptables-persistent save

echo "Listo"
echo ""
echo "Levantando Servicios"

a2dissite openstack-dashboard-ssl.conf
a2dissite openstack-dashboard-ssl-redirect.conf
a2dissite default
a2dissite default-ssl
a2ensite openstack-dashboard.conf

a2enmod wsgi

/etc/init.d/memcached restart
chkconfig memcached on

/etc/init.d/apache2 restart
chkconfig apache2 on

testhorizon=`dpkg -l openstack-dashboard-apache 2>/dev/null|tail -n 1|grep -ci ^ii`
if [ $testhorizon == "0" ]
then
	echo ""
	echo "Falló la instalación de horizon - abortando el resto de la instalación"
	echo ""
	exit 0
else
	date > /etc/openstack-control-script-config/horizon-installed
	date > /etc/openstack-control-script-config/horizon
fi

echo "Listo"
echo ""
echo "Dashboard instalado - puede entrar al puerto 80 de cualquiera"
echo "de las interfaces de este equipo para poder iniciar el dashboard"
echo "Use la cuenta administrativa principal del Keystone"
echo "Cuenta: $keystoneadminuser"
echo ""



