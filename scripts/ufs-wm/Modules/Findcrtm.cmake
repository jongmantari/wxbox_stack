# Findcrtm for Spack-installed CRTM

if(NOT DEFINED ENV{CRTM_DIR})
  message(FATAL_ERROR "CRTM_DIR not set")
endif()

# Find CRTM library (.so or .a)
file(GLOB CRTM_LIBS "$ENV{CRTM_DIR}/lib/libcrtm.*")

if(NOT CRTM_LIBS)
  message(FATAL_ERROR "CRTM library not found in $ENV{CRTM_DIR}/lib")
endif()

list(GET CRTM_LIBS 0 CRTM_LIBRARY)

# ✅ FIX: correct module directory
set(CRTM_MOD_DIR "$ENV{CRTM_DIR}/module/crtm/GNU/13.3.0")

if(NOT EXISTS "${CRTM_MOD_DIR}")
  message(FATAL_ERROR "CRTM module directory not found: ${CRTM_MOD_DIR}")
endif()

if(NOT TARGET crtm)
  add_library(crtm SHARED IMPORTED)
  set_target_properties(crtm PROPERTIES
    IMPORTED_LOCATION "${CRTM_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES "${CRTM_MOD_DIR}"
  )
endif()

set(crtm_FOUND TRUE)

message(STATUS "crtm found at $ENV{CRTM_DIR}")
message(STATUS "crtm library: ${CRTM_LIBRARY}")
message(STATUS "crtm module dir: ${CRTM_MOD_DIR}")
