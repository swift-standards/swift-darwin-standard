public import ISO_9945_Core

// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

    extension ISO_9945.Kernel.Event.Queue.Filter {
        /// Kernel-returned data from a kqueue event.
        ///
        /// This is an opaque value whose interpretation depends on the filter type.
        ///
        /// The kernel populates this field when an event fires.
        ///
        /// ## Filter-Specific Meanings
        ///
        /// | Filter | Data Interpretation |
        /// |--------|---------------------|
        /// | `.read` | Bytes available to read |
        /// | `.write` | Bytes available in write buffer |
        /// | `.timer` | Number of times timer fired |
        /// | `.vnode` | 0 |
        /// | `.proc` | 0 |
        /// | `.signal` | Number of times signal delivered |
        /// | `.user` | User-defined data |
        ///
        /// ## Usage
        ///
        /// ```swift
        /// for event in events {
        ///     if event.filter == .read {
        ///         let bytesAvailable = Int(event.filterData)
        ///         // Read up to bytesAvailable bytes
        ///     }
        /// }
        /// ```
        ///
        /// - Note: Primarily output data. When registering events, use `.zero`.
        ///
        /// ## See Also
        ///
        /// - ``Kernel/Event/Queue/Event``
        /// - ``Kernel/Event/Queue/Filter``
        public typealias Data = Tagged<ISO_9945.Kernel.Event.Queue.Filter, Int>
    }

    // MARK: - Common Values

    extension ISO_9945.Kernel.Event.Queue.Filter.Data {
        /// Zero filter data (default for event registration).
        public static let zero: Self = Self(_unchecked: 0)
    }

#endif
