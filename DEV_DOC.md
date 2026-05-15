# Inception - Developer Documentation

This document is intended for developers who want to understand, modify, or debug the Inception infrastructure.

## Prerequisites

- Docker Engine
- Docker Compose
- GNU Make
- Linux environment (tested on Alpine Linux / Debian-based VMs)

## Project Structure

- `Makefile`: Build automation and common commands.
- `srcs/docker-compose.yml`: Service orchestration definition.
- `srcs/.env`: Environment variables for configuration.
- `srcs/requirements/*/`: Custom Docker images for each service.
- `secrets/`: Plain text files containing sensitive credentials, mounted as Docker secrets.

## Configuration

### Environment Variables

Edit `srcs/.env` to configure the stack. Key variables include:

- `DOMAIN_NAME`: Must match your 42 login (e.g., `<login>.42.fr`).
- `DATA_PATH`: Host directory for persistent volumes. The subject expects `/home/<login>/data`.
- `MYSQL_DATABASE`, `MYSQL_USER`: Database configuration.
- `WORDPRESS_*`: WordPress site and user settings.

### Secrets

Create the following files under `secrets/` before building:

- `secrets/db_password.txt`
- `secrets/db_root_password.txt`
- `secrets/wp_admin_password.txt`
- `secrets/wp_user_password.txt`

**Important:** Do not commit secrets to version control. The `.gitignore` is configured to help prevent this.

## Building and Running

Build images:
```sh
make build
```

Start the full stack:
```sh
make up
```

## Cleaning Up

Stop and remove containers and volumes:
```sh
make clean
```

Full reset (prunes Docker system and deletes data directories):
```sh
make fclean
```

## Service Details

### NGINX

- **Base image**: `alpine:3.22.4`
- **Public port**: `443` (TLS only)
- **Upstream**: Forwards PHP requests to `wordpress:9000`
- **TLS**: Self-signed certificate generated at runtime via OpenSSL
- **Configuration**: `nginx.conf.template` processed with `envsubst`

### WordPress

- **Base image**: `alpine:3.22.4`
- **Runtime**: `php-fpm83` listening on `0.0.0.0:9000`
- **Installation**: Uses `wp-cli` to install WordPress and create users on first run
- **Dependencies**: Waits for MariaDB healthcheck before starting installation
- **Secrets**: Reads database and user passwords from `/run/secrets/`

### MariaDB

- **Base image**: `alpine:3.22.4`
- **Port**: `3306` (internal only)
- **Initialization**: `entrypoint.sh` installs the database and creates the user on first run
- **Healthcheck**: `mariadb-admin ping` to signal readiness to WordPress
- **Configuration**: Custom `mariadb-server.cnf`

## Networking

All services are attached to the `inception` bridge network. DNS resolution is available by container name:

- `nginx` → `wordpress:9000`
- `wordpress` → `mariadb:3306`

No ports are exposed to the host except `443` on NGINX.

## Persistent Data

Data is stored using Docker volumes with bind mount options:

- `wordpress_data` → `${DATA_PATH}/wordpress`
- `mariadb_data` → `${DATA_PATH}/mariadb`

These directories are created automatically by the `Makefile` before starting the stack.

## Debugging Tips

- Check container logs: `docker compose -f srcs/docker-compose.yml logs <service>`
- Enter a running container: `docker exec -it <container_name> sh`
- Verify secrets are mounted: `docker exec <container_name> ls /run/secrets/`
- Test database connectivity from WordPress container:
  ```sh
  docker exec -it wordpress sh
  mariadb -h mariadb -u <user> -p
  ```
