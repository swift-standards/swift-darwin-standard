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

#if canImport(Darwin)

public import ISO_9945_Core
internal import Darwin

// MARK: - Darwin renamex_np Implementation

extension ISO_9945.Kernel.File.Move {
    /// Atomically moves a file, failing if destination exists.
    ///
    /// Uses `renamex_np` with `RENAME_EXCL` flag on Darwin.
    ///
    /// - Parameters:
    ///   - oldPath: Source path.
    ///   - newPath: Destination path.
    /// - Throws: `ISO_9945.Kernel.File.Rename.Error` if the move fails.
    @unsafe
    internal static func noClobber(
        from oldPath: UnsafePointer<CChar>,
        to newPath: UnsafePointer<CChar>
    ) throws(ISO_9945.Kernel.File.Rename.Error) {
        let result = unsafe renamex_np(oldPath, newPath, UInt32(RENAME_EXCL))

        guard result == 0 else {
            let code = Error_Primitives.Error.Code.posix(errno)
            switch code.posix {
            case EEXIST:
                throw .exists
            case EPERM, EACCES:
                throw .permission(code)
            default:
                throw .platform(code)
            }
        }
    }

    /// Atomically moves a file using `Path`, failing if destination exists.
    public static func noClobber(
        from oldPath: borrowing Path.Borrowed,
        to newPath: borrowing Path.Borrowed
    ) throws(ISO_9945.Kernel.File.Rename.Error) {
        try unsafe oldPath.withUnsafePointer { oldPtr throws(ISO_9945.Kernel.File.Rename.Error) in
            try unsafe newPath.withUnsafePointer { newPtr throws(ISO_9945.Kernel.File.Rename.Error) in
                try unsafe noClobber(from: UnsafeRawPointer(oldPtr).assumingMemoryBound(to: CChar.self), to: UnsafeRawPointer(newPtr).assumingMemoryBound(to: CChar.self))
            }
        }
    }

    /// Atomically exchanges two files.
    ///
    /// Uses `renamex_np` with `RENAME_SWAP` flag on Darwin.
    /// Both paths must exist.
    ///
    /// - Parameters:
    ///   - path1: First path.
    ///   - path2: Second path.
    /// - Throws: `ISO_9945.Kernel.File.Rename.Error` on failure.
    @unsafe
    internal static func exchange(
        _ path1: UnsafePointer<CChar>,
        _ path2: UnsafePointer<CChar>
    ) throws(ISO_9945.Kernel.File.Rename.Error) {
        let result = unsafe renamex_np(path1, path2, UInt32(RENAME_SWAP))

        guard result == 0 else {
            let code = Error_Primitives.Error.Code.posix(errno)
            switch code.posix {
            case EPERM, EACCES:
                throw .permission(code)
            default:
                throw .platform(code)
            }
        }
    }

    /// Atomically exchanges two files using `Path`.
    public static func exchange(
        _ path1: borrowing Path.Borrowed,
        _ path2: borrowing Path.Borrowed
    ) throws(ISO_9945.Kernel.File.Rename.Error) {
        try unsafe path1.withUnsafePointer { ptr1 throws(ISO_9945.Kernel.File.Rename.Error) in
            try unsafe path2.withUnsafePointer { ptr2 throws(ISO_9945.Kernel.File.Rename.Error) in
                try unsafe exchange(UnsafeRawPointer(ptr1).assumingMemoryBound(to: CChar.self), UnsafeRawPointer(ptr2).assumingMemoryBound(to: CChar.self))
            }
        }
    }
}

#endif
