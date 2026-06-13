# Melis Platform Dockerfiles

This repository contains Dockerfiles to be used for [Melis Platform](https://www.melistechnology.com/).

## Install Melis with Docker — choose your path

| Path | What you get | For whom | Folder |
|------|--------------|----------|--------|
| **Pre-built image** | Pull a ready-to-run Melis (no build) + MySQL, finish via the web installer | Fastest evaluation / "just run it" | [`prebuilt/`](prebuilt/) |
| **Turnkey build** | Builds a fresh Melis skeleton on your host, editable code in `./melis`, + MySQL | Developers who want the code locally | [`install/`](install/) |
| **nginx + PHP-FPM** | Production-style stack (nginx front, PHP-FPM, MySQL), skeleton baked into the image | A more production-like topology | [`fpm/`](fpm/) |
| **Mount existing project** | Mounts an existing Melis project into a PHP-8.3-apache build | Projects you already have locally | [`app/latest/`](app/latest/) |
| **Dev base images** | Per-PHP-version base images only (Apache or FPM, PHP 8.1–8.4) | Building your own images | [`dev/`](dev/) |

> All paths finish the same way: the **native Melis web installer** at
> http://localhost:8080 (`/melis/setup`) sets up the DB schema, admin user and the
> optional demo site. The web installer is authoritative — the install is **not**
> scripted.

## Getting Started

Pick one of the paths below. Each folder is self-contained (its own
`docker-compose.yml`, `.env.example`, `conf/` and `README.md`) — see that folder's
README for full details.

> **Note:** Make sure host port **8080** is free (change `HOST_PORT` in `.env` if not).

### Clone the repository
```bash
git clone https://github.com/melisplatform/melis-docker.git
```

### Path A — Pre-built image (fastest)
Runs the published image + a MySQL service. No build on your machine.
```bash
cd melis-docker/prebuilt
cp .env.example .env
docker compose up -d
```

### Path B — Turnkey build (editable code on your host)
First run does `composer create-project` of the Melis skeleton into `./melis`
(takes a few minutes); the code stays on your host, editable.
```bash
cd melis-docker/install
cp .env.example .env
docker compose up --build
```

### Path C — nginx + PHP-FPM (production-style)
```bash
cd melis-docker/fpm
cp .env.example .env
docker compose up --build
```

### Path D — Mount an existing Melis project
Clone this repo **inside your Melis project root**, then:
```bash
cd melis-docker/app/latest
cp .env.example .env
docker compose up --build
```
> **Windows:** a `start-docker.bat` helper is provided at the repo root for this path.

### Finish the install
Open http://localhost:8080 and follow the **Melis web installer**. When it asks for
the database, use the values from your `.env`:

| Field | Value |
|-------|-------|
| Host | `melis-db` &nbsp;*(no `:port`)* |
| Database / User / Password | `melis` / `melis` / `melis` |

### Stop a stack
```bash
docker compose down       # keep data
docker compose down -v    # also remove volumes (DB + app), full reset
```

## Run several projects at once (shared local proxy)

Each stack publishes a host port (`8080` by default), so running several at once
means juggling port numbers. To avoid that — and any `:80` clash with other local
Docker projects — there's an **opt-in** shared reverse proxy in
[`local-proxy/`](local-proxy/) ([`nginxproxy/nginx-proxy`](https://github.com/nginx-proxy/nginx-proxy)).
It owns `:80` and routes by hostname; each stack declares a `VIRTUAL_HOST` and the
per-stack `docker-compose.proxy.yml` override drops its published port.

```bash
# 1) Once: create the shared network and start the proxy
docker network create webproxy
docker compose -f local-proxy/docker-compose.yml up -d

# 2) Map the *.local hostnames to localhost (one line in /etc/hosts)
#    127.0.0.1  melis-prebuilt.local melis-install.local melis-fpm.local melis-app.local

# 3) Bring up any stack WITH its proxy override (note the two -f flags)
cd prebuilt
cp .env.example .env
docker compose -f docker-compose.yml -f docker-compose.proxy.yml up -d
# → http://melis-prebuilt.local/   (no host port needed)
```

Default hostnames: `melis-prebuilt.local`, `melis-install.local`, `melis-fpm.local`,
`melis-app.local` — override any via `VIRTUAL_HOST` in that stack's `.env`. To run
**several stacks simultaneously**, also give each a distinct `MELIS_CONTAINER_NAME`
so container names don't collide.

> Without the `-f docker-compose.proxy.yml` flag every stack runs exactly as before
> (published on `HOST_PORT`) — the proxy is purely opt-in.

## Published image tags

[View on Docker Hub →](https://hub.docker.com/r/melisplatform/melis-docker)

**Pre-built (skeleton baked):**
- Apache (`mod_php`): `latest`, `php8.3`
- nginx + PHP-FPM: `fpm-latest`, `fpm-php8.3`

**Dev base images** (no app, just the PHP stack) — published from [`dev/`](dev/):
- Apache (`mod_php`): `dev-apache-8.1`, `dev-apache-8.2`, **`dev-apache-8.3`** (recommended), `dev-apache-8.4`
- PHP-FPM: `dev-fpm-8.1`, `dev-fpm-8.2`, `dev-fpm-8.3`, `dev-fpm-8.4`

> **PHP 8.3** is the default/recommended version (officially supported by Melis 5.3.x).
> **PHP 8.4** works via the maintained Laminas forks (see melisplatform/melis-core#24);
> it ships as an additional tag — `latest` stays on 8.3 until 8.4 is fully released
> upstream. The old PHP **7.x** tags are **not compatible** with current Melis.

All images are multi-arch (`linux/amd64`, `linux/arm64`).


## Contributing

Please note that this project is released with a [Contributor Code of Conduct](http://contributor-covenant.org/version/1/2/0/).

By participating in this project you agree to abide by its terms.

Feel free to fork the project, create a feature branch, and send us a pull request!

## Authors

* **Melis Technology** - [www.melistechnology.com](https://www.melistechnology.com/)

See also the list of [contributors](https://github.com/melisplatform/melis-docker/contributors) who participated in this project.

## License

This project is licensed under the OSL-3.0 License - see the [LICENSE](LICENSE) file for details