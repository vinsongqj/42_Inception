FROM debian:bookworm

ARG DOMAIN_NAME

RUN apt-get update \
    && apt-get install -y --no-install-recommends nginx openssl \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /etc/nginx/ssl \
    && openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
	-keyout /etc/nginx/ssl/nginx.key \
	-out /etc/nginx/ssl/nginx.crt \
	-subj "/CN=${DOMAIN_NAME}" \
    && rm -f /etc/nginx/sites-enabled/default

COPY conf/default.conf /etc/nginx/conf.d/default.conf
RUN sed -i "s/DOMAIN_PLACEHOLDER/${DOMAIN_NAME}/" /etc/nginx/conf.d/default.conf

EXPOSE 443
CMD ["nginx", "-g", "daemon off;"]
