#include "device_vendor_info_vmchecker.h"

#if _WIN32 && defined(_MSC_VER)
#define __DVI_VMCHECKER_MSVC 1
#define __DVI_VMCHECKER_CPUINFO_TYPE int
#include <intrin.h>
#else
#define __DVI_VMCHECKER_MSVC 0
#define __DVI_VMCHECKER_CPUINFO_TYPE unsigned int
#include <cpuid.h>
#endif

typedef __DVI_VMCHECKER_CPUINFO_TYPE cpuinfo_reg;

// Determine the running platform is under hypervisor mode, which
// denotes this program is executed inside of virtual machine or container
// rather than a real, physical machine.
bool is_hypervisor()
{
    cpuinfo_reg cpuinfo[4];

#if __DVI_VMCHECKER_MSVC
    __cpuid(cpuinfo, 1);
#else
    __get_cpuid(1, &cpuinfo[0], &cpuinfo[1], &cpuinfo[2], &cpuinfo[3]);
#endif

    return cpuinfo[2] >> 31 & 1;
}
