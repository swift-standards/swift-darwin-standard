#if canImport(Darwin)

    @_spi(Syscall) public import ISO_9945_Core
    internal import Darwin

    extension ISO_9945.Kernel.File.Attributes {

        public enum Extended {}
    }

    extension ISO_9945.Kernel.File.Attributes.Extended {

        public struct Error: Swift.Error, Sendable {
            public let code: Error.Error.Code

            public init(code: Error.Error.Code) {
                self.code = code
            }
        }
    }

    extension ISO_9945.Kernel.File.Attributes.Extended.Error {

        public static let notFound = Error(code: .posix(ENOATTR))

        public static let noSpace = Error(code: .posix(ENOSPC))

        public static let permissionDenied = Error(code: .posix(EACCES))

        @usableFromInline
        internal static func current() -> Self {
            Self(code: .posix(errno))
        }
    }

    extension ISO_9945.Kernel.File.Attributes.Extended {

        @unsafe
        internal static func list(
            path: UnsafePointer<CChar>,
            followSymlinks: Bool = true
        ) throws(Error) -> [Swift.String] {
            let options: Int32 = followSymlinks ? 0 : XATTR_NOFOLLOW

            let size = unsafe listxattr(path, nil, 0, options)
            guard size >= 0 else {
                throw .current()
            }

            if size == 0 {
                return []
            }

            var buffer = [CChar](repeating: 0, count: size)
            let result = unsafe listxattr(path, &buffer, size, options)
            guard result >= 0 else {
                throw .current()
            }

            return parseNullSeparatedStrings(buffer, count: result)
        }

        internal static func list(
            _ fd: Int32
        ) throws(Error) -> [Swift.String] {

            let size = flistxattr(fd, nil, 0, 0)
            guard size >= 0 else {
                throw .current()
            }

            if size == 0 {
                return []
            }

            var buffer = [CChar](repeating: 0, count: size)
            let result = unsafe flistxattr(fd, &buffer, size, 0)
            guard result >= 0 else {
                throw .current()
            }

            return parseNullSeparatedStrings(buffer, count: result)
        }
    }

    extension ISO_9945.Kernel.File.Attributes.Extended {

        @unsafe
        internal static func get(
            name: UnsafePointer<CChar>,
            path: UnsafePointer<CChar>,
            followSymlinks: Bool = true
        ) throws(Error) -> [UInt8] {
            let options: Int32 = followSymlinks ? 0 : XATTR_NOFOLLOW

            let size = unsafe getxattr(path, name, nil, 0, 0, options)
            guard size >= 0 else {
                throw .current()
            }

            if size == 0 {
                return []
            }

            var buffer = [UInt8](repeating: 0, count: size)
            let result = unsafe getxattr(path, name, &buffer, size, 0, options)
            guard result >= 0 else {
                throw .current()
            }

            return Array(buffer.prefix(result))
        }

        @unsafe
        internal static func get(
            name: UnsafePointer<CChar>,
            _ fd: Int32
        ) throws(Error) -> [UInt8] {

            let size = unsafe fgetxattr(fd, name, nil, 0, 0, 0)
            guard size >= 0 else {
                throw .current()
            }

            if size == 0 {
                return []
            }

            var buffer = [UInt8](repeating: 0, count: size)
            let result = unsafe fgetxattr(fd, name, &buffer, size, 0, 0)
            guard result >= 0 else {
                throw .current()
            }

            return Array(buffer.prefix(result))
        }
    }

    extension ISO_9945.Kernel.File.Attributes.Extended {

        @unsafe
        internal static func set(
            name: UnsafePointer<CChar>,
            value: UnsafeRawBufferPointer,
            path: UnsafePointer<CChar>,
            followSymlinks: Bool = true
        ) throws(Error) {
            let options: Int32 = followSymlinks ? 0 : XATTR_NOFOLLOW

            let result = unsafe setxattr(
                path,
                name,
                value.baseAddress,
                value.count,
                0,
                options
            )
            guard result == 0 else {
                throw .current()
            }
        }

        @unsafe
        internal static func set(
            name: UnsafePointer<CChar>,
            value: UnsafeRawBufferPointer,
            _ fd: Int32
        ) throws(Error) {
            let result = unsafe fsetxattr(
                fd,
                name,
                value.baseAddress,
                value.count,
                0,
                0
            )
            guard result == 0 else {
                throw .current()
            }
        }
    }

    extension ISO_9945.Kernel.File.Attributes.Extended {

        @unsafe
        internal static func remove(
            name: UnsafePointer<CChar>,
            path: UnsafePointer<CChar>,
            followSymlinks: Bool = true
        ) throws(Error) {
            let options: Int32 = followSymlinks ? 0 : XATTR_NOFOLLOW

            let result = unsafe removexattr(path, name, options)
            guard result == 0 else {
                throw .current()
            }
        }

        @unsafe
        internal static func remove(
            name: UnsafePointer<CChar>,
            _ fd: Int32
        ) throws(Error) {
            let result = unsafe fremovexattr(fd, name, 0)
            guard result == 0 else {
                throw .current()
            }
        }
    }

    extension ISO_9945.Kernel.File.Attributes.Extended {

        internal static func copyAll(
            fromFd source: Int32,
            toFd destination: Int32
        ) throws(Error) {
            let names = try list(source)

            for name in names {

                var utf8 = Array(name.utf8)
                utf8.append(0)
                try utf8.withUnsafeBufferPointer { buffer throws(Error) in
                    let namePtr = unsafe UnsafeRawPointer(buffer.baseAddress!).assumingMemoryBound(
                        to: CChar.self
                    )
                    let value = try unsafe get(name: namePtr, source)

                    try value.withUnsafeBufferPointer { valueBuffer throws(Error) in
                        try unsafe set(
                            name: namePtr,
                            value: UnsafeRawBufferPointer(valueBuffer),
                            destination
                        )
                    }
                }
            }
        }
    }

    extension ISO_9945.Kernel.File.Attributes.Extended {

        private static func parseNullSeparatedStrings(
            _ buffer: [CChar],
            count: Int
        ) -> [Swift.String] {
            var names: [Swift.String] = []
            var start = 0

            for i in 0..<count {
                if buffer[i] == 0 {
                    if i > start {
                        let slice = buffer[start..<i]
                        if let name = Swift.String(validating: Array(slice), as: UTF8.self) {
                            names.append(name)
                        }
                    }
                    start = i + 1
                }
            }

            return names
        }

        @unsafe
        fileprivate static func withCName<R, E: Swift.Error>(
            _ name: Swift.String,
            _ body: (UnsafePointer<CChar>) throws(E) -> R
        ) throws(E) -> R {
            var utf8 = Array(name.utf8)
            utf8.append(0)
            return try utf8.withUnsafeBufferPointer { buffer throws(E) in
                let ptr = unsafe UnsafeRawPointer(buffer.baseAddress!).assumingMemoryBound(
                    to: CChar.self
                )
                return try unsafe body(ptr)
            }
        }
    }

    extension ISO_9945.Kernel.File.Attributes.Extended {

        public static func list(
            path: borrowing Path.Borrowed,
            followSymlinks: Bool = true
        ) throws(Error) -> [Swift.String] {
            try unsafe path.withUnsafePointer { pathPtr throws(Error) in
                try unsafe list(
                    path: UnsafeRawPointer(pathPtr).assumingMemoryBound(to: CChar.self),
                    followSymlinks: followSymlinks
                )
            }
        }

        public static func get(
            name: Swift.String,
            path: borrowing Path.Borrowed,
            followSymlinks: Bool = true
        ) throws(Error) -> [UInt8] {
            try unsafe withCName(name) { namePtr throws(Error) in
                try unsafe path.withUnsafePointer { pathPtr throws(Error) in
                    try unsafe get(
                        name: namePtr,
                        path: UnsafeRawPointer(pathPtr).assumingMemoryBound(to: CChar.self),
                        followSymlinks: followSymlinks
                    )
                }
            }
        }

        internal static func get(
            name: Swift.String,
            _ fd: Int32
        ) throws(Error) -> [UInt8] {
            try unsafe withCName(name) { namePtr throws(Error) in
                try unsafe get(name: namePtr, fd)
            }
        }

        public static func set(
            name: Swift.String,
            value: UnsafeRawBufferPointer,
            path: borrowing Path.Borrowed,
            followSymlinks: Bool = true
        ) throws(Error) {
            try unsafe withCName(name) { namePtr throws(Error) in
                try unsafe path.withUnsafePointer { pathPtr throws(Error) in
                    try unsafe set(
                        name: namePtr,
                        value: value,
                        path: UnsafeRawPointer(pathPtr).assumingMemoryBound(to: CChar.self),
                        followSymlinks: followSymlinks
                    )
                }
            }
        }

        internal static func set(
            name: Swift.String,
            value: UnsafeRawBufferPointer,
            _ fd: Int32
        ) throws(Error) {
            try unsafe withCName(name) { namePtr throws(Error) in
                try unsafe set(name: namePtr, value: value, fd)
            }
        }

        public static func remove(
            name: Swift.String,
            path: borrowing Path.Borrowed,
            followSymlinks: Bool = true
        ) throws(Error) {
            try unsafe withCName(name) { namePtr throws(Error) in
                try unsafe path.withUnsafePointer { pathPtr throws(Error) in
                    try unsafe remove(
                        name: namePtr,
                        path: UnsafeRawPointer(pathPtr).assumingMemoryBound(to: CChar.self),
                        followSymlinks: followSymlinks
                    )
                }
            }
        }

        internal static func remove(
            name: Swift.String,
            _ fd: Int32
        ) throws(Error) {
            try unsafe withCName(name) { namePtr throws(Error) in
                try unsafe remove(name: namePtr, fd)
            }
        }
    }

    extension ISO_9945.Kernel.File.Attributes.Extended {

        public static func list(
            _ descriptor: borrowing ISO_9945.Kernel.Descriptor
        ) throws(Error) -> [Swift.String] {
            try list(descriptor._rawValue)
        }

        public static func get(
            name: Swift.String,
            _ descriptor: borrowing ISO_9945.Kernel.Descriptor
        ) throws(Error) -> [UInt8] {
            try get(name: name, descriptor._rawValue)
        }

        @unsafe
        public static func set(
            name: Swift.String,
            value: UnsafeRawBufferPointer,
            _ descriptor: borrowing ISO_9945.Kernel.Descriptor
        ) throws(Error) {
            try unsafe set(name: name, value: value, descriptor._rawValue)
        }

        public static func remove(
            name: Swift.String,
            _ descriptor: borrowing ISO_9945.Kernel.Descriptor
        ) throws(Error) {
            try remove(name: name, descriptor._rawValue)
        }

        public static func copyAll(
            from source: borrowing ISO_9945.Kernel.Descriptor,
            to destination: borrowing ISO_9945.Kernel.Descriptor
        ) throws(Error) {
            try copyAll(fromFd: source._rawValue, toFd: destination._rawValue)
        }
    }

#endif
