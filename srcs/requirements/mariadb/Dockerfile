# specify which image
FROM alpine:3.20.6

# update and install dependencies of MariaDB
RUN apk update && apk add mariadb mariadb-client bash

# copy config files
COPY conf/my.cnf /etc/mysql/my.cnf

# make sure the directory exists
RUN mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld

# copy script
COPY tools/mariadb-entrypoint.sh /usr/local/bin/

# run chmod to make the script executable
RUN chmod +x /usr/local/bin/mariadb-entrypoint.sh

# establish the script as the entrypoint
ENTRYPOINT [ "mariadb-entrypoint.sh" ]

CMD ["mysqld"]
