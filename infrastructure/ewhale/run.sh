#!/usr/bin/env bash
APP_ROOT="/var/www"
DATA_ROOT="/srv/app-data"

function info {
    printf "\033[0;36m===> \033[0;33m${1}\033[0m\n"
}

info "Fix ownership for /var/www/ /srv/app-data/"
chown -R www-data:www-data ${APP_ROOT} /srv/app-data/

# Check if the local usage
if [[ -z ${IS_LOCAL} ]]; then
    # Map environment variables
    info "Map parameters.yml to environment variables"
    composer-map-env.php ${APP_ROOT}/composer.json

    # Generate parameters.yml
    info "Run composer script 'post-install-cmd'"
    runuser -s /bin/sh -c "composer --no-interaction run-script post-install-cmd -n -d ${APP_ROOT}" www-data
fi

if [[ -z ${APP_DB_PORT} ]]; then
    if [[ "pdo_pgsql" = ${APP_DB_DRIVER} ]]; then
        APP_DB_PORT="5432"
    else
        APP_DB_PORT="3306"
    fi
fi

until nc -z ${APP_DB_HOST} ${APP_DB_PORT}; do
    info "Waiting database on ${APP_DB_HOST}:${APP_DB_PORT}"
    sleep 2
done

if [[ ! -z ${CMD_INIT_BEFORE} ]]; then
    info "Running pre init command: ${CMD_INIT_BEFORE}"
    sh -c "${CMD_INIT_BEFORE}"
fi

cd ${APP_ROOT}

# If already installed
if [[ -z ${APP_IS_INSTALLED} ]]
then
    if [[ ! -z ${CMD_INIT_CLEAN} ]]; then
        info "Running init command: ${CMD_INIT_CLEAN}"
        sh -c "${CMD_INIT_CLEAN}"
    fi
else
    info "Updating application..."
    if [[ -d ${APP_ROOT}/app/cache ]] && [[ $(ls -l ${APP_ROOT}/app/cache/ | grep -v total | wc -l) -gt 0 ]]; then
        rm -r ${APP_ROOT}/app/cache/*
    fi

    if [[ ! -z ${CMD_INIT_INSTALLED} ]]; then
        info "Running init command: ${CMD_INIT_INSTALLED}"
        sh -c "${CMD_INIT_INSTALLED}"
    fi

fi

if [[ ! -z ${CMD_INIT_AFTER} ]]; then
    info "Running post init command: ${CMD_INIT_AFTER}"
    sh -c "${CMD_INIT_AFTER}"
fi

if [ ! -d ${APP_ROOT}/app/import_export ]
then
    mkdir -p ${APP_ROOT}/app/import_export
fi

if ! grep -q 'aws_key' /var/www/app/config/parameters.yml; then

    sed -i 's/\(^.*native_file.*$\)/#\1/' /var/www/app/config/parameters.yml

    sed -i '/parameters/a \
    session_handler:    'snc_redis.session.handler' \
    redis_dsn_cache:    'redis://${REDIS_URL}:6379/0' \
    redis_dsn_session:  'redis://${REDIS_URL}:6379/1' \
    redis_dsn_doctrine: 'redis://${REDIS_URL}:6379/2' \
    aws_region: '${AWS_REGION}' \
    aws_key: '${AWS_KEY}'\
    aws_secret: '${AWS_SECRET} /var/www/app/config/parameters.yml

    sed -i '/\[opcache\]/a \
opcache.memory_consumption=512 \
opcache.validate_timestamps=0 \
opcache.interned_strings_buffer=16 \
opcache.max_accelerated_files=30000' /etc/php/7.0/fpm/php.ini

fi

sed -i "s/websocket_frontend_path\: .*$/websocket_frontend_path\: ${APP_WEBSOCKET_FRONTEND_PATH}/" /var/www/app/config/parameters.yml

sed -i "s/\$host/${APP_HOSTNAME}/g" /etc/nginx/sites-enabled/http.conf

# switch to https mode
if [ ${HTTPS_MODE} = true ]; then
    if [ ! -d /etc/letsencrypt/live ]
    then
        ssl_setup.sh ${APP_HOSTNAME}
    fi
fi

if [ ! -d /root/.aws ]
then
    mkdir /root/.aws
    cat > /root/.aws/credentials <<DELIM
[default]
aws_access_key_id = ${AWS_KEY}
aws_secret_access_key = ${AWS_SECRET}
DELIM
    cat > /root/.aws/config <<DELIM
[default]
output = json
region = ${AWS_REGION}
DELIM
fi
export PATH=~/.local/bin:$PATH
# get images from aws s3
if [ ! -d /var/www/web/media/cache ]
then
    aws s3 cp s3://ewhale-shop-prod-attachment-cache/attachment /var/www/app/attachment --recursive
    aws s3 cp s3://ewhale-shop-prod-attachment-cache/mediacache/attachment /var/www/web/media/cache/attachment --recursive

else
    aws s3 sync s3://ewhale-shop-prod-attachment-cache/attachment /var/www/app/attachment
    aws s3 sync s3://ewhale-shop-prod-attachment-cache/mediacache/attachment /var/www/web/media/cache/attachment
fi

echo '' > /var/www/src/MENA/Bundle/MENALoadDataBundle/Migrations/Data/ORM/data/products.csv
php /var/www/app/console oro:platform:update --force

##clear cache.
info "Rebuild cache"
rm -rf ${APP_ROOT}/app/cache/*
php ${APP_ROOT}/app/console cache:clear --env=prod -vvv
info "Fix ownership for /var/www/ /srv/app-data/"
chown -R www-data:www-data ${APP_ROOT} /srv/app-data/

# install cron job run every 6 hours
crontab -r
(crontab -l && echo "0 */6 * * * /usr/local/bin/aws_image_sync.sh") | crontab -
cron &

##clear entity config
#php ${APP_ROOT}/app/console oro:entity-extend:update-config

if [ ${IS_STAND_ALONE} = true ]; then
    # Starting services
    if php -r 'foreach(json_decode(file_get_contents("'${APP_ROOT}'/composer.lock"))->{"packages"} as $p) { echo $p->{"name"} . ":" . $p->{"version"} . PHP_EOL; };' | grep 'platform:2' > /dev/null
    then
      info "Starting supervisord for platform 2.x"
      exec /usr/local/bin/supervisord -n -c /etc/supervisord-2.x.conf
    else
      info "Starting supervisord for platform 1.x"
      exec /usr/local/bin/supervisord -n -c /etc/supervisord-1.x.conf
    fi

else
    while : ; do sleep 2; done
fi