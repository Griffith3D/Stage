#!/usr/bin/env bash
# https://github.com/phpv8/v8js/blob/php7/README.Linux.md

cd /tmp
git clone https://github.com/phpv8/v8js.git
cd v8js
phpize
./configure --with-v8js=/opt/v8 LDFLAGS="-lstdc++"
make
make test
sudo make install
