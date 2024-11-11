### PHP
FROM php:8.3-apache

## WORKDIR
WORKDIR /var/www/${APP_NAME}

## SYSTEM_PACKAGES
RUN apt-get update -y && apt-get upgrade -y \
    && apt-get install -y vim cron curl wget git

## PHP EXTENSIONS
RUN apt-get install -y default-mysql-client && docker-php-ext-install mysqli && docker-php-ext-enable mysqli \
    && apt-get install -y libxml2-dev && docker-php-ext-install xml && docker-php-ext-enable xml \
    && apt-get install -y libonig-dev && docker-php-ext-install mbstring && docker-php-ext-enable mbstring \
    && apt-get install -y libcurl4-gnutls-dev && docker-php-ext-install curl && docker-php-ext-enable curl \
    && apt-get install -y libzip-dev && docker-php-ext-install zip && docker-php-ext-enable zip \
    && apt-get install -y libjpeg-dev libfreetype6-dev libjpeg62-turbo-dev && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && apt-get install -y zlib1g-dev libpng-dev && docker-php-ext-install gd && docker-php-ext-enable gd \
    && docker-php-ext-install intl && docker-php-ext-enable intl \
    && docker-php-ext-install exif && docker-php-ext-enable exif \
    && docker-php-ext-install opcache && docker-php-ext-enable opcache

## TIMEZONE
RUN apt-get install -y tzdata -V systemd-timesyncd \
    && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata

## COPY FILES
COPY ./config/php.ini /usr/local/etc/php/conf.d/php-melis.ini
COPY ./config/mysql.cnf /etc/mysql/conf.d/mysql.cnf
COPY ./config/site.conf /etc/apache2/sites-available/vhost.conf
COPY ./config/apache2.conf /etc/apache2/apache2.conf
COPY --chown=www-data:www-data ./ /var/www/${APP_NAME}

## SYMBOLIC LINKS
RUN ln -s  /var/www/${APP_NAME}/mnt/public/media /var/www/${APP_NAME}/public

## PERMISSIONS
RUN chown -R www-data:www-data /var/www/${APP_NAME} \
    && chmod -R +775 /var/www/${APP_NAME}/config \
    && chmod -R +775 /var/www/${APP_NAME}/cache \
    && chmod -R +777 /var/www/${APP_NAME}/public


## APACHE
RUN a2enmod rewrite \
    && a2enmod headers \
    && a2dissite 000-default.conf \
    && a2ensite vhost.conf

## EXPOSE
EXPOSE 80
