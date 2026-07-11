# Minimal FindFMS for Spack-installed FMS

if(NOT DEFINED ENV{SPACK_ENV})
  message(FATAL_ERROR "SPACK_ENV not set")
endif()

set(FMS_FOUND TRUE)

set(FMS_DIR "$ENV{SPACK_ENV}/view")

message(STATUS "FMS detected via SPACK_ENV=${FMS_DIR}")