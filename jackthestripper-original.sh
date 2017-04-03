# ============================================================================
#  La siguiente es una guía paso a paso que explica los procedimientos 
#  implementados por la herramienta JackTheStripper
#  Copyright 2013 Eugenia Bahit
#  Licencia: GPL v 3.0
#  Página del proyecto: http://www.eugeniabahit.com/proyectos/jackthestripper
# ============================================================================


# 1. Establecer un hostname
echo foo > /etc/hostname
hostname -F /etc/hostname
echo "127.0.0.1       localhost.localdomain    localhost" >> /etc/hosts
echo "123.456.78.90   foo.example.org          foo" >> /etc/hosts


# 2. Configuración de la zona horaria
dpkg-reconfigure tzdata


# 3. Actualizar Ubuntu Server 12.04 LTS
apt-get update
apt-get upgrade -y


# 4. Agregar nuevo usuario
adduser foo
usermod -a -G sudo foo


# 5. En ordenador local (NO en el server) crear llave RSA
ssh-keygen
scp .ssh/id_rsa.pub user@123.456.78.90:


# 6. (de nuevo en servidor) mover la llave RSA
mkdir /home/user/.ssh
mv /home/user/id_rsa.pub /home/user/.ssh/authorized_keys
chmod 700 /home/user/.ssh
chmod 600 /home/user/.ssh/authorized_keys
chown -R user:user /home/user/.ssh


# 7. Securizar SSH
# Reemplazar contenido de: /etc/ssh/sshd_config
# por: http://pastebin.com/YgEtwAZ5
service ssh restart


# 8. Establecer reglas para iptables
# Crear archivo: /etc/iptables.firewall.rules
# Colocar el contenido de: http://pastebin.com/VjEGKYxj
iptables-restore < /etc/iptables.firewall.rules


# 9. Automatizar reglas iptable tras reinicio
# Crear archivo: /etc/network/if-pre-up.d/firewall 
# con el siguiente contenido:
#!/bin/sh
/sbin/iptables-restore < /etc/iptables.firewall.rules
# luego ejecutar:
chmod +x /etc/network/if-pre-up.d/firewall


# 10. Instalar Sendmail (MTA)
apt-get install sendmail


# 11. Instalar, configurar y optimizar MySQL
apt-get install mysql-server
# Reemplazar el contenido de: /etc/mysql/my.cnf
# por: http://pastebin.com/rEvMkeHx
mysql_secure_installation
service mysql restart


# 12. Instalar PHP, Apache y otras dependencia
apt-get install php5 php5-cli php-pear php5-suhosin php5-mysql


# 12.1. Configurar, optimizar y securizar PHP
# Reemplazar el contenido de: /etc/php5/apache2/php.ini
# por: http://pastebin.com/7t6sdKxq


# 13. Instalar ModSecurity 
# (firewall p/ Web apps bajo para Apache)
apt-get install libxml2 libxml2-dev libxml2-utils
apt-get install libaprutil1 libaprutil1-dev
apt-get install libapache-mod-security


# 14. Instalar las reglas de seguridad del OWASP para ModSecurity
# (OWASP: Open Web Application Security Project - owasp.org)
# Basado en una idea original de Amir Sa
# http://www.root25.com/2012/11/how-to-install-modsecurity-on-apache-ubuntu12-stepbystep-tutorial.html
wget http://pkgs.fedoraproject.org/repo/pkgs/mod_security_crs/modsecurity-crs_2.2.5.tar.gz/aaeaa1124e8efc39eeb064fb47cfc0aa/modsecurity-crs_2.2.5.tar.gz
tar -xzf modsecurity-crs_2.2.5.tar.gz
cp -R modsecurity-crs_2.2.5/* /etc/modsecurity/
rm modsecurity-crs_2.2.5.tar.gz
rm -R modsecurity-crs_2.2.5
from_path="/etc/modsecurity/modsecurity_crs_10_setup.conf.example"
to_path="/etc/modsecurity/modsecurity_crs_10_setup.conf"
mv $from_path $to_path
for archivo in /etc/modsecurity/base_rules/*
    do ln -s $archivo /etc/modsecurity/activated_rules/
done
for archivo in /etc/modsecurity/optional_rules/*
    do ln -s $archivo /etc/modsecurity/activated_rules/
done
sed s/SecRuleEngine\ DetectionOnly/SecRuleEngine\ On/g /etc/modsecurity/modsecurity.conf-recommended > salida
mv salida /etc/modsecurity/modsecurity.conf
a2enmod headers
a2enmod mod-security
service apache2 restart


# 15. Configurar y optimizar Apache | Habilitar ModRewrite
# Reemplazar el contenido de: /etc/apache2/apache2.conf
# por: http://pastebin.com/tEt5A5Rp
a2enmod rewrite
service apache2 restart


# 16. Instalar y configurar ModEvasive
# (prevención de ataques DoS - módulo para Apache)
apt-get install libapache2-mod-evasive
mkdir /var/log/mod_evasive
chown www-data:www-data /var/log/mod_evasive/
# Reemplazar el contenido de: /etc/apache2/mods-available/mod-evasive.conf
# por: http://pastebin.com/XTUGRSwZ
a2enmod mod-evasive
service apache2 restart


# 17. Instalar y configurar Fail2Ban
apt-get install fail2ban
# Crear el archivo: /etc/fail2ban/jail.local
# con el contenido de: http://pastebin.com/qY2QHVMr
/etc/init.d/fail2ban restart

# 18. Instalar paquetes adicionales
apt-get install bzr tree python-mysqldb libapache2-mod-wsgi python-pip vim
pear config-set auto_discover 1
pear install pear.phpunit.de/PHPUnit


# 19. Agregar tarea de actualización diaria al cron
crontab -e
@daily apt-get update; apt-get upgrade -y


# 20. Tunear la terminal
# Reemplazar el contenido de /root/.bashrc por http://pastebin.com/2gqMv8Mw
# y de /home/tu-usuario/.bashrc por http://pastebin.com/MC3D6N3S


# 21. Tunear editor Nano
# Reemplazar el contenido de /root/.nanorc por http://pastebin.com/NVcChMKa
cp /root/.nanorc /home/tu-usuario/.nanorc


# 21. Tunear editor Vim
# Reemplazar el contenido de /root/.vimrc por http://pastebin.com/WcTrEG6J
cp /root/.vimrc /home/tu-usuario/.vimrc


# 22. Crear comando blockip para agregar reglas de bloqueo de IPs a iptables
# Crear el archivo: /sbin/blockip con el contenido de: http://pastebin.com/7DkEBJf8
chmod +x /sbin/blockip
# para usar el comando, cuando sea necesario ejecutar:
sudo blockip 123.456.78.90