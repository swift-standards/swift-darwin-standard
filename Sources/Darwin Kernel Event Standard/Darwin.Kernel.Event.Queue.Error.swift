public import Error_Primitives
import ISO_9945_Core

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

    extension Darwin.Kernel.Event.Queue {

        public enum Error: Swift.Error, Sendable, Equatable, Hashable {

            case create(Error_Primitives.Error.Code)

            case kevent(Error_Primitives.Error.Code)

            case interrupted
        }
    }

    extension Darwin.Kernel.Event.Queue.Error: CustomStringConvertible {
        public var description: Swift.String {
            switch self {
            case .create(let code):
                return "kqueue creation failed (\(code))"

            case .kevent(let code):
                return "kevent failed (\(code))"

            case .interrupted:
                return "operation interrupted"
            }
        }
    }

#endif
