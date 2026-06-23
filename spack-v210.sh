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
# 2. CLONE SPACK-STACK 2.1 (LATEST)
###############################################
cd /opt
git clone https://github.com/JCSDA/spack-stack.git spack-stack-2.1
cd spack-stack-2.1
git checkout release/2.1
git submodule update --init --recursive
source ./setup.sh

###############################################
# 3. REGISTER COMPILERS (UPSTREAM SPACK)
###############################################
spack compiler find

###############################################
# 4. SITE CONFIG: COMPILERS (2.1 FORMAT)
###############################################
mkdir -p /opt/spack-stack-2.1/configs/sites/linux.default

cat <<EOF > /opt/spack-stack-2.1/configs/sites/linux.default/compilers.yaml
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
# 5. SITE CONFIG: EXTERNAL PACKAGES (2.1 FORMAT)
###############################################
cat <<EOF > /opt/spack-stack-2.1/configs/sites/linux.default/packages.yaml
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
# 6. CREATE GENERIC ENV (NO FV3 TEMPLATE IN 2.1)
###############################################
spack stack create env \
  --site linux.default \
  --name fv3jedi-2.1 \
  --compiler oneapi@2024.2.1

###############################################
# 7. ACTIVATE ENVIRONMENT
###############################################
spack env activate /opt/spack-stack-2.1/envs/fv3jedi-2.1

###############################################
# 8. ADD FV3-JEDI META-PACKAGE
###############################################
spack add jedi-fv3-env

###############################################
# 9. BUILD FV3-JEDI STACK
###############################################
spack concretize --force
spack install --fail-fast --show-log-on-error

###############################################
# 10. MODULES
###############################################
spack module lmod refresh -y
spack stack setup-meta-modules

spack env deactivate

echo "FV3-JEDI STACK INSTALL COMPLETE (SPACK-STACK 2.1)."
