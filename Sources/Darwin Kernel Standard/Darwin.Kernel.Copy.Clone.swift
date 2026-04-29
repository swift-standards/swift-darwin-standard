// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-darwin-primitives open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-darwin-primitives project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

public import ISO_9945_Kernel_File
public import ISO_9945_Core
@_spi(Syscall) public import Kernel_File_Primitives
internal import Darwin

// MARK: - POSIX errno to Copy.Error Mapping

extension Kernel.Copy.Error {
    /// Creates a copy error from a POSIX errno value.
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

// MARK: - macOS clonefile Implementation

extension Kernel.Copy.Clone {
    /// Clones a file using clonefile(2), creating a copy-on-write duplicate.
    ///
    /// Both files share the same data blocks until one is modified, making this
    /// extremely fast for large files on APFS.
    ///
    /// ## Threading
    /// This call blocks until the clone operation completes. The clone is atomic.
    ///
    /// ## Filesystem Support
    /// Only works on APFS. Falls back to regular copy on HFS+ or other filesystems.
    ///
    /// ## Errors
    /// - ``Kernel/Copy/Error/notFound``: Source file doesn't exist
    /// - ``Kernel/Copy/Error/exists``: Destination path already exists
    /// - ``Kernel/Copy/Error/permission``: Insufficient permissions
    /// - ``Kernel/Copy/Error/unsupported``: Filesystem doesn't support clonefile
    ///
    /// - Parameters:
    ///   - sourcePath: Path to source file.
    ///   - destPath: Path for destination file (must not exist).
    /// - Throws: ``Kernel/Copy/Error`` on failure.

    public static func file(
        from sourcePath: borrowing Path.Borrowed,
        to destPath: borrowing Path.Borrowed
    ) throws(Kernel.Copy.Error) {
        try unsafe sourcePath.withUnsafePointer { srcCString throws(Kernel.Copy.Error) in
            try unsafe destPath.withUnsafePointer { dstCString throws(Kernel.Copy.Error) in
                let result = unsafe clonefile(UnsafeRawPointer(srcCString).assumingMemoryBound(to: CChar.self), UnsafeRawPointer(dstCString).assumingMemoryBound(to: CChar.self), 0)
                guard result == 0 else {
                    throw Kernel.Copy.Error(posixErrno: errno)
                }
            }
        }
    }
}

#endif
