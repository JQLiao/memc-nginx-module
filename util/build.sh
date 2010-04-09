#!/bin/bash

# this file is mostly meant to be used by the author himself.

#ragel -I src -G2 src/ngx_http_memc_response.rl

if [ $? != 0 ]; then
    echo 'Failed to generate the memcached response parser.' 1>&2
    exit 1;
fi

root=`pwd`
cd ~/work
version=$1
opts=$2
home=~
lwp-mirror "http://sysoev.ru/nginx/nginx-$version.tar.gz" nginx-$version.tar.gz
tar -xzvf nginx-$version.tar.gz
cd nginx-$version/
if [[ "$BUILD_CLEAN" -eq 1 || ! -f Makefile || "$root/config" -nt Makefile || "$root/util/build.sh" -nt Makefile ]]; then
    ./configure --prefix=/opt/nginx \
          --with-http_addition_module \
          --add-module=$root/../echo-nginx-module \
          --add-module=$root $opts \
          --add-module=$root/../eval-nginx-module \
          --add-module=$home/work/nginx/ngx_http_upstream_keepalive-2ce9d8a1ca93 \
          --with-debug
          #--add-module=$home/work/nginx/nginx_upstream_hash-0.3 \
  #--without-http_ssi_module  # we cannot disable ssi because echo_location_async depends on it (i dunno why?!)

fi
if [ -f /opt/nginx/sbin/nginx ]; then
    rm -f /opt/nginx/sbin/nginx
fi
if [ -f /opt/nginx/logs/nginx.pid ]; then
    kill `cat /opt/nginx/logs/nginx.pid`
fi
make -j3
make install

