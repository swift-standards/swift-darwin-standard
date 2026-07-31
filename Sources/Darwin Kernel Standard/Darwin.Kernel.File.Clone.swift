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
    public import Error_Primitives
    internal import Darwin

    // MARK: - Namespace Roots
    //
    // Per swift-standards/swift-darwin-standard#3: the File.Clone vocabulary
    // family was hoisted from swift-iso-9945's "ISO 9945 Kernel" File Clone
    // namespace (L2 POSIX) to swift-kernel (L3), so this Darwin-specific
    // mechanism can no longer anchor on it — a platform L2 standard cannot
    // depend on the L3 unifier.
    // The namespace and its vocabulary (Capability, Metadata, Error,
    // Error.Syscall, Error.Operation) re-anchor onto the package's own
    // `Darwin.Kernel` root, replicated from the ISO_9945 declarations they
    // previously extended — declarations the follow-up swift-iso-9945 purge
    // (swift-iso/swift-iso-9945#65) deletes once this destination exists.

    extension Darwin_Standard_Core.Darwin.Kernel {
        /// Darwin-specific file operations rooted at the kernel namespace.
        public enum File: Sendable {}
    }

    extension Darwin.Kernel.File {
        /// Namespace for file cloning (copy-on-write reflink) operations.
        public enum Clone {}
    }

    extension Darwin.Kernel.File.Clone {
        /// The cloning capability of a filesystem/path.
        ///
        /// Capability is probed per-path because:
        /// - Different volumes may have different capabilities
        /// - The same process may work with multiple filesystems
        public enum Capability: Sendable, Equatable {
            /// The filesystem supports copy-on-write reflink.
            ///
            /// Cloning is O(1) regardless of file size.
            case reflink

            /// The filesystem does not support reflink.
            ///
            /// Only byte-by-byte copy is available.
            case none
        }
    }

    extension Darwin.Kernel.File.Clone {
        /// File metadata operations.
        public enum Metadata {}
    }

    extension Darwin.Kernel.File.Clone {
        /// Errors that can occur during clone operations.
        public enum Error: Swift.Error, Sendable, Equatable, CustomStringConvertible {
            /// Reflink is not supported on this filesystem.
            case notSupported

            /// Source and destination are on different filesystems/volumes.
            case crossDevice

            /// The source file does not exist.
            case sourceNotFound

            /// The destination already exists.
            case destinationExists

            /// Permission denied for source or destination.
            case permissionDenied

            /// The source is a directory, not a regular file.
            case isDirectory

            /// A platform-specific error occurred.
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
        /// Operation types for error context.
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
        /// Raw syscall-level errors for clone operations.
        ///
        /// This type captures the exact errno/win32 error code from syscalls.
        /// It is translated to the semantic `Darwin.Kernel.File.Clone.Error` at API boundaries.
        public enum Syscall: Swift.Error, Sendable {
            /// Platform syscall failure.
            case platform(code: Error_Primitives.Error.Code, operation: Operation)

            /// Operation not supported.
            case notSupported(operation: Operation)
        }
    }

    // MARK: - Capability Probing

    extension Darwin.Kernel.File.Clone.Capability {
        /// Probes whether the filesystem at the given path supports cloning.
        public static func probe(at path: borrowing Path.Borrowed) throws(Darwin.Kernel.File.Clone.Error.Syscall) -> Darwin.Kernel.File.Clone.Capability {
            try unsafe path.withUnsafePointer { cString throws(Darwin.Kernel.File.Clone.Error.Syscall) in
                var statfsBuf = statfs()
                let result = unsafe statfs(UnsafeRawPointer(cString).assumingMemoryBound(to: CChar.self), &statfsBuf)

                guard result == 0 else {
                    throw Darwin.Kernel.File.Clone.Error.Syscall.platform(code: .posix(errno), operation: .statfs)
                }

                let isAPFS = unsafe withUnsafeBytes(of: statfsBuf.f_fstypename) { buf in
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

    // MARK: - File Size

    extension Darwin.Kernel.File.Clone.Metadata {
        /// Gets the size of a file.
        public static func size(at path: borrowing Path.Borrowed) throws(Darwin.Kernel.File.Clone.Error.Syscall) -> Int {
            try unsafe path.withUnsafePointer { cString throws(Darwin.Kernel.File.Clone.Error.Syscall) in
                var statBuf = stat()
                let result = unsafe stat(UnsafeRawPointer(cString).assumingMemoryBound(to: CChar.self), &statBuf)

                guard result == 0 else {
                    throw Darwin.Kernel.File.Clone.Error.Syscall.platform(code: .posix(errno), operation: .stat)
                }

                return Int(statBuf.st_size)
            }
        }
    }

    // MARK: - Clonefile

    extension Darwin.Kernel.File.Clone {
        /// macOS clonefile() operations.
        public enum Clonefile {}

        /// macOS copyfile() operations.
        public enum Copyfile {}
    }

    extension Darwin.Kernel.File.Clone.Clonefile {
        /// Attempts to clone a file using clonefile().
        public static func attempt(
            source: borrowing Path.Borrowed,
            destination: borrowing Path.Borrowed
        ) throws(Darwin.Kernel.File.Clone.Error.Syscall) -> Bool {
            try unsafe source.withUnsafePointer { srcCString throws(Darwin.Kernel.File.Clone.Error.Syscall) in
                try unsafe destination.withUnsafePointer { dstCString throws(Darwin.Kernel.File.Clone.Error.Syscall) in
                    let result = unsafe clonefile(UnsafeRawPointer(srcCString).assumingMemoryBound(to: CChar.self), UnsafeRawPointer(dstCString).assumingMemoryBound(to: CChar.self), 0)

                    if result == 0 {
                        return true
                    }

                    let err = errno
                    if err == ENOTSUP {
                        return false
                    }

                    throw Darwin.Kernel.File.Clone.Error.Syscall.platform(code: .posix(err), operation: .clonefile)
                }
            }
        }
    }

    extension Darwin.Kernel.File.Clone.Copyfile {
        /// Copies a file using copyfile() with COPYFILE_CLONE flag.
        public static func clone(
            source: borrowing Path.Borrowed,
            destination: borrowing Path.Borrowed
        ) throws(Darwin.Kernel.File.Clone.Error.Syscall) {
            try unsafe source.withUnsafePointer { srcCString throws(Darwin.Kernel.File.Clone.Error.Syscall) in
                try unsafe destination.withUnsafePointer { dstCString throws(Darwin.Kernel.File.Clone.Error.Syscall) in
                    let srcPtr = unsafe UnsafeRawPointer(srcCString).assumingMemoryBound(to: CChar.self)
                    let dstPtr = unsafe UnsafeRawPointer(dstCString).assumingMemoryBound(to: CChar.self)

                    var statBuf = stat()
                    let destExists = unsafe (stat(dstPtr, &statBuf) == 0)
                    if destExists {
                        throw Darwin.Kernel.File.Clone.Error.Syscall.platform(code: .posix(EEXIST), operation: .copyfile)
                    }

                    let result = unsafe copyfile(srcPtr, dstPtr, nil, copyfile_flags_t(COPYFILE_CLONE | COPYFILE_ALL))

                    guard result == 0 else {
                        throw Darwin.Kernel.File.Clone.Error.Syscall.platform(code: .posix(errno), operation: .copyfile)
                    }
                }
            }
        }

        /// Copies a file using copyfile() without clone attempt.
        public static func data(
            source: borrowing Path.Borrowed,
            destination: borrowing Path.Borrowed
        ) throws(Darwin.Kernel.File.Clone.Error.Syscall) {
            try unsafe source.withUnsafePointer { srcCString throws(Darwin.Kernel.File.Clone.Error.Syscall) in
                try unsafe destination.withUnsafePointer { dstCString throws(Darwin.Kernel.File.Clone.Error.Syscall) in
                    let srcPtr = unsafe UnsafeRawPointer(srcCString).assumingMemoryBound(to: CChar.self)
                    let dstPtr = unsafe UnsafeRawPointer(dstCString).assumingMemoryBound(to: CChar.self)

                    var statBuf = stat()
                    let destExists = unsafe (stat(dstPtr, &statBuf) == 0)
                    if destExists {
                        throw Darwin.Kernel.File.Clone.Error.Syscall.platform(code: .posix(EEXIST), operation: .copyfile)
                    }

                    let result = unsafe copyfile(srcPtr, dstPtr, nil, copyfile_flags_t(COPYFILE_DATA))

                    guard result == 0 else {
                        throw Darwin.Kernel.File.Clone.Error.Syscall.platform(code: .posix(errno), operation: .copyfile)
                    }
                }
            }
        }
    }

#endif
