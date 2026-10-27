#!/bin/sh
set -e

DB_PASS=$(cat /run/secrets/db_password)
ROOT_PASS=$(cat /run/secrets/db_root_password)
SOCK=/run/mysqld/mysqld.sock

mkdir -p /run/mysqld
chown mysql:mysql /run/mysqld

if [ ! -d /var/lib/mysql/mysql ]; then
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null

	mariadbd --user=mysql --skip-networking --socket=$SOCK & pid=$!

	for i in $(seq 1 30); do
		mariadb-admin --socket=$SOCK ping --silent 2>/dev/null && break
		sleep 1
	done

	mariadb --socket=$SOCK <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASS}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

	mariadb-admin --socket=$SOCK -uroot -p"${ROOT_PASS}" shutdown
	wait $pid
fi

exec mariadbd --user=mysql
