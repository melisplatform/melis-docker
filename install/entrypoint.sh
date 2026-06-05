#!/bin/bash
# Melis turnkey entrypoint.
# - Bootstraps a fresh Melis skeleton if the app directory is empty.
# - Waits for MySQL (via PHP/mysqli — avoids the MariaDB-client TLS issue).
# - Leaves DB schema / admin / demo to the Melis web installer (localhost:8080).
set -e

APP_DIR="/var/www/${APP_NAME:-melis}"
DB_HOST="${MYSQL_HOST:-db}"
DB_USER="${MYSQL_USER:-melis}"
DB_PASS="${MYSQL_PASSWORD:-melis}"
DB_NAME="${MYSQL_DATABASE:-melis}"

cd "$APP_DIR"

# 1) Bootstrap a fresh Melis skeleton on first run (empty app dir / no composer.json)
if [ ! -f composer.json ]; then
  echo "[melis-docker] No Melis project found in $APP_DIR — creating a fresh skeleton..."
  composer create-project melisplatform/melis-platform-skeleton . --no-interaction --no-progress
fi

# 2) Make sure dependencies are installed (e.g. mounted project without vendor/)
if [ ! -d vendor ]; then
  echo "[melis-docker] Installing composer dependencies..."
  composer install --no-interaction --no-progress
fi

# 3) Wait for the database (PHP/mysqli — works with MySQL 8.x TLS, unlike the CLI client).
#    Env vars are exported BEFORE php so getenv() sees them; MYSQLI_REPORT_OFF makes
#    a failed connect return false instead of throwing (PHP 8.1+ default is exceptions).
echo "[melis-docker] Waiting for MySQL at ${DB_HOST}..."
tries=0
until DB_HOST="$DB_HOST" DB_USER="$DB_USER" DB_PASS="$DB_PASS" \
      php -r 'mysqli_report(MYSQLI_REPORT_OFF); exit(@mysqli_connect(getenv("DB_HOST"),getenv("DB_USER"),getenv("DB_PASS"))?0:1);'; do
  tries=$((tries + 1))
  if [ "$tries" -ge 60 ]; then
    echo "[melis-docker] WARNING: MySQL still unreachable after ~3 min — starting Apache anyway; the web installer will retry."
    break
  fi
  sleep 3
done
# Safety net: ensure the (empty) database exists — the installer fills it
DB_HOST="$DB_HOST" DB_USER="$DB_USER" DB_PASS="$DB_PASS" DB_NAME="$DB_NAME" php -r '
  mysqli_report(MYSQLI_REPORT_OFF);
  $c=@mysqli_connect(getenv("DB_HOST"),getenv("DB_USER"),getenv("DB_PASS"));
  if($c){mysqli_query($c,"CREATE DATABASE IF NOT EXISTS `".getenv("DB_NAME")."` CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci");}
' || true

# 4) Permissions: the installer writes config/, Melis writes cache/
mkdir -p "$APP_DIR/config" "$APP_DIR/cache" "$APP_DIR/mnt/public/media"
chown -R www-data:www-data "$APP_DIR" || true
chmod -R 775 "$APP_DIR/config" "$APP_DIR/cache" 2>/dev/null || true

echo "[melis-docker] ============================================================"
echo "[melis-docker]  Melis is ready. Open http://localhost:${HOST_PORT:-8080}"
echo "[melis-docker]  and follow the web installer."
echo "[melis-docker]  DB to enter in the wizard:  host=${DB_HOST}  db=${DB_NAME}"
echo "[melis-docker]                              user=${DB_USER}  pass=${DB_PASS}"
echo "[melis-docker] ============================================================"

exec apache2-foreground
