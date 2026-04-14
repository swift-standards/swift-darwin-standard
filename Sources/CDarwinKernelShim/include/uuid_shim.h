#ifndef CDARWIN_UUID_SHIM_H
#define CDARWIN_UUID_SHIM_H

#if defined(__APPLE__)
#include <uuid/uuid.h>

/// Parses a UUID string into bytes.
/// Returns 0 on success, -1 on failure.
static inline int swift_uuid_parse(const char *in, unsigned char *uu) {
    return uuid_parse(in, uu);
}

/// Formats UUID bytes as lowercase hyphenated string.
/// Output buffer must be at least 37 bytes.
static inline void swift_uuid_unparse_lower(const unsigned char *uu, char *out) {
    uuid_unparse_lower(uu, out);
}

/// Formats UUID bytes as uppercase hyphenated string.
/// Output buffer must be at least 37 bytes.
static inline void swift_uuid_unparse_upper(const unsigned char *uu, char *out) {
    uuid_unparse_upper(uu, out);
}

#endif /* __APPLE__ */

#endif /* CDARWIN_UUID_SHIM_H */
