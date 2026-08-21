import ISO_9945_Core

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

    extension Darwin.Kernel {

        public typealias Kqueue = Event.Queue
    }

#endif
