#!/bin/bash

mysql_install_db

echo "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE;" > /etc/mysql/init.sql
echo "CREATE USER IF NOT EXISTS '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD';" >> /etc/mysql/init.sql
echo "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO '$MYQSL_USER'@'%' WITH GRANT OPTION;" >> /etc/mysql/init.sql
echo "FLUSH PRIVILEGES;" >> /etc/mysql/init.sql

exec "$@"
