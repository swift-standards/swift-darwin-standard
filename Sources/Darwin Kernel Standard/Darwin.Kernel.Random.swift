#if canImport(Darwin)

    public import Random
    internal import Darwin

    extension Darwin.Kernel {

        public enum Random: Sendable {}
    }

    extension Darwin.Kernel.Random {

        public static func arc4random(_ span: inout MutableSpan<UInt8>) throws(Random.Error) {
            try span.withUnsafeMutableBytes {
                (buffer: UnsafeMutableRawBufferPointer) throws(Random.Error) in

                try unsafe arc4random(buffer)
            }
        }

        @unsafe
        public static func arc4random(_ buffer: UnsafeMutableRawBufferPointer) throws(Random.Error)
        {
            guard let base = buffer.baseAddress, buffer.count > 0 else { return }
            unsafe arc4random_buf(base, buffer.count)
        }

        @unsafe
        public static func arc4random(
            _ buffer: UnsafeMutableBufferPointer<UInt8>
        ) throws(Random.Error) {

            try unsafe arc4random(UnsafeMutableRawBufferPointer(buffer))
        }
    }

#endif
