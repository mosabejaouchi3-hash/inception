FROM debian:bullseye-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends nginx && \
    rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY static/ /var/www/static/

EXPOSE 4242

CMD ["nginx", "-g", "daemon off;"]