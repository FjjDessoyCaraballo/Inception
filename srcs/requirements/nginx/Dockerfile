# version of alpine image used
FROM alpine:3.20.6

# update and install nginx, openssl, gettext, and bash
RUN apk update && apk add nginx openssl bash gettext

# create directories
RUN mkdir -p /etc/nginx/ssl /etc/nginx/conf.d

# copy configuration files and entrypoint
COPY ./conf/nginx.conf /etc/nginx/nginx.conf
COPY ./conf/redirect.conf /etc/nginx/conf.d/redirect.conf
COPY ./conf/default.conf.template /etc/nginx/conf.d/default.conf.template
COPY ./tools/nginx-entrypoint.sh /usr/local/bin/

# change permissions of the script and create directory for ssl
RUN chmod +x /usr/local/bin/nginx-entrypoint.sh && mkdir -p /etc/nginx/ssl

# set the entrypoint script for the container
ENTRYPOINT [ "/usr/local/bin/nginx-entrypoint.sh" ]
