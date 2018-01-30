#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive
export COMPOSER_PROCESS_TIMEOUT=3600

APP_DIR=/var/www

function info {
    printf "\033[0;36m${1}\033[0m \n"
}
function note {
    printf "\033[0;33m${1}\033[0m \n"
}
function success {
    printf "\033[0;32m${1}\033[0m \n"
}
function warning {
    printf "\033[0;95m${1}\033[0m \n"
}
function error {
    printf "\033[0;31m${1}\033[0m \n"
    exit 1
}

cd /var

rm -rf /var/www

git clone -b ${GIT_REF} ${GIT_URI}

mv orocommerce-application www

# Fix for wrong file system check
sed -i -e "s/return \$fileLength == 255;/return \$fileLength > 200;/g" ${APP_DIR}/app/OroRequirements.php

# If is composer application
if [[ -f ${APP_DIR}/composer.json ]]; then

    sed -i '/require/a \
    "aws\/aws-sdk-php":"3.*",' /var/www/composer.json

    if [[ ! -f ${APP_DIR}/composer.lock ]]; then
        composer update --no-interaction --lock -d ${APP_DIR} || error "Can't update lock file"
    fi
	composer global require "fxp/composer-asset-plugin:~1.3.1"
	composer require "aws/aws-sdk-php:3.*"
    composer install --dev --no-interaction --prefer-dist --optimize-autoloader -d ${APP_DIR} || error "Can't install dependencies"
else
    error "${APP_DIR}/composer.json not found!"
fi

# Change timezone to Asia/Dubai
rm /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Dubai /etc/localtime

rm -rf /tmp/*
rm -rf ~/.ssh
#rm -rf ~/.composer