import ISO_9945_Core

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    internal import Darwin

    extension Darwin.Kernel.Event.Queue {

        public struct Flags: Sendable, Equatable, Hashable, BitwiseCopyable {
            public let rawValue: UInt16

            public init(rawValue: UInt16) {
                self.rawValue = rawValue
            }
        }
    }

    extension Darwin.Kernel.Event.Queue.Flags {

        public static let add = Self(rawValue: UInt16(EV_ADD))

        public static let delete = Self(rawValue: UInt16(EV_DELETE))

        public static let enable = Self(rawValue: UInt16(EV_ENABLE))

        public static let disable = Self(rawValue: UInt16(EV_DISABLE))
    }

    extension Darwin.Kernel.Event.Queue.Flags {

        public static let clear = Self(rawValue: UInt16(EV_CLEAR))

        public static let dispatch = Self(rawValue: UInt16(EV_DISPATCH))

        public static let oneshot = Self(rawValue: UInt16(EV_ONESHOT))
    }

    extension Darwin.Kernel.Event.Queue.Flags {

        public static let eof = Self(rawValue: UInt16(EV_EOF))

        public static let error = Self(rawValue: UInt16(EV_ERROR))
    }

    extension Darwin.Kernel.Event.Queue.Flags {

        public static func | (lhs: Self, rhs: Self) -> Self {
            Self(rawValue: lhs.rawValue | rhs.rawValue)
        }

        public func contains(_ other: Self) -> Bool {
            (rawValue & other.rawValue) == other.rawValue
        }

        public static let none = Self(rawValue: 0)
    }

#endif
