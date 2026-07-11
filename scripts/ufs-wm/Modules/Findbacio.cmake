# Findbacio for Spack-installed bacio

if(NOT DEFINED ENV{BACIO_DIR})
  message(FATAL_ERROR "BACIO_DIR not set")
endif()

# detect correct library automatically
file(GLOB BACIO_LIBS "$ENV{BACIO_DIR}/lib/libbacio*.a")

if(NOT BACIO_LIBS)
  message(FATAL_ERROR "bacio library not found in $ENV{BACIO_DIR}/lib")
endif()

list(GET BACIO_LIBS 0 BACIO_LIBRARY)

if(NOT TARGET bacio)
  add_library(bacio STATIC IMPORTED)
  set_target_properties(bacio PROPERTIES
    IMPORTED_LOCATION "${BACIO_LIBRARY}"
  )
endif()

# Required aliases for UFS
if(NOT TARGET bacio::bacio)
  add_library(bacio::bacio ALIAS bacio)
endif()

if(NOT TARGET bacio::bacio_4)
  add_library(bacio::bacio_4 ALIAS bacio)
endif()

set(bacio_FOUND TRUE)

message(STATUS "bacio found at $ENV{BACIO_DIR}")
message(STATUS "bacio library: ${BACIO_LIBRARY}")
