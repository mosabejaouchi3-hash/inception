FROM debian:12

RUN apt update && \
    apt install -y nginx &&\
    rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY static/ /var/www/static/

EXPOSE 4242

ENTRYPOINT ["nginx", "-g", "daemon off;"]