#!/bin/bash
#
# Instalador desatendido para Openstack sobre DEBIAN
# Reynaldo R. Martinez P.
# E-Mail: TigerLinux@Gmail.com
# Primera versión: Julio 18 del 2013
#
# Script principal
# Versión 1.5.3 "BlackCat Reloaded"
# 31 de Agosto del 2013
#

PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin

case $1 in
"install")

	if [ -f ./configs/main-config.rc ]
	then
		source ./configs/main-config.rc
		mkdir -p /etc/openstack-control-script-config
		date > /etc/openstack-control-script-config/install-init-date-and-time
	else
		echo "No puedo acceder a mi archivo de configuración"
		echo "Revise que esté ejecutando el instalador en su directorio"
		echo "Abortando !!!!."
		echo ""
		exit 0
	fi

	clear

	echo ""
	echo "INSTALADOR DE OPENSTACK PARA DEBIAN 7"
	echo "Realizado por Reynaldo R. Martinez P."
	echo "E-Mail: TigerLinux@Gmail.com"
	echo "Versión 1.5.3 \"BlackCat Reloaded\" - Agosto 31, 2013"
	echo ""
	echo "Se verificaran los prerequisitos"
	echo "Si alguno de los prerequisitos falla, se informará y se detendrá el proceso"
	echo ""
	echo "Prerequisitos:"
	echo "- OS: Debian 7 de 64 bits"
	echo "- El usuario que ejecuta este script debe ser root"
	echo "- El servidor debe tener el repositorio siguiente instalado:"
	echo "  * http://archive.gplhost.com/debian/pool/grizzly/main/"
	echo "- Las siguientes ramas de los repositorios oficiales de debian 7 deben estar habilitadas"
	echo "  * main contrib non-free (repo principal)"
	echo "  * main contrib non-free (repo de updates)"
	echo "- Todos los repositorios deben estar disponibles para instalar los paquetes via apt"
	echo "- El servidor debe tener todas las actualizaciones al día"
	echo "- OpenVSWITCH debe estar instalado y configurado con los bridges que se van a utilizar"
	echo "- Si desea instalar swift, los filesystems para el módulo swift deben estar montados en el"
	echo "  directorio /srv/node"
	echo ""
	echo "NOTA: Si quiere almacenar un log de todo lo que hace este instalador, use el comando tee."
	echo "Ejemplo: ./main-installer.sh install | tee -a /var/log/my_log_de_install.log"
	echo ""

	case $2 in
	auto|AUTO)
		echo "Modo automático activado"
		;;
	*)
		echo -n "Desea continuar ? [y/n]:"
		read -n 1 answer
		echo ""
		case $answer in
		y|Y)
			echo ""
			echo "Empezando Verificaciones Iniciales"
			echo ""
			;;
		*)
			echo ""
			echo "Abortando a petición del usuario/admin !!!"
			echo ""
			exit 0
			;;
		esac
		;;
	esac


	echo ""
	echo "Ejecutando validaciones iniciales e instalando requerimientos"
	echo ""

	./modules/requeriments.sh
	
	if [ -f /etc/openstack-control-script-config/libvirt-installed ]
	then
		echo ""
		echo "Requerimientos instalados"
		echo "Validaciones iniciales completadas"
		echo "Continuando con los módulos de la instalación"
		echo ""
	else
		echo ""
		echo "Falló la instalación de los requerimientos"
		echo "o fallaron las validaciones"
		echo "Abortando el resto de la instalación !!"
		echo ""
		exit 0
	fi


	echo "Listo"
	echo "Continuando con los módulos de la instalación"
	echo ""

	rm -rf /tmp/keystone-signing-*
	rm -rf /tmp/cd_gen_*

	if [ $messagebrokerinstall == "yes" ]
	then
		echo ""
		echo "Instalando message broker"
		./modules/messagebrokerinstall.sh
		
		if [ -f /etc/openstack-control-script-config/broker-installed ]
		then
			echo ""
			echo "Listo"
			echo ""
		else
			echo ""
			echo "Falló la instalación del message broker"
			echo "Abortando el resto de la instalación"
			echo ""
			exit 0
		fi
	fi

	echo ""
	echo "Ejecutando módulo de soporte de base de datos"
	echo ""

	./modules/databaseinstall.sh

	if [ -f /etc/openstack-control-script-config/db-installed ]
	then
		echo ""
		echo "Módulo de soporte de bases de datos ejecutado con éxito"
		echo ""
	else
		echo ""
		echo "Falló el módulo de soporte de bases de datos"
		echo "Abortando el resto de la instalación"
		echo ""
		exit 0
	fi

	echo ""
	echo "Instalando requisitos extras"
	echo ""
	
	./modules/requeriments-extras.sh

	if [ -f /etc/openstack-control-script-config/requeriments-extras-installed ]
	then
		echo ""
		echo "Módulo de requisitos extras ejecutado con éxito"
		echo ""
	else
		echo ""
		echo "Falló el módulo de requisitos extras"
		echo "Abortando el resto de la instalación"
		echo ""
		exit 0
	fi


	if [ $keystoneinstall == "yes" ]
	then
		echo ""
		echo "Instalando Keystone"

		./modules/keystoneinstall.sh

		if [ -f /etc/openstack-control-script-config/keystone-installed ]
		then
			echo "Keystone exitosamente instalado"
		else
			echo ""
			echo "Falló el módulo de instalación de keystone"
			echo "Abortando el resto de la instalación"
			echo ""
			exit 0
		fi

	else
		SERVICE_ENDPOINT="http://$keystonehost:35357/v2.0"
		OS_USERNAME=$keystoneadminuser
		OS_TENANT_NAME=$keystoneadminuser
		OS_PASSWORD=$keystoneadminpass
		OS_AUTH_URL="http://$keystonehost:35357/v2.0/"

		echo "# export SERVICE_ENDPOINT=$SERVICE_ENDPOINT" > $keystone_admin_rc_file
		echo "# export SERVICE_TOKEN=$SERVICE_TOKEN" >> $keystone_admin_rc_file
		echo "# export OS_SERVICE_TOKEN=$SERVICE_TOKEN" >> $keystone_admin_rc_file
		echo "export OS_USERNAME=$OS_USERNAME" >> $keystone_admin_rc_file
		echo "export OS_PASSWORD=$OS_PASSWORD" >> $keystone_admin_rc_file
		echo "export OS_TENANT_NAME=$OS_TENANT_NAME" >> $keystone_admin_rc_file
		echo "export OS_AUTH_URL=$OS_AUTH_URL" >> $keystone_admin_rc_file
		echo "PS1='[\u@\h \W(keystone_admin)]\$ '" >> $keystone_admin_rc_file

		mkdir -p /etc/openstack-control-script-config
		date > /etc/openstack-control-script-config/keystone-installed
		date > /etc/openstack-control-script-config/keystone-extra-idents
	fi

	if [ $swiftinstall == "yes" ]
	then
		echo ""
		echo "Instalando Swift"

		./modules/swiftinstall.sh

		if [ -f /etc/openstack-control-script-config/swift-installed ]
		then
			echo "Swift exitosamente instalado"
		else
			echo ""
			echo "Falló el módulo de instalación de swift"
			echo "Abortando el resto de la instalación"
			echo ""
			exit 0
		fi
	fi

	if [ $glanceinstall == "yes" ]
	then
		echo ""
		echo "Instalando Glance"

		./modules/glanceinstall.sh

		if [ -f /etc/openstack-control-script-config/glance-installed ]
		then
			echo "Glance exitosamente instalado"
		else
			echo ""
			echo "Falló el módulo de instalación de glance"
			echo "Abortando el resto de la instalación"
			echo ""
			exit 0
		fi
	fi

	if [ $cinderinstall == "yes" ]
	then
		echo ""
		echo "Instalando Cinder"

		./modules/cinderinstall.sh

		if [ -f /etc/openstack-control-script-config/cinder-installed ]
		then
			echo "Cinder exitosamente instalado"
		else
			echo ""
			echo "Falló el módulo de instalación de cinder"
			echo "Abortando el resto de la instalación"
			echo ""
			exit 0
		fi
	fi

	if [ $quantuminstall == "yes" ]
	then
		echo ""
		echo "Instalando Quantum"

		./modules/quantuminstall.sh

		if [ -f /etc/openstack-control-script-config/quantum-installed ]
		then
			echo "Quantum exitosamente instalado"
		else
			echo ""
			echo "Falló el módulo de instalación de quantum"
			echo "Abortando el resto de la instalación"
			echo ""
			exit 0
		fi
	fi

	if [ $novainstall == "yes" ]
	then
		echo ""
		echo "Instalando Nova"

		./modules/novainstall.sh

		if [ -f /etc/openstack-control-script-config/nova-installed ]
		then
			echo "Nova exitosamente instalado"
		else
			echo ""
			echo "Falló el módulo de instalación de nova"
			echo "Abortando el resto de la instalación"
			echo ""
			exit 0
		fi
	fi

	if [ $ceilometerinstall == "yes" ]
	then
		echo ""
		echo "Instalando Ceilometer"

		./modules/ceilometerinstall.sh

		if [ -f /etc/openstack-control-script-config/ceilometer-installed ]
		then
			echo "Ceilometer exitosamente instalado"
		else
			echo ""
			echo "Falló el módulo de instalación de nova"
			echo "Abortando el resto de la instalación"
			echo ""
			exit 0
		fi
	fi

	if [ $snmpinstall == "yes" ]
	then
		echo ""
		echo "Instalando infraestructura de monitoreo"

		./modules/snmpinstall.sh

		if [ -f /etc/openstack-control-script-config/snmp-installed ]
		then
			echo "Soporte SNMP exitosamente instalado"
		else
			echo ""
			echo "Falló la instalación del soporte SNMP, pero esto"
			echo "no es crítico - continuando con la instalación"
			echo ""
		fi
	fi

	if [ $horizoninstall == "yes" ]
	then
		echo ""
		echo "Instalando Dashboard Horizon"

		./modules/horizoninstall.sh

		if [ -f /etc/openstack-control-script-config/horizon-installed ]
		then
			echo "Horizon exitosamente instalado"
		else
			echo ""
			echo "Falló el módulo de instalación de horizon"
			echo "Abortando el resto de la instalación"
			echo ""
			exit 0
		fi

	fi

	echo ""
	echo "Ejecutando Post Install"
	./modules/postinstall.sh

	date > /etc/openstack-control-script-config/install-end-date-and-time

	echo ""
	echo "Instalación de OpenStack Finalizada exitosamente"
	echo ""
	

	;;
"uninstall")

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

	echo ""
	echo "Se desinstalarán todos los Servicios de OpenStack"
	echo ""
	case $2 in
	auto|AUTO)
		echo "Modo automático activado"
		;;
	*)
		echo -n "Esta seguro que desea continuar ? [y/n]:"
		read -n 1 answer
		case $answer in
		y|Y)
			echo ""
			echo "Desinstalando Servicios de OpenStack"
			echo ""
			;;
		*)
			echo ""
			echo "Se abortará la desinstalación a petición del usuario/admin"
			echo ""
			exit 0
			;;
		esac
	esac
	./modules/uninstall.sh
	;;
*)
	echo ""
	echo "Uso: $0 install | uninstall [auto]"
	echo ""
	;;
esac

