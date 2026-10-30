FROM debian:bookworm

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
	php-fpm php-cli php-mysql php-curl php-gd php-mbstring \
	php-xml php-zip php-intl php-redis \
	mariadb-client curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL -o /usr/local/bin/wp \
	https://github.com/wp-cli/wp-cli/releases/download/v2.10.0/wp-cli-2.10.0.phar \
    && chmod +x /usr/local/bin/wp

COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/setup.sh"]
