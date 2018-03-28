#!/usr/bin/env bash
# https://github.com/phpv8/v8js/blob/php7/README.Linux.md

# Install required dependencies
sudo apt-get install build-essential curl git python libglib2.0-dev

cd /tmp

# Install depot_tools first (needed for source checkout)
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH=`pwd`/depot_tools:"$PATH"

# Download v8
fetch v8
cd v8

# (optional) If you'd like to build a certain version:
git checkout 5.6.326.12
gclient sync

# Setup GN
tools/dev/v8gen.py -vv x64.release -- is_component_build=true

# Build
ninja -C out.gn/x64.release/

# Install to /opt/v8/
sudo mkdir -p /opt/v8/{lib,include}
sudo cp out.gn/x64.release/lib*.so out.gn/x64.release/*_blob.bin \
	  out.gn/x64.release/icudtl.dat /opt/v8/lib/
sudo cp -R include/* /opt/v8/include/

# Copy to x86_64-linux-gnu libs
sudo cp /opt/v8/lib/lib*.so /usr/lib/x86_64-linux-gnu/
