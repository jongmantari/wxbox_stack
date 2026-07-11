# Findg2 for Spack-installed g2 + g2tmpl + dependencies

# -------------------------------
# Required environment variables
# -------------------------------
if(NOT DEFINED ENV{G2_DIR})
  message(FATAL_ERROR "G2_DIR not set")
endif()

if(NOT DEFINED ENV{G2TMPL_DIR})
  message(FATAL_ERROR "G2TMPL_DIR not set")
endif()

if(NOT DEFINED ENV{JASPER_DIR})
  message(FATAL_ERROR "JASPER_DIR not set")
endif()

if(NOT DEFINED ENV{LIBPNG_DIR})
  message(FATAL_ERROR "LIBPNG_DIR not set")
endif()

# -------------------------------
# Find libraries
# -------------------------------

# g2
find_library(G2_LIBRARY
  NAMES g2_4
  PATHS "$ENV{G2_DIR}/lib"
  NO_DEFAULT_PATH
)

# jasper
find_library(JASPER_LIBRARY
  NAMES jasper
  PATHS "$ENV{JASPER_DIR}/lib"
  NO_DEFAULT_PATH
)

# libpng
find_library(PNG_LIBRARY
  NAMES png
  PATHS "$ENV{LIBPNG_DIR}/lib"
  NO_DEFAULT_PATH
)

# -------------------------------
# Validate
# -------------------------------

if(NOT G2_LIBRARY)
  message(FATAL_ERROR "g2 library not found")
endif()

if(NOT JASPER_LIBRARY)
  message(FATAL_ERROR "jasper library not found")
endif()

if(NOT PNG_LIBRARY)
  message(FATAL_ERROR "libpng library not found")
endif()

# -------------------------------
# Module directories (.mod)
# -------------------------------

set(G2_MOD_DIRS
  "$ENV{G2_DIR}/include_4"
  "$ENV{G2TMPL_DIR}/include"
)

# -------------------------------
# Clean link list (NO whitespace)
# -------------------------------

set(G2_LINK_LIBS
  ${G2_LIBRARY}
  ${JASPER_LIBRARY}
  ${PNG_LIBRARY}
)

# -------------------------------
# Define imported targets
# -------------------------------

if(NOT TARGET g2)
  add_library(g2 STATIC IMPORTED)
  set_target_properties(g2 PROPERTIES
    IMPORTED_LOCATION "${G2_LIBRARY}"
    INTERFACE_INCLUDE_DIRECTORIES "${G2_MOD_DIRS}"
  )
endif()

# Required by UFS
if(NOT TARGET g2::g2_4)
  add_library(g2::g2_4 INTERFACE IMPORTED)
  set_target_properties(g2::g2_4 PROPERTIES
    INTERFACE_LINK_LIBRARIES "${G2_LINK_LIBS}"
    INTERFACE_INCLUDE_DIRECTORIES "${G2_MOD_DIRS}"
  )
endif()

# -------------------------------
# Final status
# -------------------------------

set(g2_FOUND TRUE)

message(STATUS "g2 library: ${G2_LIBRARY}")
message(STATUS "g2 module dirs: ${G2_MOD_DIRS}")
message(STATUS "jasper: ${JASPER_LIBRARY}")
message(STATUS "png: ${PNG_LIBRARY}")
