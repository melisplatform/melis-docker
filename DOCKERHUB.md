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
| `dev-apache-8.1` … `8.3` | Dev **base** images (PHP + Apache + Composer) to mount your own project |
| `dev-fpm-8.1` … `8.3` | Dev **base** images (PHP-FPM + Composer) to put behind your own nginx |
| `dev-apache-7.x` | **Legacy** (PHP 7, **not** compatible with current Melis 5.3.x — kept for old projects) |

> Melis 5.3.x requires **PHP 8.1 – 8.3** (`composer ^8.1|^8.3`). Prefer a PHP 8 tag.

## Quick start

The fastest path — pull and run, then bring any MySQL 8.x:

```bash
docker run -d --name melis -p 8080:80 \
  -e MYSQL_HOST=your-db-host \
  -e MYSQL_DATABASE=melis \
  -e MYSQL_USER=melis \
  -e MYSQL_PASSWORD=melis \
  melisplatform/melis-docker:latest
```

> `MYSQL_HOST` must be a hostname **without** `:port` (e.g. `db`, not `db:3306`).

Then open **http://localhost:8080** and follow the web installer.

Prefer a one-command stack that includes the database? Use a compose file from the
repository:

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
