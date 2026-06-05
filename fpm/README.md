# Run Melis Platform with nginx + PHP-FPM (production-style)

A more production-like stack than the Apache (`mod_php`) paths: **nginx** in front,
**PHP-FPM** for PHP, **MySQL** for data. The Melis skeleton is baked into the PHP
image (like [`../prebuilt`](../prebuilt)); you only bring a database, then finish
setup through the Melis web installer.

> Prefer the simplest path? Use [`../prebuilt`](../prebuilt) (Apache, single image).
> Want to hack on the code on the host? Use [`../install`](../install).

## Requirements
- Docker + Docker Compose
- Port `8080` free (change `HOST_PORT` in `.env` otherwise)

## Quick start

```bash
git clone https://github.com/melisplatform/melis-docker.git
cd melis-docker/fpm

cp .env.example .env          # defaults are fine to start
docker compose up -d --build  # first build bakes the skeleton (a few minutes)
```

Then open **http://localhost:8080** and follow the **Melis web installer**.

When the wizard asks for the database, use the values from your `.env`:

| Field    | Value (default) |
|----------|-----------------|
| Host     | `melis-db`      |
| Database | `melis`         |
| User     | `melis`         |
| Password | `melis`         |

## How it works

- **`web`** (nginx) serves static files and proxies `*.php` to **`php`** (PHP-FPM) on
  port `9000`.
- **`php`** holds the baked Melis code; on first run it seeds the shared `melis-app`
  named volume, which nginx mounts read-only.
- **`db`** (MySQL 8.4) stores the data; the database is created with collation
  `utf8mb4_general_ci` (required by the Melis installer).
- PHP-FPM runs with `clear_env = no` so PHP sees the container's `MYSQL_*` / `MELIS_*`
  environment variables (`getenv`).

## Everyday use

```bash
docker compose up -d        # start
docker compose stop         # stop
docker compose down         # stop & remove containers (volumes kept)
docker compose down -v      # full reset (drops the database AND the app volume)
```

## Notes
- This stack is for **local evaluation / development**. It mirrors a production
  topology (nginx + php-fpm) but is not hardened for production exposure.
- The baked skeleton is the **Community Edition**; the installer adds CMS / Front /
  Engine / demo as you choose.
