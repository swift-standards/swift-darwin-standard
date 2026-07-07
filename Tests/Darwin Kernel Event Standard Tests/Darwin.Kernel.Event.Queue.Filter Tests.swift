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

    extension Kernel.Event.Queue.Filter {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Bridging Unit Tests

    extension Kernel.Event.Queue.Filter.Test.Unit {

        @Test
        func `read and write filters are distinct`() {
            #expect(Kernel.Event.Queue.Filter.read != .write)
            #expect(Kernel.Event.Queue.Filter.read.rawValue != Kernel.Event.Queue.Filter.write.rawValue)
        }

        @Test
        func `read filter rawValue matches EVFILT_READ`() {
            #expect(Kernel.Event.Queue.Filter.read.rawValue == Int16(EVFILT_READ))
        }

        @Test
        func `write filter rawValue matches EVFILT_WRITE`() {
            #expect(Kernel.Event.Queue.Filter.write.rawValue == Int16(EVFILT_WRITE))
        }

        @Test
        func `user filter rawValue matches EVFILT_USER`() {
            #expect(Kernel.Event.Queue.Filter.user.rawValue == Int16(EVFILT_USER))
        }

        @Test
        func `filter conforms to Equatable`() {
            let filter1 = Kernel.Event.Queue.Filter.read
            let filter2 = Kernel.Event.Queue.Filter.read
            let filter3 = Kernel.Event.Queue.Filter.write

            #expect(filter1 == filter2)
            #expect(filter1 != filter3)
        }

        @Test
        func `filter conforms to Hashable`() {
            let filter1 = Kernel.Event.Queue.Filter.read
            let filter2 = Kernel.Event.Queue.Filter.read

            #expect(filter1.hashValue == filter2.hashValue)
        }
    }

#endif
