#!/bin/bash
set -e

mkdir -p /opt/lua/src

cd /opt/lua/src

wget https://sourceforge.net/projects/lmod/files/lua-5.1.4.9.tar.bz2

tar -xjf lua-5.1.4.9.tar.bz2

cd lua-5.1.4.9

./configure --prefix=/opt/lua

make -j$(nproc)

make install
