#!/bin/bash
set -e

mkdir -p /opt/lmod/src

cd /opt/lmod/src

wget https://sourceforge.net/projects/lmod/files/Lmod-8.7.tar.bz2

tar -xjf Lmod-8.7.tar.bz2

cd Lmod-8.7

./configure \
  --prefix=/opt/lmod \
  --with-lua=/opt/lua

make install
