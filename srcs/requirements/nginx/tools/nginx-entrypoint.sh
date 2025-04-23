#!/bin/sh
set -e

# remove default config file
rm -f /etc/nginx/http.d/default.conf

# generate certificates for HTTPS
if [ ! -f "/etc/nginx/ssl/cert.crt" ]; then
	echo "Generating SSL certificate for ${DOMAIN_NAME}..."
	openssl req -x509 -days 365 -newkey rsa:2048 -nodes \
		-out '/etc/nginx/ssl/cert.crt' \
		-keyout '/etc/nginx/ssl/cert.key' \
		-subj "/CN=${DOMAIN_NAME}" \
		>/dev/null 2>/dev/null
fi

# process the template to replace environment variables
echo "Configuring nginx for domain: ${DOMAIN_NAME}"
envsubst '${DOMAIN_NAME}' < /etc/nginx/conf.d/default.conf.template > /etc/nginx/conf.d/default.conf

echo "Configuration completed successfully"

# start nginx in the foreground
exec nginx -g 'daemon off;'
