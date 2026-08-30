FROM debian:bookworm-slim
RUN apt update && apt install -y nginx
RUN apt-get update && apt-get install -y openssl && \
    mkdir -p /etc/ssl/certs /etc/ssl/private && \
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/nginx-selfsigned.key \
    -out /etc/ssl/certs/nginx-selfsigned.crt \
    -subj "/C=MA/ST=Khouribga/L=Khouribga/O=1337/OU=IT/CN=mjaouchi.42.fr"
WORKDIR /var/www/html
COPY configue.conf /etc/nginx/nginx.conf
CMD ["nginx", "-g", "daemon off;"]