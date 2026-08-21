public import ISO_9945_Core

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    internal import Darwin

    extension Darwin.Kernel.Event.Queue {

        public struct Event: Sendable, Equatable, Hashable, BitwiseCopyable {

            public var id: Darwin.Kernel.Event.ID

            public var filter: Filter

            public var flags: Flags

            public var fflags: Filter.Flags

            public var filterData: Filter.Data

            public var data: Data

            public init(
                id: Darwin.Kernel.Event.ID,
                filter: Filter,
                flags: Flags,
                fflags: Filter.Flags = .none,
                filterData: Filter.Data = .zero,
                data: Data = .zero
            ) {
                self.id = id
                self.filter = filter
                self.flags = flags
                self.fflags = fflags
                self.filterData = filterData
                self.data = data
            }
        }
    }

    extension Darwin.Kernel.Event.Queue.Event {

        @unsafe
        internal init(_ cEvent: kevent) {
            self.id = unsafe Darwin.Kernel.Event.ID(_unchecked: cEvent.ident)
            self.filter = unsafe Darwin.Kernel.Event.Queue.Filter(rawValue: cEvent.filter)
            self.flags = unsafe Darwin.Kernel.Event.Queue.Flags(rawValue: cEvent.flags)
            self.fflags = unsafe Darwin.Kernel.Event.Queue.Filter.Flags(rawValue: cEvent.fflags)
            self.filterData = unsafe Darwin.Kernel.Event.Queue.Filter.Data(_unchecked: cEvent.data)
            self.data = unsafe Data(cEvent.udata)
        }

        @unsafe
        internal var cValue: kevent {
            var ev = unsafe kevent()
            unsafe (ev.ident = id.underlying)
            unsafe (ev.filter = filter.rawValue)
            unsafe (ev.flags = flags.rawValue)
            unsafe (ev.fflags = fflags.rawValue)
            unsafe (ev.data = filterData.underlying)
            unsafe (ev.udata = UnsafeMutableRawPointer(data))
            return unsafe ev
        }
    }

#endif
