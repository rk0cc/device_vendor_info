#include "vmchecker.h"

// Determine the running platform is under hypervisor mode, which
// denotes this program is executed inside of virtual machine or container
// rather than a real, physical machine.
bool is_hypervisor()
{
#if _WIN32 && defined(_MSC_VER)
  int cpuinfo[4];
  __cpuid(cpuinfo, 1);

  if (cpuinfo[2] >> 31 & 1)
    return true;
#else
  unsigned int eax, ebx, ecx, edx;

  __get_cpuid(1, &eax, &ebx, &ecx, &edx);

  if (ecx >> 31 & 1)
    return true;
#endif
  return false;
}
