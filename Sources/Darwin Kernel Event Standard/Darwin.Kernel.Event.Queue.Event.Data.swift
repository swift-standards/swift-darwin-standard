public import ISO_9945_Core

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

    extension Darwin.Kernel.Event.Queue.Event {

        public typealias Data = Tagged<Darwin.Kernel.Event.Queue.Event, UInt64>
    }

    extension Darwin.Kernel.Event.Queue.Event.Data {

        public init(_ pointer: UnsafeMutableRawPointer?) {
            self.init(_unchecked: UInt64(UInt(bitPattern: pointer)))
        }

        public init(_ pointer: UnsafeRawPointer) {
            self.init(_unchecked: UInt64(UInt(bitPattern: pointer)))
        }

        public init<T>(pointer: UnsafePointer<T>) {
            self.init(_unchecked: UInt64(UInt(bitPattern: pointer)))
        }

        public init<T>(pointer: UnsafeMutablePointer<T>) {
            self.init(_unchecked: UInt64(UInt(bitPattern: pointer)))
        }
    }

    extension UnsafeMutableRawPointer {

        @unsafe
        public init?(_ data: Darwin.Kernel.Event.Queue.Event.Data) {
            unsafe self.init(bitPattern: UInt(data.underlying))
        }
    }

    extension Darwin.Kernel.Event.Queue.Event.Data {

        public static let zero: Self = Self(_unchecked: 0)
    }

#endif
