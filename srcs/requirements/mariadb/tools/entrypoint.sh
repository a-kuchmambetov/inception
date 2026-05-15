#!/bin/sh
set -e

MYSQL_PASSWORD="$(cat /run/secrets/db_password)"
MYSQL_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"

mkdir -p /run/mysqld /var/lib/mysql
chown -R mysql:mysql /run/mysqld /var/lib/mysql

if [ ! -d "/var/lib/mysql/mysql" ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql

    mariadbd --user=mysql --skip-networking &
    pid="$!"

    until mariadb-admin ping --silent; do
        sleep 1
    done

    mariadb -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    mariadb-admin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait "$pid"
fi

exec "$@"
