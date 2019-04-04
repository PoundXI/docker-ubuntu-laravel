#!/usr/bin/env bash

# FILE PATH : /root/startup.sh
# Start LEMP Service
service mysql start > /dev/null 2>&1
service php7.3-fpm start > /dev/null 2>&1
service nginx start > /dev/null 2>&1

# Start Redis Service for Laravel Cache and Session
service redis-server start > /dev/null 2>&1
