# The Flutter tooling requires that developers have CMake 3.10 or later
# installed. You should not increase this version, as doing so will cause
# the plugin to fail to compile for some customers of the plugin.
cmake_minimum_required(VERSION 3.10)

project(device_vendor_info_vmchecker_library VERSION 0.0.1 LANGUAGES C)

add_library(device_vendor_info_vmchecker SHARED
  "device_vendor_info_vmchecker.c"
)

set_target_properties(device_vendor_info_vmchecker PROPERTIES
  PUBLIC_HEADER device_vendor_info_vmchecker.h
  OUTPUT_NAME "device_vendor_info_vmchecker"
)

target_compile_definitions(device_vendor_info_vmchecker PUBLIC DART_SHARED_LIB)
