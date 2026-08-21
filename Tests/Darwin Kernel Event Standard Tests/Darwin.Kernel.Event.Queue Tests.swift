#if canImport(Darwin)
    import Darwin
    import Testing

    @_spi(Syscall) import ISO_9945_Core
    import ISO_9945_Kernel_Test_Support
    @testable import Darwin_Kernel_Event_Standard
    import Darwin_Standard_Core

    private typealias Kernel = Darwin.Kernel

    extension ISO_9945.Kernel.Event.Test {

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

    extension Kernel.Event.Queue.Test.Unit {

        @Test
        func `create returns valid kqueue descriptor`() throws {
            let kq = try Kernel.Event.Queue.create()
            defer { ISO_9945.Kernel.Event.Test.closeNoThrow(kq) }

            #expect(kq >= 0)
        }

        @Test
        func `Kqueue namespace exists`() {

            _ = Kernel.Event.Queue.self
        }
    }

#endif
