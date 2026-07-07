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

    import Darwin_Kernel_Event_Standard_Test_Support
    @testable import Darwin_Kernel_Event_Standard

    extension Kernel.Event.Queue {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Syscall Unit Tests

    extension Kernel.Event.Queue.Test.Unit {

        // MARK: - Lifecycle Tests

        @Test
        func `create returns valid kqueue descriptor`() throws {
            let kq = try Kernel.Event.Queue.create()
            defer { Kernel.Event.Test.closeNoThrow(kq) }

            #expect(kq.rawValue >= 0)
        }

        @Test
        func `Kqueue namespace exists`() {
            // Type check - ensures the namespace compiles
            _ = Kernel.Event.Queue.self
        }
    }

#endif
