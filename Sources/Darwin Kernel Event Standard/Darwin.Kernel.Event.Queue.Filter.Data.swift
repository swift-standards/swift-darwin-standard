public import ISO_9945_Core

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

    extension Darwin.Kernel.Event.Queue.Filter {

        public typealias Data = Tagged<Darwin.Kernel.Event.Queue.Filter, Int>
    }

    extension Darwin.Kernel.Event.Queue.Filter.Data {

        public static let zero: Self = Self(_unchecked: 0)
    }

#endif
