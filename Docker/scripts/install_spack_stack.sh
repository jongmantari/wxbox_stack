#!/bin/bash
set -euo pipefail

###############################################################################
# Docker / Lmod compatibility
###############################################################################

export LOGNAME=${LOGNAME:-root}
export USER=${USER:-root}
export HOME=${HOME:-/root}

set +u
source /opt/lmod/lmod/init/profile
set -u

###############################################################################
# Clone Spack-Stack
###############################################################################

cd /opt

if [ -d /opt/spack-stack ]; then
    rm -rf /opt/spack-stack
fi

git clone \
    -b release/2.1 \
    --recursive \
    https://github.com/jcsda/spack-stack.git

cd /opt/spack-stack

###############################################################################
# Initialize Spack
###############################################################################

source ./setup.sh

echo "===== SPACK VERSION ====="
spack --version

###############################################################################
# Compiler Discovery
###############################################################################

spack compiler find || true

echo "===== SPACK COMPILERS ====="
spack compilers || true

export CC=$(which gcc)
export CXX=$(which g++)
export FC=$(which gfortran || echo /usr/bin/gfortran-13)

echo "CC=$CC"
echo "CXX=$CXX"
echo "FC=$FC"

###############################################################################
# Create FV3-JEDI Environment
###############################################################################

module purge || true
unset SPACK_ENV || true

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
module list || true

echo "===== COMPILERS ====="

which gcc || true
which g++ || true
which gfortran || true

gcc --version || true
g++ --version || true
gfortran --version || true

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
# Verify Installation
###############################################################################

echo
echo "===== INSTALLED PACKAGES ====="

spack find

echo
echo "===== PACKAGE COUNT ====="

spack find | wc -l

###############################################################################
# Load Final Environment
###############################################################################

set +u
source /opt/lmod/lmod/init/profile
set -u

if [ -d "/opt/spack-stack/envs/fv3jedi-2.1/modules/Core" ]; then
    module use /opt/spack-stack/envs/fv3jedi-2.1/modules/Core
fi

module avail || true

###############################################################################
# Completed
###############################################################################

echo
echo "================================================="
echo " FV3-JEDI environment installation completed"
echo "================================================="
