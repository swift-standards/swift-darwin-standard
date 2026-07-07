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

#if canImport(Darwin)
    import Darwin
    import Testing

    @_spi(Syscall) import ISO_9945_Core
    import ISO_9945_Kernel_File
    import ISO_9945_Kernel_Test_Support
    @testable import Darwin_Kernel_Event_Standard

    private typealias Kernel = ISO_9945.Kernel

    extension Kernel.Event.Queue.Event {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Bridging Unit Tests

    extension Kernel.Event.Queue.Event.Test.Unit {

        @Test
        func `event roundtrips through C conversion`() throws {
            // `pipe`'s Descriptor fields close themselves on deinit
            // (best-effort, per ISO_9945.Kernel.Close docs) — no manual
            // close needed, and `.read`/`.write` are borrow-only so
            // there's nothing consumable to extract ahead of that.
            let pipe = try Kernel.Event.Test.makePipe()

            let original = Kernel.Event.Queue.Event(
                id: Kernel.Event.ID(pipe.read._rawValue),
                filter: .read,
                flags: .add | .enable,
                fflags: .none,
                filterData: .zero,
                data: Kernel.Event.Queue.Event.Data(42)
            )

            // Convert to C and back
            let cEvent = original.cValue
            let restored = Kernel.Event.Queue.Event(cEvent)

            #expect(restored.id == original.id)
            #expect(restored.filter == original.filter)
            #expect(restored.flags == original.flags)
            #expect(restored.fflags == original.fflags)
            // Note: data may not roundtrip perfectly due to pointer conversion
        }

        @Test
        func `event data roundtrips value`() {
            let data = Kernel.Event.Queue.Event.Data(12345)
            #expect(data == 12345)
        }

        @Test
        func `event data zero constant exists`() {
            let data = Kernel.Event.Queue.Event.Data.zero
            #expect(data == 0)
        }

        @Test
        func `event conforms to Equatable`() {
            let event1 = Kernel.Event.Queue.Event(
                id: Kernel.Event.ID(UInt(42)),
                filter: .read,
                flags: .add
            )
            let event2 = Kernel.Event.Queue.Event(
                id: Kernel.Event.ID(UInt(42)),
                filter: .read,
                flags: .add
            )
            let event3 = Kernel.Event.Queue.Event(
                id: Kernel.Event.ID(UInt(42)),
                filter: .write,
                flags: .add
            )

            #expect(event1 == event2)
            #expect(event1 != event3)
        }

        @Test
        func `event conforms to Hashable`() {
            let event1 = Kernel.Event.Queue.Event(
                id: Kernel.Event.ID(UInt(42)),
                filter: .read,
                flags: .add
            )
            let event2 = Kernel.Event.Queue.Event(
                id: Kernel.Event.ID(UInt(42)),
                filter: .read,
                flags: .add
            )

            #expect(event1.hashValue == event2.hashValue)
        }
    }

#endif
