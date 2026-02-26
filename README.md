# Guacamole with docker-compose
A docker-compose setup for **Apache Guacamole** using **Traefik** as reverse proxy.

Apache Guacamole is a clientless remote desktop gateway supporting VNC, RDP, SSH and Telnet. More information on the [project homepage](https://guacamole.apache.org/).

## Prerequisites
- Docker and docker compose
- A running Traefik reverse proxy with an external docker network named `traefik`

## Quick start

```bash
git clone "https://github.com/boschkundendienst/guacamole-docker-compose.git"
cd guacamole-docker-compose
./prepare.sh
```

Create a `.env` file with your configuration:

```env
GUACAMOLE_HOSTNAME=guacamole.example.com
POSTGRES_PASSWORD=YourSecurePassword
POSTGRES_USER=guacamole_user
TRAEFIK_CERTRESOLVER=myresolver
```

Start the services:

```bash
docker compose up -d
```

Guacamole is now available at `https://guacamole.example.com`.

Default login: `guacadmin` / `guacadmin` — change this immediately!

## Configuration

### Environment variables

| Variable | Default | Description |
|---|---|---|
| `GUACAMOLE_HOSTNAME` | — | Hostname for Traefik routing (required) |
| `POSTGRES_PASSWORD` | `ChooseYourOwnPasswordHere1234` | PostgreSQL password |
| `POSTGRES_USER` | `guacamole_user` | PostgreSQL user |
| `TRAEFIK_CERTRESOLVER` | `myresolver` | Name of your Traefik certificate resolver |

### Traefik network

The `docker-compose.yml` expects an external docker network named `traefik`. If your Traefik network has a different name, adjust the network name in `docker-compose.yml` accordingly.

### Traefik labels

The guacamole service includes labels that:
- Route traffic via `Host()` rule based on `GUACAMOLE_HOSTNAME`
- Use the `websecure` entrypoint with TLS
- Add a `/guacamole` path prefix (Guacamole serves on `/guacamole` by default)
- Expose port `8080` to Traefik

## prepare.sh
Creates the database initialization file `./init/initdb.sql` needed by PostgreSQL.

## reset.sh
Deletes database, recordings and drive files. Run `./prepare.sh` again after a reset.
