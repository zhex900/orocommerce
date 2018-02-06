FROM zhex900/ewhale:base

COPY run.sh /usr/local/bin/
#COPY ssl_setup.sh /usr/local/bin/
#
#COPY https.conf /etc/nginx/sites-available/https.conf
#COPY http.conf /etc/nginx/sites-available/http.conf

RUN     apt-get update && \
        apt-get install -y python-pip python-certbot-nginx&& \
        pip install awscli --upgrade --user && \
        export PATH=~/.local/bin:$PATH && \
        cd /var/www/ && \
        composer require aws/aws-sdk-php -vvv && \
        sed -i s/"#- { resource: aws_s3.yml }/- { resource: aws_s3.yml }"/g /var/www/app/config/config.yml &&\
        git clone https://github.com/zhex900/ewhale.git && \
        cp -r ewhale/MENA src && \
        cp -r ewhale/.git src

   # app/console oro:platform:update --force && \
   # app/console cache:clear --env=prod -vvv && \
   # chown -R www-data:www-data /var/www /srv/app-data/

# aws s3 cp s3://ewhale-shop-prod-attachment-cache/attachment /var/www/app/attachment --recursive
# aws s3 cp s3://ewhale-shop-prod-attachment-cache/mediacache /var/www/web/media --recursive
#deb http://us.archive.ubuntu.com/ubuntu/ xenial main restricted
#deb-src http://us.archive.ubuntu.com/ubuntu/ xenial main restricted
#deb http://us.archive.ubuntu.com/ubuntu/ xenial universe
#deb-src http://us.archive.ubuntu.com/ubuntu/ xenial universe
#deb http://us.archive.ubuntu.com/ubuntu/ xenial-security main restricted
#deb-src http://us.archive.ubuntu.com/ubuntu/ xenial-security main restricted
#deb http://us.archive.ubuntu.com/ubuntu/ xenial-security universe
#deb-src http://us.archive.ubuntu.com/ubuntu/ xenial-security universe
#deb http://us.archive.ubuntu.com/ubuntu/ xenial-updates main restricted
#deb-src http://us.archive.ubuntu.com/ubuntu/ xenial-updates main restricted
#deb http://us.archive.ubuntu.com/ubuntu/ xenial universe
#deb-src http://us.archive.ubuntu.com/ubuntu/ xenial universe
#deb http://us.archive.ubuntu.com/ubuntu/ xenial-updates universe
#deb-src http://us.archive.ubuntu.com/ubuntu/ xenial-updates universe
