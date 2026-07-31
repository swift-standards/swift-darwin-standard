// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-darwin open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-darwin project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import ISO_9945_Core
public import ISO_9945_Loader
public import Loader_Primitives

// MARK: - Non-POSIX Extension Options (Darwin)
//
// RTLD_NOLOAD and RTLD_NODELETE are not POSIX; both are Darwin extensions.
// Per swift-standards/swift-darwin-standard#3 (the Darwin half of the RTLD
// residue relocated out of swift-iso-9945 per swift-iso/swift-iso-9945#65),
// these live here as a platform extension on `ISO_9945.Loader.Library.Options`
// — the Options type itself stays at L2. The Linux counterpart is
// swift-linux-foundation/swift-linux-standard#4.

#if canImport(Darwin)

    internal import Darwin

    extension ISO_9945.Loader.Library.Options {
        /// Don't load, just check if loadable (RTLD_NOLOAD).
        ///
        /// Returns the handle if the library is already loaded,
        /// or fails without loading. Useful for probing.
        ///
        /// Non-POSIX extension. Also available on glibc (since 2.2).
        public static let noLoad = Self(rawValue: RTLD_NOLOAD)

        /// Don't delete on close (RTLD_NODELETE).
        ///
        /// Keeps the library in memory even after `close`.
        /// The library's static destructors will not run.
        ///
        /// Non-POSIX extension. Also available on glibc (since 2.2).
        public static let noDelete = Self(rawValue: RTLD_NODELETE)
    }

#endif
