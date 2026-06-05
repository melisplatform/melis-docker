# Install Melis Platform with Docker (turnkey)

Get a working Melis Platform locally in 3 commands — no PHP, MySQL or Composer
needed on your machine, just Docker.

## Requirements
- Docker + Docker Compose
- Port `8080` free (change `HOST_PORT` in `.env` otherwise)

## Install

```bash
# 1. Get this folder
git clone https://github.com/melisplatform/melis-docker.git
cd melis-docker/install

# 2. Configure (defaults are fine to start)
cp .env.example .env

# 3. Build & start (first run downloads a fresh Melis skeleton — a few minutes)
docker compose up --build
```

Then open **http://localhost:8080** and follow the **Melis web installer**.

When the wizard asks for the database, use the values from your `.env`:

| Field      | Value (default) |
|------------|-----------------|
| Host       | `melis-db`      |
| Database   | `melis`         |
| User       | `melis`         |
| Password   | `melis`         |

The installer lets you choose an **empty install**, a **starter site module**, or
the **MelisCmsDemo** website to learn with.

## Everyday use

```bash
docker compose up -d        # start
docker compose stop         # stop
docker compose down         # stop & remove containers (DB volume kept)
docker compose down -v      # full reset (drops the database)
```

- Your Melis code lives in `./melis` on the host — edit it directly.
- To reinstall from scratch: `docker compose down -v && rm -rf ./melis` then `docker compose up --build`.

## Notes
- The skeleton is the **Community Edition** (public modules); the installer adds
  CMS / Front / Engine / demo as you choose.
- This setup is for **local development**. For production, see the project's
  Kubernetes / OCI deployment, not this compose file.
