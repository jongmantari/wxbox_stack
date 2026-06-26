#!/bin/bash
#
# ==============================================================================
# FV3-JEDI / Spack-Stack Build Environment Provisioning Script
# ==============================================================================
#
# Purpose:
#   Configure a Linux system for FV3-JEDI development using:
#     - GCC/GFortran 13
#     - Intel oneAPI 2025.3 toolchain
#     - Lua 5.1.4.9
#     - Lmod 8.7
#     - JCSDA Spack-Stack release 2.1
#
# Major Steps:
#   1. Update the operating system.
#   2. Install compiler and build dependencies.
#   3. Configure GCC 13 toolchain.
#   4. Install Intel oneAPI components.
#   5. Build and install Lua.
#   6. Build and install Lmod.
#   7. Configure modulefiles for Intel oneAPI.
#   8. Install and configure Spack-Stack.
#   9. Create FV3-JEDI environment.
#   10. Build the software stack.
#
# Notes:
#   - Intended to be run as root.
#   - Script exits immediately on errors.
#   - Existing spack-stack installation is removed and recreated.
#
# ==============================================================================

set -euo pipefail

# Disable interactive package installation prompts.
export DEBIAN_FRONTEND=noninteractive

###############################################################################
# Update Operating System
###############################################################################

# Refresh package metadata and apply available upgrades.
apt update
apt upgrade -y

###############################################################################
# Install Development Toolchain
###############################################################################

# Install GNU compilers and common build utilities.
apt install -y \
    build-essential \
    g++-13 \
    gcc-13 \
    gfortran-13 \
    make \
    cmake \
    automake \
    autoconf \
    apt-utils

###############################################################################
# Install Runtime and Development Dependencies
###############################################################################

# Install libraries and utilities required by:
#   - FV3-JEDI
#   - Spack
#   - Intel oneAPI
#   - Qt-based tools
#   - MySQL client development
#   - LLVM toolchain
apt install -y \
    cpp-13 \
    libgomp1 \
    git \
    git-lfs \
    autopoint \
    mysql-server \
    libmysqlclient-dev \
    qtbase5-dev \
    qt5-qmake \
    libqt5svg5-dev \
    qt5dxcb-plugin \
    wget \
    curl \
    file \
    tcl-dev \
    gnupg2 \
    iproute2 \
    locales \
    unzip \
    less \
    bzip2 \
    gettext \
    libtree \
    pkg-config \
    libcurl4-openssl-dev \
    mysql-server \
    libtool \
    flex \
    llvm-14

###############################################################################
# Configure LLVM
###############################################################################

# Make LLVM 14 available through llvm-config.
update-alternatives --install \
    /usr/bin/llvm-config \
    llvm-config \
    /usr/bin/llvm-config-14 \
    10

###############################################################################
# Python Development Environment
###############################################################################

# Install Python and common build packages required by Spack.
apt install -y \
    python3 \
    python3-pip \
    python3-setuptools

###############################################################################
# Git Configuration
###############################################################################

# Cache credentials for one hour to reduce repeated authentication prompts.
git config --global credential.helper 'cache --timeout=3600'

# Enable Git LFS support.
git lfs install

###############################################################################
# Configure GNU Compiler Alternatives
###############################################################################

# Register GCC 13 toolchain as the preferred compiler suite.
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-13 100
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-13 100
update-alternatives --install /usr/bin/gfortran gfortran /usr/bin/gfortran-13 100

###############################################################################
# Intel oneAPI Repository Setup
###############################################################################

# Import Intel signing key.
wget -O- \
    https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
    | gpg --dearmor \
    | tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null

# Register Intel oneAPI package repository.
echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] https://apt.repos.intel.com/oneapi all main" \
    | tee /etc/apt/sources.list.d/oneAPI.list

apt update

###############################################################################
# Install Intel oneAPI Components
###############################################################################

# Install:
#   - DPC++/C++ compiler
#   - Fortran compiler
#   - MPI
#   - TBB
#   - MKL
apt install -y \
    intel-oneapi-compiler-dpcpp-cpp-2025.3 \
    intel-oneapi-compiler-fortran-2025.3 \
    intel-oneapi-mpi-devel-2021.17 \
    intel-oneapi-tbb-devel-2022.3 \
    intel-oneapi-mkl-devel-2025.3

###############################################################################
# Build and Install Lua 5.1.4.9
###############################################################################

# Newer Lua installation required for modern Spack-generated modulefiles.
mkdir -p /opt/lua/5.1.4.9/src && cd $_

wget https://sourceforge.net/projects/lmod/files/lua-5.1.4.9.tar.bz2
tar -xvf lua-5.1.4.9.tar.bz2

cd lua-5.1.4.9

./configure --prefix=/opt/lua/5.1.4.9 \
    2>&1 | tee log.config

make VERBOSE=1 \
    2>&1 | tee log.make

make install \
    2>&1 | tee log.install

###############################################################################
# Configure Lua Environment
###############################################################################

cat > /etc/profile.d/02-lua.sh <<'EOF'
# Lua environment variables

export PATH="/opt/lua/5.1.4.9/bin:${PATH}"
export LD_LIBRARY_PATH="/opt/lua/5.1.4.9/lib:${LD_LIBRARY_PATH:-}"
export CPATH="/opt/lua/5.1.4.9/include:${CPATH:-}"
export MANPATH="/opt/lua/5.1.4.9/man:${MANPATH:-}"
EOF

###############################################################################
# Install Lmod 8.7
###############################################################################

mkdir -p /opt/lmod/8.7/src
cd /opt/lmod/8.7/src

wget https://sourceforge.net/projects/lmod/files/Lmod-8.7.tar.bz2
tar -xvf Lmod-8.7.tar.bz2

cd Lmod-8.7

./configure \
    --prefix=/opt/ \
    --with-lmodConfigDir=/opt/lmod/8.7/config \
    2>&1 | tee log.config

make install \
    2>&1 | tee log.install

###############################################################################
# Configure Lmod Startup Scripts
###############################################################################

ln -sf /opt/lmod/lmod/init/profile      /etc/profile.d/z00_lmod.sh
ln -sf /opt/lmod/lmod/init/cshrc        /etc/profile.d/z00_lmod.csh
ln -sf /opt/lmod/lmod/init/profile.fish /etc/profile.d/z00_lmod.fish

###############################################################################
# Initialize Lua and Lmod
###############################################################################

source /etc/profile.d/02-lua.sh
source /etc/profile.d/z00_lmod.sh

# Verify successful installation.
lua -v
module --version

###############################################################################
# Configure Intel oneAPI Modulefiles
###############################################################################

if [ -d "/opt/intel/oneapi/modulefiles" ]; then
    rm -rf /opt/intel/oneapi/modulefiles
fi

/opt/intel/oneapi/modulefiles-setup.sh \
    --output-dir=/opt/intel/oneapi/modulefiles

###############################################################################
# Persist Intel Modulefile Path
###############################################################################

cat << 'EOF' >> /etc/profile.d/z01_lmod.sh
module use /opt/intel/oneapi/modulefiles
EOF

###############################################################################
# Create Meta-Module for oneAPI Environment
###############################################################################

mkdir -p /opt/intel/oneapi/modulefiles/intel-oneapi-full-env

cat > /opt/intel/oneapi/modulefiles/intel-oneapi-full-env/2025.3.0 <<'EOF'
#%Module1.0

proc ModulesHelp { } {
    puts stderr "intel-oneapi-full-env defines the entire module set used for spack-stack intel builds"
}

module-whatis "intel-oneapi-full-env defines the entire module set used for spack-stack intel builds"

module load umf/latest
module load tbb/latest
module load compiler-rt/latest
module load compiler/latest
module load compiler-intel-llvm/latest
module load mkl/latest
EOF

#install Intel OneAPI Spack-Stack Environment
#module load intel-oneapi-full-env/2025.3.0
#export FC=ifx
#export CXX=icpx
#export CC=icx

###############################################################################
# Install Spack-Stack Release 2.1
###############################################################################

cd /opt

if [ -d "spack-stack" ]; then
    rm -rf spack-stack
fi

git clone \
    -b release/2.1 \
    --depth 1 \
    --recursive \
    https://github.com/jcsda/spack-stack.git

cd /opt/spack-stack

source ./setup.sh

###############################################################################
# Create FV3-JEDI Environment
###############################################################################

module purge
unset SPACK_ENV

spack stack create env \
    --site linux.default \
    --name fv3jedi-2.1 \
    --compiler gcc

cd /opt/spack-stack/envs/fv3jedi-2.1

spack env activate .

###############################################################################
# Add FV3-JEDI Bundle
###############################################################################

spack add jedi-fv3-env

###############################################################################
# Resolve Dependencies
###############################################################################

spack concretize --force

###############################################################################
# Diagnostics
###############################################################################

echo "===== MODULES ====="
module list

echo "===== COMPILERS ====="
which gcc
which g++
which gfortran
which clang-tidy || true

env | egrep '^(CC|CXX|FC)=' || true

###############################################################################
# Build Software Stack
###############################################################################

spack install --fail-fast -j 8

###############################################################################
# Generate Modulefiles
###############################################################################

spack module lmod refresh -y

spack stack setup-meta-modules

###############################################################################
# Load Final Environment
###############################################################################

module use /opt/spack-stack/envs/fv3jedi-2.1/modules/Core

module load stack-gcc/13.3.0
module load stack-openmpi/5.0.8
module load jedi-fv3-env/1.0.0

###############################################################################
# Completed Successfully
###############################################################################

echo "FV3-JEDI environment installation completed successfully."
