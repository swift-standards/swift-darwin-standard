#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

    public import Darwin_Standard_Core
    internal import Darwin.Mach
    internal import MachO

    extension Darwin_Standard_Core.Darwin.Loader.Image {

        @safe
        public struct Header: Sendable, Equatable {

            nonisolated(unsafe) public let rawValue: UnsafeRawPointer

            @unsafe
            @inlinable
            public init(rawValue: UnsafeRawPointer) {
                unsafe (self.rawValue = rawValue)
            }
        }
    }

    extension Darwin_Standard_Core.Darwin.Loader.Image.Header {

        public var isInSharedCache: Bool {
            let header64 = unsafe rawValue.assumingMemoryBound(to: mach_header_64.self)
            return unsafe (header64.pointee.flags & UInt32(MH_DYLIB_IN_CACHE)) != 0
        }

        @inlinable
        public static func == (lhs: Self, rhs: Self) -> Bool {
            unsafe lhs.rawValue == rhs.rawValue
        }
    }

    extension Darwin_Standard_Core.Darwin.Loader.Image.Header {

        @unsafe
        internal var header64: UnsafePointer<mach_header_64> {
            unsafe rawValue.assumingMemoryBound(to: mach_header_64.self)
        }
    }

#endif
