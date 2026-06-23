#!/bin/bash
set -euo pipefail

###############################################
# 0. CLEAN OLD INTEL REPOS (IMPORTANT)
###############################################
rm -f /etc/apt/sources.list.d/intel-*.list
rm -f /etc/apt/sources.list.d/oneAPI.list
rm -f /usr/share/keyrings/oneapi-archive-keyring.gpg
rm -f /usr/share/keyrings/oneapi.gpg

###############################################
# 1. BASE DIRECTORIES
###############################################
mkdir -p /opt/build /opt/dist
mkdir -p /opt/modulefiles/intel-oneapi
mkdir -p /opt/modulefiles/intel-oneapi-mpi
mkdir -p /opt/modulefiles/rocoto

###############################################
# 2. SYSTEM PACKAGES
###############################################
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get upgrade -y

apt-get install -y \
  gcc g++ gfortran gdb build-essential \
  libkrb5-dev m4 git git-lfs bzip2 unzip \
  automake autopoint gettext texlive \
  libcurl4-openssl-dev libssl-dev \
  lua5.3 liblua5.3-dev lua-posix \
  tcl tcl-dev tcl8.6 tcl8.6-dev \
  python3 python3-pip python3-venv \
  emacs-nox

git lfs install

###############################################
# 3. INSTALL INTEL ONEAPI 2024.2 (NO VERSION PINNING)
###############################################
wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
  | gpg --dearmor | tee /usr/share/keyrings/oneapi.gpg >/dev/null

echo "deb [signed-by=/usr/share/keyrings/oneapi.gpg] https://apt.repos.intel.com/oneapi all main" \
  > /etc/apt/sources.list.d/oneAPI.list

apt-get update -y

# Install full toolchains (safe, stable, future-proof)
apt-get install -y \
  intel-basekit \
  intel-hpckit

# Load oneAPI environment
set +u
source /opt/intel/oneapi/setvars.sh
set -u

###############################################
# 4. INSTALL CMAKE 3.27.9
###############################################
cd /opt/build
curl -LO https://github.com/Kitware/CMake/releases/download/v3.27.9/cmake-3.27.9-linux-x86_64.sh
bash cmake-3.27.9-linux-x86_64.sh --prefix=/usr/local --skip-license

###############################################
# 5. INSTALL LMOD 8.7
###############################################
cd /opt/build
wget https://sourceforge.net/projects/lmod/files/Lmod-8.7.tar.bz2
tar xjf Lmod-8.7.tar.bz2
cd Lmod-8.7

./configure --prefix=/usr/share
make
make install

ln -sf /usr/share/lmod/lmod/init/profile /etc/profile.d/z00_lmod.sh

echo "dash dash/sh boolean false" | debconf-set-selections
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

source /etc/profile.d/z00_lmod.sh || true

###############################################
# 6. MODULEFILES FOR ONEAPI (OPTIONAL BUT USEFUL)
###############################################
cat >/opt/modulefiles/intel-oneapi/2024.2.1.lua <<'EOF'
help("Intel oneAPI 2024.2.1")
prepend_path("PATH", "/opt/intel/oneapi/compiler/latest/linux/bin")
prepend_path("PATH", "/opt/intel/oneapi/mpi/latest/bin")
prepend_path("LD_LIBRARY_PATH", "/opt/intel/oneapi/compiler/latest/linux/lib")
prepend_path("LD_LIBRARY_PATH", "/opt/intel/oneapi/mpi/latest/lib")
setenv("CC", "icx")
setenv("CXX", "icpx")
setenv("FC", "ifx")
EOF

###############################################
# DONE
###############################################
echo "[AMI] Base system ready for Spack-Stack 1.9.3 + FV3-JEDI toolchain"
