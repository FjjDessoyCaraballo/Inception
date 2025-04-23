#!/bin/bash
set -e

# Ensure proper permissions for the mysql data directory
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    # Initialize the MySQL database
    mysql_install_db --datadir=/var/lib/mysql --skip-test-db --user=mysql --group=mysql \
        --auth-root-authentication-method=socket >/dev/null 2>/dev/null
    
    # Start MariaDB in background
    echo "Starting temporary MariaDB server..."
    mysqld_safe --datadir=/var/lib/mysql &
    
    # Wait for MariaDB to be ready
    echo "Waiting for MariaDB to be ready..."
    until mysqladmin ping -u root --silent; do
        sleep 1
    done
    
    echo "Setting up MariaDB database and users..."
    # Create database and users
    mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%';
FLUSH PRIVILEGES;
EOF
    
    # Shutdown MariaDB
    echo "Shutting down temporary MariaDB server..."
    mysqladmin -u root shutdown
    
    echo "MariaDB initialization completed."
fi

# Start MariaDB with the configuration file
echo "Starting MariaDB server..."
exec mysqld_safe --datadir=/var/lib/mysql
