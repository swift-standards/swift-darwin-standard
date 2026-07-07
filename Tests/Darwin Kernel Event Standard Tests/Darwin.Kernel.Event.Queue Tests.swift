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
    import ISO_9945_Kernel_Test_Support
    @testable import Darwin_Kernel_Event_Standard

    private typealias Kernel = ISO_9945.Kernel

    extension ISO_9945.Kernel.Event.Test {
        /// Best-effort close, ignoring errors (test cleanup only).
        static func closeNoThrow(_ rawDescriptor: Int32) {
            try? ISO_9945.Kernel.Close.close(ISO_9945.Kernel.Descriptor(_rawValue: rawDescriptor))
        }
    }

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

            #expect(kq >= 0)
        }

        @Test
        func `Kqueue namespace exists`() {
            // Type check - ensures the namespace compiles
            _ = Kernel.Event.Queue.self
        }
    }

#endif
