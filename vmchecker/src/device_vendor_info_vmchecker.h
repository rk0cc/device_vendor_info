#ifndef DEVICE_VENDOR_INFO_VMCHECKER_H
#define DEVICE_VENDOR_INFO_VMCHECKER_H

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdbool.h>

#if _WIN32
#include <windows.h>
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif

    // Determine the running platform is under hypervisor mode, which
    // denotes this program is executed inside of virtual machine or container
    // rather than a real, physical machine.
    FFI_PLUGIN_EXPORT bool is_hypervisor();

#ifdef __cplusplus
}
#endif

#endif
