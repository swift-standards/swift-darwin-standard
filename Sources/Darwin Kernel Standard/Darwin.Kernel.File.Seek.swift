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
internal import Darwin

// MARK: - Darwin-specific Seek Whence

extension Kernel.File.Seek.Whence {
    /// Seek to the next hole (SEEK_HOLE).
    public static let hole = Self(rawValue: SEEK_HOLE)

    /// Seek to the next data region (SEEK_DATA).
    public static let data = Self(rawValue: SEEK_DATA)
}

#endif
