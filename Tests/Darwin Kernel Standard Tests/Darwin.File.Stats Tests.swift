#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    import Darwin
    @_spi(Syscall) import ISO_9945_Core
    import Testing

    @testable import Darwin_Kernel_Standard

    extension Darwin.File.Stats {
        @Suite
        struct Test {
            @Suite struct `Edge Case` {}
        }
    }

    extension Darwin.File.Stats.Test.`Edge Case` {
        @Test
        func `a descriptor whose device number is negative stats without trapping`() throws {
            // dev_t is a signed Int32, and fstat reports a socket's device as -1.
            let raw = socket(AF_UNIX, SOCK_STREAM, 0)
            try #require(raw >= 0)
            let socket = ISO_9945.Kernel.Descriptor(_rawValue: raw)

            let stats = try Darwin.File.Stats.get(socket)

            #expect(stats.device.rawValue == UInt64(UInt32(bitPattern: -1)))
        }
    }
#endif
