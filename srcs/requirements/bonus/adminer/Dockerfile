FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        php-cli \
        php-mysql \
        wget \
        ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/adminer && \
    wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php -O /var/www/adminer/index.php

WORKDIR /var/www/adminer

RUN chmod 755 /var/www/adminer/index.php

EXPOSE 8080

CMD ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/adminer"]