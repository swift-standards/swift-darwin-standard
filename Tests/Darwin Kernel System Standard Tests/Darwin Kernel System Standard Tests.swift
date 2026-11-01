#if canImport(Darwin)

    import Darwin_Kernel_System_Standard
    import ISO_9945_Kernel_System
    import Testing

    @Suite
    struct `CPU.Core.count Tests` {
        @Test
        func `count is at least one`() {
            #expect(Int(CPU.Core.count) >= 1)
        }

        @Test
        func `count does not exceed the logical count`() {
            #expect(Int(CPU.Core.count) <= Int(CPU.Logical.count))
        }
    }

    @Suite
    struct `Memory.Physical.capacity Tests` {
        @Test
        func `capacity exceeds one mebibyte`() {
            #expect(Int(Memory.Physical.capacity) > 1024 * 1024)
        }

        @Test
        func `capacity is consistent across reads`() {
            #expect(Memory.Physical.capacity == Memory.Physical.capacity)
        }
    }

    @Suite
    struct `CPU.NUMA.state Tests` {
        @Test
        func `Darwin reports no NUMA topology`() {
            #expect(CPU.NUMA.state == .unavailable)
        }
    }

#endif
