# Findg2tmpl for Spack-installed g2tmpl

if(NOT DEFINED ENV{G2TMPL_DIR})
  message(FATAL_ERROR "G2TMPL_DIR not set")
endif()

file(GLOB G2TMPL_LIBS "$ENV{G2TMPL_DIR}/lib/libg2tmpl.*")

if(NOT G2TMPL_LIBS)
  message(FATAL_ERROR "g2tmpl library not found")
endif()

list(GET G2TMPL_LIBS 0 G2TMPL_LIBRARY)

if(NOT TARGET g2tmpl)
  add_library(g2tmpl STATIC IMPORTED)
  set_target_properties(g2tmpl PROPERTIES
    IMPORTED_LOCATION "${G2TMPL_LIBRARY}"
  )
endif()

# Required alias
if(NOT TARGET g2tmpl::g2tmpl)
  add_library(g2tmpl::g2tmpl ALIAS g2tmpl)
endif()

set(g2tmpl_FOUND TRUE)

message(STATUS "g2tmpl found at $ENV{G2TMPL_DIR}")