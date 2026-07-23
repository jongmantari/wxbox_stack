#!/bin/bash
set -euo pipefail

export PATH=/opt/lua/bin:$PATH
export LD_LIBRARY_PATH=/opt/lua/lib:${LD_LIBRARY_PATH:-}

echo "===== LUA CHECK ====="

which lua
which luac

lua -v

###############################################################################
# Download
###############################################################################

mkdir -p /opt/lmod/src
cd /opt/lmod/src

curl -L \
  --retry 10 \
  --retry-delay 10 \
  --connect-timeout 30 \
  -o Lmod-8.7.tar.bz2 \
  https://sourceforge.net/projects/lmod/files/Lmod-8.7.tar.bz2/download

tar -xjf Lmod-8.7.tar.bz2

cd Lmod-8.7

###############################################################################
# Configure
###############################################################################

./configure \
    --prefix=/opt \
    --with-lua=/opt/lua/bin/lua \
    --with-luac=/opt/lua/bin/luac \
    --with-lmodConfigDir=/opt/lmod/config

###############################################################################
# Build
###############################################################################

make -j"$(nproc)"

###############################################################################
# Install
###############################################################################

make install

###############################################################################
# Verify
###############################################################################

test -f /opt/lmod/lmod/init/profile

echo "Lmod installation successful"
