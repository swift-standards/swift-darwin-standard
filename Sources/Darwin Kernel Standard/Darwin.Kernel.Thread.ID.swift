// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-darwin open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-darwin project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

@_spi(Syscall) public import Kernel_Thread_Primitives
internal import Darwin

extension Kernel.Thread {
    /// Opaque OS thread identifier on Darwin.
    ///
    /// The raw value is the Mach port name for the thread, as returned by
    /// `pthread_mach_thread_np(pthread_self())`. This is the identifier the
    /// Mach kernel uses internally and the one Instruments displays.
    ///
    /// Not portable across processes or platforms. Within a single process,
    /// two `ID` values compare equal iff they refer to the same OS thread.
    public struct ID: Hashable, Sendable, RawRepresentable, CustomStringConvertible {
        /// The Mach port name. On Darwin, `mach_port_t` is typedef'd to
        /// `UInt32`; we expose `UInt32` directly to avoid leaking the
        /// platform typedef into the public API.
        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public var description: String { "mach_port(\(rawValue))" }
    }
}

extension Kernel.Thread.ID {
    /// The ID of the calling thread.
    public static var current: Self {
        .init(rawValue: UInt32(unsafe pthread_mach_thread_np(unsafe pthread_self())))
    }
}

#endif
