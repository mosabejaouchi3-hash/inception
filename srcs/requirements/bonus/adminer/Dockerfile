FROM debian:12

RUN apt update && \
    apt install -y \
        php-cli \
        php-mysql \
        wget && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/adminer && \
    wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php -O /var/www/adminer/index.php

WORKDIR /var/www/adminer

RUN chmod 755 /var/www/adminer/index.php

EXPOSE 8080

ENTRYPOINT ["php", "-S", "0.0.0.0:8080", "-t", "/var/www/adminer"]