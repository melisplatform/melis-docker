# Melis Platform — pre-built image (PHP 8.3 + Apache + Composer)
# Unlike install/Dockerfile, the Melis skeleton is BAKED AT BUILD TIME, so the
# published image already contains a ready-to-run Melis project: the user only
# needs a database and `docker run` — no Composer/build step on their machine.
# DB schema, admin user and the optional demo site are still set up through the
# native Melis web installer on first visit.
FROM php:8.3-apache

ARG APP_NAME=melis
ARG TZ=Europe/Paris
# Pin the skeleton version for reproducible images (override at build:
#   --build-arg SKELETON_VERSION="^5.3").  Empty = latest stable.
ARG SKELETON_VERSION=
ENV APP_NAME=${APP_NAME} \
    TZ=${TZ} \
    COMPOSER_ALLOW_SUPERUSER=1

WORKDIR /var/www/${APP_NAME}

# System packages + PHP extensions required by Melis
RUN apt-get update -y && apt-get upgrade -y \
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

# Composer (kept at runtime too: the web installer adds modules via composer)
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

# Apache: serve Melis from /public, enable rewrite
COPY ./conf/vhost.conf /etc/apache2/sites-available/000-default.conf
COPY ./conf/php.ini /usr/local/etc/php/conf.d/php-melis.ini
RUN a2enmod rewrite headers

# --- Bake the Melis skeleton into the image (the key difference vs install/) ---
# Community Edition skeleton (public); cms/front/engine + demo are added later by
# the web installer. Built into a ready-to-serve project under the app dir.
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

EXPOSE 80
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
