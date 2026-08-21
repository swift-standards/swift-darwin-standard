#ifndef CDARWIN_UUID_SHIM_H
#define CDARWIN_UUID_SHIM_H

#if defined(__APPLE__)
#include <uuid/uuid.h>

static inline int swift_uuid_parse(const char *in, unsigned char *uu) {
    return uuid_parse(in, uu);
}

static inline void swift_uuid_unparse_lower(const unsigned char *uu, char *out) {
    uuid_unparse_lower(uu, out);
}

static inline void swift_uuid_unparse_upper(const unsigned char *uu, char *out) {
    uuid_unparse_upper(uu, out);
}

#endif

#endif
