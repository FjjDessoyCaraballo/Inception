#!/bin/bash
set -e

# on the first container run, configure the server to be reachable by other containers
if [ ! -e /etc/.firstrun ]; then
	cat << EOF >> /etc/my.cnf.d/mariadb-server.cnf
[mysqld]
bind-address=0.0.0.0
skip-networking=0
EOF
	touch /etc/.firstrun
fi

# on 
if [ ! -e /var/lib/mysql/.firstmount ]; then
	# mysql installation
	mysql_install_db --datadir=/var/lib/mysql --skip-test-db --user=mysql --group=mysql \
		--auth-root-authentication-method=socket >dev/null 2>/dev/null
	# shove it to the background
	mysqld_safe &
	mysqld_pid=$!

	# wait for the server to be started, then set up database and accounts
	mysqladmin ping -u root --silent --wait >/dev/null 2>/dev/null
	cat << EOF | mysql --protocol=socket -u root -p=
CREATE DATABASE $MYSQL_DATABASE
CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%';
GRANT ALL PRIVILEGES ON *.* to 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD';
FLUSH PRIVILEGES;
EOF

	# shut down the temporary server and mark the volume as initialized
	mysqladmin shutdown
	touch /var/lib/mysql/.firstmount
fi

exec mysqld_safe
