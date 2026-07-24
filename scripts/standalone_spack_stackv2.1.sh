#!/bin/bash
set -euo pipefail

###############################################################################
# Initialize Lua and Lmod
###############################################################################
#source /etc/profile.d/02-lua.sh
#source /etc/profile.d/z00_lmod.sh

###############################################################################
# Clone spack-stack in HOME
###############################################################################
cd /opt

if [ -d "spack-stack" ]; then
    echo "✅ spack-stack already exists, skipping clone"
else
    git clone -b release/2.1 --depth 1 --recursive \
        https://github.com/jcsda/spack-stack.git spack-stack
fi

cd ~/spack-stack

# Initialize spack-stack (safe in home)
source ./setup.sh

###############################################################################
# Create environment
###############################################################################
module purge
unset SPACK_ENV

spack stack create env \
    --site linux.default \
    --name ufs-env \
    --compiler gcc

cd ~/spack-stack/envs/ufs-env
spack env activate .

###############################################################################
# FIX known build issue (Berkeley DB)
###############################################################################
# Prevent STL build bug that breaks installation
spack add berkeley-db~cxx

###############################################################################
# Add dependencies (CHOOSE ONE MODE)
###############################################################################

# ===============================
# OPTION A: Minimal UFS (RECOMMENDED ✅)
# ===============================
spack add esmf
spack add bacio
spack add w3emc
spack add g2
spack add g2tmpl
spack add ip
spack add sp
spack add parallelio
spack add netcdf-c
spack add netcdf-fortran
spack add crtm
spack add libpng
spack add jasper

# ===============================
# OPTION B: Full JEDI stack (VERY HEAVY ❗)
# ===============================
spack add jedi-fv3-env

###############################################################################
# Clean previous failed builds
###############################################################################
spack clean -a

###############################################################################
# Concretize and install
###############################################################################
spack concretize -f
spack install --fail-fast -j 8

###############################################################################
# Generate modulefiles
###############################################################################
spack module lmod refresh -y
spack stack setup-meta-modules

###############################################################################
# Instructions
###############################################################################
echo ""
echo "✅ Environment built successfully!"
echo ""
echo "To load this environment later:"
echo ""
echo "module use /opt/spack-stack/envs/ufs-env/modules/Core"
echo "module load stack-gcc/13.3.0"
echo "module load stack-openmpi/5.0.8"
echo ""
#echo "Then build UFS Weather Model:"
#echo "cd ~/ufs-weather-model/build"
#echo "cmake .. -DCMAKE_PREFIX_PATH=\$SPACK_ENV/view"
#echo "make -j"
`
