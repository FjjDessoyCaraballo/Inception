#!/bin/bash
set -e
cd /var/www/html

# check if WordPress is already installed
if [ ! -f wp-config.php ]; then
    echo "WordPress not found, installing..."
    
    # wait for MariaDB to be ready
    echo "Waiting for MariaDB to be ready..."
    until mariadb-admin ping --protocol=tcp --host=mariadb -u "$MYSQL_USER" --password="$MYSQL_PASSWORD" --wait 2>&1; do
        echo "MariaDB is not ready yet... waiting"
        sleep 2
    done
    echo "MariaDB is ready, proceeding with WordPress installation"

    # download WordPress core files
    wp core download --allow-root
    
    # create WordPress config file
    echo "Creating wp-config.php..."
    wp config create --allow-root \
        --dbhost=mariadb \
        --dbuser="$MYSQL_USER" \
        --dbpass="$MYSQL_PASSWORD" \
        --dbname="$MYSQL_DATABASE"
    
    # add additional configuration settings
    wp config set WP_REDIS_HOST redis --allow-root || true
    wp config set WP_REDIS_PORT 6379 --raw --allow-root || true
    wp config set WP_CACHE true --raw --allow-root || true
    wp config set FS_METHOD direct --allow-root
    
    # install WordPress
    echo "Installing WordPress..."
    wp core install --allow-root \
        --skip-email \
        --url="$DOMAIN_NAME" \
        --title="$WORDPRESS_TITLE" \
        --admin_user="$WORDPRESS_ADMIN_USER" \
        --admin_password="$WORDPRESS_ADMIN_PASSWORD" \
        --admin_email="$WORDPRESS_ADMIN_EMAIL"
    
    # create an additional user if specified
    if [ ! -z "$WORDPRESS_USER" ] && [ ! -z "$WORDPRESS_PASSWORD" ] && [ ! -z "$WORDPRESS_EMAIL" ]; then
        echo "Creating additional WordPress user..."
        wp user create "$WORDPRESS_USER" "$WORDPRESS_EMAIL" \
            --role=author \
            --user_pass="$WORDPRESS_PASSWORD" \
            --allow-root || echo "User already exists, skipping"
    fi
    
    # set proper permissions
    echo "Setting proper permissions..."
    chmod -R 775 /var/www/html/wp-content
    chown -R nobody:nobody /var/www/html
    
    echo "WordPress installation completed successfully!"
else
    echo "WordPress is already installed. Skipping installation."
fi


echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm82 -F
