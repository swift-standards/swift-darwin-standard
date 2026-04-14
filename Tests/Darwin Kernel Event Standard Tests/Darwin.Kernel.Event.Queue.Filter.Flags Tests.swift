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
        @Test("init with rawValue stores value")
        func initWithRawValue() {
            let flags = Kernel.Event.Queue.Filter.Flags(rawValue: 42)
            #expect(flags.rawValue == 42)
        }

        @Test("none has rawValue of 0")
        func noneHasZeroRawValue() {
            #expect(Kernel.Event.Queue.Filter.Flags.none.rawValue == 0)
        }

        @Test("trigger matches NOTE_TRIGGER")
        func triggerMatchesNoteTrigger() {
            #expect(Kernel.Event.Queue.Filter.Flags.trigger.rawValue == UInt32(NOTE_TRIGGER))
        }

        @Test("flags can be combined with |")
        func flagsCombineWithOr() {
            let combined = Kernel.Event.Queue.Filter.Flags.trigger | Kernel.Event.Queue.Filter.Flags.none
            #expect(combined.rawValue == Kernel.Event.Queue.Filter.Flags.trigger.rawValue)
        }

        @Test("contains returns true for contained flag")
        func containsReturnsTrueForContained() {
            let flags = Kernel.Event.Queue.Filter.Flags.trigger
            #expect(flags.contains(.trigger))
        }

        @Test("contains returns true for none in any flags")
        func containsReturnsTrueForNone() {
            let flags = Kernel.Event.Queue.Filter.Flags.trigger
            #expect(flags.contains(.none))
        }

        @Test("contains returns false for non-contained flag")
        func containsReturnsFalseForNonContained() {
            let flags = Kernel.Event.Queue.Filter.Flags.none
            #expect(!flags.contains(.trigger))
        }

        @Test("rawValue roundtrip preserves value")
        func rawValueRoundtrip() {
            let original: UInt32 = 0xDEAD_BEEF
            let flags = Kernel.Event.Queue.Filter.Flags(rawValue: original)
            #expect(flags.rawValue == original)
        }
    }

    // MARK: - Conformance Tests

    extension Kernel.Event.Queue.Filter.Flags.Test.Unit {
        @Test("Flags is Sendable")
        func isSendable() {
            let flags: any Sendable = Kernel.Event.Queue.Filter.Flags.trigger
            #expect(flags is Kernel.Event.Queue.Filter.Flags)
        }

        @Test("Flags is Equatable")
        func isEquatable() {
            let a = Kernel.Event.Queue.Filter.Flags.trigger
            let b = Kernel.Event.Queue.Filter.Flags.trigger
            let c = Kernel.Event.Queue.Filter.Flags.none
            #expect(a == b)
            #expect(a != c)
        }

        @Test("Flags is Hashable")
        func isHashable() {
            var set = Set<Kernel.Event.Queue.Filter.Flags>()
            set.insert(.trigger)
            set.insert(.none)
            set.insert(.trigger)  // duplicate
            #expect(set.count == 2)
        }
    }

    // MARK: - Edge Cases

    extension Kernel.Event.Queue.Filter.Flags.Test.EdgeCase {
        @Test("combining same flag is idempotent")
        func combiningIdempotent() {
            let combined = Kernel.Event.Queue.Filter.Flags.trigger | .trigger
            #expect(combined == .trigger)
        }

        @Test("combining with none is identity")
        func combiningWithNoneIsIdentity() {
            let combined = Kernel.Event.Queue.Filter.Flags.trigger | .none
            #expect(combined == .trigger)
        }

        @Test("none combined with none is none")
        func noneCombinedWithNone() {
            let combined = Kernel.Event.Queue.Filter.Flags.none | .none
            #expect(combined == .none)
        }
    }
#endif
