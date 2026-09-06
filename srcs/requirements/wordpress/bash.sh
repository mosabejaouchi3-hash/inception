#!/bin/sh
set -e

WP_DIR="/var/www/html"
cd "$WP_DIR"
rm -rf "$WP_DIR"/*
mv /var/tmp/* "$WP_DIR"


if [ -f "/run/secrets/db_password" ]; then
    DB_PASSWORD=$(cat /run/secrets/db_password)
else
    echo "Error: db_password secret not found!"
    exit 1
fi

if [ -f "/run/secrets/wp_pass_user" ]; then
    WP_PASS_USER=$(cat /run/secrets/wp_pass_user)
else
    echo "Error: wp_pass_user secret not found!"
    exit 1
fi

if [ -f "/run/secrets/wp_admin_pass" ]; then
    WP_ADMIN_PASS=$(cat /run/secrets/wp_admin_pass)
else
    echo "Error: wp_admin_pass secret not found!"
    exit 1
fi

if ! wordpress core is-installed --allow-root 2>/dev/null; then

    echo "Configuring WordPress..."
    wordpress config create \
        --dbname="${DB_NAME}" \
        --dbuser="${DB_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="${DB_HOST}" \
        --allow-root

    echo "Installing WordPress Core..."
    wordpress core install \
        --url="https://${DOMAIN_NAME}" \
        --title="My Inception Site" \
        --admin_user="${ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASS}" \
        --admin_email="${ADMIN_EMAIL}" \
        --allow-root

    wordpress user create "${NEW_USER}" "${NEW_USER_EMAIL}" \
    --role=author \
    --user_pass="${WP_PASS_USER}" \
    --allow-root
fi

mkdir -p /run/php
chown -R www-data:www-data "$WP_DIR" /run/php

find /etc/php -name "www.conf" -exec sed -i 's|^listen = .*|listen = 0.0.0.0:9000|' {} +

PHP_FPM_BIN=$(command -v php-fpm || ls /usr/sbin/php-fpm* 2>/dev/null | head -n 1)

if [ -z "$PHP_FPM_BIN" ]; then
    echo "Error: PHP-FPM binary not found!"
    exit 1
fi

echo "WordPress FastCGI is running with ($PHP_FPM_BIN)..."

exec "$PHP_FPM_BIN" -F