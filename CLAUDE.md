# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this repo is

`melis-docker` — the public Docker tooling for **Melis Platform** (a PHP/Laminas
CMS, modules `melisplatform/*`, version line 5.3.x). It ships Dockerfiles,
docker-compose stacks and CI to install/run Melis with one command. It does **not**
contain Melis itself — the application code comes from the Packagist skeleton
`melisplatform/melis-platform-skeleton` (Melis CE), pulled via Composer.

There is no application source, no test suite, no build step to run here — the
"code" is Dockerfiles, compose files, shell entrypoints and GitHub Actions. Verify
changes by building/running the relevant stack, not by unit tests.

## The five paths (each is self-contained in its own folder)

| Folder | What it does | Audience |
|---|---|---|
| [`prebuilt/`](prebuilt/) | Pulls a **pre-built** image that bakes the skeleton at build time + a MySQL service. No build on the user's machine. | Fastest "just run it" |
| [`install/`](install/) | **Turnkey build**: builds locally, `composer create-project` the skeleton at first run into `./melis` (editable on host) + MySQL. | Devs who want code locally |
| [`fpm/`](fpm/) | Production-style **nginx + PHP-FPM + MySQL**, skeleton baked into the image. | More production-like topology |
| [`app/latest/`](app/latest/) | **Legacy** dev path: mounts an existing Melis project (`../../../`) into a PHP-8.3-apache build. | Existing projects |
| [`dev/`](dev/) | Per-PHP-version **base images** only (no compose). `dev-{apache,fpm}-{8.1,8.2,8.3,8.4,8.5}`. | Image building blocks |
| [`local-proxy/`](local-proxy/) | Shared **nginx-proxy** (opt-in) so several stacks share `:80` by hostname. | Running many projects locally |

All paths finish the same way: the **native Melis web installer** at
http://localhost:8080 (`/melis/setup`) sets up the DB schema, admin user and the
optional demo site. **We never script the Melis install** — the web wizard is
authoritative; scripting it is fragile and was a deliberate non-goal.

## Architecture conventions

- **Stack baseline:** PHP **8.3** (mod_php for apache variants, php-fpm for fpm),
  Apache 2.4 / nginx 1.27, **MySQL 8.4 LTS**.
- **PHP version is configurable** in the runnable stacks (`install/`, `prebuilt/`,
  `fpm/`): `ARG PHP_VERSION=8.3` → `FROM php:${PHP_VERSION}-{apache,fpm}`, wired into
  compose build args and `.env` (`PHP_VERSION=`). 8.4 is experimental but runs;
  8.5 builds the image but Melis won't install (Laminas deps cap at 8.4) — use 8.3/8.4.
- **Root `Makefile`** wraps the common compose ops: `make up|up-build|down|destroy|
  logs|shell|ps STACK=install|prebuilt|fpm|app/latest`, plus `proxy-up`, `PROXY=1`,
  and `adminer` (DB GUI on :8082). `make help` lists all.
- **Xdebug** is opt-in in `install/` via `ARG WITH_XDEBUG=1` (`.env` `WITH_XDEBUG=1`):
  pecl xdebug + config (mode debug,develop; trigger; IDE port 9003). Off by default.
- **Required PHP extensions:** `pdo_mysql` + `intl` are mandatory, plus
  `mysqli, gd, zip, mbstring, xml, curl, exif, opcache`. `gd` is configured
  `--with-freetype --with-jpeg`; `intl` needs `libicu-dev`.
- **Composer is required in the image** — not just for bootstrap but because the
  Melis web installer adds modules (cms/front/engine) via Composer at install time.
- Each folder keeps its own `Dockerfile`, `docker-compose.yml`, `entrypoint.sh`,
  `.env.example`, `conf/`, `README.md`. Keep them consistent across folders when
  changing shared logic (extensions, MySQL wait loop, collation, perms).

## Hard-won gotchas — respect these (they cost real debugging)

1. **`MYSQL_HOST` / `MYSQL_HOSTNAME` must NOT contain `:port`.** Use `melis-db`,
   never `melis-db:3306`. A `host:port` value makes Melis' flyway/JDBC build a
   double-port URL and breaks. (Was the legacy `app/latest` bug.)
2. **Do DB readiness checks via PHP/mysqli, not the `mysql` CLI.** The MariaDB
   client (`default-mysql-client`) rejects MySQL 8.x's self-signed TLS cert.
   Entrypoints wait on MySQL with PHP. When passing creds to `php -r`, pass them as
   **environment** (prefix `DB_HOST=… php -r …`), not as `$argv` — the original
   entrypoints passed them as args, `getenv()` returned empty, the loop spun
   forever and **Apache never started (HTTP 000)**. Also set
   `mysqli_report(MYSQLI_REPORT_OFF)` (PHP 8.1+ throws instead of returning false)
   and bound the retry (~3 min) so Apache always comes up.
3. **DB collation must be `utf8mb4_general_ci`.** The Melis installer rejects
   `utf8mb4_unicode_ci` at "Test database connection". Set it in both the compose
   `--collation-server` and the entrypoint `CREATE DATABASE`.
4. **MySQL 8.4 removed `--default-authentication-plugin`** — don't pass it; rely on
   the server default (`caching_sha2_password`), which PHP 8.x connects to natively.
5. **`prebuilt/`: never bind-mount a host dir over `/var/www/melis`** — it would
   mask the baked code. Use the **named volume** `melis-app` (seeded from the image
   on first run). `fpm/clear_env=no` so PHP-FPM sees `getenv(MYSQL_*)`.
6. **PHP 7.x is incompatible** with current Melis (`require php: ^8.1|^8.3`). **PHP 8.4**
   runs Melis (every dependency allows `~8.4`) and is the experimental ceiling. **PHP 8.5
   does NOT run Melis yet** (verified 2026-06-13): the skeleton's Laminas deps
   (laminas-mvc, -servicemanager, -mime, -math, melis-core…) cap at 8.4, so
   `composer install` fails on 8.5 — at run time for `install/`, at *build* time for
   `prebuilt/`/`fpm/` (they bake the skeleton). `dev-*-8.5` images build (pure PHP base,
   forward-looking). `latest` stays on 8.3. See `melisplatform/melis-core#24`.
7. **PHP 8.5 build gotcha: don't `docker-php-ext-install opcache`** — on 8.5 Zend
   OPcache is built into core (no shared module), so it fails with
   `cp: cannot stat 'modules/*'`. All Dockerfiles gate it on `version_compare(...,
   "8.5", "<")` so opcache is installed only on < 8.5 (it's already loaded on 8.5).

## Shared local proxy (opt-in, `local-proxy/` + `*/docker-compose.proxy.yml`)

`nginxproxy/nginx-proxy` on a shared external `webproxy` network owns `:80` and
routes by container `VIRTUAL_HOST`. Each runnable stack has a
`docker-compose.proxy.yml` override that: declares `VIRTUAL_HOST`/`VIRTUAL_PORT`,
joins `webproxy`, and **drops the published host port via the Compose `!reset []`
tag**. Activated by adding `-f docker-compose.proxy.yml`; without it, stacks behave
exactly as before (published on `HOST_PORT`). The proxy targets the `php` service
(install/prebuilt/app-latest) or the nginx `web` service (fpm — php is FPM-only).
Default hosts: `melis-{prebuilt,install,fpm,app}.local`. To run several at once,
set distinct `MELIS_CONTAINER_NAME` + `VIRTUAL_HOST` per `.env`. Mirrors the setup
in the sibling `../melis-platform-website` project. Validate edits with
`docker compose -f docker-compose.yml -f docker-compose.proxy.yml config`.

## Security / hygiene

- **Never commit a real `.env` or any secret** — `.env.example` only. `.gitignore`
  ignores `**/.env`, `install/melis/`, `.claude/settings.local.json`, `.DS_Store`.
- DB ports are bound to `127.0.0.1` (not exposed on the LAN).
- Web services have a `HEALTHCHECK`; Apache gets an explicit `ServerName localhost`
  to silence `AH00558`.

## CI (GitHub Actions, all multi-arch `linux/amd64,linux/arm64`)

- **`docker-image.yml`** — builds `dev/` base images, matrix `{apache,fpm} × {8.1..8.5}`,
  pushes `melisplatform/melis-docker:dev-{variant}-{php}` on `master` only.
- **`prebuilt-image.yml`** — builds the baked images: `prebuilt/` → `latest`/`php8.3`,
  `fpm/` → `fpm-latest`/`fpm-php8.3`; pushes on `master` pushes and `v*` tags.
- **`dockerhub-description.yml`** — syncs `DOCKERHUB.md` to the Docker Hub overview.
- PRs **build-only** (no push, no secrets needed). Pushing requires repo secrets
  `DOCKERHUB_USERNAME` / `DOCKERHUB_TOKEN`. Pushing a `.github/workflows/*` change
  needs the `workflow` scope on the `gh` token.

## How to test a change locally

```bash
# Pre-built (validated E2E): build the baked image, then run image + db
cd prebuilt && docker build -t melisplatform/melis-docker:latest . \
  && cp -n .env.example .env && docker compose up -d
# Turnkey: builds + composer create-project on first run (slow first time)
cd install && cp -n .env.example .env && docker compose up --build
# nginx + php-fpm
cd fpm && cp -n .env.example .env && docker compose up --build   # default 8080
```
Then open http://localhost:8080 — expect `/` → 302 → `/melis/setup` → 200, and
drive the wizard (DB host = `melis-db` **without port**, db/user/pass = `melis`).
Baked images are ~1.5 GB each; `docker rmi` test images when done.

## Notes

- [`HANDOFF.md`](HANDOFF.md) is the detailed session log / decision record — read it
  for the full backstory, upstream PRs (melis-installer #19/#20/#21) and roadmap.
- The repo lives next to a private `../demo` (the Melis demo on OCI/Kubernetes);
  the gotchas above are shared lessons from that deployment.
- Cloud sync (iCloud/Dropbox) occasionally drops `* 2.ext` / `* 3.ext` duplicate
  files in the tree. They are not part of the build — delete them. Find with:
  `find . -not -path './.git/*' \( -name '* [0-9].*' -o -name '* [0-9]' \)`.
