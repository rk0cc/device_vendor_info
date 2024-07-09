#include <cpuid.h>

#include "vmchecker.h"

bool is_hypervisor()
{
    unsigned int eax, ebx, ecx, edx;

    __get_cpuid(1, &eax, &ebx, &ecx, &edx);

    if (ecx >> 31 & 1)
        return true;

    return false;
}