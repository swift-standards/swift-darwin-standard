#if canImport(Darwin)

    import Darwin_Memory_Standard
    import Darwin_Standard_Core
    import Testing

    enum `Darwin.Memory.Allocation.Statistics Tests` {}

    extension `Darwin.Memory.Allocation.Statistics Tests` {
        @Suite
        struct Test {
            @Suite struct Unit {}
        }
    }

    extension `Darwin.Memory.Allocation.Statistics Tests`.Test.Unit {
        @Test
        func `capture reports the blocks and bytes in use`() {
            let snapshot = Darwin.Memory.Allocation.Statistics.capture()
            #expect(snapshot.blocksInUse > 0)
            #expect(snapshot.bytesInUse >= snapshot.blocksInUse)
        }

        @Test
        func `bytes in use grow while an allocation is held`() {
            let before = Darwin.Memory.Allocation.Statistics.capture()
            let held = [UInt8](repeating: 1, count: 1 << 20)
            let during = Darwin.Memory.Allocation.Statistics.capture()
            withExtendedLifetime(held) {
                #expect(during.bytesInUse > before.bytesInUse)
            }
        }
    }

#endif
