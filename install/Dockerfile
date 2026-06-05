# Melis Platform — turnkey install image (PHP 8.3 + Apache + Composer)
# Boots a fresh Melis skeleton on first run; the Melis web installer then
# handles DB schema, admin user and the optional demo site.
FROM php:8.3-apache

ARG APP_NAME=melis
ARG TZ=Europe/Paris
ENV APP_NAME=${APP_NAME} \
    TZ=${TZ}

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

# Composer (needed at runtime: skeleton bootstrap + the web installer adds modules)
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

# Apache: serve Melis from /public, enable rewrite
COPY ./conf/vhost.conf /etc/apache2/sites-available/000-default.conf
COPY ./conf/php.ini /usr/local/etc/php/conf.d/php-melis.ini
RUN a2enmod rewrite headers

COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 80
# Container is healthy once Apache serves the app. start-period is generous because
# the very first run downloads the skeleton (composer create-project) before Apache.
HEALTHCHECK --interval=30s --timeout=5s --start-period=300s --retries=3 \
    CMD curl -fsS http://localhost/ -o /dev/null || exit 1
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
