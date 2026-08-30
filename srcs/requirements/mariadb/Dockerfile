FROM debian:bookworm-slim
RUN apt update && apt install -y mariadb-server mariadb-client
COPY --chmod=755 entrypoint.sh /entrypoint.sh
COPY ./maria.cnf /etc/mysql/mariadb.cnf
EXPOSE 3306
VOLUME /var/lib/mysql
ENTRYPOINT ["/entrypoint.sh"]