# FindESMF for Spack-installed ESMF + full dependency chain

# -------------------------------
# Required environment variables
# -------------------------------
if(NOT DEFINED ENV{ESMF_DIR})
  message(FATAL_ERROR "ESMF_DIR not set")
endif()

if(NOT DEFINED ENV{PIO_DIR})
  message(FATAL_ERROR "PIO_DIR not set")
endif()

if(NOT DEFINED ENV{NETCDF_DIR})
  message(FATAL_ERROR "NETCDF_DIR not set")
endif()

if(NOT DEFINED ENV{NETCDFF_DIR})
  message(FATAL_ERROR "NETCDFF_DIR not set")
endif()

# -------------------------------
# Find libraries
# -------------------------------

# ESMF
find_library(ESMF_LIBRARY
  NAMES esmf
  PATHS "$ENV{ESMF_DIR}/lib"
  NO_DEFAULT_PATH
)

# ParallelIO (PIO) – both C and Fortran
find_library(PIOC_LIBRARY
  NAMES pioc
  PATHS "$ENV{PIO_DIR}/lib"
  NO_DEFAULT_PATH
)

find_library(PIOF_LIBRARY
  NAMES piof
  PATHS "$ENV{PIO_DIR}/lib"
  NO_DEFAULT_PATH
)

# NetCDF (needed by PIO)
find_library(NETCDF_C_LIBRARY
  NAMES netcdf
  PATHS "$ENV{NETCDF_DIR}/lib"
  NO_DEFAULT_PATH
)

find_library(NETCDF_F_LIBRARY
  NAMES netcdff
  PATHS "$ENV{NETCDFF_DIR}/lib"
  NO_DEFAULT_PATH
)

# -------------------------------
# Validate
# -------------------------------

if(NOT ESMF_LIBRARY)
  message(FATAL_ERROR "ESMF library not found")
endif()

if(NOT PIOC_LIBRARY OR NOT PIOF_LIBRARY)
  message(FATAL_ERROR "PIO libraries not found")
endif()

if(NOT NETCDF_C_LIBRARY OR NOT NETCDF_F_LIBRARY)
  message(FATAL_ERROR "NetCDF libraries not found")
endif()

# -------------------------------
# Module directory (.mod files)
# -------------------------------

set(ESMF_MOD_DIR "$ENV{ESMF_DIR}/include")

if(NOT EXISTS "${ESMF_MOD_DIR}/esmf.mod")
  message(FATAL_ERROR "esmf.mod not found in ${ESMF_MOD_DIR}")
endif()

# -------------------------------
# Define target (clean list usage)
# -------------------------------

set(ESMF_LINK_LIBS
  ${ESMF_LIBRARY}
  ${PIOC_LIBRARY}
  ${PIOF_LIBRARY}
  ${NETCDF_C_LIBRARY}
  ${NETCDF_F_LIBRARY}
)

if(NOT TARGET ESMF::ESMF)
  add_library(ESMF::ESMF INTERFACE IMPORTED)
  set_target_properties(ESMF::ESMF PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${ESMF_MOD_DIR}"
    INTERFACE_LINK_LIBRARIES "${ESMF_LINK_LIBS}"
  )
endif()

# -------------------------------
# Final status messages
# -------------------------------

set(ESMF_FOUND TRUE)

message(STATUS "ESMF library: ${ESMF_LIBRARY}")
