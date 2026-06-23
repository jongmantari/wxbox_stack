#!/bin/bash
set -euo pipefail

###############################################
# 0. CLEAN RESET
###############################################
rm -rf /opt/spack-stack-2.1
rm -rf /opt/modulefiles/spack
rm -rf /root/.spack

mkdir -p /opt/modulefiles

###############################################
# 1. LOAD ONEAPI + LMOD FROM AMI
###############################################
set +u
source /opt/intel/oneapi/setvars.sh --force
source /etc/profile.d/z00_lmod.sh
set -u

###############################################
# 2. CLONE SPACK-STACK 2.1
###############################################
cd /opt
git clone -b release/2.1 --recurse-submodules https://github.com/JCSDA/spack-stack.git spack-stack-2.1
cd spack-stack-2.1
source ./setup.sh

###############################################
# 3. CLONE UPSTREAM SPACK (REQUIRED)
###############################################
rm -rf spack
git clone https://github.com/spack/spack.git spack
cd spack
git checkout releases/v0.23
git submodule update --init --recursive
cd ..

###############################################
# 4. REGISTER COMPILERS (CLEAN)
###############################################
rm -f ~/.spack/linux/compilers.yaml
spack compiler find

###############################################
# 5. SITE CONFIG: COMPILERS
###############################################
mkdir -p configs/sites/linux.default

cat <<EOF > configs/sites/linux.default/compilers.yaml
compilers:
- compiler:
    spec: oneapi@2024.2.1
    paths:
      cc: /opt/intel/oneapi/compiler/latest/bin/icx
      cxx: /opt/intel/oneapi/compiler/latest/bin/icpx
      f77: /opt/intel/oneapi/compiler/latest/bin/ifx
      fc: /opt/intel/oneapi/compiler/latest/bin/ifx
    operating_system: ubuntu22.04
    target: x86_64
    modules: []
EOF

###############################################
# 6. SITE CONFIG: EXTERNAL PACKAGES
###############################################
cat <<EOF > configs/sites/linux.default/packages.yaml
packages:
  all:
    providers:
      mpi: [intel-oneapi-mpi]
      blas: [mkl]
      lapack: [mkl]
      fftw-api: [fftw]

  intel-oneapi-mpi:
    buildable: false
    externals:
    - spec: intel-oneapi-mpi@2024.2.1
      prefix: /opt/intel/oneapi/mpi/latest

  mkl:
    buildable: false
    externals:
    - spec: mkl@2024.2.1
      prefix: /opt/intel/oneapi/mkl/latest
EOF

###############################################
# 7. CREATE FV3-JEDI ENVIRONMENT
###############################################
spack stack create env --site linux.default --template fv3jedi --name fv3jedi-2.1 --compiler oneapi@2024.2.1

###############################################
# 8. PATCH BROKEN SPAK-STACK-GENERATED spack.yaml
###############################################
SPACKYAML=/opt/spack-stack-2.1/envs/fv3jedi-2.1/spack.yaml

# Remove broken core_compilers block
sed -i '/core_compilers:/,/packages:/d' $SPACKYAML

# Remove any dpcpp contamination
sed -i 's/dpcpp[^ ]*//g' $SPACKYAML

# Insert working module block
cat <<EOF >> $SPACKYAML

  modules:
    default:
      lmod:
        core_compilers:
        - gcc@11.4.0
        - gcc@12.3.0

  packages:
    all:
      compiler: [gcc@11.4.0]

    fortran:
      prefer: [gcc@11.4.0]
EOF

###############################################
# 9. ACTIVATE ENVIRONMENT
###############################################
spack env activate /opt/spack-stack-2.1/envs/fv3jedi-2.1

###############################################
# 10. BUILD FV3-JEDI STACK
###############################################
spack concretize --force
spack install --fail-fast --show-log-on-error

###############################################
# 11. MODULES
###############################################
spack module lmod refresh -y
spack stack setup-meta-modules

spack env deactivate

module use /opt/spack-stack-2.1/envs/fv3jedi-2.1/modules/Core
module load stack-gcc/11.4.0
module load stack-openmpi/5.0.8
module load  jedi-base-env/1.0.0
module list

echo "FV3-JEDI STACK INSTALL COMPLETE (SPACK-STACK 2.1, AWS-SAFE)."
