// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-darwin open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-darwin project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Darwin_Standard_Core
public import Kernel_File_Primitives
@_spi(Syscall) public import Kernel_Descriptor_Primitives
@_spi(Syscall) public import ISO_9945_Kernel_Descriptor
internal import Time_Primitives

// L2 init?(code:) extensions for Kernel.Descriptor.Validity.Error and Kernel.IO.Error
internal import ISO_9945_Kernel

#if canImport(Darwin)
internal import Darwin

// Use stat directly since Darwin module is imported (stat shadows Darwin_Standard_Core.Darwin)
internal typealias PlatformStat = stat

extension Darwin_Standard_Core.Darwin.File {
    /// Darwin-specific file metadata including birthtime.
    ///
    /// This type extends the cross-platform `Kernel.File.Stats` with Darwin-specific
    /// fields like `birthtime` (file creation time) that are not available on all platforms.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// import Darwin_Kernel_Standard
    ///
    /// let stats = try Darwin.File.Stats.get(path: "/tmp/data.txt")
    /// print("Created: \(stats.birthtime)")  // Non-optional, always available on Darwin
    /// print("Size: \(stats.base.size)")
    /// ```
    ///
    /// ## See Also
    ///
    /// - ``Kernel/File/Stats`` for cross-platform file stats
    public struct Stats: Sendable, Equatable {
        /// The cross-platform file stats.
        public let base: Kernel.File.Stats

        /// File creation time (birthtime).
        ///
        /// This is always available on Darwin systems as `st_birthtimespec`.
        /// On other platforms, use the platform-specific package or omit this field.
        public let birthtime: Kernel.Time

        /// Creates Darwin file stats.
        @inlinable
        public init(base: Kernel.File.Stats, birthtime: Kernel.Time) {
            self.base = base
            self.birthtime = birthtime
        }
    }
}

// MARK: - Convenience accessors

extension Darwin_Standard_Core.Darwin.File.Stats {
    /// File size in bytes.
    @inlinable
    public var size: Kernel.File.Size { base.size }

    /// File type (regular, directory, symlink, etc.).
    @inlinable
    public var type: Kernel.File.Stats.Kind { base.type }

    /// POSIX file permissions.
    @inlinable
    public var permissions: Kernel.File.Permissions { base.permissions }

    /// Owner user ID.
    @inlinable
    public var uid: Kernel.User.ID { base.uid }

    /// Owner group ID.
    @inlinable
    public var gid: Kernel.Group.ID { base.gid }

    /// Inode number.
    @inlinable
    public var inode: Kernel.Inode { base.inode }

    /// Device ID.
    @inlinable
    public var device: Kernel.Device { base.device }

    /// Number of hard links.
    @inlinable
    public var linkCount: Kernel.Link.Count { base.linkCount }

    /// Last access time.
    @inlinable
    public var accessTime: Kernel.Time { base.accessTime }

    /// Last modification time.
    @inlinable
    public var modificationTime: Kernel.Time { base.modificationTime }

    /// Status change time.
    @inlinable
    public var changeTime: Kernel.Time { base.changeTime }
}

// MARK: - Get operations

extension Darwin_Standard_Core.Darwin.File.Stats {
    /// Error type for Darwin file stats operations.
    public typealias Error = Kernel.File.Stats.Error

    /// Gets Darwin-specific file metadata for a path (follows symlinks).
    ///
    /// - Parameter path: The path to stat.
    /// - Returns: Darwin file metadata including birthtime.
    /// - Throws: ``Kernel/File/Stats/Error`` if the syscall fails.
    public static func get(path: borrowing Kernel.Path) throws(Error) -> Self {
        let cPath = unsafe UnsafeRawPointer(path.view.pointer).assumingMemoryBound(to: CChar.self)
        return try unsafe get(path: cPath)
    }

    /// Gets Darwin-specific file metadata for a path using a C string.
    ///
    /// - Parameter path: The path as a C string.
    /// - Returns: Darwin file metadata including birthtime.
    /// - Throws: ``Kernel/File/Stats/Error`` if the syscall fails.
    @_spi(Syscall)
    @unsafe
    public static func get(path: UnsafePointer<CChar>) throws(Error) -> Self {
        var sb = PlatformStat()
        guard unsafe stat(path, &sb) == 0 else {
            throw Error(_posixErrno: errno)
        }
        return Self(_from: sb)
    }

    /// Gets Darwin-specific file metadata for a path without following symlinks.
    ///
    /// - Parameter path: The path to stat.
    /// - Returns: Darwin file metadata including birthtime.
    /// - Throws: ``Kernel/File/Stats/Error`` if the syscall fails.
    public static func lget(path: borrowing Kernel.Path) throws(Error) -> Self {
        let cPath = unsafe UnsafeRawPointer(path.view.pointer).assumingMemoryBound(to: CChar.self)
        return try unsafe lget(path: cPath)
    }

    /// Gets Darwin-specific file metadata for a path using a C string without following symlinks.
    ///
    /// - Parameter path: The path as a C string.
    /// - Returns: Darwin file metadata including birthtime.
    /// - Throws: ``Kernel/File/Stats/Error`` if the syscall fails.
    @_spi(Syscall)
    @unsafe
    public static func lget(path: UnsafePointer<CChar>) throws(Error) -> Self {
        var sb = PlatformStat()
        guard unsafe lstat(path, &sb) == 0 else {
            throw Error(_posixErrno: errno)
        }
        return Self(_from: sb)
    }

    /// Gets Darwin-specific file metadata for an open raw file descriptor.
    ///
    /// Spec-literal: takes a raw `Int32` fd. The L3-policy typed-descriptor
    /// convenience lives at swift-darwin per [PLAT-ARCH-005] / [PLAT-ARCH-008e].
    ///
    /// - Parameter fd: The raw file descriptor to stat.
    /// - Returns: Darwin file metadata including birthtime.
    /// - Throws: ``Kernel/File/Stats/Error`` if the syscall fails.
    @_spi(Syscall)
    public static func get(fd: Int32) throws(Error) -> Self {
        var sb = PlatformStat()
        guard unsafe fstat(fd, &sb) == 0 else {
            throw Error(_posixErrno: errno)
        }
        return Self(_from: sb)
    }

    /// Gets Darwin-specific file metadata for a typed descriptor.
    ///
    /// Phase 1.5 typed L2 form. Delegates to the raw `get(fd:)` SPI.
    public static func get(_ descriptor: borrowing POSIX.Kernel.Descriptor) throws(Error) -> Self {
        try get(fd: descriptor._rawValue)
    }
}

// MARK: - Internal construction

extension Darwin_Standard_Core.Darwin.File.Stats {
    /// Creates Darwin file stats from a Darwin stat structure.
    internal init(_from sb: PlatformStat) {
        let atime = Instant(
            __unchecked: (),
            secondsSinceUnixEpoch: Int64(sb.st_atimespec.tv_sec),
            nanosecondFraction: Int32(sb.st_atimespec.tv_nsec)
        )
        let mtime = Instant(
            __unchecked: (),
            secondsSinceUnixEpoch: Int64(sb.st_mtimespec.tv_sec),
            nanosecondFraction: Int32(sb.st_mtimespec.tv_nsec)
        )
        let ctime = Instant(
            __unchecked: (),
            secondsSinceUnixEpoch: Int64(sb.st_ctimespec.tv_sec),
            nanosecondFraction: Int32(sb.st_ctimespec.tv_nsec)
        )
        let btime = Instant(
            __unchecked: (),
            secondsSinceUnixEpoch: Int64(sb.st_birthtimespec.tv_sec),
            nanosecondFraction: Int32(sb.st_birthtimespec.tv_nsec)
        )

        let base = Kernel.File.Stats(
            size: Kernel.File.Size(Int64(sb.st_size)),
            type: Kernel.File.Stats.Kind(_mode: sb.st_mode),
            permissions: Kernel.File.Permissions(rawValue: UInt16(sb.st_mode & 0o7777)),
            uid: Kernel.User.ID(__unchecked: (), UInt32(sb.st_uid)),
            gid: Kernel.Group.ID(__unchecked: (), UInt32(sb.st_gid)),
            inode: Kernel.Inode(UInt64(sb.st_ino)),
            device: Kernel.Device(UInt64(sb.st_dev)),
            linkCount: Kernel.Link.Count(__unchecked: (), Cardinal(UInt(sb.st_nlink))),
            accessTime: atime,
            modificationTime: mtime,
            changeTime: ctime
        )

        self.init(base: base, birthtime: btime)
    }
}

// MARK: - Error extension for posix errno

extension Kernel.File.Stats.Error {
    /// Creates an error from a POSIX errno.
    internal init(_posixErrno code: Int32) {
        let errorCode = Kernel.Error.Code.posix(code)
        if let e = Kernel.Descriptor.Validity.Error(code: errorCode) {
            self = .handle(e)
            return
        }
        if let e = Kernel.IO.Error(code: errorCode) {
            self = .io(e)
            return
        }
        self = .platform(Kernel.Error(code: errorCode))
    }
}

// MARK: - Kind extension for mode_t

extension Kernel.File.Stats.Kind {
    /// Creates a file type from POSIX st_mode.
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
