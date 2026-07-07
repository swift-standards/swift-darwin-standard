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

    extension Kernel.Event.Queue.Error {
        enum Test {
            @Suite struct Unit {}
            @Suite struct EdgeCase {}
            @Suite struct Integration {}
            @Suite(.serialized) struct Performance {}
        }
    }

    // MARK: - Error Unit Tests

    extension Kernel.Event.Queue.Error.Test.Unit {

        @Test
        func `create error captures posix error code`() {
            let code = Error_Primitives.Error.Code.posix(EBADF)
            let error = Kernel.Event.Queue.Error.create(code)

            if case .create(let capturedCode) = error {
                #expect(capturedCode.posix == EBADF)
            } else {
                Issue.record("Expected .create error case")
            }
        }

        @Test
        func `kevent error captures posix error code`() {
            let code = Error_Primitives.Error.Code.posix(EINVAL)
            let error = Kernel.Event.Queue.Error.kevent(code)

            if case .kevent(let capturedCode) = error {
                #expect(capturedCode.posix == EINVAL)
            } else {
                Issue.record("Expected .kevent error case")
            }
        }

        @Test
        func `error conforms to Swift.Error`() {
            let error: any Swift.Error = Kernel.Event.Queue.Error.interrupted
            #expect(error is Kernel.Event.Queue.Error)
        }

        @Test
        func `error conforms to Equatable`() {
            let error1 = Kernel.Event.Queue.Error.interrupted
            let error2 = Kernel.Event.Queue.Error.interrupted
            let error3 = Kernel.Event.Queue.Error.create(.posix(EBADF))

            #expect(error1 == error2)
            #expect(error1 != error3)
        }

        @Test
        func `error has description`() {
            let error = Kernel.Event.Queue.Error.interrupted
            #expect(!error.description.isEmpty)
        }
    }

#endif
