# (c) Copyright 2019, Pongsakorn Ritrugsa <poundxi@protonmail.com>
# This project is licensed under the terms of the MIT license.

# Build a custom Ubuntu image for Laravel development.
# Image details:
#   - Set timezone to user specified argument
#   - Enable bash color prompt
#   - Make APT auto select mirrors
#   - Install gnupg it's require for apt-key command
#   - Install less command (easy to use than more command)
#   - Install networking tools (wget + curl)
#   - Install development tools (git + zip)
#   - Install VIM editor with custom configuration file
#   - Install LEMP Stack (Nginx + MariaDB + PHP) with PHP modules requires by Laravel
#   - Install Redis server (caching & session server)
#   - Install Composer (dependency manager for PHP)
#   - Add install-laravel.sh to install Laravel manually after run container
#   - Add startup.sh to run any services on container starts

FROM ubuntu:18.04
MAINTAINER Pongsakorn Ritrugsa <poundxi@protonmail.com>

ARG DEBIAN_FRONTEND=noninteractive
ARG ubuntu_timezone
ARG php_version
ARG mariadb_repo_url
ARG mariadb_root_passwd

#===============================================================================
# [ Basic Setup ]
#===============================================================================
RUN \
    # Set timezone to user specified argument
    echo $ubuntu_timezone > /etc/timezone ; cat /etc/timezone ; \
    # Enable bash color prompt
    sed -i 's/#.\?force_color_prompt/force_color_prompt/g' /root/.bashrc ; \
    # Make APT auto select mirrors
    sed -i 's/http:\/\/archive.ubuntu.com\/ubuntu\//mirror:\/\/mirrors.ubuntu.com\/mirrors.txt/g' /etc/apt/sources.list ; \
    # Install gnupg command (requires by apt-key command)
    apt update && apt install -y gnupg ; \
    # Clean retrieved package files and remove no longer needed packages
    apt clean -y && apt autoremove -y

#===============================================================================
# [ Add repositories ]
#===============================================================================
RUN \
    # Add Nginx repository
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 00A6F0A3C300EE8C ; \
    echo "deb http://ppa.launchpad.net/nginx/stable/ubuntu bionic main " >> /etc/apt/sources.list ; \
    # Add MariaDB repository
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8 ; \
    echo "deb [arch=amd64,i386,ppc64el] $mariadb_repo_url bionic main" >> /etc/apt/sources.list ; \
    # Add PHP repository
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C ; \
    echo "deb http://ppa.launchpad.net/ondrej/php/ubuntu bionic main" >> /etc/apt/sources.list ; \
    # Update APT index
    apt update

#===============================================================================
# [ Install packages and tools ]
#===============================================================================
RUN \
    # Make MariaDB not prompt for password while installing
    echo "mariadb-server mysql-server/root_password password $mariadb_root_passwd" | debconf-set-selections ; \
    echo "mariadb-server mysql-server/root_password_again password $mariadb_root_passwd" | debconf-set-selections ; \
    # Install packages
    apt install -y \
    # Install less command
    less \
    # Install networking tools
    wget curl \
    # Install development tools
    vim git zip \
    # Install LEMP Stack (Nginx + MariaDB + PHP)
    nginx mariadb-server php${php_version}-fpm php${php_version}-mysql \
    # Install PHP modules requires by laravel
    php${php_version}-mbstring php${php_version}-xml \
    # Install Redis server (caching & session server)
    redis-server ; \
    # Clean retrieved package files and remove no longer needed packages
    apt clean -y && apt autoremove -y

# Install Composer (dependency manager for PHP)
RUN wget https://raw.githubusercontent.com/composer/getcomposer.org/master/web/installer -O - -q | \
    php -- --install-dir /usr/local/bin/ --filename=composer --quiet ; \
    chmod +x /usr/local/bin/composer

#===============================================================================
# [ Config Nginx and PHP ]
#===============================================================================
# Copy Nginx config file for Laravel to the container
COPY ["data/nginx-laravel.conf", "/etc/nginx/sites-available/laravel"]

RUN \
    # Correct php version for unix socket in Nginx config file for Laravel
    sed -i "s/##php_version##/$php_version/g" /etc/nginx/sites-available/laravel ; \
    # Disable Nginx default site
    rm /etc/nginx/sites-enabled/default ; \
    # Enable Laravel site
    ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/laravel ; \
    # Make PHP not execute foo.jpg if it contains PHP script
    sed -i 's/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g' /etc/php/$php_version/fpm/php.ini

#===============================================================================
# [ Install VIM and custom config file ]
#===============================================================================
# Copy custom config file to the container
COPY ["data/.vimrc", "/root/.vimrc"]

RUN \
    # Make VIM as default editor
    echo 'SELECTED_EDITOR="/usr/bin/vi"' > /root/.selected_editor ; \
    # Install Nginx syntax for VIM
    mkdir -p /root/.vim ; \
    echo "au BufRead,BufNewFile /etc/nginx/*,/usr/local/nginx/conf/* if &ft == '' | setfiletype nginx | endif" >> /root/.vim/filetype.vim ; \
    mkdir -p /root/.vim/syntax ; \
    wget https://raw.githubusercontent.com/vim-scripts/nginx.vim/master/syntax/nginx.vim -O /root/.vim/syntax/nginx.vim

#===============================================================================
# [ Add install-laravel.sh to install Laravel manually after run container ]
#===============================================================================
# Copy install-laravel.sh script to the container and make it executable
COPY ["data/install-laravel.sh", "/root/install-laravel.sh"]
RUN chmod +x /root/install-laravel.sh

#===============================================================================
# [ Add startup.sh to run any services on container starts ]
#===============================================================================
# Copy startup.sh to the container and make it executable
COPY ["data/startup.sh", "/root/startup.sh"]
RUN chmod +x /root/startup.sh

# Run startup script and exit to bash everytimes while container starts.
CMD /root/startup.sh; /bin/bash
