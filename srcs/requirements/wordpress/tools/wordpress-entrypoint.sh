#!/bin/bash
set -e 
cd /var/www/html

# check if wordpress is already installed
if [ ! -f wp-config.php ]; then
	echo "WordPress not found, installing..."

	# wait for mariadb to be ready with better error handling
	echo "Waiting for MariaDB to be ready..."
	max_tries=30
	tries=0
	while [ $tries -lt $max_tries ]; do
		if mariadb -h mariadb -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1;" >/dev/null 2>&1; then
			echo "Successfully connected to MariaDB!"
			break
		fi
		tries=$((tries + 1))
		echo "MariaDB is not ready yet... waiting (attempt $tries/$max_tries)"
		sleep 3
	done
	
	if [ $tries -eq $max_tries ]; then
		echo "Could not connect to MariaDB after $max_tries attempts. Check your MariaDB configuration."
		echo "Attempting to connect with more debug information:"
		mariadb -h mariadb -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" -e "SELECT 1;" || true
		exit 1
	fi

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

echo "Starting PHP-FPM"
exec /usr/sbin/php-fpm82 -F
