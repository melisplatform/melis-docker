# Melis Platform — turnkey install image (Apache + Composer)
# Boots a fresh Melis skeleton on first run; the Melis web installer then
# handles DB schema, admin user and the optional demo site.
#
# PHP version is configurable: default 8.3 (officially supported by Melis 5.3.x).
# Override with --build-arg PHP_VERSION=8.4 (or PHP_VERSION in .env via compose).
# 8.4 is experimental but runs Melis. 8.5 is NOT usable yet: this image builds, but
# the skeleton's Laminas deps cap at 8.4, so composer install fails at run time
# (see melis-core#24).
ARG PHP_VERSION=8.3
FROM php:${PHP_VERSION}-apache

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
    # opcache: built into core on PHP 8.5+ (not a shared module), so only install
    # it on < 8.5. Detected at build time → works for any PHP_VERSION.
    && OPCACHE=$(php -r 'echo version_compare(PHP_VERSION, "8.5", "<") ? "opcache" : "";') \
    && docker-php-ext-install -j"$(nproc)" \
        mysqli pdo pdo_mysql xml mbstring curl zip gd intl exif $OPCACHE \
    && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone \
    && rm -rf /var/lib/apt/lists/*

# Optional Xdebug for step-debugging — opt-in (off by default to keep it lean).
# Enable with --build-arg WITH_XDEBUG=1 (or WITH_XDEBUG=1 in .env via compose).
# Defaults: connects back to your IDE on port 9003; on Linux add to the php service
#   extra_hosts: ["host.docker.internal:host-gateway"]
ARG WITH_XDEBUG=0
RUN if [ "$WITH_XDEBUG" = "1" ]; then \
        pecl install xdebug && docker-php-ext-enable xdebug \
        && { \
            echo "xdebug.mode=debug,develop"; \
            echo "xdebug.start_with_request=trigger"; \
            echo "xdebug.client_host=host.docker.internal"; \
            echo "xdebug.client_port=9003"; \
            echo "xdebug.discover_client_host=true"; \
        } > /usr/local/etc/php/conf.d/zz-xdebug.ini ; \
    fi

# Composer (needed at runtime: skeleton bootstrap + the web installer adds modules)
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

# Clone public github repos over HTTPS instead of SSH (the image has no ssh client
# or keys). Needed when Composer resolves the public melisplatform Laminas forks
# from their VCS source — e.g. on PHP 8.5, where the locked dist versions can't be
# used. No-op for 8.3/8.4 (which install from dist). Public repos → no credentials.
RUN git config --system url."https://github.com/".insteadOf "git@github.com:"

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
