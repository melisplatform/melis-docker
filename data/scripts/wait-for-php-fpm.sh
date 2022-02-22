#!/bin/sh
sh -c 'wait-for php-fpm:9000 -t 300 -- echo "PHP FPM is ready!"'