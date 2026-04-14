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

    // Kernel.Event.Queue.Filter.Data is a typealias to Tagged<Kernel.Event.Queue.Filter, Int>
    // Use a custom test suite since #Tests cannot be used on typealiases

    @Suite("Kernel.Event.Queue.Filter.Data Tests")
    struct KqueueFilterDataTests {

        // MARK: - Unit Tests

        @Test("zero constant equals 0")
        func zeroConstant() {
            let zero = Kernel.Event.Queue.Filter.Data.zero
            #expect(zero == 0)
        }

        @Test("init from Int stores value")
        func initFromInt() {
            let data = Kernel.Event.Queue.Filter.Data(42)
            #expect(data == 42)
        }

        @Test("literal initialization works")
        func literalInit() {
            let data: Kernel.Event.Queue.Filter.Data = 100
            #expect(data == 100)
        }

        @Test("negative values are preserved")
        func negativeValues() {
            let data = Kernel.Event.Queue.Filter.Data(-1)
            #expect(data == -1)
        }

        // MARK: - Conformance Tests

        @Test("Data is Sendable")
        func isSendable() {
            let data: any Sendable = Kernel.Event.Queue.Filter.Data.zero
            #expect(data is Kernel.Event.Queue.Filter.Data)
        }

        @Test("Data is Equatable")
        func isEquatable() {
            let a = Kernel.Event.Queue.Filter.Data(42)
            let b = Kernel.Event.Queue.Filter.Data(42)
            let c = Kernel.Event.Queue.Filter.Data(0)
            #expect(a == b)
            #expect(a != c)
        }

        @Test("Data is Hashable")
        func isHashable() {
            var set = Set<Kernel.Event.Queue.Filter.Data>()
            set.insert(Kernel.Event.Queue.Filter.Data(1))
            set.insert(Kernel.Event.Queue.Filter.Data(2))
            set.insert(Kernel.Event.Queue.Filter.Data(1))  // duplicate
            #expect(set.count == 2)
        }

        // MARK: - Edge Cases

        @Test("Int.max is preserved")
        func intMaxPreserved() {
            let data = Kernel.Event.Queue.Filter.Data(Int.max)
            #expect(data.rawValue == Int.max)
        }

        @Test("Int.min is preserved")
        func intMinPreserved() {
            let data = Kernel.Event.Queue.Filter.Data(Int.min)
            #expect(data.rawValue == Int.min)
        }
    }
#endif
