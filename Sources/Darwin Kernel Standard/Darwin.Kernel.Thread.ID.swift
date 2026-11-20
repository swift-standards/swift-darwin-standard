#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

    public import Darwin_Standard_Core
    internal import Darwin

    extension Darwin_Standard_Core::Darwin.Kernel.Thread {

        public struct ID: Hashable, Sendable, RawRepresentable, CustomStringConvertible {

            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Darwin_Standard_Core::Darwin.Kernel.Thread.ID {
        public var description: String { "mach_port(\(rawValue))" }
    }

    extension Darwin_Standard_Core::Darwin.Kernel.Thread.ID {

        public static var current: Self {
            .init(rawValue: UInt32(unsafe pthread_mach_thread_np(unsafe pthread_self())))
        }
    }

#endif
