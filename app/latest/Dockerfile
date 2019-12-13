FROM melisplatform/melis-docker:dev-apache-7.1

RUN apt-get update && \
     apt-get install -y \
         zlib1g-dev \
         sudo \
         && docker-php-ext-install zip \
         && echo "www-data ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

RUN mkdir -p /usr/src/melisplatform && cd /usr/src/melisplatform \
    && curl -sS https://codeload.github.com/melisplatform/melis-cms-skeleton/zip/master -o melis-cms-skeleton.zip \
    && unzip melis-cms-skeleton.zip \
    && rm -r /var/www/html \
    && mv melis-cms-skeleton-master /var/www/html \
    && cd /var/www/html \
    && composer update --no-scripts --no-dev \
    && rm -r /usr/src/melisplatform

ADD ./setup /usr/local/bin/

CMD ["setup"]