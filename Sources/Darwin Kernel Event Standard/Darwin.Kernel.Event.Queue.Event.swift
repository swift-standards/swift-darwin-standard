public import ISO_9945_Core

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

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    internal import Darwin

    extension Kernel.Event.Queue {
        /// A kqueue event describing an event source and its state.
        ///
        /// Events are used both for registering interest (input) and receiving
        /// notifications (output). When registering, you specify what to monitor;
        /// when receiving, you get details about what happened.
        ///
        /// ## Usage
        ///
        /// ```swift
        /// // Register interest in read events on a socket
        /// let event = Kernel.Event.Queue.Event(
        ///     id: Kernel.Event.ID(socketFd.rawValue),
        ///     filter: .read,
        ///     flags: .add | .enable
        /// )
        /// try Kernel.Event.Queue.register(kq, events: [event])
        ///
        /// // Process returned events
        /// for event in results {
        ///     if event.filter == .read {
        ///         let bytesAvailable = event.filterData
        ///         // Read from event.id
        ///     }
        /// }
        /// ```
        ///
        /// ## See Also
        ///
        /// - ``Kernel/Event/Queue``
        /// - ``Kernel/Event/Queue/Filter``
        /// - ``Kernel/Event/Queue/Flags``
        public struct Event: Sendable, Equatable, Hashable, BitwiseCopyable {
            /// Identifier for this event.
            ///
            /// The meaning depends on the filter type:
            /// - `EVFILT_READ`, `EVFILT_WRITE`: file descriptor
            /// - `EVFILT_SIGNAL`: signal number
            /// - `EVFILT_PROC`: process ID
            public var id: Kernel.Event.ID

            /// Filter type (EVFILT_READ, EVFILT_WRITE, etc.).
            public var filter: Filter

            /// Action and status flags (EV_ADD, EV_DELETE, etc.).
            public var flags: Flags

            /// Filter-specific flags.
            public var fflags: Filter.Flags

            /// Filter-specific data (e.g., bytes available for read).
            public var filterData: Filter.Data

            /// User-defined data for event routing.
            ///
            /// Typically stores an ID to dispatch the event to the correct handler.
            public var data: Data

            /// Creates a kqueue event.
            ///
            /// - Parameters:
            ///   - id: Event source identifier.
            ///   - filter: Filter type.
            ///   - flags: Action and behavior flags.
            ///   - fflags: Filter-specific flags.
            ///   - filterData: Filter-specific data.
            ///   - data: User-defined routing data.
            public init(
                id: Kernel.Event.ID,
                filter: Filter,
                flags: Flags,
                fflags: Filter.Flags = .none,
                filterData: Filter.Data = .zero,
                data: Data = .zero
            ) {
                self.id = id
                self.filter = filter
                self.flags = flags
                self.fflags = fflags
                self.filterData = filterData
                self.data = data
            }
        }
    }

    // MARK: - Darwin Conversion

    extension Kernel.Event.Queue.Event {
        /// Creates an Event from the Darwin kevent struct.
        @unsafe
        internal init(_ cEvent: kevent) {
            self.id = unsafe Kernel.Event.ID(__unchecked: (), cEvent.ident)
            self.filter = unsafe Kernel.Event.Queue.Filter(rawValue: cEvent.filter)
            self.flags = unsafe Kernel.Event.Queue.Flags(rawValue: cEvent.flags)
            self.fflags = unsafe Kernel.Event.Queue.Filter.Flags(rawValue: cEvent.fflags)
            self.filterData = unsafe Kernel.Event.Queue.Filter.Data(__unchecked: (), cEvent.data)
            self.data = unsafe Data(cEvent.udata)
        }

        /// Converts to the Darwin kevent struct.
        @unsafe
        internal var cValue: kevent {
            var ev = unsafe kevent()
            unsafe (ev.ident = id.rawValue)
            unsafe (ev.filter = filter.rawValue)
            unsafe (ev.flags = flags.rawValue)
            unsafe (ev.fflags = fflags.rawValue)
            unsafe (ev.data = filterData.rawValue)
            unsafe (ev.udata = UnsafeMutableRawPointer(data))
            return unsafe ev
        }
    }

#endif
