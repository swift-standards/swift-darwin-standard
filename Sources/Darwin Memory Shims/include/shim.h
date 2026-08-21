#ifndef CDARWIN_MEMORY_SHIM_H
#define CDARWIN_MEMORY_SHIM_H

#if defined(__APPLE__)

#include <malloc/malloc.h>

static inline void darwin_malloc_zone_statistics(malloc_statistics_t *stats) {
    malloc_zone_statistics(NULL, stats);
}

#endif

#endif
