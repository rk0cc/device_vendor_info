#include "device_vendor_info_vmchecker.h"

#if _WIN32 && defined(_MSC_VER)
#include <intrin.h>
typedef int cpuinfo_reg;
#else
#include <cpuid.h>
typedef unsigned int cpuinfo_reg;
#endif

// Determine the running platform is under hypervisor mode, which
// denotes this program is executed inside of virtual machine or container
// rather than a real, physical machine.
bool is_hypervisor()
{
    cpuinfo_reg cpuinfo[4];

#if _WIN32 && defined(_MSC_VER)
    __cpuid(cpuinfo, 1);
#else
    __get_cpuid(1, &cpuinfo[0], &cpuinfo[1], &cpuinfo[2], &cpuinfo[3]);
#endif

    return cpuinfo[2] >> 31 & 1;
}
