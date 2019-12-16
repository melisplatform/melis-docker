
# Dockerfile Melis Platform
FROM melisplatform/melis-docker:dev-apache-7.1

# Installing dependencies
RUN apt-get update && apt-get install -y \
    zlib1g-dev \
    sudo

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Installing extensions
RUN docker-php-ext-install zip

# Installing Melis Platform Skeleton
RUN mkdir -p /usr/src/melisplatform && cd /usr/src/melisplatform \
    && curl -sS https://codeload.github.com/melisplatform/melis-cms-skeleton/zip/master -o melis-cms-skeleton.zip \
    && unzip melis-cms-skeleton.zip \
    && rm -r /var/www/html \
    && mv melis-cms-skeleton-master /var/www/html \
    && cd /var/www/html \
    && composer update --no-scripts --no-dev \
    && rm -r /usr/src/melisplatform

# Change permissions
RUN echo "www-data ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
ADD ./setup /usr/local/bin/
CMD ["setup"]