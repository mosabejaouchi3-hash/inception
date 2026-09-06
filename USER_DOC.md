## Understand What Services Are Provided by the Stack

The infrastructure runs dedicated, isolated services within a custom Docker bridge network, strictly following the single-responsibility principle:

* **NGINX (Reverse Proxy & TLS Termination):**
  The sole external entry point to the infrastructure. It listens on port `443` over TLSv1.3, terminates SSL, routes traffic, serves the static website, and proxies dynamic PHP requests to WordPress or Adminer via FastCGI.

* **WordPress (Application Server):**
  Runs PHP-FPM on internal port `9000`. It executes the CMS logic, processes PHP scripts, and queries MariaDB over the internal network.

* **MariaDB (Database Engine):**
  Relational database listening on internal port `3306`. It handles structured data storage for WordPress with no exposure to the host.

* **Adminer (Database Management Tool - Bonus):**
  A lightweight, single-file database management interface running via PHP-FPM. listening on internal port `8080`. It allows direct web-based administration of the MariaDB database without exposing raw database ports.

* **Static Site (Bonus):**
  A standalone, non-CMS static website (HTML/CSS/JS) served directly via NGINX under a dedicated route. listening on internal port `4242`.

## Start and Stop the Project

Run the following commands from the repository root:

```bash
# Start in detached mode (background)
make

# Start in foreground (shows real-time logs)
make build

# Stop running containers
make down

# Stop and purge containers, images, and persistent volumes
make fclean
```

## Access the Website and the Administration Panel

All services are accessible exclusively over HTTPS via your configured domain:

* **WordPress Public Site:** Navigate to `https://mjaouchi.42.fr`.
* **WordPress Admin Panel:** Navigate to `https://mjaouchi.42.fr/wp-login.php` (or `/wp-admin`) and log in with your administrator credentials.
* **Adminer (Database GUI):** Access `https://mjaouchi.42.fr/adminer` (or your configured port/route) and log in using the credentials from `secrets/db_password.txt` or `secrets/db_root_pass.txt`.
* **Static Site:** Access `https://mjaouchi.42.fr/static` (or your configured subpath) to view the static presentation.

## Locate and Manage Credentials

Sensitive credentials and runtime secrets are decoupled from the code and configuration files, adhering to the principle of least privilege:

* **File Location:** All plaintext secrets are stored on the host system inside the local `secrets/` directory:
  * `admin_pass.txt`: WordPress administrator account password.
  * `wp_pass_user.txt`: WordPress standard user account password.
  * `db_password.txt`: Password for the dedicated WordPress MariaDB user.
  * `db_root_pass.txt`: Administrative password for the MariaDB root user.

* **Security & Storage:** The `secrets/` directory is strictly excluded from version control via `.gitignore`. Docker mounts these files at container runtime as secure secrets (in-memory `tmpfs`), ensuring credentials never leak into persistent image layers or environment variables (`ENV`).

* **Modifying Credentials:** To change a credential, update the content of the corresponding text file inside `secrets/` before running `make` or re-initializing the stack with `make re`.

## Check That the Services Are Running Correctly

Verify the state and health of running containers:

```bash
docker ps
```

All three services (`nginx`, `wordpress`, `mariadb`) should display a `Up` status without constant restarts.