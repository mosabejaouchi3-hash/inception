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
