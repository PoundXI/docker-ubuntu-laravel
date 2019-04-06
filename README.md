# docker-ubuntu-laravel
Build a custom Ubuntu image for Laravel development.

## Image details
 - Set timezone to user specified argument
 - Enable bash color prompt
 - Make APT auto select mirrors
 - Install gnupg it's require for apt-key command
 - Install less command (easy to use than more command)
 - Install networking tools (net-tools + wget + curl)
 - Install development tools (git + zip)
 - Install screen manager
 - Install VIM editor with custom configuration file
 - Install LEMP Stack (Nginx + MariaDB + PHP) with PHP modules requires by Laravel
 - Install Redis server (caching & session server)
 - Install Composer (dependency manager for PHP)
 - Add startup.sh to run any services on container starts

## How to build image
 - Change args values in docker-compose.yml (Optional)
 - **host $** sudo docker-compose build

## How to run a container
**host $** sudo docker run -it -p <host_port>:80 -v <host_laravel_dir>/:/var/www/html/laravel --restart unless-stopped --name ubuntu-laravel poundxi/ubuntu-laravel

## How to detach from a container shell
Press Ctrl+P and then Ctrl+Q

## How to attach to a container shell
**host $** sudo docker attach ubuntu-laravel

## Install Laravel 5.5
**container #** /root/install-laravel.sh

## Access Laravel website
- Open Web Browser
- Enter URL : 127.0.0.1:<host_port>
