# docker build -t melisplatform/melis-docker:dev-apache-7.3 .

# build it from root project
FROM php:7.3-apache

# Set default system timezone
RUN ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime

# Install last update and php extension
RUN apt-get update && apt-get install -y \
    git \
    vim \
    bzip2 \
    zip \
    libbz2-dev \
    libzip-dev \
    libmcrypt-dev \
    libicu-dev \
    zlib1g-dev \
    sudo \
    && docker-php-ext-configure mysqli \
    && docker-php-ext-install mysqli pdo_mysql bz2 intl

RUN pecl install mcrypt-1.0.3
RUN pecl install zip

RUN docker-php-ext-enable mcrypt && \
    docker-php-ext-enable zip
   
# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Enable Apache Rewrite module
RUN a2enmod rewrite \
    && a2enmod headers

# Install mysql client
RUN apt-get update && \
    apt-get -y install default-mysql-client

# Install composer
RUN curl -sS https://getcomposer.org/installer | php \
	&& mv composer.phar /usr/bin/composer

CMD ["apache2-foreground"]
