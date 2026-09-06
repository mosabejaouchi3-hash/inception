This project was created as part of the 42 curriculum by mjaouchi.

## Description

**Project Goal:**
Build three interconnected services to serve WordPress pages.

**Components:**
The infrastructure consists of three core services: NGINX, PHP-FPM, and MariaDB.

### Architectural Decisions & Comparisons

NGINX acts as a reverse proxy server; it receives requests from the client via HTTPS and forwards them to PHP-FPM via the FastCGI protocol. PHP-FPM processes the requested PHP files and responds to NGINX, which in turn returns the response to the client.

To handle dynamic content, PHP-FPM connects to MariaDB over TCP/IP (using an IP address and port). The communication consists of SQL queries used to retrieve, filter, or update persistent data.

## Instructions

## Instructions

### 1. Prerequisites
Ensure Docker Engine, Docker Compose, and GNU `make` are installed. Map the local domain in `/etc/hosts` and create the required host volume mount directories:

```bash
echo "127.0.0.1 mjaouchi.42.fr" | sudo tee -a /etc/hosts
sudo mkdir -p /home/mjaouchi/data/wordpress /home/mjaouchi/data/mariadb
```

### 2. Compilation & Lifecycle Management
Manage the infrastructure lifecycle directly using the root `Makefile`:

```bash
# Build custom images and start all services in detached mode
make

# Check container health and running states
docker compose -f srcs/docker-compose.yml ps

# Stop running containers and tear down the network
make down

# Purge containers, custom images, networks, and persistent volume data
make fclean
```

### 3. Verification
* **HTTPS Access:** Open `https://mjaouchi.42.fr` to verify TLSv1.2/TLSv1.3 encryption.
* **Port Isolation:** Ensure only port `443` is reachable on the host (ports `80`, `3306`, and `9000` must remain closed or internal).
* **Persistence Test:** Run `make down` followed by `make` to verify that WordPress posts and database records persist.


## Resources

https://docs.docker.com/engine/install/

https://docs.docker.com/get-started/

https://docs.docker.com/reference/compose-file/

https://docs.docker.com/reference/dockerfile/

https://docs.docker.com/engine/storage/

https://docs.docker.com/engine/network/

https://docs.docker.com/compose/how-tos/use-secrets/

https://semaphore.io/blog/docker-secrets-management

https://nginx.org/en/docs/http/ngx_http_fastcgi_module.html

https://mariadb.com/docs/server/mariadb-quickstart-guides/installing-mariadb-server-guide

https://developer.wordpress.org/advanced-administration/before-install/howto-install/

https://spacelift.io/blog/docker-networking#docker-network-types

https://www.datacamp.com/tutorial/docker-mount


## Virtual Machines vs. Docker

* Technical Nuance to convey:
Strictly speaking, the architectural comparison is between Virtual Machines and Containers. Docker is the ecosystem and container engine used to automate, build, and manage these Linux containers.


**Isolation:** VMs provide complete hardware-level isolation via a Hypervisor, where each VM runs its own dedicated Guest OS Kernel. In Contrast, containers share the Host OS Kernel and rely on Linux primitives (namespaces and cgroups), resulting in lighter process-level isolation

**Resource Consumption:** Containers are sigificantly more lightweight because they eliminate the overhead of running multiple guest kernels and full OS stacks. They share host resources directly, resulting in lower RAM usage, faster startup times, and minimal CPU overhead.

**Protability & Workflow:** Containers can be built, destroyed, and scaled in seconds using simple declarative files (Dockerfile, docker-compose.yml), making them far more portable and suitable for multi-service environments than heavy VM images.


## Secrets vs. Environment Variables

**ENV Definition & Role:** Environment variables provide a way to pass dynamic configuration settings to applications running inside a container without modifying their source code.
**Injection Methods:** They can be injected at runtime via Docker CLI flags, Dockerfile instructions (such as ENV), and configuration files like docker-compose.yml 

* **Environment Variables (Insecure for Credentials):**
  Environment variables are suitable for non-sensitive runtime configuration. However, passing credentials (such as database passwords) via environment variables is a major security risk: they remain exposed in plaintext inside image layers (`docker history`), container metadata (`docker inspect`), and process listings (`/proc/1/environ`).

* **Docker Secrets (Secure In-Memory Storage):**
  Sensitive data is stored in dedicated files outside the image build context. Docker Compose references these files, allowing the Docker daemon to mount them into the container at runtime into a target directory in-memory using `tmpfs`. This means that data is never baked into image layers, and if the container stops, the sensitive data is immediately cleared from memory.


## Docker Network vs Host Network

**Isolation & Ports:** In Host Network mode, the container shares the host's network namespace directly, which eliminates port isolation and can cause port conflicts. In contrast, a custom Docker Network provides strict isolation using Linux network namespaces, giving each container its own isolated port space.

**Performance & Security & DNS:** The Host Network offers near-native performance and lower latency by bypassing virtualization layers (like NAT and bridges). However, a Docker Network is significantly more secure (preventing direct exposure to the host's interfaces) and enables built-in DNS resolution between containers.)



## Docker Volumes vs Bind Mounts

Containers are ephemeral by default; when a container is stopped or removed, all runtime state and internal data written to its writable layer are permanently lost. To achieve data persistence, Docker provides two primary storage mechanisms:

* **Named Volumes (Docker-Managed Lifecycle):**
  Volumes are managed entirely by the Docker daemon and stored within a dedicated storage area on the host filesystem (typically `/var/lib/docker/volumes/`). They isolate container data from the host's core filesystem structure and are ideal for databases and production workloads:
  ```bash docker volume create db_data docker run -v db_data:/var/lib/mysql mariadb```

Bind Mounts (Granular Host Control):
Bind mounts map an explicit, user-defined file or directory from the host filesystem directly into the container. Unlike managed volumes, bind mounts offer granular control over the exact directory path, file permissions, and directory structure on the host, making them ideal for development environments and configuration file injection:

Bash
```docker run -v /home/user/app/config:/etc/nginx/conf.d:ro nginx```

ro = Read-Only
