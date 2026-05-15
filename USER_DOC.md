# Inception - User Documentation

This document explains how to use the Inception infrastructure as an end user or administrator.

## Services

The infrastructure provides the following services:

- **NGINX**: Web server and reverse proxy with TLS termination.
- **WordPress**: Content management system.
- **MariaDB**: Database server for WordPress.

## Starting and Stopping

To start the services:
```sh
make up
```

To stop the services:
```sh
make down
```

To completely remove containers and volumes:
```sh
make clean
```

To fully reset the environment (including persistent data):
```sh
make fclean
```

## Accessing the Services

Open your browser and navigate to:
```text
https://<login>.42.fr
```

The WordPress admin panel is available at:
```text
https://<login>.42.fr/wp-admin
```

## Credentials

Login credentials are configured in:
- `srcs/.env` (usernames and emails)
- `secrets/` directory (passwords)

**Do not share or commit secret files.**

## Monitoring

Check service status:
```sh
docker compose -f srcs/docker-compose.yml ps
```

View logs:
```sh
docker compose -f srcs/docker-compose.yml logs nginx
docker compose -f srcs/docker-compose.yml logs wordpress
docker compose -f srcs/docker-compose.yml logs mariadb
```

## Data Persistence

WordPress files and the database are persisted on the host at the path defined by `DATA_PATH` in `srcs/.env`.
