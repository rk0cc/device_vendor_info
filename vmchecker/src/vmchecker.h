#include <stdbool.h>

#if _WIN32 && defined(_MSC_VER)
#include <intrin.h>
#else
#include <cpuid.h>
#endif

#if _WIN32
#define FFI_PLUGIN_EXPORT __declspec(dllexport)
#else
#define FFI_PLUGIN_EXPORT
#endif

// Determine the running platform is under hypervisor mode, which
// denotes this program is executed inside of virtual machine or container
// rather than a real, physical machine.
FFI_PLUGIN_EXPORT bool is_hypervisor();
