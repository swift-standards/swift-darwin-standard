// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-darwin open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-darwin project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#ifndef CDARWIN_MEMORY_SHIM_H
#define CDARWIN_MEMORY_SHIM_H

#if defined(__APPLE__)

#include <malloc/malloc.h>

/// Wrapper for malloc_zone_statistics to make it available to Swift.
///
/// The original function has a complex signature that doesn't import cleanly.
static inline void darwin_malloc_zone_statistics(malloc_statistics_t *stats) {
    malloc_zone_statistics(NULL, stats);
}

#endif /* __APPLE__ */

#endif /* CDARWIN_MEMORY_SHIM_H */
