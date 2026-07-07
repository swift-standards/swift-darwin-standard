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
    @testable import Darwin_Kernel_Event_Standard

    private typealias Kernel = ISO_9945.Kernel

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

        @Test
        func `add and delete flags are distinct`() {
            #expect(Kernel.Event.Queue.Flags.add != .delete)
            #expect(Kernel.Event.Queue.Flags.add.rawValue != Kernel.Event.Queue.Flags.delete.rawValue)
        }

        @Test
        func `flags combine with OR operator`() {
            let combined = Kernel.Event.Queue.Flags.add | .enable
            #expect(combined.contains(.add))
            #expect(combined.contains(.enable))
            #expect(!combined.contains(.delete))
        }

        @Test
        func `contains detects single flag`() {
            #expect(Kernel.Event.Queue.Flags.add.contains(.add))
            #expect(!Kernel.Event.Queue.Flags.add.contains(.delete))
        }

        @Test
        func `none has rawValue zero`() {
            #expect(Kernel.Event.Queue.Flags.none.rawValue == 0)
        }

        @Test
        func `add flag rawValue matches EV_ADD`() {
            #expect(Kernel.Event.Queue.Flags.add.rawValue == UInt16(EV_ADD))
        }

        @Test
        func `delete flag rawValue matches EV_DELETE`() {
            #expect(Kernel.Event.Queue.Flags.delete.rawValue == UInt16(EV_DELETE))
        }
    }

#endif
