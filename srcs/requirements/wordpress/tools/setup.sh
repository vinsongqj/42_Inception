#!/bin/sh
set -e

DB_PASS=$(cat /run/secrets/db_password)
WP_ADMIN_PASS=$(sed -n 1p /run/secrets/credentials)
WP_USER_PASS=$(sed -n 2p /run/secrets/credentials)
WP_PATH=/var/www/html

mkdir -p /run/php "$WP_PATH"
cd "$WP_PATH"

for i in $(seq 1 30); do
	mariadb -h mariadb -u"$MYSQL_USER" -p"$DB_PASS" -e "SELECT 1" >/dev/null	2>&1 && break
	[ "$i" = 30 ] && { echo "MariaDB unreachable"; exit 1; }
	sleep 2
done

if [ ! -f wp-load.php ]; then
	wp core download --allow-root
fi

if [ ! -f wp-config.php ]; then
	wp config create --allow-root \
		--dbname="$MYSQL_DATABASE" --dbuser="$MYSQL_USER" \
		--dbpass="$DB_PASS" --dbhost=mariadb
fi

if ! wp core is-installed --allow-root; then
	wp core install --allow-root \
		--url="https://${DOMAIN_NAME}" --title="$WP_TITLE" \
		--admin_user="$WP_ADMIN_USER" --admin_password="$WP_ADMIN_PASS" \
		--admin_email="$WP_ADMIN_EMAIL" --skip-email
fi

if ! wp user get "$WP_USER" --allow-root >/dev/null 2>&1; then
	wp user create "$WP_USER" "$WP_USER_EMAIL" --role=author \
		--user_pass="$WP_USER_PASS" --allow-root
fi

wp config set WP_REDIS_HOST redis --allow-root
wp config set WP_REDIS_PORT 6379 --raw --allow-root
wp config set WP_REDIS_TIMEOUT 1 --raw --allow-root
wp config set WP_REDIS_READ_TIMEOUT 1 --raw --allow-root
if ! wp plugin is-installed redis-cache --allow-root; then
	wp plugin install redis-cache --activate --allow-root
fi
wp redis status --allow-root | grep -q "Status: Connected" \
    || wp redis enable --allow-root

chown -R www-data:www-data "$WP_PATH"

exec php-fpm8.2 -F -O
