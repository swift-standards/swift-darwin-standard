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

    @testable import Darwin_Kernel_Event_Standard

    extension Kernel.Event.Queue.Filter.Flags {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Unit Tests

    extension Kernel.Event.Queue.Filter.Flags.Test.Unit {
        @Test
        func `init with rawValue stores value`() {
            let flags = Kernel.Event.Queue.Filter.Flags(rawValue: 42)
            #expect(flags.rawValue == 42)
        }

        @Test
        func `none has rawValue of 0`() {
            #expect(Kernel.Event.Queue.Filter.Flags.none.rawValue == 0)
        }

        @Test
        func `trigger matches NOTE_TRIGGER`() {
            #expect(Kernel.Event.Queue.Filter.Flags.trigger.rawValue == UInt32(NOTE_TRIGGER))
        }

        @Test
        func `flags can be combined with |`() {
            let combined = Kernel.Event.Queue.Filter.Flags.trigger | Kernel.Event.Queue.Filter.Flags.none
            #expect(combined.rawValue == Kernel.Event.Queue.Filter.Flags.trigger.rawValue)
        }

        @Test
        func `contains returns true for contained flag`() {
            let flags = Kernel.Event.Queue.Filter.Flags.trigger
            #expect(flags.contains(.trigger))
        }

        @Test
        func `contains returns true for none in any flags`() {
            let flags = Kernel.Event.Queue.Filter.Flags.trigger
            #expect(flags.contains(.none))
        }

        @Test
        func `contains returns false for non-contained flag`() {
            let flags = Kernel.Event.Queue.Filter.Flags.none
            #expect(!flags.contains(.trigger))
        }

        @Test
        func `rawValue roundtrip preserves value`() {
            let original: UInt32 = 0xDEAD_BEEF
            let flags = Kernel.Event.Queue.Filter.Flags(rawValue: original)
            #expect(flags.rawValue == original)
        }
    }

    // MARK: - Conformance Tests

    extension Kernel.Event.Queue.Filter.Flags.Test.Unit {
        @Test
        func `Flags is Sendable`() {
            let flags: any Sendable = Kernel.Event.Queue.Filter.Flags.trigger
            #expect(flags is Kernel.Event.Queue.Filter.Flags)
        }

        @Test
        func `Flags is Equatable`() {
            let a = Kernel.Event.Queue.Filter.Flags.trigger
            let b = Kernel.Event.Queue.Filter.Flags.trigger
            let c = Kernel.Event.Queue.Filter.Flags.none
            #expect(a == b)
            #expect(a != c)
        }

        @Test
        func `Flags is Hashable`() {
            var set = Set<Kernel.Event.Queue.Filter.Flags>()
            set.insert(.trigger)
            set.insert(.none)
            set.insert(.trigger)  // duplicate
            #expect(set.count == 2)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.Event.Queue.Filter.Flags.Test.EdgeCase {
        @Test
        func `combining same flag is idempotent`() {
            let combined = Kernel.Event.Queue.Filter.Flags.trigger | .trigger
            #expect(combined == .trigger)
        }

        @Test
        func `combining with none is identity`() {
            let combined = Kernel.Event.Queue.Filter.Flags.trigger | .none
            #expect(combined == .trigger)
        }

        @Test
        func `none combined with none is none`() {
            let combined = Kernel.Event.Queue.Filter.Flags.none | .none
            #expect(combined == .none)
        }
    }
#endif
