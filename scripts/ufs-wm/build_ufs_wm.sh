source ~/spack-stack/setup.sh
spack env activate ~/spack-stack/env/ufs-env

source /etc/profile.d/02-lua.sh
source /etc/profile.d/z00_lmod.sh

module use ~/modulefile
module load jedi/5a0d925
source set_env.sh

export SPACK_ENV=~/spack-stack/envs/ufs-env

cd ufs-weatehr/build

cmake ..   -DAPP=ATM   -DCCPP_SUITES=FV3_RRFS_v1beta   -D32BIT=ON   -DCMAKE_BUILD_TYPE=Release   -DCMAKE_PREFIX_PATH="$SPACK_ENV/view"   -DCMAKE_MODULE_PATH=../CMakeModules

make -j8
