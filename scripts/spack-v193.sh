#!/bin/bash
set -euo pipefail

###############################################
# 0. CLEAN RESET
###############################################
rm -rf /opt/spack-stack
rm -rf /opt/modulefiles/spack
rm -rf /root/.spack

mkdir -p /opt/modulefiles

###############################################
# 1. LOAD ONEAPI + LMOD FROM AMI
###############################################
set +u
source /opt/intel/oneapi/setvars.sh
source /etc/profile.d/z00_lmod.sh
set -u

###############################################
# 2. CLONE SPACK-STACK 1.9.3
###############################################
cd /opt
git clone -b 1.9.3 --recurse-submodules https://github.com/JCSDA/spack-stack.git
cd spack-stack
. ./setup.sh

###############################################
# 3. REGISTER COMPILERS
###############################################
spack compiler find

# Remove Ubuntu GCC 12 to avoid conflicts
spack compiler rm gcc@12.3.0 || true

###############################################
# 4. SITE CONFIG: COMPILERS
###############################################
mkdir -p /opt/spack-stack/configs/sites/tier2/linux.default

cat <<EOF > /opt/spack-stack/configs/sites/tier2/linux.default/compilers.yaml
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
    modules:
    - intel-oneapi/2024.2.1
EOF

###############################################
# 5. SITE CONFIG: EXTERNAL PACKAGES
###############################################
cat <<EOF > /opt/spack-stack/configs/sites/tier2/linux.default/packages.yaml
packages:
  autoconf: {externals: [{spec: autoconf@2.71, prefix: /usr}]}
  automake: {externals: [{spec: automake@1.16.5, prefix: /usr}]}
  gawk: {externals: [{spec: gawk@5.1.0, prefix: /usr}]}
  gettext: {externals: [{spec: gettext@0.21, prefix: /usr}]}
  git: {externals: [{spec: git@2.34.1, prefix: /usr}]}
  git-lfs: {externals: [{spec: git-lfs@3.0.2, prefix: /usr}]}
  gmake: {externals: [{spec: gmake@4.3, prefix: /usr}]}
  grep: {externals: [{spec: grep@3.7, prefix: /usr}]}
  groff: {externals: [{spec: groff@1.22.4, prefix: /usr}]}
  m4: {externals: [{spec: m4@1.4.18, prefix: /usr}]}
  openssl: {externals: [{spec: openssl@3.0.2, prefix: /usr}]}
  perl: {externals: [{spec: perl@5.34, prefix: /usr}]}
  sed: {externals: [{spec: sed@4.8, prefix: /usr}]}
  wget: {externals: [{spec: wget@1.21.2, prefix: /usr}]}
EOF

###############################################
# 6. SITE CONFIG: ONEAPI MPI (CORRECTED)
###############################################
cat <<EOF > /opt/spack-stack/configs/sites/tier2/linux.default/packages_oneapi.yaml
packages:
  all:
    compiler:: [oneapi@2024.2.1]
    providers:
      mpi:: [intel-oneapi-mpi]
      blas:: [mkl]
      lapack:: [mkl]
      fftw-api:: [fftw]

  mpi:
    buildable: False

  intel-oneapi-mpi:
    buildable: False
    externals:
    - spec: intel-oneapi-mpi@latest
      prefix: /opt/intel/oneapi/mpi/latest
EOF

###############################################
# 7. CREATE FV3-JEDI ENVIRONMENT (CORRECT)
###############################################
spack env create /opt/spack-stack/envs/fv3jedi-1.9.3
spack env activate /opt/spack-stack/envs/fv3jedi-1.9.3

# Add ONLY the FV3-JEDI meta-package
spack add jedi-fv3-env

###############################################
# 8. BUILD FV3-JEDI STACK
###############################################
spack concretize --force
spack install --fail-fast --show-log-on-error

spack module lmod refresh -y
spack stack setup-meta-modules

spack env deactivate

echo "FV3-JEDI STACK INSTALL COMPLETE."
