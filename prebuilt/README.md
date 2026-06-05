# Run Melis Platform from the pre-built image

This is the fastest path: the published image **already contains a ready-to-run
Melis project**, so there is no Composer/build step on your machine. You only
bring a database, then finish setup through the Melis web installer.

> Looking to build the skeleton yourself / hack on the code on the host?
> Use [`../install`](../install) instead (turnkey build).

## Requirements
- Docker + Docker Compose
- Port `8080` free (change `HOST_PORT` in `.env` otherwise)

## Quick start (compose: image + database)

```bash
git clone https://github.com/melisplatform/melis-docker.git
cd melis-docker/prebuilt

cp .env.example .env        # defaults are fine to start
docker compose up -d        # pulls the pre-built image + starts MySQL
```

Then open **http://localhost:8080** and follow the **Melis web installer**.

When the wizard asks for the database, use the values from your `.env`:

| Field    | Value (default) |
|----------|-----------------|
| Host     | `melis-db`      |
| Database | `melis`         |
| User     | `melis`         |
| Password | `melis`         |

The installer lets you choose an **empty install**, a **starter site module**, or
the **MelisCmsDemo** website to learn with.

## Even quicker (no compose): bring your own database

If you already have a MySQL 8.x server, a single `docker run` is enough:

```bash
docker run -d --name melis -p 8080:80 \
  -e MYSQL_HOST=your-db-host \
  -e MYSQL_DATABASE=melis \
  -e MYSQL_USER=melis \
  -e MYSQL_PASSWORD=melis \
  melisplatform/melis-docker:latest
```

> `MYSQL_HOST` must be a hostname **without** `:port` (e.g. `db`, not `db:3306`) —
> a `host:port` value breaks Melis' flyway/JDBC URL.

## Everyday use

```bash
docker compose up -d        # start
docker compose stop         # stop
docker compose down         # stop & remove containers (volumes kept)
docker compose down -v      # full reset (drops the database AND the app volume)
```

## Notes
- The baked skeleton is the **Community Edition** (public modules); the installer
  adds CMS / Front / Engine / demo as you choose.
- The app lives in a **named volume** (`melis-app`), seeded from the image on first
  run and persisting what the installer writes (config, cache, media). Don't bind a
  host folder over `/var/www/melis` or it would hide the pre-built project.
- This setup is for **local evaluation / development**. For production, see the
  project's Kubernetes / OCI deployment, not this compose file.
- Pin a specific image tag in `.env` (`MELIS_IMAGE`) for reproducible runs.
