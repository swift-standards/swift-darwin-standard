import ISO_9945_Core

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    internal import Darwin

    extension Darwin.Kernel.Event.Queue {

        public struct Filter: RawRepresentable, Sendable, Equatable, Hashable, BitwiseCopyable {
            public let rawValue: Int16

            public init(rawValue: Int16) {
                self.rawValue = rawValue
            }
        }
    }

    extension Darwin.Kernel.Event.Queue.Filter {

        public static let read = Self(rawValue: Int16(EVFILT_READ))

        public static let write = Self(rawValue: Int16(EVFILT_WRITE))

        public static let user = Self(rawValue: Int16(EVFILT_USER))
    }

#endif
