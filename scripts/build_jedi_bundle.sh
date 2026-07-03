#!/bin/bash
set -euxo pipefail

INSTALL_DIR=${1:-/opt/jedi-bundle}

source /etc/profile.d/02-lua.sh
source /etc/profile.d/z00_lmod.sh

module purge
module use /opt/spack-stack/envs/fv3jedi-2.1/modules/Core
module load stack-gcc/13.3.0
module load stack-openmpi/5.0.8
module load jedi-fv3-env/1.0.0

mkdir -p "${INSTALL_DIR}"
cd "${INSTALL_DIR}"

git clone https://github.com/JCSDA/jedi-bundle.git
cd jedi-bundle

git checkout 5a0d9257a258b9954a44593285df20add0d6416d

sed -i '/MPAS\|mpas/s/^/#/' CMakeLists.txt

echo "===== MPAS Lines ====="
grep -n "MPAS\|mpas" CMakeLists.txt

mkdir build
cd build

ecbuild ..

git lfs install

make update

make -j8

ctest -j8
