*This project has been created as part of the 42 curriculum by akuchmam.*

# Inception

## Description

Inception is a system administration project from the 42 curriculum. It consists of setting up a small infrastructure composed of different services under specific rules using Docker Compose. The entire stack must be built from custom Dockerfiles, and the services must run in isolated containers.

The project deploys a WordPress website served by an NGINX reverse proxy with a MariaDB database backend. All services are containerized and communicate over a private Docker bridge network. Persistent data is stored using Docker volumes backed by bind mounts.

### Services Overview

- **NGINX**: The sole public entrypoint. Listens on port `443` with TLSv1.2/TLSv1.3 and forwards PHP requests to the WordPress container.
- **WordPress**: Runs PHP-FPM on port `9000`, serves the WordPress application files, and connects to the MariaDB database.
- **MariaDB**: Hosts the WordPress database on port `3306` internally.

## Project Description

### Virtual Machines vs Docker

- **Virtual Machines** emulate entire hardware stacks, including a full operating system, leading to high resource overhead and slower startup times.
- **Docker containers** share the host OS kernel, making them lightweight, fast to start, and more efficient in terms of CPU and memory usage. Containers provide process-level isolation without the overhead of hardware virtualization.

### Secrets vs Environment Variables

- **Environment variables** are injected directly into a container's runtime environment. They are visible in process listings and Docker inspect output, making them less secure for sensitive data.
- **Docker secrets** are mounted as files into the container filesystem (typically under `/run/secrets/`). They are only accessible to the processes inside the container and are not exposed in environment listings, providing a more secure mechanism for handling passwords and tokens.

### Docker Network vs Host Network

- **Docker bridge network** (default private network) isolates containers from the host network and from each other unless explicitly connected. It allows DNS resolution by container name and provides a secure, segmented environment.
- **Host network** mode removes network isolation and attaches the container directly to the host's network stack. While it offers better performance, it reduces security and can cause port conflicts.

### Docker Volumes vs Bind Mounts

- **Docker volumes** are managed by Docker and stored in a dedicated location on the host (`/var/lib/docker/volumes/`). They are portable, easier to back up, and abstract the host filesystem.
- **Bind mounts** map a specific host directory into the container. They offer direct access to host files but are less portable and can be affected by host filesystem permissions and structure.

In this project, persistent data is stored using **Docker volumes with bind mount driver options**, combining Docker's volume management with direct host path mapping.

## Architecture

```
┌─────────────────┐
│     Host        │
│   Port 443      │
└────────┬────────┘
         │
┌────────▼────────┐
│      NGINX      │
│   (TLS/443)     │
│  Custom Alpine  │
└────────┬────────┘
         │ FastCGI
┌────────▼────────┐
│    WordPress    │
│   (PHP-FPM)     │
│  Port 9000      │
└────────┬────────┘
         │ MySQL
┌────────▼────────┐
│     MariaDB     │
│   Port 3306     │
└─────────────────┘
```

All services share the `inception` bridge network. NGINX is the only service with published ports.

## Instructions

### Prerequisites

- Docker and Docker Compose installed
- GNU Make
- Linux environment (the project is designed for a Linux VM)

### Setup

1. Ensure the secret files exist in the `secrets/` directory:
   - `secrets/db_password.txt`
   - `secrets/db_root_password.txt`
   - `secrets/wp_admin_password.txt`
   - `secrets/wp_user_password.txt`

2. Review and configure `srcs/.env` with your settings.

3. Build and start the infrastructure:
   ```sh
   make
   ```

### Available Make Commands

| Command | Description |
|---------|-------------|
| `make` or `make up` | Build images and start containers in detached mode |
| `make down` | Stop and remove containers |
| `make build` | Build images without starting containers |
| `make clean` | Stop containers and remove named volumes |
| `make fclean` | Run `clean` and additionally prune all Docker objects and remove data directories |
| `make re` | Run `fclean` followed by `up` |

### Access

Once running, access the site at:
```text
https://<login>.42.fr
```

WordPress admin panel:
```text
https://<login>.42.fr/wp-admin
```

## Configuration

### Environment Variables

The following variables are defined in `srcs/.env` (do not commit this file with secrets):

| Variable | Description |
|----------|-------------|
| `DOMAIN_NAME` | The domain name serving the WordPress site |
| `MYSQL_DATABASE` | Name of the WordPress database |
| `MYSQL_USER` | Database user for WordPress |
| `WORDPRESS_TITLE` | Title of the WordPress site |
| `WORDPRESS_ADMIN_USER` | WordPress admin username |
| `WORDPRESS_ADMIN_EMAIL` | WordPress admin email |
| `WORDPRESS_USER` | Additional WordPress user username |
| `WORDPRESS_USER_EMAIL` | Additional WordPress user email |
| `DATA_PATH` | Host path for persistent data directories |

### Secrets

Sensitive values are stored as plain text files under `secrets/` and mounted via Docker secrets:

| Secret file | Used by | Purpose |
|-------------|---------|---------|
| `secrets/db_password.txt` | WordPress, MariaDB | Database user password |
| `secrets/db_root_password.txt` | MariaDB | Database root password |
| `secrets/wp_admin_password.txt` | WordPress | WordPress admin password |
| `secrets/wp_user_password.txt` | WordPress | Additional WordPress user password |

## Source Tree

```
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
├── secrets/
│   ├── .gitkeep
│   ├── db_password.txt
│   ├── db_root_password.txt
│   ├── wp_admin_password.txt
│   └── wp_user_password.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── mariadb-server.cnf
        │   └── tools/
        │       └── entrypoint.sh
        ├── nginx/
        │   ├── Dockerfile
        │   ├── conf/
        │   │   └── nginx.conf.template
        │   └── tools/
        │       └── entrypoint.sh
        └── wordpress/
            ├── Dockerfile
            └── tools/
                └── entrypoint.sh
```

## Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Secrets](https://docs.docker.com/engine/swarm/secrets/)
- [NGINX Documentation](https://nginx.org/en/docs/)
- [WordPress CLI Documentation](https://developer.wordpress.org/cli/commands/)
- [MariaDB Documentation](https://mariadb.com/kb/en/documentation/)
- [Alpine Linux Packages](https://pkgs.alpinelinux.org/packages)

---

**AI Usage Disclosure**

AI was used to help plan the documentation structure, extract requirements from the subject, and review whether the README covered mandatory topics. All technical content was reviewed and adapted manually.
