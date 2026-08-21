#if canImport(Darwin)

    public import ISO_9945_Core
    internal import Darwin

    extension ISO_9945.Kernel.File.Seek.Whence {

        public static let hole = Self(rawValue: SEEK_HOLE)

        public static let data = Self(rawValue: SEEK_DATA)
    }

#endif
