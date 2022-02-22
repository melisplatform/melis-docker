#!/bin/sh
sh -c 'wait-for redis:6379 -t 300 -- echo "Redis is ready!"'
sh -c 'wait-for db:3306 -t 300 -- echo "MariaDb is ready!"'