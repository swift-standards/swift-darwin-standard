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

public import Random_Primitives
public import ISO_9945_Kernel_System
internal import Darwin

// MARK: - Darwin arc4random syscall

extension Darwin.Kernel.Random {
    /// Fills a mutable span with cryptographically secure random bytes using
    /// `arc4random_buf`.
    ///
    /// Darwin's `arc4random_buf` reads from the kernel's CSPRNG and is
    /// infallible — it never fails and never blocks. The
    /// `throws(Random.Error)` annotation is present for cross-platform
    /// signature parity with `Linux.Kernel.Random.getrandom(_:)` and
    /// `Windows.Kernel.Random.bCryptGenRandom(_:)`; the body never throws on
    /// Darwin (see [PATTERN-009]).
    ///
    /// - Parameter span: The mutable span to fill with random bytes.
    public static func arc4random(_ span: inout MutableSpan<UInt8>) throws(Random.Error) {
        try unsafe span.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) throws(Random.Error) in
            try unsafe arc4random(buffer)
        }
    }

    /// Fills a buffer with cryptographically secure random bytes using
    /// `arc4random_buf`.
    ///
    /// Darwin's `arc4random_buf` reads from the kernel's CSPRNG and is
    /// infallible — it never fails and never blocks. The
    /// `throws(Random.Error)` annotation is present for cross-platform
    /// signature parity (see [PATTERN-009]).
    ///
    /// - Parameter buffer: The buffer to fill with random bytes.
    @unsafe
    public static func arc4random(_ buffer: UnsafeMutableRawBufferPointer) throws(Random.Error) {
        guard let base = buffer.baseAddress, buffer.count > 0 else { return }
        unsafe arc4random_buf(base, buffer.count)
    }

    /// Fills a typed buffer with cryptographically secure random bytes using
    /// `arc4random_buf`.
    ///
    /// - Parameter buffer: The buffer to fill with random bytes.
    @unsafe
    public static func arc4random(_ buffer: UnsafeMutableBufferPointer<UInt8>) throws(Random.Error) {
        try unsafe arc4random(UnsafeMutableRawBufferPointer(buffer))
    }
}

#endif
