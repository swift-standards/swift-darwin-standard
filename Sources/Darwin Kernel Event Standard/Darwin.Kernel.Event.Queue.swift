internal import Darwin_Kernel_Time_Standard
package import Darwin_Standard_Core
@_spi(Syscall) public import ISO_9945_Core
internal import ISO_9945_Kernel

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    internal import Darwin

    internal typealias CKevent = kevent

    extension Darwin_Standard_Core.Darwin.Kernel {

        public enum Event: Sendable {}
    }

    extension Darwin.Kernel.Event {

        public typealias ID = Tagged<Darwin.Kernel.Event, UInt>
    }

    extension Tagged where Tag == Darwin.Kernel.Event, Underlying == UInt {

        @inlinable
        public init(_ value: Int32) {
            self.init(_unchecked: UInt(bitPattern: Int(value)))
        }
    }

    extension Darwin.Kernel.Event {

        @safe
        public struct Queue: ~Copyable, Sendable {

            internal let descriptor: ISO_9945.Kernel.Descriptor

            public init() throws(Error) {
                self.descriptor = try ISO_9945.Kernel.Descriptor(_rawValue: Self.create())
            }
        }
    }

    extension Darwin.Kernel.Event.Queue {

        public func register(events: [Event]) throws(Error) {
            try Self.register(self, events: events)
        }

        public func poll(into events: inout [Event], timeout: Duration?) throws(Error) -> Int {
            try Self.poll(self, into: &events, timeout: timeout)
        }

        public func wakeup() throws(Error) -> @Sendable () -> Void {
            let wakeupEvent = Event(id: .zero, filter: .user, flags: .add | .clear)
            try self.register(events: [wakeupEvent])

            let rawFd = self.descriptor._rawValue
            return {
                let trigger = Event(id: .zero, filter: .user, flags: .none, fflags: .trigger)
                do throws(Error) {
                    try Self.register(rawDescriptor: rawFd, events: [trigger])
                } catch {
                    if case .kevent(let code) = error,
                        code == .POSIX.EBADF || code == .POSIX.ENOENT
                    {

                    } else {
                        assertionFailure("wakeup trigger failed: \(error)")
                    }
                }
            }
        }
    }

    @_silgen_name("kevent")
    internal func _kevent(
        _ kq: Int32,
        _ changelist: UnsafePointer<kevent>?,
        _ nchanges: Int32,
        _ eventlist: UnsafeMutablePointer<kevent>?,
        _ nevents: Int32,
        _ timeout: UnsafePointer<timespec>?
    ) -> Int32

    extension Darwin.Kernel.Event.Queue {

        package static func create() throws(Darwin.Kernel.Event.Queue.Error) -> Int32 {
            let kq = kqueue()
            guard kq >= 0 else {
                throw .create(.posix(errno))
            }
            return kq
        }

        package static func register(
            _ kq: borrowing Darwin.Kernel.Event.Queue,
            events: [Event]
        ) throws(Darwin.Kernel.Event.Queue.Error) {
            guard !events.isEmpty else { return }

            try unsafe withUnsafeTemporaryAllocation(
                of: CKevent.self,
                capacity: events.count
            ) { buffer throws(Darwin.Kernel.Event.Queue.Error) in
                for i in 0..<events.count {
                    unsafe (buffer[i] = unsafe events[i].cValue)
                }
                let result = unsafe _kevent(
                    kq.descriptor._rawValue,
                    buffer.baseAddress,
                    Int32(events.count),
                    nil,
                    0,
                    nil
                )
                guard result >= 0 else {
                    let code = Error.Error.Code.posix(errno)
                    if code.posix == EINTR { throw .interrupted }
                    throw .kevent(code)
                }
            }
        }

        package static func register(
            rawDescriptor kq: Int32,
            events: [Event]
        ) throws(Darwin.Kernel.Event.Queue.Error) {
            guard !events.isEmpty else { return }

            try unsafe withUnsafeTemporaryAllocation(
                of: CKevent.self,
                capacity: events.count
            ) { buffer throws(Darwin.Kernel.Event.Queue.Error) in
                for i in 0..<events.count {
                    unsafe (buffer[i] = unsafe events[i].cValue)
                }
                let result = unsafe _kevent(
                    kq,
                    buffer.baseAddress,
                    Int32(events.count),
                    nil,
                    0,
                    nil
                )
                guard result >= 0 else {
                    let code = Error.Error.Code.posix(errno)
                    if code.posix == EINTR { throw .interrupted }
                    throw .kevent(code)
                }
            }
        }
    }

    extension Darwin.Kernel.Event.Queue {

        package static func poll(
            _ kq: borrowing Darwin.Kernel.Event.Queue,
            into events: inout [Event],
            timeout: Duration?
        ) throws(Darwin.Kernel.Event.Queue.Error) -> Int {
            guard !events.isEmpty else { return 0 }
            let count = events.count

            return try unsafe withUnsafeTemporaryAllocation(
                of: CKevent.self,
                capacity: count
            ) { buffer throws(Darwin.Kernel.Event.Queue.Error) -> Int in
                let result: Int32
                if var ts = timespec(timeout) {
                    result = unsafe _kevent(
                        kq.descriptor._rawValue,
                        nil,
                        0,
                        buffer.baseAddress,
                        Int32(count),
                        &ts
                    )
                } else {
                    result = unsafe _kevent(
                        kq.descriptor._rawValue,
                        nil,
                        0,
                        buffer.baseAddress,
                        Int32(count),
                        nil
                    )
                }
                guard result >= 0 else {
                    let code = Error.Error.Code.posix(errno)
                    if code.posix == EINTR { throw .interrupted }
                    throw .kevent(code)
                }
                let eventCount = Int(result)
                for i in 0..<eventCount {
                    events[i] = unsafe Event(buffer[i])
                }
                return eventCount
            }
        }

        package static func poll(
            _ kq: borrowing Darwin.Kernel.Event.Queue,
            into events: UnsafeMutableBufferPointer<Event>,
            timeout: Duration?
        ) throws(Darwin.Kernel.Event.Queue.Error) -> Int {
            guard !events.isEmpty else { return 0 }
            let count = events.count

            return try unsafe withUnsafeTemporaryAllocation(
                of: CKevent.self,
                capacity: count
            ) { buffer throws(Darwin.Kernel.Event.Queue.Error) -> Int in
                let result: Int32
                if var ts = timespec(timeout) {
                    result = unsafe _kevent(
                        kq.descriptor._rawValue,
                        nil,
                        0,
                        buffer.baseAddress,
                        Int32(count),
                        &ts
                    )
                } else {
                    result = unsafe _kevent(
                        kq.descriptor._rawValue,
                        nil,
                        0,
                        buffer.baseAddress,
                        Int32(count),
                        nil
                    )
                }
                guard result >= 0 else {
                    let code = Error.Error.Code.posix(errno)
                    if code.posix == EINTR { throw .interrupted }
                    throw .kevent(code)
                }
                let eventCount = Int(result)
                for i in 0..<eventCount {
                    unsafe (events[i] = unsafe Event(buffer[i]))
                }
                return eventCount
            }
        }
    }

#endif
