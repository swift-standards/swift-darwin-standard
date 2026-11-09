#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

    public import Darwin_Standard_Core
    import Darwin_Memory_Shims

    extension Darwin_Standard_Core::Darwin.Memory.Allocation {

        /// A snapshot of the default malloc zone: what is in use at the moment of capture,
        /// not running counts of allocations and deallocations.
        public struct Statistics: Sendable, Equatable {

            /// The number of heap blocks in use.
            public let blocksInUse: Int

            /// The number of bytes in use by those blocks.
            public let bytesInUse: Int

            public init(blocksInUse: Int = 0, bytesInUse: Int = 0) {
                self.blocksInUse = blocksInUse
                self.bytesInUse = bytesInUse
            }
        }
    }

    extension Darwin_Standard_Core::Darwin.Memory.Allocation.Statistics {

        public static func capture() -> Self {
            var stats = malloc_statistics_t()
            unsafe darwin_malloc_zone_statistics(&stats)

            return Self(
                blocksInUse: Int(stats.blocks_in_use),
                bytesInUse: Int(stats.size_in_use)
            )
        }
    }

#endif
