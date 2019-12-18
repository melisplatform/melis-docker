
# Dockerfile Melis Platform
ARG tag
FROM melisplatform/melis-docker:${tag}

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