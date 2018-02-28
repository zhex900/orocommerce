FROM zhex900/nginx_pagespeed

COPY ["setup.sh", "configure.sh", "/opt/bin/"]

RUN /bin/bash /opt/bin/setup.sh
RUN /bin/bash /opt/bin/configure.sh

COPY ["bin/*", "/usr/local/bin/"]

RUN chmod +x /usr/local/bin/*
