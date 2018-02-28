FROM zhex900/orocommerce

COPY run.sh /usr/local/bin/
COPY ssl_setup.sh /usr/local/bin/
COPY aws_image_sync.sh /usr/local/bin/
COPY https.conf /etc/nginx/sites-available/ssl_https.conf
COPY http.conf /etc/nginx/sites-available/ssl_http.conf
COPY supervisord-web-services.conf /etc/supervisord-web-services.conf

RUN     chmod +x /usr/local/bin/ssl_setup.sh && \
        chmod +x /usr/local/bin/aws_image_sync.sh && \
        rm -rf /var/www/src && \
        git clone https://github.com/zhex900/ewhale.git -b master --single-branch /var/www/src && \
        rm -rf /var/www/src/MENA/Bundle/MENALoadDataBundle && \
        chown -R www-data:www-data /var/www/ /srv/app-data/ && \
        php /var/www/app/console cache:clear --env=prod -vvv && \
        php /var/www/app/console oro:platform:update --force
