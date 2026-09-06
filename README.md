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





## Virtual Machines vs. Docker

Technical Nuance to convey:
Strictly speaking, the architectural comparison is between Virtual Machines and Containers. Docker is the ecosystem and container engine used to automate, build, and manage these Linux containers.


**Isolation:** VMs provide complete hardware-level isolation via a Hypervisor, where each VM runs its own dedicated Guest OS Kernel. In Contrast, containers share the Host OS Kernel and rely on Linux primitives (namespaces and cgroups), resulting in lighter process-level isolation

**Resource Consumption:** Containers are sigificantly more lightweight because they eliminate the overhead of running multiple guest kernels and full OS stacks. They share host resources directly, resulting in lower RAM usage, faster startup times, and minimal CPU overhead.

**Protability & Workflow:** Containers can be built, destroyed, and scaled in seconds using simple declarative files (Dockerfile, docker-compose.yml), making them far more portable and suitable for multi-service environments than heavy VM images.


## Secrets vs. Environment Variables

what is Roles of ENV ?
What is problem of ENV with sensitive data, and How the secret solve this problem ? 

**what is ENV:** in container run a programmes this programmes it need i varibles for work how can set this varibles into container? at this moment, it comes a ENV for solve this problem via inject this env from the image or cmd or docker-compose.

**What is problem of ENV with sensitive data:** but this way dont do not allow to inject a sensitive data because env can you wathes by multipel way if you inject env in images by dockerfile just write docker image history My-image can watch all ENV if you use docker-compose or cmd line the same thing can watch by cmd docker container inspect "CONTAINER ID" can you watch all env or run env cmd into container.

**How the secret solve this problem?**
in secrets method add the sensitive data in file and docker demon move this file into a folder in container if programme in container if this programme want use this data just take from file 
ب

**security:** Environment can inject into image by dockerfile this way is bad practice if you want pass the secrets as this way because any one has a image can watch all secrets by cmd "docker image history My_image" and can pass by cmd or docker-compose even this method can user of the container watch value of ENV and if there is any secrets, it poses a danger depending on the sensitivily of the secret. In contrast "Secrets Method" it save your sensitive data from access to any user 