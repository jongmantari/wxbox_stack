#!/bin/bash
set -euo pipefail

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

echo "===== Preparing CRTM Coefficients ====="

mkdir -p test-data-release

if [ -f /opt/crtm/fix_REL-3.1.2.0.tgz ]; then
    echo "Found CRTM archive in AMI cache:"
    ls -lh /opt/crtm/fix_REL-3.1.2.0.tgz

    cp -p \
        /opt/crtm/fix_REL-3.1.2.0.tgz \
        test-data-release/

    echo "Copied CRTM archive to:"
    ls -lh test-data-release/fix_REL-3.1.2.0.tgz
else
    echo "CRTM archive not found in /opt/crtm"
    echo "CRTM build system will download it automatically."
fi

mkdir build
cd build

ecbuild ..

git lfs install

make update

make -j8 2>&1 | tee /tmp/jedi-build.log

#ctest -j8
