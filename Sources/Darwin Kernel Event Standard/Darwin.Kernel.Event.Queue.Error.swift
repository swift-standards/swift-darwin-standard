// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//
public import Error_Primitives
public import Kernel_Event_Primitives

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

    extension Kernel.Event.Queue {
        /// Errors from kqueue operations.
        ///
        /// Low-level errors from kqueue syscalls. Each case wraps the
        /// underlying `Error_Primitives.Error.Code` for platform-specific details.
        /// Convert to `Error_Primitives.Error` for semantic error handling.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// do {
        ///     let kq = try Kernel.Event.Queue.create()
        /// } catch let error as Kernel.Event.Queue.Error {
        ///     switch error {
        ///     case .create(let code):
        ///         print("kqueue creation failed: \(code)")
        ///     case .interrupted:
        ///         // Retry the operation
        ///     default:
        ///         throw Error_Primitives.Error(error)
        ///     }
        /// }
        /// ```
        ///
        /// ## See Also
        ///
        /// - ``Kernel/Event/Queue``
        /// - ``Kernel/Error``
        public enum Error: Swift.Error, Sendable, Equatable, Hashable {
            /// Failed to create a kqueue instance.
            ///
            /// Returned by `kqueue()` syscall. Common causes: process
            /// has too many open file descriptors, system limit reached.
            case create(Error_Primitives.Error.Code)

            /// Failed to register, modify, or query events.
            ///
            /// Returned by `kevent()` syscall. Common causes: invalid
            /// kqueue descriptor, bad event specification, invalid filter.
            case kevent(Error_Primitives.Error.Code)

            /// Operation was interrupted by a signal.
            ///
            /// The operation should typically be retried.
            case interrupted
        }
    }

    extension Kernel.Event.Queue.Error: CustomStringConvertible {
        public var description: Swift.String {
            switch self {
            case .create(let code):
                return "kqueue creation failed (\(code))"
            case .kevent(let code):
                return "kevent failed (\(code))"
            case .interrupted:
                return "operation interrupted"
            }
        }
    }

#endif
