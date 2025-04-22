# version of alpine image used
FROM alpine:3.20.6

# update and install nginx, openssl, and bash
RUN apk update && apk add nginx openssl bash

# copy executable script
COPY tools/nginx-entrypoint.sh /usr/local/bin/

# change permissions of the script and create directory for ssl
RUN chmod +x /usr/local/bin/nginx-entrypoint.sh && \
	mkdir -p /etc/nginx/ssl

# set the entrypoint script for the container
ENTRYPOINT [ "nginx-entrypoint.sh" ]
