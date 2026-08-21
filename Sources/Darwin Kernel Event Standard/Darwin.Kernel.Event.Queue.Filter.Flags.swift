import ISO_9945_Core

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    internal import Darwin

    extension Darwin.Kernel.Event.Queue.Filter {

        public struct Flags: Sendable, Equatable, Hashable, BitwiseCopyable {
            public let rawValue: UInt32

            public init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    extension Darwin.Kernel.Event.Queue.Filter.Flags {

        public static let trigger = Self(rawValue: UInt32(NOTE_TRIGGER))

        public static let none = Self(rawValue: 0)

        public static func | (lhs: Self, rhs: Self) -> Self {
            Self(rawValue: lhs.rawValue | rhs.rawValue)
        }

        public func contains(_ other: Self) -> Bool {
            (rawValue & other.rawValue) == other.rawValue
        }
    }

#endif
