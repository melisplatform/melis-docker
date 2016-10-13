FROM melisplatform/melis-docker:dev-apache-7.0

RUN mkdir -p /usr/src/melisplatform && cd /usr/src/melisplatform \
    && curl -sS https://codeload.github.com/melisplatform/melis-cms-skeleton/zip/master -o melis-cms-skeleton.zip \
    && unzip melis-cms-skeleton.zip \
    && rm -r /var/www/html \
    && mv melis-cms-skeleton-master /var/www/html \
    && cd /var/www/html \
    && composer update \
    && rm -r /usr/src/melisplatform

