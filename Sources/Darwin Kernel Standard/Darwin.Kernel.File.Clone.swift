#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

    public import ISO_9945_Kernel_File
    import ISO_9945_Core
    public import Error_Primitives
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

        public enum Error: Swift.Error, Sendable, Equatable, CustomStringConvertible {

            case notSupported

            case crossDevice

            case sourceNotFound

            case destinationExists

            case permissionDenied

            case isDirectory

            case platform(code: Error_Primitives.Error.Code, operation: Operation)
        }
    }

    extension Darwin.Kernel.File.Clone.Error {
        public var description: Swift.String {
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

        public enum Operation: Swift.String, Sendable, Equatable {
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

        public enum Syscall: Swift.Error, Sendable {

            case platform(code: Error_Primitives.Error.Code, operation: Operation)

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
                    let ptr = unsafe buf.baseAddress!.assumingMemoryBound(to: CChar.self)
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

    extension Darwin.Kernel.File.Clone.Clonefile {

        public static func attempt(
            source: borrowing Path.Borrowed,
            destination: borrowing Path.Borrowed
        ) throws(Darwin.Kernel.File.Clone.Error.Syscall) -> Bool {
            try unsafe source.withUnsafePointer {
                srcCString throws(Darwin.Kernel.File.Clone.Error.Syscall) in
                try unsafe destination.withUnsafePointer {
                    dstCString throws(Darwin.Kernel.File.Clone.Error.Syscall) in
                    let result = unsafe clonefile(
                        UnsafeRawPointer(srcCString).assumingMemoryBound(to: CChar.self),
                        UnsafeRawPointer(dstCString).assumingMemoryBound(to: CChar.self),
                        0
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

                    var statBuf = stat()
                    let destExists = unsafe (stat(dstPtr, &statBuf) == 0)
                    if destExists {
                        throw Darwin.Kernel.File.Clone.Error.Syscall.platform(
                            code: .posix(EEXIST),
                            operation: .copyfile
                        )
                    }

                    let result = unsafe copyfile(
                        srcPtr,
                        dstPtr,
                        nil,
                        copyfile_flags_t(COPYFILE_CLONE | COPYFILE_ALL)
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

                    var statBuf = stat()
                    let destExists = unsafe (stat(dstPtr, &statBuf) == 0)
                    if destExists {
                        throw Darwin.Kernel.File.Clone.Error.Syscall.platform(
                            code: .posix(EEXIST),
                            operation: .copyfile
                        )
                    }

                    let result = unsafe copyfile(
                        srcPtr,
                        dstPtr,
                        nil,
                        copyfile_flags_t(COPYFILE_DATA)
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
