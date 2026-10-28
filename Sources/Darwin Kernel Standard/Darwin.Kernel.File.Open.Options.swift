#if canImport(Darwin)

    public import ISO_9945_Core
    internal import Darwin

    extension ISO_9945.Kernel.File.Open.Options {

        public static let noCache = Self(rawValue: 1 << 30)

        public static let eventOnly = Self(rawValue: O_EVTONLY)

        @usableFromInline
        internal var needsNoCache: Bool {
            contains(.noCache)
        }

        @usableFromInline
        internal var openFlags: Int32 {
            rawValue & ~(1 << 30)
        }
    }

#endif
