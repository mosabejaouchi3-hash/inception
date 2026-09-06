## Set up the environment from scratch (prerequisites, configuration files, secrets)

Follow these steps on a clean host system before starting the containers:

### 1. Host Configuration & Prerequisites
* Ensure `docker`, `docker compose`, and `make` are installed.
* Map your domain to localhost in `/etc/hosts`:
  ```bash
  echo "127.0.0.1 mjaouchi.42.fr" | sudo tee -a /etc/hosts
  ```

### 2. Environment Variables
Create the environment configuration file `srcs/.env` and define the required parameters:

```env
# Domain & Network Configuration
DOMAIN_NAME=mjaouchi.42.fr           # Your 42 login domain (e.g. login.42.fr)
DB_HOST=mariadb:3306                 # Service name and internal port of MariaDB

# Database Configuration
DB_NAME=wordpress_db                 # Name of the WordPress database to create
DB_USER=wp_user                      # Dedicated non-root database user

# WordPress Administrator Account (Cannot contain 'admin' or 'administrator')
ADMIN_USER=your_admin_username       # Admin username for WordPress
ADMIN_EMAIL=admin@example.com        # Valid email format for the admin account

# WordPress Standard User Account
NEW_USER=your_regular_username       # Standard author/editor user
NEW_USER_EMAIL=user@example.com      # Valid email format for the standard user
```

### 3. Secrets Provisioning
Credentials are decoupled from Git. Create the `secrets/` directory and populate each file with the corresponding raw plaintext password:

```bash
mkdir -p secrets
echo "strong_admin_pass" > secrets/admin_pass.txt       # Password for ADMIN_USER
echo "strong_user_pass"  > secrets/wp_pass_user.txt     # Password for NEW_USER
echo "strong_db_pass"    > secrets/db_password.txt      # Password for DB_USER
echo "strong_root_pass"  > secrets/db_root_pass.txt     # Password for MariaDB root user
```


## Build and launch the project using the Makefile and Docker Compose

Manage the infrastructure build and execution directly via the root `Makefile`:

```bash
# Build custom images and run containers in detached mode (background)
make

# Build and run containers in foreground mode (streams live logs to the terminal)
make build

# View running container status and health
docker compose -f srcs/docker-compose.yml ps

# Follow logs across all active services
docker compose -f srcs/docker-compose.yml logs -f
```


## Use relevant commands to manage the containers and volumes

Manage the running state, network routing, and persistent storage using either the `Makefile` or native Docker CLI commands:

### Container Lifecycle
```bash
# Stop and remove containers and networks (preserves volumes)
make down

# Restart the entire stack from scratch
make re

# Access an interactive shell inside a running container (e.g., WordPress)
docker exec -it wordpress sh
```

### Volume & Storage Management
```bash
# List all Docker volumes managed by the stack
docker volume ls

# Inspect host mount details and disk mapping for a specific volume
docker volume inspect v-wordpress
docker volume inspect v-mariadb

# Completely purge containers, images, internal networks, and host storage directories
make fclean
```


## Identify where the project data is stored and how it persists

Data persistence is decoupled from container lifecycles using Docker named volumes configured with host bind-mount points. This ensures database records and site files survive container re-creation and crashes.

### Host Storage Locations
All persistent data resides under the designated host directory `/home/mjaouchi/data/`:

* **WordPress Files:** `/home/mjaouchi/data/wordpress/`
  * Contains the WordPress core files, `wp-config.php`, active themes, installed plugins, and user uploads (`/var/www/html`).
* **MariaDB Database:** `/home/mjaouchi/data/mariadb/`
  * Contains the raw database storage engine files, tablespaces, schemas, and transaction logs (`/var/lib/mysql`).

### Persistence Mechanism
* **Named Volumes with Local Driver:** In `docker-compose.yml`, volumes are defined using the `local` driver options (`device: /home/mjaouchi/data/...`, `type: none`, `o: bind`).
* **Container Lifecycle Isolation:** Running `make down` terminates and deletes the container processes and internal networks without touching the underlying host filesystem.
* **Complete Purge:** Data is erased only when explicitly executing `make fclean`, which triggers `docker compose down -v` and recursively deletes the contents of the `/home/mjaouchi/data/` subdirectories.
