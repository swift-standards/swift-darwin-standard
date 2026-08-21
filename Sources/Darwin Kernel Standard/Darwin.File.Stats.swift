public import Darwin_Standard_Core
@_spi(Syscall) public import ISO_9945_Core
internal import ISO_9945_Kernel
import ISO_9945_Kernel_File
internal import Time_Primitives

#if canImport(Darwin)
    internal import Darwin

    internal typealias PlatformStat = stat

    extension Darwin_Standard_Core.Darwin.File {

        public struct Stats: Sendable, Equatable {

            public let base: ISO_9945.Kernel.File.Stats

            public let birthtime: ISO_9945.Kernel.Time

            @inlinable
            public init(base: ISO_9945.Kernel.File.Stats, birthtime: ISO_9945.Kernel.Time) {
                self.base = base
                self.birthtime = birthtime
            }
        }
    }

    extension Darwin_Standard_Core.Darwin.File.Stats {

        @inlinable
        public var size: ISO_9945.Kernel.File.Size { base.size }

        @inlinable
        public var type: ISO_9945.Kernel.File.Stats.Kind { base.type }

        @inlinable
        public var permissions: ISO_9945.Kernel.File.Permissions { base.permissions }

        @inlinable
        public var uid: ISO_9945.Kernel.User.ID { base.uid }

        @inlinable
        public var gid: ISO_9945.Kernel.Group.ID { base.gid }

        @inlinable
        public var inode: ISO_9945.Kernel.Inode { base.inode }

        @inlinable
        public var device: ISO_9945.Kernel.Device { base.device }

        @inlinable
        public var linkCount: ISO_9945.Kernel.Link.Count { base.linkCount }

        @inlinable
        public var accessTime: ISO_9945.Kernel.Time { base.accessTime }

        @inlinable
        public var modificationTime: ISO_9945.Kernel.Time { base.modificationTime }

        @inlinable
        public var changeTime: ISO_9945.Kernel.Time { base.changeTime }
    }

    extension Darwin_Standard_Core.Darwin.File.Stats {

        public typealias Error = ISO_9945.Kernel.File.Stats.Error

        public static func get(path: borrowing Path) throws(Error) -> Self {
            let cPath = unsafe UnsafeRawPointer(path.view.pointer).assumingMemoryBound(
                to: CChar.self
            )
            return try unsafe get(path: cPath)
        }

        @unsafe
        internal static func get(path: UnsafePointer<CChar>) throws(Error) -> Self {
            var sb = PlatformStat()
            guard unsafe stat(path, &sb) == 0 else {
                throw Error(_posixErrno: errno)
            }
            return Self(_from: sb)
        }

        public static func lget(path: borrowing Path) throws(Error) -> Self {
            let cPath = unsafe UnsafeRawPointer(path.view.pointer).assumingMemoryBound(
                to: CChar.self
            )
            return try unsafe lget(path: cPath)
        }

        @unsafe
        internal static func lget(path: UnsafePointer<CChar>) throws(Error) -> Self {
            var sb = PlatformStat()
            guard unsafe lstat(path, &sb) == 0 else {
                throw Error(_posixErrno: errno)
            }
            return Self(_from: sb)
        }

        internal static func get(fd: Int32) throws(Error) -> Self {
            var sb = PlatformStat()
            guard unsafe fstat(fd, &sb) == 0 else {
                throw Error(_posixErrno: errno)
            }
            return Self(_from: sb)
        }

        public static func get(
            _ descriptor: borrowing ISO_9945.Kernel.Descriptor
        ) throws(Error) -> Self {
            try get(fd: descriptor._rawValue)
        }
    }

    extension Darwin_Standard_Core.Darwin.File.Stats {

        internal init(_from sb: PlatformStat) {
            let atime = Instant(
                _unchecked: (),
                secondsSinceUnixEpoch: Int64(sb.st_atimespec.tv_sec),
                nanosecondFraction: Int32(sb.st_atimespec.tv_nsec)
            )
            let mtime = Instant(
                _unchecked: (),
                secondsSinceUnixEpoch: Int64(sb.st_mtimespec.tv_sec),
                nanosecondFraction: Int32(sb.st_mtimespec.tv_nsec)
            )
            let ctime = Instant(
                _unchecked: (),
                secondsSinceUnixEpoch: Int64(sb.st_ctimespec.tv_sec),
                nanosecondFraction: Int32(sb.st_ctimespec.tv_nsec)
            )
            let btime = Instant(
                _unchecked: (),
                secondsSinceUnixEpoch: Int64(sb.st_birthtimespec.tv_sec),
                nanosecondFraction: Int32(sb.st_birthtimespec.tv_nsec)
            )

            let base = ISO_9945.Kernel.File.Stats(
                size: ISO_9945.Kernel.File.Size(Int64(sb.st_size)),
                type: ISO_9945.Kernel.File.Stats.Kind(_mode: sb.st_mode),
                permissions: ISO_9945.Kernel.File.Permissions(
                    rawValue: UInt16(sb.st_mode & 0o7777)
                ),
                uid: ISO_9945.Kernel.User.ID(_unchecked: UInt32(sb.st_uid)),
                gid: ISO_9945.Kernel.Group.ID(_unchecked: UInt32(sb.st_gid)),
                inode: ISO_9945.Kernel.Inode(UInt64(sb.st_ino)),
                device: ISO_9945.Kernel.Device(UInt64(sb.st_dev)),
                linkCount: ISO_9945.Kernel.Link.Count(_unchecked: Cardinal(UInt(sb.st_nlink))),
                accessTime: atime,
                modificationTime: mtime,
                changeTime: ctime
            )

            self.init(base: base, birthtime: btime)
        }
    }

    extension ISO_9945.Kernel.File.Stats.Error {

        internal init(_posixErrno code: Int32) {
            let errorCode = Error_Primitives.Error.Code.posix(code)
            if let e = ISO_9945.Kernel.Descriptor.Validity.Error(code: errorCode) {
                self = .handle(e)
                return
            }
            self = .platform(Error_Primitives.Error(code: errorCode))
        }
    }

    extension ISO_9945.Kernel.File.Stats.Kind {

        internal init(_mode: mode_t) {
            let fileType = _mode & S_IFMT
            switch fileType {
            case S_IFREG:
                self = .regular

            case S_IFDIR:
                self = .directory

            case S_IFLNK:
                self = .link(.symbolic)

            case S_IFBLK:
                self = .device(.block)

            case S_IFCHR:
                self = .device(.character)

            case S_IFIFO:
                self = .fifo

            case S_IFSOCK:
                self = .socket

            default:
                self = .unknown
            }
        }
    }

#endif
