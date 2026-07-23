#!/bin/bash
set -euo pipefail

mkdir -p /opt/lua/src
cd /opt/lua/src

###############################################################################
# Download
###############################################################################

curl -L \
  --retry 10 \
  --retry-delay 10 \
  --connect-timeout 30 \
  -o lua-5.1.4.9.tar.bz2 \
  https://sourceforge.net/projects/lmod/files/lua-5.1.4.9.tar.bz2/download

###############################################################################
# Build
###############################################################################

tar -xjf lua-5.1.4.9.tar.bz2

cd lua-5.1.4.9

./configure --prefix=/opt/lua

make -j"$(nproc)"

make install

###############################################################################
# Verify
###############################################################################

export PATH=/opt/lua/bin:$PATH

echo "===== LUA CHECK ====="

which lua
which luac

lua -v

###############################################################################
# Verify required modules
###############################################################################

lua -e "require('posix')"
lua -e "require('lfs')"
lua -e "require('lpeg')"

echo "Lua installation successful"
