#!/usr/bin/env bash

cd /var/www/html
composer create-project --prefer-dist laravel/laravel laravel "5.5.*"
chgrp -R www-data laravel/storage laravel/bootstrap/cache
chmod -R ug+rwx laravel/storage laravel/bootstrap/cache
