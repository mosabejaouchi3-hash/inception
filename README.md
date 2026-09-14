*This project has been created as part of the 42 curriculum by mjaouchi.*

## Description

**Project Goal:**
Build three interconnected services to serve WordPress pages over HTTPS.

**Components:**
The infrastructure consists of three core services: NGINX, PHP-FPM, and MariaDB.

NGINX acts as a reverse proxy. It receives requests from the client over HTTPS and forwards them to PHP-FPM using the FastCGI protocol. PHP-FPM processes the PHP files and sends the response back to NGINX, which then returns it to the client.

To handle dynamic content, PHP-FPM connects to MariaDB over TCP/IP. The communication consists of SQL queries used to retrieve, filter, or update persistent data.

---

## Instructions

### 1. Prerequisites

Make sure Docker Engine, Docker Compose, and GNU `make` are installed. Then map the local domain and create the required host directories:

```bash
echo "127.0.0.1 mjaouchi.42.fr" | sudo tee -a /etc/hosts
sudo mkdir -p /home/mjaouchi/data/wordpress /home/mjaouchi/data/mariadb
```

### 2. Build and Manage

Use the root `Makefile` to manage the infrastructure:

```bash
# Build images and start all services in detached mode
make

# Check container health and running state
docker compose -f srcs/docker-compose.yml ps

# Stop containers and tear down the network
make down

# Remove containers, images, networks, and persistent volume data
make fclean
```

### 3. Verification

- **HTTPS Access:** Open `https://mjaouchi.42.fr` to verify TLSv1.3 encryption is working.
- **Port Isolation:** Confirm that only port `443` is reachable from the host.
- **Persistence Test:** Run `make re` and verify that WordPress posts and database records survive a full restart.

---

## Resources

### Documentation

- [Docker Engine Installation](https://docs.docker.com/engine/install/)
- [Docker Getting Started](https://docs.docker.com/get-started/)
- [Docker Compose File Reference](https://docs.docker.com/reference/compose-file/)
- [Dockerfile Reference](https://docs.docker.com/reference/dockerfile/)
- [Docker Storage (Volumes & Bind Mounts)](https://docs.docker.com/engine/storage/)
- [Docker Networking](https://docs.docker.com/engine/network/)
- [Docker Secrets](https://docs.docker.com/compose/how-tos/use-secrets/)
- [NGINX FastCGI Module](https://nginx.org/en/docs/http/ngx_http_fastcgi_module.html)
- [MariaDB Installation Guide](https://mariadb.com/docs/server/mariadb-quickstart-guides/installing-mariadb-server-guide)
- [WordPress Installation Guide](https://developer.wordpress.org/advanced-administration/before-install/howto-install/)

### Articles

- [Docker Secrets Management – Semaphore](https://semaphore.io/blog/docker-secrets-management)
- [Docker Networking Types – Spacelift](https://spacelift.io/blog/docker-networking#docker-network-types)
- [Docker Volumes and Bind Mounts – DataCamp](https://www.datacamp.com/tutorial/docker-mount)

### AI Usage

AI was used during this project for:
- Understanding core concepts such as FastCGI, Docker networking, and secret management.
- Formatting and structuring technical comparisons in this documentation (VM vs Docker, Secrets vs ENV, etc.).

---

## Project Description

### The Use of Docker

Docker packages each service (NGINX, WordPress/PHP-FPM, and MariaDB) inside its own lightweight isolated unit called a **container**.

Unlike heavy Virtual Machines, containers share the host OS kernel but stay isolated from each other. Each container includes everything it needs to run, so the application behaves consistently across environments. Docker Compose lets you define, start, stop, and connect all services with a single command using a declarative configuration file.

### Sources Included in the Project

| Path | Role |
|------|------|
| `srcs/docker-compose.yml` | Defines all services, networks, volumes, environment variables, and Docker secrets |
| `srcs/requirements/nginx/` | NGINX Dockerfile, server config (`nginx.conf`), and TLS setup |
| `srcs/requirements/wordpress/` | WordPress/PHP-FPM Dockerfile and entrypoint script (WP-CLI install and config) |
| `srcs/requirements/mariadb/` | MariaDB Dockerfile, server config (`maria.cnf`), and database initialization script |
| `secrets/` | Sensitive credentials (passwords, admin credentials) mounted at runtime via Docker secrets |
| `Makefile` | Automates building, running, stopping, and cleaning the entire infrastructure |

### Main Design Choices

- **Custom Dockerfiles only:** Every image is built from Debian or Alpine from scratch. No pre-built application images from Docker Hub are used (as required by 42 rules).
- **Single Responsibility Principle:** One process per container. NGINX handles TLS termination and reverse proxying, PHP-FPM executes PHP, and MariaDB handles persistence.
- **Minimal port exposure:** Only port `443` (HTTPS) is bound to the host. MariaDB (3306) and PHP-FPM (9000) communicate exclusively over an isolated internal Docker bridge network using container DNS names.
- **Persistent bind mounts:** Explicit host directory mapping (`/home/mjaouchi/data/...`) guarantees that database and WordPress files survive container restarts and teardowns.
- **Runtime-only secrets:** Sensitive credentials are never written into environment variables or image layers. They are mounted as files at runtime and read by the entrypoint scripts.

---

### Virtual Machines vs. Docker

> The accurate comparison is between **Virtual Machines** and **Containers**. Docker is the toolchain used to build and manage containers.

| | Virtual Machines | Containers (Docker) |
|---|---|---|
| **Isolation** | Hardware-level via a Hypervisor; each VM runs its own full Guest OS kernel | Process-level via Linux namespaces and cgroups; containers share the Host OS kernel |
| **Resource usage** | High — each VM runs a complete OS stack | Low — no guest kernel overhead; startup in seconds |
| **Portability** | Heavy VM images, slow to distribute | Lightweight images, built and shared via `Dockerfile` and registries |
| **Use case** | Full OS isolation, legacy workloads | Microservices, CI/CD, multi-service environments |

---

### Secrets vs. Environment Variables

Environment variables pass configuration settings to containers without modifying source code. They can be injected via CLI flags, `Dockerfile` `ENV` instructions, or `docker-compose.yml`.

| | Environment Variables | Docker Secrets |
|---|---|---|
| **Security** | Exposed in plaintext in image layers (`docker history`), container metadata (`docker inspect`), and process listings (`/proc/1/environ`) | Stored outside the image; mounted into the container at runtime as a file under `/run/secrets/` |
| **Persistence in memory** | Remain in the container environment throughout its lifetime | In Docker Swarm, mounted via `tmpfs` (in-memory only). In Docker Compose, mounted as a bind mount to `/run/secrets/` — still outside image layers |
| **Suitable for** | Non-sensitive config (ports, feature flags, hostnames) | Passwords, API keys, TLS certificates |

---

### Docker Network vs. Host Network

| | Docker Network (Bridge) | Host Network |
|---|---|---|
| **Isolation** | Each container gets its own network namespace; ports do not conflict | Container shares the host network namespace directly; no port isolation |
| **Security** | Containers are not directly reachable from outside the bridge; only explicitly published ports are exposed | All container ports are exposed on the host interface |
| **DNS** | Built-in DNS resolution between containers by service name | No container DNS; services must use `localhost` or explicit IPs |
| **Performance** | Slight overhead from NAT and the virtual bridge | Near-native, no virtualization layer |
| **Use case** | Production: isolated multi-service architectures | Specific performance-critical scenarios where isolation is not needed |

---

### Docker Volumes vs. Bind Mounts

Containers are ephemeral by default — when a container is removed, all data written to its writable layer is lost. Docker provides two mechanisms for persistent storage:

| | Named Volumes | Bind Mounts |
|---|---|---|
| **Managed by** | Docker daemon (stored in `/var/lib/docker/volumes/`) | The user — an explicit host path is mapped into the container |
| **Host path control** | None — Docker chooses the location | Full control over the exact directory and permissions |
| **Use case** | Production databases, portability across environments | Development, config file injection, direct host access to files |
| **Example** | `docker run -v db_data:/var/lib/mysql mariadb` | `docker run -v /home/user/config:/etc/nginx/conf.d:ro nginx` |

> `ro` means **read-only** — the container can read the files but cannot modify them.