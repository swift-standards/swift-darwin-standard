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

    // Kernel.Event.Queue.Event.Data is a typealias to Tagged<Kernel.Event.Queue.Event, UInt64>
    // Use a custom test suite since #Tests cannot be used on typealiases

    @Suite("Kernel.Event.Queue.Event.Data Tests")
    struct KqueueEventDataTests {

        // MARK: - Unit Tests

        @Test
        func `zero constant equals 0`() {
            let zero = Kernel.Event.Queue.Event.Data.zero
            #expect(zero == 0)
        }

        @Test
        func `init from UInt64 stores value`() {
            let data = Kernel.Event.Queue.Event.Data(42)
            #expect(data == 42)
        }

        @Test
        func `literal initialization works`() {
            let data: Kernel.Event.Queue.Event.Data = 100
            #expect(data == 100)
        }

        // MARK: - Pointer Conversion Tests

        @Test
        func `init from optional mutable raw pointer preserves bitPattern`() {
            var value: Int = 42
            let pointer: UnsafeMutableRawPointer? = withUnsafeMutablePointer(to: &value) {
                UnsafeMutableRawPointer($0)
            }
            let data = Kernel.Event.Queue.Event.Data(pointer)
            #expect(data.rawValue == UInt64(UInt(bitPattern: pointer)))
        }

        @Test
        func `init from nil pointer gives zero`() {
            let pointer: UnsafeMutableRawPointer? = nil
            let data = Kernel.Event.Queue.Event.Data(pointer)
            #expect(data == 0)
        }

        @Test
        func `init from raw pointer preserves bitPattern`() {
            var value: Int = 42
            let data = withUnsafePointer(to: &value) { ptr in
                Kernel.Event.Queue.Event.Data(UnsafeRawPointer(ptr))
            }
            #expect(data != 0)
        }

        @Test
        func `init from typed pointer preserves bitPattern`() {
            var value: Int = 42
            let data = withUnsafePointer(to: &value) { ptr in
                Kernel.Event.Queue.Event.Data(pointer: ptr)
            }
            #expect(data != 0)
        }

        @Test
        func `init from mutable typed pointer preserves bitPattern`() {
            var value: Int = 42
            let data = withUnsafeMutablePointer(to: &value) { ptr in
                Kernel.Event.Queue.Event.Data(pointer: ptr)
            }
            #expect(data != 0)
        }

        // MARK: - Pointer Extraction Tests

        @Test
        func `UnsafeMutableRawPointer init from non-zero data returns pointer`() {
            var value: Int = 42
            withUnsafeMutablePointer(to: &value) { ptr in
                let originalPtr = UnsafeMutableRawPointer(ptr)
                let data = Kernel.Event.Queue.Event.Data(originalPtr)
                let extractedPtr = UnsafeMutableRawPointer(data)
                #expect(extractedPtr == originalPtr)
            }
        }

        @Test
        func `UnsafeMutableRawPointer init from zero data returns nil`() {
            let data = Kernel.Event.Queue.Event.Data.zero
            let extractedPtr = UnsafeMutableRawPointer(data)
            #expect(extractedPtr == nil)
        }

        @Test
        func `pointer roundtrip preserves address`() {
            var value: Int = 42
            withUnsafeMutablePointer(to: &value) { ptr in
                let originalPtr = UnsafeMutableRawPointer(ptr)
                let data = Kernel.Event.Queue.Event.Data(originalPtr)
                let extractedPtr = UnsafeMutableRawPointer(data)
                #expect(extractedPtr == originalPtr)
            }
        }

        // MARK: - Conformance Tests

        @Test
        func `Data is Sendable`() {
            let data: any Sendable = Kernel.Event.Queue.Event.Data.zero
            #expect(data is Kernel.Event.Queue.Event.Data)
        }

        @Test
        func `Data is Equatable`() {
            let a = Kernel.Event.Queue.Event.Data(42)
            let b = Kernel.Event.Queue.Event.Data(42)
            let c = Kernel.Event.Queue.Event.Data(0)
            #expect(a == b)
            #expect(a != c)
        }

        @Test
        func `Data is Hashable`() {
            var set = Set<Kernel.Event.Queue.Event.Data>()
            set.insert(Kernel.Event.Queue.Event.Data(1))
            set.insert(Kernel.Event.Queue.Event.Data(2))
            set.insert(Kernel.Event.Queue.Event.Data(1))  // duplicate
            #expect(set.count == 2)
        }

        // MARK: - Edge Cases

        @Test
        func `UInt64.max is preserved`() {
            let data = Kernel.Event.Queue.Event.Data(UInt64.max)
            #expect(data.rawValue == UInt64.max)
        }

        @Test
        func `large pointer values are preserved`() {
            // Create data from a large value simulating a high memory address
            let largeValue: UInt64 = 0x7FFF_FFFF_FFFF_FFFF
            let data = Kernel.Event.Queue.Event.Data(largeValue)
            #expect(data.rawValue == largeValue)
        }
    }
#endif
