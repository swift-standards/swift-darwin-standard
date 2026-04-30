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

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

public import Darwin_Standard_Core
import CDarwinMemoryShim

extension Darwin_Standard_Core.Darwin.Memory.Allocation {
    /// Memory allocation statistics for Darwin platforms.
    ///
    /// Uses `malloc_zone_statistics` to capture current allocation state.
    public struct Statistics: Sendable, Equatable {
        /// Number of allocations (blocks in use).
        public let allocations: Int

        /// Number of deallocations.
        public let deallocations: Int

        /// Total bytes allocated.
        public let bytesAllocated: Int

        /// Initialize allocation statistics.
        ///
        /// - Parameters:
        ///   - allocations: Number of allocations.
        ///   - deallocations: Number of deallocations.
        ///   - bytesAllocated: Total bytes allocated.
        public init(allocations: Int = 0, deallocations: Int = 0, bytesAllocated: Int = 0) {
            self.allocations = allocations
            self.deallocations = deallocations
            self.bytesAllocated = bytesAllocated
        }
    }
}

extension Darwin_Standard_Core.Darwin.Memory.Allocation.Statistics {
    /// Capture current allocation statistics.
    ///
    /// Uses Darwin's `malloc_zone_statistics` to retrieve memory allocation
    /// information from the default malloc zone.
    ///
    /// - Returns: Current allocation statistics.
    public static func capture() -> Self {
        var stats = malloc_statistics_t()
        unsafe darwin_malloc_zone_statistics(&stats)

        return Self(
            allocations: Int(stats.blocks_in_use),
            deallocations: 0,
            bytesAllocated: Int(stats.size_in_use)
        )
    }
}

#endif
