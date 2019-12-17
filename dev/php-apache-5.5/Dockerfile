# docker build -t melisplatform/melis-docker:dev-apache-5.5 -f dev/php-apache-5.5/Dockerfile .
# build from root project
FROM php:5.5-apache

# Set default system timezone
RUN ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime

# Install last update and php extension
RUN apt-get update && apt-get install -y \
    git \
    vim \
    bzip2 \
    zip \
    libbz2-dev \
    libmcrypt-dev \
    libicu-dev \
    zlib1g-dev \
    sudo \
    && docker-php-ext-configure mysqli \
    && docker-php-ext-install mysqli pdo_mysql bz2 mcrypt intl zip

# Enable Apache Rewrite module & headers
RUN a2enmod rewrite && \
    a2enmod headers

#Install mysql client
RUN apt-get update && \
    apt-get -qq install mysql-client 


# Copy source file
COPY dev/php-apache-5.5/src /var/www/html/public
#Install composer
RUN curl -sS https://getcomposer.org/installer | php \
	&& mv composer.phar /usr/bin/composer

CMD ["apache2-foreground"]
