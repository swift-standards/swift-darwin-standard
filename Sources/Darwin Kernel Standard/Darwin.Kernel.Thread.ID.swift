#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

    internal import Darwin
    public import ISO_9945_Kernel_Thread

    extension ISO_9945.Kernel.Thread {

        public struct ID: Hashable, Sendable, RawRepresentable, CustomStringConvertible {

            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension ISO_9945.Kernel.Thread.ID {
        public var description: String { "mach_port(\(rawValue))" }
    }

    extension ISO_9945.Kernel.Thread.ID {

        public static var current: Self {
            .init(rawValue: UInt32(unsafe pthread_mach_thread_np(unsafe pthread_self())))
        }
    }

#endif
