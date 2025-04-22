#!/bin/bash

set -e

# Create necessary directories
mkdir -p /etc/nginx/ssl
mkdir -p /etc/nginx/conf.d

# Remove default config if it exists
rm -f /etc/nginx/conf.d/default.conf
rm -f /etc/nginx/http.d/default.conf

# Generate certificate for HTTPS
openssl req -x509 -days 365 -newkey rsa:2048 -nodes \
    -out '/etc/nginx/ssl/cert.crt' \
    -keyout '/etc/nginx/ssl/cert.key' \
    -subj "/CN=$DOMAIN_NAME" \
    >/dev/null 2>/dev/null

# Create a main nginx.conf
cat << EOF > /etc/nginx/nginx.conf
user nginx;
worker_processes auto;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    # SSL Settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_prefer_server_ciphers on;
    
    # Logging Settings
    access_log /var/log/nginx/access.log;
    error_log /var/log/nginx/error.log;
    
    # Virtual Host Configs
    include /etc/nginx/conf.d/*.conf;
}
EOF

# Configure nginx to serve static wordpress files
cat << EOF > /etc/nginx/conf.d/default.conf
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name $DOMAIN_NAME;

    ssl_certificate /etc/nginx/ssl/cert.crt;
    ssl_certificate_key /etc/nginx/ssl/cert.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;

    root /var/www/html;
    index index.php index.html index.htm;

    location / {
        try_files \$uri \$uri/ /index.php?\$args;
    }

    location ~ [^/]\.php(/|\$) {
        try_files \$fastcgi_script_name =404;

        fastcgi_pass wordpress:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param PATH_INFO \$fastcgi_path_info;
        fastcgi_split_path_info ^(.+\.php)(/.*)\$;
        include fastcgi_params;
    }
}
EOF

# Redirect HTTP to HTTPS
cat << EOF > /etc/nginx/conf.d/redirect.conf
server {
    listen 80;
    listen [::]:80;
    server_name _;
    return 301 https://\$host\$request_uri;
}
EOF

echo "Configuration completed successfully"

# Start nginx in the foreground
exec nginx -g 'daemon off;'
