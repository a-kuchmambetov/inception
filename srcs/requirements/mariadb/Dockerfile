FROM alpine:3.22.4

RUN apk update && apk add --no-cache mariadb mariadb-client \
    && mkdir -p /run/mysqld /var/lib/mysql \
    && chown -R mysql:mysql /run/mysqld /var/lib/mysql

COPY conf/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf
COPY tools/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3306

VOLUME ["/var/lib/mysql"]

ENTRYPOINT ["entrypoint.sh"]
CMD ["mariadbd", "--user=mysql", "--console"]
