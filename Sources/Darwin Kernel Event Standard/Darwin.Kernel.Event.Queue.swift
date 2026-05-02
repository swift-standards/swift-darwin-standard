@_spi(Syscall) public import ISO_9945_Core
package import Darwin_Standard_Core

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
internal import Darwin_Kernel_Time_Standard

// L2 .POSIX namespace constants
internal import ISO_9945_Kernel

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
internal import Darwin

/// Type alias for C kevent struct to avoid ambiguity with Swift kevent method.
internal typealias CKevent = kevent

extension ISO_9945.Kernel.Event {
    /// Kqueue event notification (Darwin).
    ///
    /// Owns the kqueue file descriptor via `~Copyable` — deinit closes
    /// the fd automatically. Instance methods provide the modern Swift API;
    /// package statics preserve the C API mirror for platform-stack internal use.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// var kq = try ISO_9945.Kernel.Event.Queue()
    /// try kq.register(events: [event])
    /// let count = try kq.poll(into: &events, timeout: .seconds(1))
    /// // kq deinit closes the kqueue fd
    /// ```
    @safe
    public struct Queue: ~Copyable, Sendable {
        /// The underlying kqueue file descriptor.
        internal let descriptor: ISO_9945.Kernel.Descriptor

        /// Creates a new kqueue instance.
        ///
        /// - Throws: `Error.create` if kqueue creation fails.
        public init() throws(Error) {
            self.descriptor = try ISO_9945.Kernel.Descriptor(_rawValue: Self.create())
        }
    }
}

// MARK: - Public Instance API

extension ISO_9945.Kernel.Event.Queue {
    /// Registers events without waiting.
    ///
    /// - Parameter events: Array of events to register/modify.
    /// - Throws: `Error.kevent` on failure.
    public func register(events: [Event]) throws(Error) {
        try Self.register(self, events: events)
    }

    /// Waits for events.
    ///
    /// - Parameters:
    ///   - events: Buffer for returned events (pre-sized).
    ///   - timeout: Timeout duration, or `nil` for infinite.
    /// - Returns: Number of events written to buffer.
    /// - Throws: `Error.kevent` on failure, `.interrupted` on EINTR.
    public func poll(into events: inout [Event], timeout: Duration?) throws(Error) -> Int {
        try Self.poll(self, into: &events, timeout: timeout)
    }

    /// Creates a Sendable signal closure for cross-thread poll interruption.
    ///
    /// Registers `EVFILT_USER` on this kqueue instance and returns a
    /// `@Sendable` closure that triggers it from any thread. Call before
    /// transferring the Queue to the poll thread via `sending`.
    ///
    /// L3 consumers wrap the returned closure into `Kernel.Wakeup.Channel(signal:)`
    /// at the site of use; the closure carries the raw fd capture so L3 callers
    /// never see `_rawValue` (typed-everywhere discipline per [PLAT-ARCH-008j]).
    public func wakeup() throws(Error) -> @Sendable () -> Void {
        let wakeupEvent = Event(id: .zero, filter: .user, flags: .add | .clear)
        try self.register(events: [wakeupEvent])

        let rawFd = self.descriptor._rawValue
        return {
            let trigger = Event(id: .zero, filter: .user, flags: .none, fflags: .trigger)
            do throws(Error) {
                try Self.register(rawDescriptor: rawFd, events: [trigger])
            } catch {
                if case .kevent(let code) = error,
                   code == .POSIX.EBADF || code == .POSIX.ENOENT
                {
                    // Benign: kqueue fd closed during shutdown.
                } else {
                    assertionFailure("wakeup trigger failed: \(error)")
                }
            }
        }
    }
}

// MARK: - Syscall Bridge

@_silgen_name("kevent")
internal func _kevent(
    _ kq: Int32,
    _ changelist: UnsafePointer<kevent>?,
    _ nchanges: Int32,
    _ eventlist: UnsafeMutablePointer<kevent>?,
    _ nevents: Int32,
    _ timeout: UnsafePointer<timespec>?
) -> Int32

// MARK: - Package Statics (C API Mirror)

extension ISO_9945.Kernel.Event.Queue {
    /// Creates a new kqueue, returning the raw fd.
    ///
    /// Spec-literal: returns the raw `Int32` fd. Zero descriptor construction:
    /// the L3-policy wrapper at swift-darwin wraps the result via
    /// `ISO_9945.Kernel.Descriptor(_rawValue:)` per [PLAT-ARCH-005] / [PLAT-ARCH-008e].
    /// § 5.6 handle-returning bifurcation.
    package static func create() throws(ISO_9945.Kernel.Event.Queue.Error) -> Int32 {
        let kq = kqueue()
        guard kq >= 0 else {
            throw .create(.posix(errno))
        }
        return kq
    }

    /// Registers events without waiting.
    package static func register(
        _ kq: borrowing ISO_9945.Kernel.Event.Queue,
        events: [Event]
    ) throws(ISO_9945.Kernel.Event.Queue.Error) {
        guard !events.isEmpty else { return }

        try unsafe withUnsafeTemporaryAllocation(
            of: CKevent.self,
            capacity: events.count
        ) { (buffer) throws(ISO_9945.Kernel.Event.Queue.Error) in
            for i in 0..<events.count {
                unsafe (buffer[i] = unsafe events[i].cValue)
            }
            let result = unsafe _kevent(
                kq.descriptor._rawValue, buffer.baseAddress, Int32(events.count), nil, 0, nil
            )
            guard result >= 0 else {
                let code = Error_Primitives.Error.Code.posix(errno)
                if code.posix == EINTR { throw .interrupted }
                throw .kevent(code)
            }
        }
    }

    /// Registers events using a raw file descriptor value.
    ///
    /// For contexts where a `ISO_9945.Kernel.Descriptor` borrow cannot be maintained
    /// (e.g., `@Sendable` closures that outlive the descriptor's lexical scope).
    package static func register(
        rawDescriptor kq: Int32,
        events: [Event]
    ) throws(ISO_9945.Kernel.Event.Queue.Error) {
        guard !events.isEmpty else { return }

        try unsafe withUnsafeTemporaryAllocation(
            of: CKevent.self,
            capacity: events.count
        ) { (buffer) throws(ISO_9945.Kernel.Event.Queue.Error) in
            for i in 0..<events.count {
                unsafe (buffer[i] = unsafe events[i].cValue)
            }
            let result = unsafe _kevent(
                kq, buffer.baseAddress, Int32(events.count), nil, 0, nil
            )
            guard result >= 0 else {
                let code = Error_Primitives.Error.Code.posix(errno)
                if code.posix == EINTR { throw .interrupted }
                throw .kevent(code)
            }
        }
    }
}

// MARK: - Package Statics: Polling

extension ISO_9945.Kernel.Event.Queue {
    /// Waits for events (array variant).
    package static func poll(
        _ kq: borrowing ISO_9945.Kernel.Event.Queue,
        into events: inout [Event],
        timeout: Duration?
    ) throws(ISO_9945.Kernel.Event.Queue.Error) -> Int {
        guard !events.isEmpty else { return 0 }
        let count = events.count

        return try unsafe withUnsafeTemporaryAllocation(
            of: CKevent.self,
            capacity: count
        ) { (buffer) throws(ISO_9945.Kernel.Event.Queue.Error) -> Int in
            let result: Int32
            if var ts = timespec(timeout) {
                result = unsafe _kevent(kq.descriptor._rawValue, nil, 0, buffer.baseAddress, Int32(count), &ts)
            } else {
                result = unsafe _kevent(kq.descriptor._rawValue, nil, 0, buffer.baseAddress, Int32(count), nil)
            }
            guard result >= 0 else {
                let code = Error_Primitives.Error.Code.posix(errno)
                if code.posix == EINTR { throw .interrupted }
                throw .kevent(code)
            }
            let eventCount = Int(result)
            for i in 0..<eventCount {
                events[i] = unsafe Event(buffer[i])
            }
            return eventCount
        }
    }

    /// Waits for events (buffer pointer variant).
    package static func poll(
        _ kq: borrowing ISO_9945.Kernel.Event.Queue,
        into events: UnsafeMutableBufferPointer<Event>,
        timeout: Duration?
    ) throws(ISO_9945.Kernel.Event.Queue.Error) -> Int {
        guard !events.isEmpty else { return 0 }
        let count = events.count

        return try unsafe withUnsafeTemporaryAllocation(
            of: CKevent.self,
            capacity: count
        ) { (buffer) throws(ISO_9945.Kernel.Event.Queue.Error) -> Int in
            let result: Int32
            if var ts = timespec(timeout) {
                result = unsafe _kevent(kq.descriptor._rawValue, nil, 0, buffer.baseAddress, Int32(count), &ts)
            } else {
                result = unsafe _kevent(kq.descriptor._rawValue, nil, 0, buffer.baseAddress, Int32(count), nil)
            }
            guard result >= 0 else {
                let code = Error_Primitives.Error.Code.posix(errno)
                if code.posix == EINTR { throw .interrupted }
                throw .kevent(code)
            }
            let eventCount = Int(result)
            for i in 0..<eventCount {
                unsafe (events[i] = unsafe Event(buffer[i]))
            }
            return eventCount
        }
    }
}

#endif
