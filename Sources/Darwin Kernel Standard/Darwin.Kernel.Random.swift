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

public import Kernel_Random_Primitives
internal import Darwin

// MARK: - Darwin arc4random Implementation

extension Kernel.Random {
    /// Fills a mutable span with cryptographically secure random bytes.
    ///
    /// Uses arc4random_buf which reads from the kernel's CSPRNG.
    /// This function never fails and never blocks.
    ///
    /// - Parameter span: The mutable span to fill with random bytes.

    public static func fill(_ span: inout MutableSpan<UInt8>) {
        unsafe span.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) in
            unsafe fill(buffer)
        }
    }

    /// Fills a buffer with cryptographically secure random bytes.
    ///
    /// Uses arc4random_buf which reads from the kernel's CSPRNG.
    /// This function never fails and never blocks.
    ///
    /// - Parameter buffer: The buffer to fill with random bytes.

    @unsafe
    public static func fill(_ buffer: UnsafeMutableRawBufferPointer) {
        guard let base = buffer.baseAddress, buffer.count > 0 else { return }
        unsafe arc4random_buf(base, buffer.count)
    }

    /// Fills a typed buffer with cryptographically secure random bytes.
    ///
    /// - Parameter buffer: The buffer to fill with random bytes.

    @unsafe
    public static func fill(_ buffer: UnsafeMutableBufferPointer<UInt8>) {
        unsafe fill(UnsafeMutableRawBufferPointer(buffer))
    }
}

#endif
