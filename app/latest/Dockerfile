FROM php:8.3-apache AS builder

# Define build arguments
ARG APP_NAME
ARG TZ
ARG MELIS_PLATFORM
ARG MELIS_MODULE
ARG PROJECT_DIR

# Validate .env and PROJECT_DIR
RUN if [ ! -f .env ]; then \
    echo "Error: .env file not found! Please create one from .env.example"; \
    exit 1; \
    fi && \
    if [ -z "${PROJECT_DIR}" ]; then \
    echo "Error: PROJECT_DIR is not set. Please set it in your .env file"; \
    exit 1; \
    fi

# Set environment variables
ENV APP_NAME=${APP_NAME} \
    TZ=${TZ} \
    MELIS_PLATFORM=${MELIS_PLATFORM} \
    MELIS_MODULE=${MELIS_MODULE} \
    PROJECT_DIR=${PROJECT_DIR}

## WORKDIR
WORKDIR /var/www/${APP_NAME}

# Install dependencies in a single RUN command to reduce layers
RUN apt-get update -y \
    && apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        vim \
        cron \
        curl \
        wget \
        git \
        default-mysql-client \
        libxml2-dev \
        libonig-dev \
        libcurl4-gnutls-dev \
        libzip-dev \
        libjpeg-dev \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        zlib1g-dev \
        libpng-dev \
        tzdata \
        systemd-timesyncd \
    && rm -rf /var/lib/apt/lists/* \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
        mysqli \
        pdo \
        pdo_mysql \
        xml \
        mbstring \
        curl \
        zip \
        gd \
        intl \
        exif \
        opcache \
    && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata

FROM builder AS config

# Copy configuration files
COPY ./conf/php.ini /usr/local/etc/php/conf.d/php-melis.ini
COPY ./conf/my.cnf /etc/mysql/conf.d/mysql.cnf
COPY ./conf/vhost.conf /etc/apache2/sites-available/vhost.conf
COPY ./conf/apache2.conf /etc/apache2/apache2.conf

# Final stage
FROM config

# Create necessary directories first
RUN mkdir -p /var/www/${APP_NAME}/config \
    && mkdir -p /var/www/${APP_NAME}/cache \
    && mkdir -p /var/www/${APP_NAME}/public \
    && mkdir -p /var/www/${APP_NAME}/mnt/public/media

# Set initial permissions
RUN chown -R www-data:www-data /var/www/${APP_NAME} \
    && chmod -R 775 /var/www/${APP_NAME}/config \
    && chmod -R 775 /var/www/${APP_NAME}/cache \
    && chmod -R 777 /var/www/${APP_NAME}/public

# Copy application files
COPY ${PROJECT_DIR} /var/www/${APP_NAME}/

# Final permissions and Apache configuration
RUN chown -R www-data:www-data /var/www/${APP_NAME} \
    && ln -sf /var/www/${APP_NAME}/mnt/public/media /var/www/${APP_NAME}/public \
    && a2enmod rewrite headers \
    && a2dissite 000-default.conf \
    && a2ensite vhost.conf

## EXPOSE
EXPOSE 80
