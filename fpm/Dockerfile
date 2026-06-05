# Melis Platform — pre-built PHP-FPM image (PHP 8.3 FPM + Composer)
# Production-style runtime: PHP-FPM only (no bundled web server) — nginx sits in
# front (see docker-compose.yml). The Melis skeleton is BAKED at build time, like
# prebuilt/, so the image is self-contained; only a database is needed at run time.
# DB schema / admin / optional demo are still set up via the Melis web installer.
FROM php:8.3-fpm

ARG APP_NAME=melis
ARG TZ=Europe/Paris
# Pin the skeleton version for reproducible images (empty = latest stable).
ARG SKELETON_VERSION=
ENV APP_NAME=${APP_NAME} \
    TZ=${TZ} \
    COMPOSER_ALLOW_SUPERUSER=1

WORKDIR /var/www/${APP_NAME}

# System packages + PHP extensions required by Melis (intl needs libicu-dev)
RUN apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        git unzip curl wget \
        default-mysql-client \
        libxml2-dev libonig-dev libcurl4-gnutls-dev libzip-dev \
        libjpeg-dev libfreetype6-dev libjpeg62-turbo-dev zlib1g-dev libpng-dev \
        libicu-dev tzdata \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j"$(nproc)" \
        mysqli pdo pdo_mysql xml mbstring curl zip gd intl exif opcache \
    && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone \
    && rm -rf /var/lib/apt/lists/*

# Composer (kept at runtime: the web installer adds modules via composer)
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

# PHP + FPM pool config (clear_env=no so PHP sees the container's MYSQL_*/MELIS_* vars)
COPY ./conf/php.ini /usr/local/etc/php/conf.d/php-melis.ini
COPY ./conf/www.conf /usr/local/etc/php-fpm.d/zz-melis.conf

# --- Bake the Melis skeleton into the image (Community Edition, public) ---
RUN if [ -n "${SKELETON_VERSION}" ]; then \
        composer create-project melisplatform/melis-platform-skeleton:"${SKELETON_VERSION}" . \
            --no-interaction --no-progress --prefer-dist ; \
    else \
        composer create-project melisplatform/melis-platform-skeleton . \
            --no-interaction --no-progress --prefer-dist ; \
    fi \
    && mkdir -p config cache mnt/public/media \
    && chown -R www-data:www-data /var/www/${APP_NAME}

COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
