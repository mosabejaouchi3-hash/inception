#!/bin/sh
set -e

mkdir -p /run/mysqld
chmod 777 /run/mysqld


if [ -f "/run/secrets/db_password" ]; then
    DB_PASSWORD=$(cat /run/secrets/db_password)
else
    echo "Error: db_password secret not found!"
    exit 1
fi

if [ -f "/run/secrets/db_root_pass" ]; then
    DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_pass)
fi

if [ ! -d "/var/lib/mysql/${DB_NAME}" ]; then
    echo "Initializing MariaDB database and users..."

    mariadbd-safe --datadir=/var/lib/mysql &
    
    while ! mariadb-admin ping --silent; do
        sleep 1
    done

    mariadb -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF


    mariadb-admin -u root -p"${DB_ROOT_PASSWORD}" shutdown
    echo "Database initialization complete."
fi

echo "Starting MariaDB in foreground..."
exec mysqld --user=mysql --datadir=/var/lib/mysql --bind-address=0.0.0.0 --port="${MYSQL_PORT:-3306}"