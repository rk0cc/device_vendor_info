cmake_minimum_required(VERSION 3.29)

project(device_vendor_info_vmchecker_library VERSION 2.0.0 LANGUAGES C)
add_library(device_vendor_info_vmchecker_library SHARED vmchecker.c vmchecker.def)

set_target_properties(device_vendor_info_vmchecker_library PROPERTIES
    PUBLIC_HEADER vmchecker.h
    VERSION ${PROJECT_VERSION}
    SOVERSION 1
    OUTPUT_NAME "vmchecker"
)
