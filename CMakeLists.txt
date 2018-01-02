cmake_minimum_required(VERSION 2.6)
project(openscad)

find_library(ALPHA2_MATH NAMES alpha2-math)
find_library(ALPHA2_UTIL NAMES alpha2-util)

add_library(openscad-tools STATIC 
  src/format-stl.cpp
  src/formats.cpp
  src/types.cpp
  src/compute.cpp
)

add_executable(finger-faces
  src/finger-faces.cpp
  src/format-stl.cpp
  src/formats.cpp
  src/types.cpp
  src/compute.cpp
  )

target_link_libraries(finger-faces
  ${ALPHA2_UTIL}
  ${ALPHA2_MATH}
  )

#target_link_libraries(finger-faces
#  libopenscad-tools.a)

if (CMAKE_CXX_COMPILER_ID MATCHES "(Clang|GNU)")
  add_definitions(-Wall -Wpedantic -Wextra -Werror -std=c++14)
endif()

