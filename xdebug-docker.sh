#!/bin/bash
# vim: fdm=marker ts=2 sw=2 sts=2 expandtab
set -eu

LOGDIR=/home/wwwlogs/xdebug

# install xdebug
wget https://xdebug.org/files/xdebug-2.4.0.tgz
tar xvf xdebug-2.4.0.tgz
cd xdebug-2.4.0
phpize
./configure && make && make install

# create xdebug logs dir
if [[ ! -d $LOGDIR ]]; then
  mkdir $LOGDIR
fi

# create xdebug conf file
cat << EOF > /etc/php.d/xdebug.ini
[xdebug]
; WARN: must use zend_extension, otherwise it will be failed.
zend_extension=xdebug.so
xdebug.remote_enable=1
; WARN: mac's docker work diff from linux, can not set to be 127.0.0.1
xdebug.remote_host=10.254.254.254
xdebug.remote_port=9000
xdebug.remote_connect_back=0
; TIPS: whether enable profiler for analyzing performance
xdebug.profiler_enable=0
xdebug.profiler_output_dir="$LOGDIR"
; WARN: important, the same setting from chrome xdeubg plugin
xdebug.idekey=PHPSTORM
; WARN: important, allow breakpoints with the remote debugger
xdebug.extended_info = 1
xdebug.remote_log="$LOGDIR/xdebug.log"
EOF

# restart php-fpm
ps aux | grep php-fpm.conf | grep -v color | awk '{print $2}' | xargs kill -USR2

