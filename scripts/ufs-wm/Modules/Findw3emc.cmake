# Findw3emc for Spack-installed w3emc

if(NOT DEFINED ENV{W3EMC_DIR})
  message(FATAL_ERROR "W3EMC_DIR not set")
endif()

# Automatically detect correct library
file(GLOB W3EMC_LIBS "$ENV{W3EMC_DIR}/lib/libw3emc*.a")

if(NOT W3EMC_LIBS)
  message(FATAL_ERROR "w3emc library not found in $ENV{W3EMC_DIR}/lib")
endif()

list(GET W3EMC_LIBS 0 W3EMC_LIBRARY)

if(NOT TARGET w3emc)
  add_library(w3emc STATIC IMPORTED)
  set_target_properties(w3emc PROPERTIES
    IMPORTED_LOCATION "${W3EMC_LIBRARY}"
  )
endif()

# Required alias for UFS
if(NOT TARGET w3emc::w3emc_d)
  add_library(w3emc::w3emc_d ALIAS w3emc)
endif()

set(w3emc_FOUND TRUE)

message(STATUS "w3emc found at $ENV{W3EMC_DIR}")
message(STATUS "w3emc library: ${W3EMC_LIBRARY}")