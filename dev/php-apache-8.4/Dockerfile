# Melis Platform — dev base image (PHP 8.4 + Apache + Composer)
# A ready-to-use PHP/Apache base with the extensions Melis needs. Mount your Melis
# project into the container (see app/latest/ for a full local dev stack).
# Build: docker build -t melisplatform/melis-docker:dev-apache-8.4 .
FROM php:8.4-apache

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
    && docker-php-ext-install -j"$(nproc)" \
        mysqli pdo pdo_mysql xml mbstring curl zip gd intl exif opcache \
    && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone \
    && rm -rf /var/lib/apt/lists/*

# Composer (official image) + Apache modules Melis relies on
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer
RUN a2enmod rewrite headers

EXPOSE 80
CMD ["apache2-foreground"]
