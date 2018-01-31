FROM zhex900/ewhale:base

COPY run.sh /usr/local/bin/

RUN cd /var/www/ && \
    composer require aws/aws-sdk-php -vvv && \
    sed -i s/"#- { resource: aws_s3.yml }/- { resource: aws_s3.yml }"/g /var/www/app/config/config.yml &&\
    git clone https://github.com/zhex900/ewhale.git && \
    cp -r ewhale/MENA src && \
    cp -r ewhale/.git src && \
   # app/console oro:platform:update --force && \
   # app/console cache:clear --env=prod -vvv && \
   # chown -R www-data:www-data /var/www /srv/app-data/

