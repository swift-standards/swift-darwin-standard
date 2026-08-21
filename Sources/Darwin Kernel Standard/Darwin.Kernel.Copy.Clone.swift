#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

    public import ISO_9945_Kernel_File
    import ISO_9945_Core
    internal import Darwin

    extension Darwin_Standard_Core.Darwin.Kernel {

        public enum Copy: Sendable {}
    }

    extension Darwin.Kernel.Copy {

        public enum Error: Swift.Error, Sendable, Equatable, Hashable {

            case invalidDescriptor

            case crossDevice

            case unsupported

            case noSpace

            case io

            case permissionDenied

            case exists

            case notFound
        }
    }

    extension Darwin.Kernel.Copy.Error: CustomStringConvertible {
        public var description: Swift.String {
            switch self {
            case .invalidDescriptor: return "invalid file descriptor"
            case .crossDevice: return "cross-device copy not supported"
            case .unsupported: return "operation not supported"
            case .noSpace: return "no space left on device"
            case .io: return "I/O error"
            case .permissionDenied: return "permission denied"
            case .exists: return "destination already exists"
            case .notFound: return "source not found"
            }
        }
    }

    extension Darwin.Kernel.Copy {

        public enum Clone {}
    }

    extension Darwin.Kernel.Copy.Error {

        internal init(posixErrno: Int32) {
            switch posixErrno {
            case EBADF:
                self = .invalidDescriptor

            case EXDEV:
                self = .crossDevice

            case ENOSPC:
                self = .noSpace

            case EIO:
                self = .io

            case EACCES, EPERM:
                self = .permissionDenied

            case ENOENT:
                self = .notFound

            case EEXIST:
                self = .exists

            case EINVAL, ENOTSUP:
                self = .unsupported

            default:
                self = .unsupported
            }
        }
    }

    extension Darwin.Kernel.Copy.Clone {

        public static func file(
            from sourcePath: borrowing Path.Borrowed,
            to destPath: borrowing Path.Borrowed
        ) throws(Darwin.Kernel.Copy.Error) {
            try unsafe sourcePath.withUnsafePointer { srcCString throws(Darwin.Kernel.Copy.Error) in
                try unsafe destPath.withUnsafePointer {
                    dstCString throws(Darwin.Kernel.Copy.Error) in
                    let result = unsafe clonefile(
                        UnsafeRawPointer(srcCString).assumingMemoryBound(to: CChar.self),
                        UnsafeRawPointer(dstCString).assumingMemoryBound(to: CChar.self),
                        0
                    )
                    guard result == 0 else {
                        throw Darwin.Kernel.Copy.Error(posixErrno: errno)
                    }
                }
            }
        }
    }

#endif
