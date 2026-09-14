# User Documentation

---

## 1. What Services Does This Stack Provide?

The infrastructure runs five isolated services inside a private Docker network. Only port `443` is reachable from outside.

| Service | Role | Access |
|---------|------|--------|
| **NGINX** | Reverse proxy and TLS termination. The only entry point from the internet. Listens on port `443` over TLSv1.3 and routes traffic to the other services. | External (port 443) |
| **WordPress** | The CMS application server. Runs PHP-FPM on internal port `9000`, processes page requests, and reads/writes data from MariaDB. | Internal only |
| **MariaDB** | Relational database engine. Stores all WordPress content, users, and settings. Listens on internal port `3306`. | Internal only |
| **Adminer** *(bonus)* | Lightweight web interface for browsing and managing the MariaDB database directly. Runs PHP-FPM on internal port `8080`, proxied through NGINX. | Via NGINX at `/adminer` |
| **Static Site** *(bonus)* | A standalone HTML/CSS/JS website served directly by NGINX. No CMS or database involved. | Via NGINX at `/static` |

---

## 2. Start and Stop the Project

Run all commands from the root of the repository.

```bash
# Build images and start all services in the background
make

# Stop running containers (data is preserved)
make down

# Stop containers and delete all data (full reset)
make fclean
```

To watch live logs while the stack is running:

```bash
docker compose -f srcs/docker-compose.yml logs -f
```

To rebuild and restart from scratch without losing data:

```bash
make re
```

---

## 3. Access the Website and Administration Panel

All services are accessible only over HTTPS using your configured domain.

> Make sure `127.0.0.1 mjaouchi.42.fr` is present in your `/etc/hosts` file before opening any URL.

| What | URL |
|------|-----|
| WordPress public site | `https://mjaouchi.42.fr` |
| WordPress admin panel | `https://mjaouchi.42.fr/wp-admin` |
| Adminer (database GUI) *(bonus)* | `https://mjaouchi.42.fr/adminer` |
| Static site *(bonus)* | `https://mjaouchi.42.fr/static` |

**WordPress Admin Login:**
Use the `ADMIN_USER` and the password stored in `secrets/admin_pass.txt`.

**Adminer Login:**
- Server: `mariadb`
- Username: value of `DB_USER` in `srcs/.env`
- Password: content of `secrets/db_password.txt`
- Database: value of `DB_NAME` in `srcs/.env`

---

## 4. Locate and Manage Credentials

All sensitive credentials are stored as plain text files inside the `secrets/` directory on the host. They are never written into image layers or environment variables.

```
secrets/
├── admin_pass.txt      # WordPress administrator password
├── wp_pass_user.txt    # WordPress standard user password
├── db_password.txt     # MariaDB password for the WordPress database user
└── db_root_pass.txt    # MariaDB root password
```

**Important rules:**
- The `secrets/` directory is excluded from version control via `.gitignore`. Never commit these files.
- Docker mounts each file into the container at runtime as a read-only file under `/run/secrets/`. The credentials are never baked into the image.
- To change a password, update the corresponding file and run `make re` to apply the change.

---

## 5. Check That the Services Are Running Correctly

### Quick status check

```bash
docker compose -f srcs/docker-compose.yml ps
```

All services (`nginx`, `wordpress`, `mariadb`) should show status `running` with no repeated restarts.

### Check individual container logs

```bash
# View logs for a specific service
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb
```

### Verify HTTPS is working

Open `https://mjaouchi.42.fr` in your browser. Click the padlock icon and confirm:
- Protocol: **TLSv1.3**
- Certificate is valid for `mjaouchi.42.fr`

### Verify port isolation

Only port `443` should be reachable from outside the Docker network:

```bash
# Should connect successfully
curl -k https://mjaouchi.42.fr

# Should be refused (not exposed to host)
curl http://mjaouchi.42.fr:3306
curl http://mjaouchi.42.fr:9000
```