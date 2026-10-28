#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    import Darwin
    import ISO_9945_Core
    import Testing

    @testable import Darwin_Kernel_Standard

    extension ISO_9945.Kernel.File.Open.Options {
        @Suite
        struct Test {
            @Suite struct Unit {}
        }
    }

    extension ISO_9945.Kernel.File.Open.Options.Test.Unit {
        @Test
        func `eventOnly matches O_EVTONLY`() {
            #expect(ISO_9945.Kernel.File.Open.Options.eventOnly.rawValue == O_EVTONLY)
        }

        @Test
        func `eventOnly leaves the open flags intact`() {
            #expect(ISO_9945.Kernel.File.Open.Options.eventOnly.openFlags == O_EVTONLY)
            #expect(!ISO_9945.Kernel.File.Open.Options.eventOnly.needsNoCache)
        }
    }
#endif
