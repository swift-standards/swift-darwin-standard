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

#if canImport(Darwin)

public import Darwin_Standard_Core
public import Kernel_File_Primitives
internal import Darwin

// MARK: - Sysctl Namespace

extension Darwin_Standard_Core.Darwin.Kernel {
    /// BSD `sysctl(3)` MIB query by name.
    ///
    /// Wraps `sysctlbyname(3)` at L2 so higher layers don't call the raw
    /// syscall directly. Consumers at L3 (e.g. `swift-darwin`'s
    /// `System.Memory.Total` and `System.Processor.Physical.Count`) delegate
    /// here per [PLAT-ARCH-008c] — L3 MUST NOT bypass L2 when an L2 wrapper
    /// exists.
    public enum Sysctl {}
}

// MARK: - Error

extension Darwin_Standard_Core.Darwin.Kernel.Sysctl {
    /// Error type for sysctl operations.
    public struct Error: Swift.Error, Sendable {
        public let code: Kernel.Error.Code

        public init(code: Kernel.Error.Code) {
            self.code = code
        }

        /// Creates an error from the current errno.
        @usableFromInline
        internal static func current() -> Self {
            Self(code: .posix(errno))
        }
    }
}

// MARK: - Typed integer query

extension Darwin_Standard_Core.Darwin.Kernel.Sysctl {
    /// Reads a fixed-width integer sysctl value by MIB name.
    ///
    /// Wraps `sysctlbyname(3)` for scalar integer values such as
    /// `"hw.memsize"` (UInt64) or `"hw.physicalcpu"` (Int32). The result
    /// type is inferred from the call-site type annotation.
    ///
    /// - Parameters:
    ///   - name: The MIB name (e.g. `"hw.memsize"`).
    ///   - type: The expected value type; typically inferred.
    /// - Returns: The sysctl value.
    /// - Throws: `Error` if the syscall fails.
    public static func byName<T: FixedWidthInteger>(
        _ name: Swift.String,
        as type: T.Type = T.self
    ) throws(Error) -> T {
        var value = T(0)
        var size = MemoryLayout<T>.size

        // Manual NUL-terminated UTF-8 buffer: withCString does not preserve
        // typed throws on Swift 6.3.
        var utf8 = Array(name.utf8)
        utf8.append(0)
        let result = unsafe utf8.withUnsafeBufferPointer { buffer -> Int32 in
            let namePtr = unsafe UnsafeRawPointer(buffer.baseAddress!).assumingMemoryBound(to: CChar.self)
            return unsafe sysctlbyname(namePtr, &value, &size, nil, 0)
        }
        guard result == 0 else {
            throw .current()
        }
        return value
    }
}

#endif // canImport(Darwin)
