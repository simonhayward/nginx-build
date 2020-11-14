#!/bin/bash
set -exu

NGINX_DIR=/opt/nginx
NGINX_SRC=${NGINX_DIR}/src
NGINX_USER=nginx
NGINX_GROUP=nginx

mkdir -p ${NGINX_SRC}

# pagespeed
cd ${NGINX_SRC}
wget https://github.com/apache/incubator-pagespeed-ngx/archive/v${NPS_VERSION}.zip
unzip v${NPS_VERSION}.zip
NPS_DIR=$(find . -name "*pagespeed-ngx-${NPS_VERSION}" -type d)
cd ${NPS_DIR}
NPS_RELEASE_NUMBER=${NPS_VERSION/beta/}
NPS_RELEASE_NUMBER=${NPS_VERSION/stable/}
psol_url=https://dl.google.com/dl/page-speed/psol/${NPS_RELEASE_NUMBER}.tar.gz
[ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL)
wget ${psol_url}
tar -xzvf $(basename ${psol_url})

# nginx
cd ${NGINX_SRC}
wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
tar -xvzf nginx-${NGINX_VERSION}.tar.gz
cd nginx-${NGINX_VERSION}
./configure --prefix=${NGINX_DIR}/compiled/${NGINX_VERSION} --user=${NGINX_USER} --group=${NGINX_GROUP} --with-http_ssl_module --with-http_stub_status_module --add-module=${NGINX_SRC}/${NPS_DIR} --with-http_v2_module
make && make install