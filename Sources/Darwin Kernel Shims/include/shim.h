#ifndef CDARWIN_SHIM_H
#define CDARWIN_SHIM_H

#if defined(__APPLE__)

#include "uuid_shim.h"

#include <sys/mman.h>
#include <sys/types.h>
#include <fcntl.h>
#include <dlfcn.h>

static inline int swift_shm_open(const char *name, int oflag, mode_t mode) {
    return shm_open(name, oflag, mode);
}

static inline void *swift_RTLD_MAIN_ONLY(void) {
    return RTLD_MAIN_ONLY;
}

static inline int32_t swift_RTLD_FIRST(void) {
    return RTLD_FIRST;
}

static inline void *swift_RTLD_DEFAULT(void) {
    return RTLD_DEFAULT;
}

static inline void *swift_RTLD_NEXT(void) {
    return RTLD_NEXT;
}

#endif

#endif
