#!/bin/bash
set -exu

NGINX_DIR=/opt/nginx
NGINX_SRC=${NGINX_DIR}/src
NGINX_USER=nginx
NGINX_GROUP=nginx

mkdir -p ${NGINX_SRC}

# modsecurity
cd ${NGINX_SRC}
git clone https://github.com/owasp-modsecurity/ModSecurity
cd ModSecurity/
git submodule init
git submodule update
sh build.sh
./configure
make && sudo make install

cd ${NGINX_SRC}
git clone --depth 1 https://github.com/owasp-modsecurity/ModSecurity-nginx.git

# pagespeed
cd ${NGINX_SRC}
wget https://github.com/apache/incubator-pagespeed-ngx/archive/${NPS_COMMIT}.zip
unzip ${NPS_COMMIT}.zip
NPS_DIR=$(find . -name "*pagespeed-ngx-${NPS_COMMIT}" -type d)
cd ${NPS_DIR}
wget http://www.tiredofit.nl/psol-${PSOL}.tar.xz
tar xvf psol-${PSOL}.tar.xz

# nginx
cd ${NGINX_SRC}
wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
tar -xvzf nginx-${NGINX_VERSION}.tar.gz
cd nginx-${NGINX_VERSION}
./configure --prefix=${NGINX_DIR}/compiled/${NGINX_VERSION} --user=${NGINX_USER} --group=${NGINX_GROUP} --with-http_ssl_module --with-http_stub_status_module --add-module=${NGINX_SRC}/${NPS_DIR} --with-http_v2_module --with-http_v3_module --with-debug --with-http_realip_module --with-compat --add-dynamic-module=${NGINX_SRC}/ModSecurity-nginx
make && make install

cp -r /usr/local/modsecurity ${NGINX_DIR}/compiled/${NGINX_VERSION}