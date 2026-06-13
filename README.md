# Melis Platform Dockerfiles

This repository contains Dockerfiles to be used for [Melis Platform](https://www.melistechnology.com/).

## Install Melis with Docker — choose your path

| Path | What you get | For whom | Folder |
|------|--------------|----------|--------|
| **Pre-built image** | Pull a ready-to-run Melis (no build) + MySQL, finish via the web installer | Fastest evaluation / "just run it" | [`prebuilt/`](prebuilt/) |
| **Turnkey build** | Builds a fresh Melis skeleton on your host, editable code in `./melis`, + MySQL | Developers who want the code locally | [`install/`](install/) |
| **nginx + PHP-FPM** | Production-style stack (nginx front, PHP-FPM, MySQL), skeleton baked into the image | A more production-like topology | [`fpm/`](fpm/) |
| **Mount existing project** | Mounts an existing Melis project into a PHP-8.3-apache build | Projects you already have locally | [`app/latest/`](app/latest/) |
| **Dev base images** | Per-PHP-version base images only (Apache or FPM, PHP 8.1–8.5) | Building your own images | [`dev/`](dev/) |

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
- Apache (`mod_php`): `dev-apache-8.1`, `dev-apache-8.2`, **`dev-apache-8.3`** (recommended), `dev-apache-8.4`, `dev-apache-8.5`
- PHP-FPM: `dev-fpm-8.1`, `dev-fpm-8.2`, `dev-fpm-8.3`, `dev-fpm-8.4`, `dev-fpm-8.5`

> **PHP 8.3** is the default/recommended version (officially supported by Melis 5.3.x).
> **PHP 8.4** is experimental but runs Melis (every dependency allows it). **PHP 8.5**
> base images build, but Melis does **not** run on 8.5 yet — the skeleton's Laminas
> dependencies cap at 8.4, so its `composer install` fails on 8.5. The `dev-*-8.5` tags
> are forward-looking (standalone PHP base) until upstream lifts the cap (see
> melisplatform/melis-core#24). `latest` stays on 8.3. The old PHP **7.x** tags are
> **not compatible** with current Melis.

All images are multi-arch (`linux/amd64`, `linux/arm64`).

## Choosing the PHP version

The buildable stacks (`install/`, `prebuilt/`, `fpm/`) default to **PHP 8.3**. To
build on another version, set `PHP_VERSION` in that stack's `.env` and rebuild:

```bash
cd install
echo "PHP_VERSION=8.4" >> .env     # 8.3 (default, recommended) | 8.4 (experimental)
docker compose up -d --build
```

> **8.4** is experimental but installs and runs Melis. **8.5 is not usable for Melis
> yet**: the skeleton's Laminas dependencies cap at 8.4, so `composer install` fails on
> 8.5 (it fails at run time for `install/`, and at *build* time for `prebuilt/`/`fpm/`
> which bake the skeleton). Use **8.3 or 8.4** to actually run Melis. The standalone
> `dev-*-8.5` base images do build — they're forward-looking. See melis-core#24.

## Handy shortcuts (Makefile)

A root [`Makefile`](Makefile) wraps the common `docker compose` calls. Pick a stack
with `STACK=…` (default `prebuilt`):

```bash
make up STACK=install     # cp .env + start (turnkey build)
make up-build STACK=fpm   # build + start the nginx + php-fpm stack
make logs                 # follow logs        make shell    # shell into php
make down                 # stop (keep data)   make destroy  # stop + wipe volumes
make proxy-up             # shared nginx-proxy  make up PROXY=1  # run a stack behind it
make adminer              # web DB client → http://localhost:8082
make help                 # list everything
```

## Troubleshooting / FAQ

**Port 8080 already in use** — change `HOST_PORT` in the stack's `.env`, or run
behind the [shared proxy](#run-several-projects-at-once-shared-local-proxy) and
drop host ports entirely.

**"Test database connection" fails in the web installer** — enter the DB **host
without a port** (e.g. `melis-db`, *not* `melis-db:3306`); a `host:port` value
breaks Melis' flyway/JDBC URL. Credentials are whatever you set in `.env`
(defaults `melis` / `melis` / `melis`). The DB must use collation
`utf8mb4_general_ci` (these compose files already do).

**The page won't load on first start** — the first run downloads the Melis skeleton
(turnkey) or seeds the app volume (pre-built) before Apache/nginx answers; give it
a minute. Follow progress with `make logs` (or `docker compose logs -f`).

**Reset everything and start fresh** — `make destroy` (or `docker compose down -v`).
For the turnkey stack also delete the host code: `rm -rf install/melis`.

**Switch PHP version** — see [Choosing the PHP version](#choosing-the-php-version);
remember to rebuild (`--build`). The pre-built image's version is fixed by its tag.

**Connect a DB GUI** — the DB is published on `127.0.0.1:33061` (localhost only), or
run `make adminer` for a browser client at http://localhost:8082.

**Step-debugging (Xdebug)** — the turnkey [`install/`](install/) stack can bake Xdebug
in: set `WITH_XDEBUG=1` in `.env` and rebuild (`docker compose up -d --build`). It
connects back to your IDE on port **9003** and starts on a trigger (browser extension
or `XDEBUG_TRIGGER`). On Linux the compose file already maps `host.docker.internal`.

**Apache warning `AH00558: … ServerName`** — harmless; the images set
`ServerName localhost` to silence it.

## Contributing

Please note that this project is released with a [Contributor Code of Conduct](http://contributor-covenant.org/version/1/2/0/).

By participating in this project you agree to abide by its terms.

Feel free to fork the project, create a feature branch, and send us a pull request!

## Authors

* **Melis Technology** - [www.melistechnology.com](https://www.melistechnology.com/)

See also the list of [contributors](https://github.com/melisplatform/melis-docker/contributors) who participated in this project.

## License

This project is licensed under the OSL-3.0 License - see the [LICENSE](LICENSE) file for details