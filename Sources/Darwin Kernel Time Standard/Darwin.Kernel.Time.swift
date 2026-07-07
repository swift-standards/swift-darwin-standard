// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-darwin open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-darwin project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if canImport(Darwin)
    import Darwin

    // MARK: - timespec from Duration

    extension timespec {
        /// Creates a timespec from a Swift Duration.
        ///
        /// - Parameter duration: The duration to convert.
        package init(_ duration: Duration) {
            let (seconds, attoseconds) = duration.components
            let nanoseconds = attoseconds / 1_000_000_000
            self.init(tv_sec: Int(seconds), tv_nsec: Int(nanoseconds))
        }

        /// Creates a timespec from an optional Duration.
        ///
        /// - Parameter duration: The duration to convert, or `nil`.
        ///
        /// - Returns: A timespec, or `nil` if duration was `nil`.
        package init?(_ duration: Duration?) {
            guard let duration else { return nil }
            self.init(duration)
        }
    }

#endif
