FROM zhex900/nginx-pagespeed

COPY ["setup.sh", "configure.sh", "/opt/bin/"]

RUN apt-get update && apt-get install -y locales
RUN /bin/bash /opt/bin/setup.sh
RUN /bin/bash /opt/bin/configure.sh

COPY ["bin/*", "/usr/local/bin/"]

RUN chmod +x /usr/local/bin/*
