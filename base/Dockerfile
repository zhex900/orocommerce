FROM zhex900/orobase

COPY bin/run.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/run.sh

COPY conf/aws_s3.yml          /etc/aws_s3.yml
COPY conf/nginx.conf          /etc/nginx/nginx.conf
COPY conf/http.conf      /etc/nginx/sites-enabled/http.conf
COPY ["conf/supervisord-1.x.conf", "conf/supervisord-2.x.conf", "/etc/"] 

EXPOSE 443 80

# HTTPS or SSH
# If you want to use ssh don't forget to provide ssh key via build arg directive
ARG GIT_URI="https://github.com/orocommerce/orocommerce-application.git"

# branch name or tag 
ARG GIT_REF="1.5"

COPY bin/install-application.sh          /usr/local/bin/install-application.sh

RUN install-application.sh

CMD ["run.sh"]

