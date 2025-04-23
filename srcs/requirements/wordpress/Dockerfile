FROM alpine:3.20.6

# php installation with all required packages
RUN apk update && apk add bash curl mariadb-client icu-data-full ghostscript \
	imagemagick openssl php82 php82-fpm php82-phar php82-json php82-mysqli \
	php82-curl php82-dom php82-exif php82-fileinfo php82-pecl-igbinary \
	php82-pecl-imagick php82-intl php82-mbstring php82-openssl php82-xml \
	php82-zip php82-iconv php82-shmop php82-shmop php82-simplexml php82-sodium \
	php82-xmlreader php82-zlib php82-tokenizer

# installation of WP-CLI for wordpress management
RUN cd /usr/local/bin && \
	curl -o wp -L https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
	chmod +x wp && ln -sf /usr/bin/php82 /usr/bin/php

# create directory for php logs
RUN mkdir -p /var/log && touch /var/log/php_errors.log && chmod 666 /var/log/php_errors.log

# copy configuration files
COPY conf/www.conf /etc/php82/php-fpm.d/www.conf
COPY conf/php.ini /etc/php82/php.ini

# copy entrypoint
COPY tools/wordpress-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh

# set working directory
WORKDIR /var/www/html

ENTRYPOINT [ "/usr/local/bin/wordpress-entrypoint.sh" ]
	
