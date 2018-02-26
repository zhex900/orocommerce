FROM zhex900/orocommerce

COPY run.sh /usr/local/bin/
COPY ssl_setup.sh /usr/local/bin/
COPY aws_image_sync.sh /usr/local/bin/
COPY https.conf /etc/nginx/sites-available/ssl_https.conf
COPY http.conf /etc/nginx/sites-available/ssl_http.conf

RUN     chmod +x /usr/local/bin/ssl_setup.sh && \
        chmod +x /usr/local/bin/aws_image_sync.sh && \
        sed -i s/"#- { resource: aws_s3.yml }/- { resource: aws_s3.yml }"/g /var/www/app/config/config.yml &&\
        rm -rf /var/www/src && \
        git clone https://github.com/zhex900/ewhale.git -b master --single-branch /var/www/src
