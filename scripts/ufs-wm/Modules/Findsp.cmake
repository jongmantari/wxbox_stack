# Findsp for Spack-installed sp

if(NOT DEFINED ENV{SP_DIR})
  message(FATAL_ERROR "SP_DIR not set")
endif()

# detect real library name
file(GLOB SP_LIBS "$ENV{SP_DIR}/lib/libsp*.a")

if(NOT SP_LIBS)
  message(FATAL_ERROR "sp library not found in $ENV{SP_DIR}/lib")
endif()

list(GET SP_LIBS 0 SP_LIBRARY)

if(NOT TARGET sp)
  add_library(sp STATIC IMPORTED)
  set_target_properties(sp PROPERTIES
    IMPORTED_LOCATION "${SP_LIBRARY}"
  )
endif()

# required alias for UFS
if(NOT TARGET sp::sp_d)
  add_library(sp::sp_d ALIAS sp)
endif()

set(sp_FOUND TRUE)

message(STATUS "sp found at $ENV{SP_DIR}")
message(STATUS "sp library: ${SP_LIBRARY}")