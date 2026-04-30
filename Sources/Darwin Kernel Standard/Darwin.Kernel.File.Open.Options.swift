// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-darwin-primitives open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-darwin-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if canImport(Darwin)

public import ISO_9945_Core

// MARK: - Darwin-specific Open Options

extension ISO_9945.Kernel.File.Open.Options {
    /// Disables caching (F_NOCACHE).
    ///
    /// Darwin-specific. Applied via `fcntl` after open.
    /// This flag is stored internally and applied post-open.
    public static let noCache = Self(rawValue: 1 << 30)  // Internal flag, not passed to open()

    /// Returns true if noCache was requested.
    @usableFromInline
    internal var needsNoCache: Bool {
        contains(.noCache)
    }

    /// Returns the flags to pass to open(), excluding internal flags.
    @usableFromInline
    internal var openFlags: Int32 {
        rawValue & ~(1 << 30)
    }
}

#endif
