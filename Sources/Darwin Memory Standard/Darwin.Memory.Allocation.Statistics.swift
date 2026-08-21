#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

    public import Darwin_Standard_Core
    import Darwin_Memory_Shims

    extension Darwin_Standard_Core.Darwin.Memory.Allocation {

        public struct Statistics: Sendable, Equatable {

            public let allocations: Int

            public let deallocations: Int

            public let bytesAllocated: Int

            public init(allocations: Int = 0, deallocations: Int = 0, bytesAllocated: Int = 0) {
                self.allocations = allocations
                self.deallocations = deallocations
                self.bytesAllocated = bytesAllocated
            }
        }
    }

    extension Darwin_Standard_Core.Darwin.Memory.Allocation.Statistics {

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
