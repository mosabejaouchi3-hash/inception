#!/bin/sh

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

number=0

while ! mariadb-admin ping --silent && [ "$number" -lt 4 ]; do
    sleep 1
    number=$((number + 1))
done

if [ "$number" -ge 4 ]; then
    echo "MariaDB failed to start in time." >&2
    exit 1
fi

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
exec mysqld --user=mysql --datadir=/var/lib/mysql