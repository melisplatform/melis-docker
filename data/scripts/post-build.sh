#!/bin/bash
cd / || exit 1
#echo "Setting up PhpMyAdmin..."
#tar -xzf /phpmyadmin511.tar.gz
#chown -R www-data:www-data /pma
echo "Setting up Melis..."
cd /usr/src/melisplatform/melis-platform-skeleton-master
composer install --no-scripts --no-dev
chown -R www-data:www-data /usr/src/melisplatform/melis-platform-skeleton-master
echo "Cleaning up..."