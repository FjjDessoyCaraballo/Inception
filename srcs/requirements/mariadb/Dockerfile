# specify which image
FROM alpine:3.20.6

# update and install dependencies of MariaDB
RUN apk update && apk add mariadb mariadb-client bash

# copy executable script
COPY tools/mariadb-entrypoint.sh /usr/local/bin/

# run chmod to make the script executable
RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh

# establish the script as the entrypoint
ENTRYPOINT [ "mariadb-entrypoint.sh" ]

