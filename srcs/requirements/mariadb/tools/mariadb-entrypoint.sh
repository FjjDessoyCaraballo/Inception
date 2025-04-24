#!/bin/bash
set -e

if [ -z "$(ls -A /var/lib/mysql)" ]; then
	echo "Initializing MariaDB database..."
	mysql_install_db --datadir=/var/lib/mysql
	echo "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;" > /etc/mysql/init.sql
	echo "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';" >> /etc/mysql/init.sql
	echo "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%' WITH GRANT OPTION;" >> /etc/mysql/init.sql
	echo "FLUSH PRIVILEGES;" >> /etc/mysql/init.sql
else
	echo "MariaDB database directory already initialized, skipping initialization"
fi

exec "$@"
