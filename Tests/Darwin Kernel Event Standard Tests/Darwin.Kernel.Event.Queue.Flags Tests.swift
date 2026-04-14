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

    extension Kernel.Event.Queue.Flags {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Bridging Unit Tests

    extension Kernel.Event.Queue.Flags.Test.Unit {

        @Test("add and delete flags are distinct")
        func addAndDeleteAreDistinct() {
            #expect(Kernel.Event.Queue.Flags.add != .delete)
            #expect(Kernel.Event.Queue.Flags.add.rawValue != Kernel.Event.Queue.Flags.delete.rawValue)
        }

        @Test("flags combine with OR operator")
        func flagsCombineWithOrOperator() {
            let combined = Kernel.Event.Queue.Flags.add | .enable
            #expect(combined.contains(.add))
            #expect(combined.contains(.enable))
            #expect(!combined.contains(.delete))
        }

        @Test("contains detects single flag")
        func containsDetectsSingleFlag() {
            #expect(Kernel.Event.Queue.Flags.add.contains(.add))
            #expect(!Kernel.Event.Queue.Flags.add.contains(.delete))
        }

        @Test("none has rawValue zero")
        func noneHasRawValueZero() {
            #expect(Kernel.Event.Queue.Flags.none.rawValue == 0)
        }

        @Test("add flag rawValue matches EV_ADD")
        func addRawValueMatchesEVADD() {
            #expect(Kernel.Event.Queue.Flags.add.rawValue == UInt16(EV_ADD))
        }

        @Test("delete flag rawValue matches EV_DELETE")
        func deleteRawValueMatchesEVDELETE() {
            #expect(Kernel.Event.Queue.Flags.delete.rawValue == UInt16(EV_DELETE))
        }
    }

#endif
