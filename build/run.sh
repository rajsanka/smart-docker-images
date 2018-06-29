s does the job of mysql_secure_installation via queries that works
# better in a single-process Docker environment
#

secure_installation() {
    echo "Securing installation.."
    mysql -u root <<-EOF
    UPDATE mysql.user SET Password=PASSWORD('root') WHERE User='root';
    DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
    DELETE FROM mysql.user WHERE User='';
    DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%';
    GRANT ALL PRIVILEGES ON *.* TO 'smarttest' IDENTIFIED BY 'smarttest' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
    CREATE DATABASE IF NOT EXISTS smarttest CHARACTER SET utf8;
    SOURCE /usr/share/mysql/innodb_memcached_config.sql;
    USE mysql;
    SOURCE /etc/mysql/zoneinfo.sql;
    install plugin daemon_memcached soname "libmemcached.so";
EOF
}

echo "Setting up initial data"
mysql_install_db

echo "Starting mysql to setup privileges..."
/usr/sbin/mysqld &
MYSQL_TMP_PID=$!
echo "Sleeping for 5s"
sleep 5

# Try to connect as root without a password
mysql -u root <<-EOF
USE mysql;
EOF

if [ $? != 1 ]; then
    secure_installation
else
    echo "Error is OK, root password already set"
fi 

echo "Kill temporary mysql daemon"
kill -TERM $MYSQL_TMP_PID && wait

echo "Launching mysqld_safe"
/usr/bin/mysqld_safe --skip-syslog &

/home/checkdb.sh

#start up apache
apache2ctl start


#switch user to smartuser and run smart
cd /home/smartuser/smartinstall
su -c "./startSmart.sh SecureServer" smartuser

/home/checkserver.sh

/home/deploy.sh localhost 9081
/home/createtenant.sh localhost 9081

tail -f /home/smartuser/smartinstall/nohup.out

