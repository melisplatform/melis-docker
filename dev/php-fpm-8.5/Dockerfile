# Melis Platform — dev base image (PHP 8.5 FPM + Composer)
# PHP-FPM base with the extensions Melis needs (listens on :9000). Put a web server
# (e.g. nginx) in front — see fpm/ for a ready-to-run nginx + php-fpm stack.
# Build: docker build -t melisplatform/melis-docker:dev-fpm-8.5 .
#
# NOTE: This is a valid PHP 8.5 base image, but **Melis does not run on 8.5 yet** —
# the skeleton's Laminas dependencies cap at PHP 8.4, so `composer install` fails on
# 8.5. Provided as a forward-looking / standalone PHP base until upstream lifts the
# cap (see melis-core#24). To actually run Melis use 8.3 (default) or 8.4.
FROM php:8.5-fpm

ARG TZ=Europe/Paris
ENV TZ=${TZ}

# System packages + PHP extensions required by Melis (intl needs libicu-dev)
RUN apt-get update -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        git unzip curl wget vim \
        default-mysql-client \
        libxml2-dev libonig-dev libcurl4-gnutls-dev libzip-dev \
        libjpeg-dev libfreetype6-dev libjpeg62-turbo-dev zlib1g-dev libpng-dev \
        libicu-dev tzdata \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    # NOTE: opcache is omitted here — on PHP 8.5 Zend OPcache is built into core
    # (already loaded, no shared module), so docker-php-ext-install opcache fails.
    && docker-php-ext-install -j"$(nproc)" \
        mysqli pdo pdo_mysql xml mbstring curl zip gd intl exif \
    && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone \
    && rm -rf /var/lib/apt/lists/*

# Composer (official image)
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

EXPOSE 9000
CMD ["php-fpm"]
