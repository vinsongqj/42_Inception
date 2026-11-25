#!/bin/sh
set -e

DB_PASS=$(cat /run/secrets/db_password)
ROOT_PASS=$(cat /run/secrets/db_root_password)

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

if [ ! -d /var/lib/mysql/mysql ]; then
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null

	mariadbd --user=mysql --bootstrap <<EOF

FLUSH PRIVILEGES;
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASS}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
fi

exec mariadbd --user=mysql
