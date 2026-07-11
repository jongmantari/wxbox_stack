#!/usr/bin/env bash

# ----------------------------------
# ✅ Load Spack
# ----------------------------------
cd ~/spack-stack
. setup.sh
spack env activate ~/spack-stack/envs/ufs-env

# ----------------------------------
# ✅ Core paths
# ----------------------------------
export SPACK_ENV=~/spack-stack/envs/ufs-env

# ----------------------------------
# ✅ NetCDF
# ----------------------------------
export NETCDF=$(spack location -i netcdf-c)
export NETCDF_FORTRAN=$(spack location -i netcdf-fortran)

export NETCDF_DIR=$NETCDF
export NETCDFF_DIR=$NETCDF_FORTRAN

export PATH=$NETCDF/bin:$NETCDF_FORTRAN/bin:$PATH

# ----------------------------------
# ✅ ESMF + PIO
# ----------------------------------
export ESMF_DIR=$(spack location -i esmf)
export PIO_DIR=$(spack location -i parallelio)

# useful for legacy builds
export ESMFMKFILE=$(find $ESMF_DIR -name esmf.mk | head -1)

# ----------------------------------
# ✅ FV3 dependencies
# ----------------------------------
export FMS_DIR=$(spack location -i fms)

# ----------------------------------
# ✅ NCEP libraries
# ----------------------------------
export BACIO_DIR=$(spack location -i bacio)
export W3EMC_DIR=$(spack location -i w3emc)
export SP_DIR=$(spack location -i sp)
export IP_DIR=$(spack location -i ip)

# ----------------------------------
# ✅ GRIB2 stack
# ----------------------------------
export G2_DIR=$(spack location -i g2)
export G2TMPL_DIR=$(spack location -i g2tmpl)

# ----------------------------------
# ✅ CRTM (radiation)
# ----------------------------------
export CRTM_DIR=$(spack location -i crtm)

# ----------------------------------
# ✅ g2 dependencies
# ----------------------------------
export LIBPNG_DIR=$(spack location -i libpng)
export JASPER_DIR=$(spack location -i jasper)

# ----------------------------------
# ✅ Helpful debug print (optional)
# ----------------------------------
echo "ESMF_DIR=$ESMF_DIR"
echo "PIO_DIR=$PIO_DIR"
echo "G2_DIR=$G2_DIR"
echo "CRTM_DIR=$CRTM_DIR"
