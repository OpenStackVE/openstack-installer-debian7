#!/bin/bash
#
# Instalador desatendido para Openstack sobre DEBIAN
# Reynaldo R. Martinez P.
# E-Mail: TigerLinux@Gmail.com
# Agosto del 2013
#
# Script de instalacion y preparacion de base de datos
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

if [ $dbpopulate == "no" ]
then
	echo "No se poblarán las bases de datos"
	echo "Saliendo del módulo de instalación/preparación de Bases de Datos"
	date > /etc/openstack-control-script-config/db-installed
	exit 0
fi

if [ -f /etc/openstack-control-script-config/db-installed ]
then
	echo ""
	echo "Soporte de Base de Datos previamente instalado"
	echo "Saliendo del módulo"
	echo ""
	exit 0
fi

if [ $dbinstall == "yes" ]
then
	echo "Se instalará el software de base de datos"
	case $dbflavor in
	"mysql")
		echo "Preparando DB Mysql local"
		rm -f /root/.my.cnf

		echo "mysql-server-5.5 mysql-server/root_password_again password $mysqldbpassword" > /tmp/mysql-seed.txt
		echo "mysql-server-5.5 mysql-server/root_password password $mysqldbpassword" >> /tmp/mysql-seed.txt
		debconf-set-selections /tmp/mysql-seed.txt
		aptitude -y install mysql-server-5.5 mysql-client-5.5
		sed -r -i 's/127\.0\.0\.1/0\.0\.0\.0/' /etc/mysql/my.cnf
		service mysql restart
		chkconfig mysql on
		sleep 5
		echo "[client]" > /root/.my.cnf
		echo "user=$mysqldbadm" >> /root/.my.cnf
		echo "password=$mysqldbpassword" >> /root/.my.cnf
		echo "GRANT ALL PRIVILEGES ON *.* TO '$mysqldbadm'@'%' IDENTIFIED BY '$mysqldbpassword' WITH GRANT OPTION;"|mysql
		echo "FLUSH PRIVILEGES;"|mysql
		iptables -A INPUT -p tcp -m multiport --dports $mysqldbport -j ACCEPT
		/etc/init.d/iptables-persistent save
		rm -f /tmp/mysql-seed.txt
		echo "Base de datos MySQL lista"
		;;
	"postgres")
		echo "Prepadando DB Postgres local"
		rm -f /root/.pgpass
		apt-get -y install postgresql postgresql-client
		/etc/init.d/postgresql restart
		chkconfig postgresql on
		sleep 5
		su - $psqldbadm -c "echo \"ALTER ROLE $psqldbadm WITH PASSWORD '$psqldbpassword';\"|psql"
		sleep 5
		sync
		echo "listen_addresses = '*'" >> /etc/postgresql/9.1/main/postgresql.conf
		echo "port = 5432" >> /etc/postgresql/9.1/main/postgresql.conf
		echo -e "host\tall\tall\t0.0.0.0 0.0.0.0\tmd5" >> /etc/postgresql/9.1/main/pg_hba.conf
		/etc/init.d/postgresql restart
		sleep 5
		sync
		echo "*:*:*:$psqldbadm:$psqldbpassword" > /root/.pgpass
		chmod 0600 /root/.pgpass
		iptables -A INPUT -p tcp -m multiport --dports $psqldbport -j ACCEPT
		/etc/init.d/iptables-persistent save
		echo "Base de datos Postgres lista"
		;;
	esac
fi

if [ $dbinstall == "yes" ]
then
	case $dbflavor in
	"mysql")
		testmysql=`dpkg -l mysql-server-5.5 2>/dev/null|tail -n 1|grep -ci ^ii`
		if [ $testmysql == "0" ]
		then
			echo ""
			echo "Falló la instalación de mysql-server - abortando el resto de la instalación"
			echo ""
			exit 0
		else
			date > /etc/openstack-control-script-config/db-installed
		fi
		;;
	"postgres")
		testpgsql=`dpkg -l postgresql 2>/dev/null|tail -n 1|grep -ci ^ii`
		if [ $testpgsql == "0" ]
		then
			echo ""
			echo "Falló la instalación de postgresql-server - abortando el resto de la instalación"
			echo ""
			exit 0
		else
			date > /etc/openstack-control-script-config/db-installed
		fi
		;;
	esac
fi

mysqlcommand="mysql --port=$mysqldbport --password=$mysqldbpassword --user=$mysqldbadm --host=$dbbackendhost"
psqlcommand="psql -U $psqldbadm --host $dbbackendhost -p $psqldbport"

if [ $dbcreate == "yes" ]
then
	echo "Creando bases de datos"
	case $dbflavor in
	"mysql")
		echo "[client]" > /root/.my.cnf
		echo "user=$mysqldbadm" >> /root/.my.cnf
		echo "password=$mysqldbpassword" >> /root/.my.cnf
		echo "Creando database de keystone"
		echo "CREATE DATABASE $keystonedbname;"|$mysqlcommand
		echo "GRANT ALL ON $keystonedbname.* TO '$keystonedbuser'@'%' IDENTIFIED BY '$keystonedbpass';"|$mysqlcommand
		echo "GRANT ALL ON $keystonedbname.* TO '$keystonedbuser'@'localhost' IDENTIFIED BY '$keystonedbpass';"|$mysqlcommand
		echo "GRANT ALL ON $keystonedbname.* TO '$keystonedbuser'@'$keystonehost' IDENTIFIED BY '$keystonedbpass';"|$mysqlcommand
		for extrahost in $extrakeystonehosts
		do
			echo "GRANT ALL ON $keystonedbname.* TO '$keystonedbuser'@'$extrahost' IDENTIFIED BY '$keystonedbpass';"|$mysqlcommand
		done
		echo "FLUSH PRIVILEGES;"|$mysqlcommand
		sync
		sleep 5
		sync

		echo "Creando database de glance"
		echo "CREATE DATABASE $glancedbname;"|$mysqlcommand
		echo "GRANT ALL ON $glancedbname.* TO '$glancedbuser'@'%' IDENTIFIED BY '$glancedbpass';"|$mysqlcommand
		echo "GRANT ALL ON $glancedbname.* TO '$glancedbuser'@'localhost' IDENTIFIED BY '$glancedbpass';"|$mysqlcommand
		echo "GRANT ALL ON $glancedbname.* TO '$glancedbuser'@'$glancehost' IDENTIFIED BY '$glancedbpass';"|$mysqlcommand
		for extrahost in $extraglancehosts
		do
			echo "GRANT ALL ON $glancedbname.* TO '$glancedbuser'@'$extrahost' IDENTIFIED BY '$glancedbpass';"|$mysqlcommand
		done
		echo "FLUSH PRIVILEGES;"|$mysqlcommand
		sync
		sleep 5
		sync

		echo "Creando database de cinder"
		echo "CREATE DATABASE $cinderdbname;"|$mysqlcommand
		echo "GRANT ALL ON $cinderdbname.* TO '$cinderdbuser'@'%' IDENTIFIED BY '$cinderdbpass';"|$mysqlcommand
		echo "GRANT ALL ON $cinderdbname.* TO '$cinderdbuser'@'localhost' IDENTIFIED BY '$cinderdbpass';"|$mysqlcommand
		echo "GRANT ALL ON $cinderdbname.* TO '$cinderdbuser'@'$cinderhost' IDENTIFIED BY '$cinderdbpass';"|$mysqlcommand
		for extrahost in $extracinderhosts
		do
			echo "GRANT ALL ON $cinderdbname.* TO '$cinderdbuser'@'$extrahost' IDENTIFIED BY '$cinderdbpass';"|$mysqlcommand
		done
		echo "FLUSH PRIVILEGES;"|$mysqlcommand
		sync
		sleep 5
		sync

		echo "Creando database de quantum"
		echo "CREATE DATABASE $quantumdbname;"|$mysqlcommand
		echo "GRANT ALL ON $quantumdbname.* TO '$quantumdbuser'@'%' IDENTIFIED BY '$quantumdbpass';"|$mysqlcommand
		echo "GRANT ALL ON $quantumdbname.* TO '$quantumdbuser'@'localhost' IDENTIFIED BY '$quantumdbpass';"|$mysqlcommand
		echo "GRANT ALL ON $quantumdbname.* TO '$quantumdbuser'@'$quantumhost' IDENTIFIED BY '$quantumdbpass';"|$mysqlcommand
		for extrahost in $extraquantumhosts
		do
			echo "GRANT ALL ON $quantumdbname.* TO '$quantumdbuser'@'$extrahost' IDENTIFIED BY '$quantumdbpass';"|$mysqlcommand
		done
		echo "FLUSH PRIVILEGES;"|$mysqlcommand
		sync
		sleep 5
		sync

		echo "Creando database de nova"
		echo "CREATE DATABASE $novadbname;"|$mysqlcommand
		echo "GRANT ALL ON $novadbname.* TO '$novadbuser'@'%' IDENTIFIED BY '$novadbpass';"|$mysqlcommand
		echo "GRANT ALL ON $novadbname.* TO '$novadbuser'@'localhost' IDENTIFIED BY '$novadbpass';"|$mysqlcommand
		echo "GRANT ALL ON $novadbname.* TO '$novadbuser'@'$novahost' IDENTIFIED BY '$novadbpass';"|$mysqlcommand
		for extrahost in $extranovahosts
		do
			echo "GRANT ALL ON $novadbname.* TO '$novadbuser'@'$extrahost' IDENTIFIED BY '$novadbpass';"|$mysqlcommand
		done
		echo "FLUSH PRIVILEGES;"|$mysqlcommand
		sync
		sleep 5
		sync

		echo "Creando database de horizon"
		echo "CREATE DATABASE $horizondbname;"|$mysqlcommand
		echo "GRANT ALL ON $horizondbname.* TO '$horizondbuser'@'%' IDENTIFIED BY '$horizondbpass';"|$mysqlcommand
		echo "GRANT ALL ON $horizondbname.* TO '$horizondbuser'@'localhost' IDENTIFIED BY '$horizondbpass';"|$mysqlcommand
		echo "GRANT ALL ON $horizondbname.* TO '$horizondbuser'@'$horizonhost' IDENTIFIED BY '$horizondbpass';"|$mysqlcommand
		for extrahost in $extrahorizonhosts
		do
			echo "GRANT ALL ON $horizondbname.* TO '$horizondbuser'@'$extrahost' IDENTIFIED BY '$horizondbpass';"|$mysqlcommand
		done
		echo "FLUSH PRIVILEGES;"|$mysqlcommand
		sync
		sleep 5
		sync

		echo ""
		echo "Lista de databases instaladas:"
		echo "show databases;"|$mysqlcommand

		checkdbcreation=`echo "show databases;"|$mysqlcommand|grep -ci $horizondbname`
		if [ $checkdbcreation == "0" ]
		then
			echo ""
			echo "Falla en la creación de las bases de datos - abortando !!"
			echo ""
			rm -f /etc/openstack-control-script-config/db-installed
			exit 0
		else
			date > /etc/openstack-control-script-config/db-installed
		fi

		echo ""

		;;
	"postgres")
		echo "*:*:*:$psqldbadm:$psqldbpassword" > /root/.pgpass
		chmod 0600 /root/.pgpass
		echo "Creando database de keystone"
		echo "CREATE user $keystonedbuser;"|$psqlcommand
		echo "ALTER user $keystonedbuser with password '$keystonedbpass'"|$psqlcommand
		echo "CREATE DATABASE $keystonedbname"|$psqlcommand
		echo "GRANT ALL PRIVILEGES ON database $keystonedbname TO $keystonedbuser;"|$psqlcommand
		sync
		sleep 5
		sync

		echo "Creando database de glance"
		echo "CREATE user $glancedbuser;"|$psqlcommand
		echo "ALTER user $glancedbuser with password '$glancedbpass'"|$psqlcommand
		echo "CREATE DATABASE $glancedbname"|$psqlcommand
		echo "GRANT ALL PRIVILEGES ON database $glancedbname TO $glancedbuser;"|$psqlcommand
		sync
		sleep 5
		sync

		echo "Creando database de cinder"
		echo "CREATE user $cinderdbuser;"|$psqlcommand
		echo "ALTER user $cinderdbuser with password '$cinderdbpass'"|$psqlcommand
		echo "CREATE DATABASE $cinderdbname"|$psqlcommand
		echo "GRANT ALL PRIVILEGES ON database $cinderdbname TO $cinderdbuser;"|$psqlcommand
		sync
		sleep 5
		sync

		echo "Creando database de quantum"
		echo "CREATE user $quantumdbuser;"|$psqlcommand
		echo "ALTER user $quantumdbuser with password '$quantumdbpass'"|$psqlcommand
		echo "CREATE DATABASE $quantumdbname"|$psqlcommand
		echo "GRANT ALL PRIVILEGES ON database $quantumdbname TO $quantumdbuser;"|$psqlcommand
		sync
		sleep 5
		sync

		echo "Creando database de nova" 
		echo "CREATE user $novadbuser;"|$psqlcommand
		echo "ALTER user $novadbuser with password '$novadbpass'"|$psqlcommand
		echo "CREATE DATABASE $novadbname"|$psqlcommand
		echo "GRANT ALL PRIVILEGES ON database $novadbname TO $novadbuser;"|$psqlcommand
		sync
		sleep 5
		sync

		echo "Creando database de horizon" 
		echo "CREATE user $horizondbuser;"|$psqlcommand
		echo "ALTER user $horizondbuser with password '$horizondbpass'"|$psqlcommand
		echo "CREATE DATABASE $horizondbname"|$psqlcommand
		echo "GRANT ALL PRIVILEGES ON database $horizondbname TO $horizondbuser;"|$psqlcommand
		sync
		sleep 5
		sync

		echo ""
		echo "Lista de databases instaladas:"
		echo "\list"|$psqlcommand

		checkdbcreation=`echo "\list"|$psqlcommand|grep -ci $horizondbname`
		if [ $checkdbcreation == "0" ]
		then
			echo ""
			echo "Falla en la creación de las bases de datos - abortando !!"
			echo ""
			rm -f /etc/openstack-control-script-config/db-installed
			exit 0
		else
			date > /etc/openstack-control-script-config/db-installed
		fi

		echo ""
		;;
	esac
fi

echo ""
echo "Preparación de bases de datos Listo"
echo ""
