FROM debian:12
RUN apt update && apt install -y mariadb-server mariadb-client
COPY --chmod=755 entrypoint.sh /entrypoint.sh
COPY maria.cnf /etc/mysql/mariadb.cnf
EXPOSE 3306
ENTRYPOINT ["/entrypoint.sh"]