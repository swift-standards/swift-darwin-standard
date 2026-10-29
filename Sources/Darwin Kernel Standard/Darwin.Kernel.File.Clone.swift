#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

    public import ISO_9945_Kernel_File
    import ISO_9945_Core
    public import Error
    internal import Darwin

    extension Darwin_Standard_Core.Darwin.Kernel {

        public enum File: Sendable {}
    }

    extension Darwin.Kernel.File {

        public enum Clone {}
    }

    extension Darwin.Kernel.File.Clone {

        public enum Capability: Sendable, Equatable {

            case reflink

            case none
        }
    }

    extension Darwin.Kernel.File.Clone {

        public enum Metadata {}
    }

    extension Darwin.Kernel.File.Clone {

        public enum Error: Swift::Error, Sendable, Equatable, CustomStringConvertible {

            case notSupported

            case crossDevice

            case sourceNotFound

            case destinationExists

            case permissionDenied

            case isDirectory

            case platform(code: Error::Error.Code, operation: Operation)
        }
    }

    extension Darwin.Kernel.File.Clone.Error {
        public var description: Swift::String {
            switch self {
            case .notSupported:
                return "Reflink not supported on this filesystem"

            case .crossDevice:
                return "Source and destination are on different devices"

            case .sourceNotFound:
                return "Source file not found"

            case .destinationExists:
                return "Destination already exists"

            case .permissionDenied:
                return "Permission denied"

            case .isDirectory:
                return "Source is a directory"

            case .platform(let code, let operation):
                return "Platform error \(code) during \(operation)"
            }
        }
    }

    extension Darwin.Kernel.File.Clone.Error {

        public enum Operation: Swift::String, Sendable, Equatable {
            case clonefile
            case copyfile
            case ficlone
            case copyFileRange
            case duplicateExtents
            case statfs
            case stat
            case copy
        }
    }

    extension Darwin.Kernel.File.Clone.Error {

        public enum Syscall: Swift::Error, Sendable {

            case platform(code: Error::Error.Code, operation: Operation)

            case notSupported(operation: Operation)
        }
    }

    extension Darwin.Kernel.File.Clone.Capability {

        public static func probe(
            at path: borrowing Path.Borrowed
        ) throws(Darwin.Kernel.File.Clone.Error.Syscall) -> Darwin.Kernel.File.Clone.Capability {
            try unsafe path.withUnsafePointer {
                cString throws(Darwin.Kernel.File.Clone.Error.Syscall) in
                var statfsBuf = statfs()
                let result = unsafe statfs(
                    UnsafeRawPointer(cString).assumingMemoryBound(to: CChar.self),
                    &statfsBuf
                )

                guard result == 0 else {
                    throw Darwin.Kernel.File.Clone.Error.Syscall.platform(
                        code: .posix(errno),
                        operation: .statfs
                    )
                }

                let isAPFS = withUnsafeBytes(of: statfsBuf.f_fstypename) { buf in
                    guard let base = buf.baseAddress else {
                        preconditionFailure("A tuple buffer has a base address")
                    }
                    let ptr = unsafe base.assumingMemoryBound(to: CChar.self)
                    return unsafe strcmp(ptr, "apfs") == 0
                }
                if isAPFS {
                    return .reflink
                }

                return .none
            }
        }
    }

    extension Darwin.Kernel.File.Clone.Metadata {

        public static func size(
            at path: borrowing Path.Borrowed
        ) throws(Darwin.Kernel.File.Clone.Error.Syscall) -> Int {
            try unsafe path.withUnsafePointer {
                cString throws(Darwin.Kernel.File.Clone.Error.Syscall) in
                var statBuf = stat()
                let result = unsafe stat(
                    UnsafeRawPointer(cString).assumingMemoryBound(to: CChar.self),
                    &statBuf
                )

                guard result == 0 else {
                    throw Darwin.Kernel.File.Clone.Error.Syscall.platform(
                        code: .posix(errno),
                        operation: .stat
                    )
                }

                return Int(statBuf.st_size)
            }
        }
    }

    extension Darwin.Kernel.File.Clone {

        public enum Clonefile {}

        public enum Copyfile {}
    }

    extension Darwin.Kernel.File.Clone {

        /// Clones `source` (following symlinks) to a new `destination`; returns
        /// `clonefile`'s result and sets `errno`, failing with `EEXIST` for any
        /// existing destination entry, a dangling symlink included.
        @unsafe
        internal static func exclusive(
            source: UnsafePointer<CChar>,
            destination: UnsafePointer<CChar>
        ) -> Int32 {
            let descriptor = unsafe open(source, O_RDONLY | O_CLOEXEC)
            guard descriptor >= 0 else { return -1 }
            defer {
                let saved = errno
                close(descriptor)
                errno = saved
            }
            return unsafe fclonefileat(descriptor, AT_FDCWD, destination, UInt32(CLONE_NOFOLLOW))
        }
    }

    extension Darwin.Kernel.File.Clone.Clonefile {

        public static func attempt(
            source: borrowing Path.Borrowed,
            destination: borrowing Path.Borrowed
        ) throws(Darwin.Kernel.File.Clone.Error.Syscall) -> Bool {
            try unsafe source.withUnsafePointer {
                srcCString throws(Darwin.Kernel.File.Clone.Error.Syscall) in
                try unsafe destination.withUnsafePointer {
                    dstCString throws(Darwin.Kernel.File.Clone.Error.Syscall) in
                    // `clonefile` follows a dangling symlink at the destination and
                    // creates its target; `fclonefileat` with `CLONE_NOFOLLOW` refuses
                    // any existing destination entry, while the source, opened here,
                    // still follows symlinks.
                    let result = unsafe Darwin.Kernel.File.Clone.exclusive(
                        source: UnsafeRawPointer(srcCString).assumingMemoryBound(to: CChar.self),
                        destination: UnsafeRawPointer(dstCString).assumingMemoryBound(to: CChar.self)
                    )

                    if result == 0 {
                        return true
                    }

                    let err = errno
                    if err == ENOTSUP {
                        return false
                    }

                    throw Darwin.Kernel.File.Clone.Error.Syscall.platform(
                        code: .posix(err),
                        operation: .clonefile
                    )
                }
            }
        }
    }

    extension Darwin.Kernel.File.Clone.Copyfile {

        public static func clone(
            source: borrowing Path.Borrowed,
            destination: borrowing Path.Borrowed
        ) throws(Darwin.Kernel.File.Clone.Error.Syscall) {
            try unsafe source.withUnsafePointer {
                srcCString throws(Darwin.Kernel.File.Clone.Error.Syscall) in
                try unsafe destination.withUnsafePointer {
                    dstCString throws(Darwin.Kernel.File.Clone.Error.Syscall) in
                    let srcPtr = unsafe UnsafeRawPointer(srcCString).assumingMemoryBound(
                        to: CChar.self
                    )
                    let dstPtr = unsafe UnsafeRawPointer(dstCString).assumingMemoryBound(
                        to: CChar.self
                    )

                    let result = unsafe copyfile(
                        srcPtr,
                        dstPtr,
                        nil,
                        copyfile_flags_t(COPYFILE_CLONE | COPYFILE_ALL | COPYFILE_EXCL)
                    )

                    guard result == 0 else {
                        throw Darwin.Kernel.File.Clone.Error.Syscall.platform(
                            code: .posix(errno),
                            operation: .copyfile
                        )
                    }
                }
            }
        }

        public static func data(
            source: borrowing Path.Borrowed,
            destination: borrowing Path.Borrowed
        ) throws(Darwin.Kernel.File.Clone.Error.Syscall) {
            try unsafe source.withUnsafePointer {
                srcCString throws(Darwin.Kernel.File.Clone.Error.Syscall) in
                try unsafe destination.withUnsafePointer {
                    dstCString throws(Darwin.Kernel.File.Clone.Error.Syscall) in
                    let srcPtr = unsafe UnsafeRawPointer(srcCString).assumingMemoryBound(
                        to: CChar.self
                    )
                    let dstPtr = unsafe UnsafeRawPointer(dstCString).assumingMemoryBound(
                        to: CChar.self
                    )

                    let result = unsafe copyfile(
                        srcPtr,
                        dstPtr,
                        nil,
                        copyfile_flags_t(COPYFILE_DATA | COPYFILE_EXCL)
                    )

                    guard result == 0 else {
                        throw Darwin.Kernel.File.Clone.Error.Syscall.platform(
                            code: .posix(errno),
                            operation: .copyfile
                        )
                    }
                }
            }
        }
    }

#endif
