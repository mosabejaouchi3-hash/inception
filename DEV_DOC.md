# Developer Documentation

---

## 1. Set Up the Environment from Scratch

Follow these steps on a clean host system before starting the containers.

### Prerequisites

Make sure the following tools are installed:
- `docker`
- `docker compose`
- `make`

Map your domain to localhost:

```bash
echo "127.0.0.1 mjaouchi.42.fr" | sudo tee -a /etc/hosts
```

Create the host directories used for persistent storage:

```bash
sudo mkdir -p /home/mjaouchi/data/wordpress /home/mjaouchi/data/mariadb
```

---

### Environment Variables

Create the file `srcs/.env` and fill in the required values:

```env
# Domain & Network
DOMAIN_NAME=mjaouchi.42.fr       # Your 42 login domain (e.g. login.42.fr)
DB_HOST=mariadb:3306             # MariaDB service name and internal port

# Database
DB_NAME=name_database             # Name of the WordPress database
DB_USER=user_database                  # Dedicated non-root database user

# WordPress Admin Account (must not contain 'admin' or 'administrator')
ADMIN_USER=your_admin_username
ADMIN_EMAIL=admin@example.com

# WordPress Standard User
NEW_USER=your_regular_username
NEW_USER_EMAIL=user@example.com
```

---

### Secrets Provisioning

Credentials are kept outside Git. Create the `secrets/` directory and write each password into its own file:

```bash
mkdir -p secrets
echo "strong_admin_pass" > secrets/admin_pass.txt       # Password for ADMIN_USER
echo "strong_user_pass"  > secrets/wp_pass_user.txt     # Password for NEW_USER
echo "strong_db_pass"    > secrets/db_password.txt      # Password for DB_USER
echo "strong_root_pass"  > secrets/db_root_pass.txt     # Password for MariaDB root
```

> Each file must contain **raw plaintext only** — no quotes, no newlines beyond what `echo` adds.

---

## 2. Build and Launch the Project

### Using the Makefile (recommended)

```bash
# Build custom images and start all services in detached mode (background)
make

# Stop containers and remove networks (volumes are preserved)
make down

# Full rebuild from scratch
make re
```

### Using Docker Compose directly

```bash
# Build images and start in detached mode
docker compose -f srcs/docker-compose.yml up --build -d

# Build images and start in foreground mode (streams live logs)
docker compose -f srcs/docker-compose.yml up --build

# Check running container status and health
docker compose -f srcs/docker-compose.yml ps

# Follow logs from all services
docker compose -f srcs/docker-compose.yml logs -f
```

---

## 3. Manage Containers and Volumes

### Container Lifecycle

```bash
# Access an interactive shell inside a running container
docker exec -it wordpress sh
docker exec -it mariadb sh
docker exec -it nginx sh

# Stop and remove containers and networks (volumes untouched)
make down

# Full teardown: containers, images, networks, and all persistent data
make fclean
```

### Volume Inspection

```bash
# List all Docker volumes managed by the stack
docker volume ls

# Inspect host mount path and configuration for a specific volume
docker volume inspect v-wordpress
docker volume inspect v-mariadb
```

---

## 4. Data Storage and Persistence

Containers are ephemeral — all data written to a container's writable layer is lost when the container is removed. This project uses **named volumes with host bind-mount points** to decouple data from container lifecycles.

### Host Storage Locations

All persistent data lives under `/home/mjaouchi/data/`:

| Service | Host Path | Container Path | Contents |
|---------|-----------|----------------|----------|
| WordPress | `/home/mjaouchi/data/wordpress/` | `/var/www/html` | Core files, themes, plugins, uploads, `wp-config.php` |
| MariaDB | `/home/mjaouchi/data/mariadb/` | `/var/lib/mysql` | Database files, tablespaces, transaction logs |

### How Persistence Works

Volumes are defined in `docker-compose.yml` using the `local` driver with bind options:

```yaml
driver: local
driver_opts:
  type: none
  o: bind
  device: /home/mjaouchi/data/wordpress
```

This means the data lives on the **host filesystem**, not inside Docker's internal storage area. The container is just a process that reads and writes to that directory.

### Lifecycle Behavior

| Command | Containers | Networks | Volumes / Host Data |
|---------|-----------|----------|---------------------|
| `make down` | Removed | Removed | **Preserved** |
| `make re` | Rebuilt | Rebuilt | **Preserved** |
| `make fclean` | Removed | Removed | **Deleted** |

> `make fclean` runs `docker compose down -v` and recursively deletes the contents of `/home/mjaouchi/data/`. This is a **destructive operation** — all WordPress files and database records will be lost.