# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(vmchecker_library VERSION 1.0.0 LANGUAGES C)

add_library(vmchecker SHARED
  "vmchecker.c"
)

set_target_properties(vmchecker PROPERTIES
  PUBLIC_HEADER vmchecker.h
  OUTPUT_NAME "vmchecker"
)

target_compile_definitions(vmchecker PUBLIC DART_SHARED_LIB)
