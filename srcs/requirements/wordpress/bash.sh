#!/bin/sh

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

if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "Downloading WordPress Core..."
    wordpress core download --allow-root

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
        --title="Inception" \
        --admin_user="${ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASS}" \
        --admin_email="${ADMIN_EMAIL}" \
        --allow-root

    echo "Creating secondary user..."
    wordpress user create "${NEW_USER}" "${NEW_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_PASS_USER}" \
        --allow-root
else
    echo "WordPress is already installed and configured."
fi

chown -R www-data:www-data /var/www/html


exec /usr/sbin/php-fpm8.2 -F