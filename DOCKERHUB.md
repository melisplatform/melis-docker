# Melis Platform — Docker images

Ready-to-run Docker images for [**Melis Platform**](https://www.melistechnology.com/),
the PHP / Laminas CMS. Pull an image, point it at a MySQL database, and finish the
setup through the native Melis **web installer** (DB schema, admin user, optional demo).

Images are **multi-arch** (`linux/amd64` + `linux/arm64`, so they run natively on
Intel/AMD and on Apple Silicon).

Source & full docs: **https://github.com/melisplatform/melis-docker**

## Tags

| Tag | What it is |
|-----|-----------|
| `latest`, `php8.3` | **Pre-built** Melis (Apache + mod_php), skeleton baked in — just add a DB |
| `fpm-latest`, `fpm-php8.3` | **Pre-built** Melis for an **nginx + PHP-FPM** stack, skeleton baked in |
| `dev-apache-8.1` … `8.5` | Dev **base** images (PHP + Apache + Composer) to mount your own project |
| `dev-fpm-8.1` … `8.5` | Dev **base** images (PHP-FPM + Composer) to put behind your own nginx |
| `dev-apache-7.x` | **Legacy** (PHP 7, **not** compatible with current Melis 5.3.x — kept for old projects) |

> **PHP 8.3** is the recommended/default version — `latest` points to it.
> **PHP 8.4** is experimental but runs Melis. **PHP 8.5** dev images build, but Melis does
> **not** run on 8.5 yet — the skeleton's Laminas dependencies cap at 8.4, so its
> `composer install` fails on 8.5 (the `dev-*-8.5` tags are forward-looking base images).
> `latest` stays on **8.3**. See melisplatform/melis-core#24.

## Quick start

The image needs a MySQL database. The simplest self-contained way is a small
Docker network with a MySQL container and the Melis image — here `MYSQL_HOST` is
the **database container's name** on that network (`melis-db`):

```bash
docker network create melis

docker run -d --name melis-db --network melis \
  -e MYSQL_DATABASE=melis -e MYSQL_USER=melis \
  -e MYSQL_PASSWORD=melis -e MYSQL_ROOT_PASSWORD=melis \
  mysql:8.4 --collation-server=utf8mb4_general_ci

docker run -d --name melis --network melis -p 8080:80 \
  -e MYSQL_HOST=melis-db \
  -e MYSQL_DATABASE=melis -e MYSQL_USER=melis -e MYSQL_PASSWORD=melis \
  melisplatform/melis-docker:latest
```

Then open **http://localhost:8080** and follow the web installer (use the same DB
values: host `melis-db`, database/user/password `melis`).

> `MYSQL_HOST` is a hostname **without** `:port` (e.g. `melis-db`, not `melis-db:3306`).
> Pointing at an existing MySQL server instead? Set `MYSQL_HOST` to that server's
> host (and make sure the container can reach it — e.g. `host.docker.internal` for a
> DB running on your machine).

### Even simpler: a ready-made compose stack

The repository ships compose files that wire the image + database together for you:

- [`prebuilt/`](https://github.com/melisplatform/melis-docker/tree/master/prebuilt) — Apache image + MySQL
- [`fpm/`](https://github.com/melisplatform/melis-docker/tree/master/fpm) — nginx + PHP-FPM + MySQL
- [`install/`](https://github.com/melisplatform/melis-docker/tree/master/install) — turnkey build with editable code on the host

## Notes

- The baked images ship the Melis **Community Edition** skeleton; the installer adds
  CMS / Front / Engine / demo as you choose.
- Designed for **local evaluation / development**. For production, see the project's
  Kubernetes / OCI deployment.

## License

OSL-3.0 — see the [repository](https://github.com/melisplatform/melis-docker).
