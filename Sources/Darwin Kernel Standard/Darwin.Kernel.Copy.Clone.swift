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
    internal import Darwin

    // MARK: - Namespace Roots
    //
    // Per swift-standards/swift-darwin-standard#3: the Copy vocabulary family
    // was hoisted from swift-iso-9945's "ISO 9945 Kernel" Copy namespace
    // (L2 POSIX) to swift-kernel (L3), so this Darwin-specific mechanism can
    // no longer anchor on it. The namespace and its vocabulary re-anchor
    // onto the package's own `Darwin.Kernel` root, replicated from the
    // declarations they previously extended — declarations the follow-up
    // swift-iso-9945 purge (swift-iso/swift-iso-9945#65) deletes once this
    // destination exists.

    extension Darwin_Standard_Core.Darwin.Kernel {
        /// File copy operations using kernel-accelerated mechanisms.
        public enum Copy: Sendable {}
    }

    extension Darwin.Kernel.Copy {
        /// Errors from copy operations.
        ///
        /// Each case represents a specific failure mode of `copy_file_range`,
        /// `clone` (FICLONE), or `clonefile`.
        public enum Error: Swift.Error, Sendable, Equatable, Hashable {
            /// Invalid file descriptor.
            case invalidDescriptor

            /// Cross-device copy not supported.
            ///
            /// The source and destination are on different filesystems.
            case crossDevice

            /// Operation not supported.
            ///
            /// The filesystem or file type doesn't support this operation.
            case unsupported

            /// No space left on device.
            case noSpace

            /// Physical I/O error.
            case io

            /// Permission denied.
            case permissionDenied

            /// Destination already exists.
            case exists

            /// Source not found.
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
        /// Clone operations (copy-on-write).
        ///
        /// Creates copy-on-write clones where supported, sharing data blocks
        /// until either file is modified.
        public enum Clone {}
    }

    // MARK: - POSIX errno to Copy.Error Mapping

    extension Darwin.Kernel.Copy.Error {
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

    extension Darwin.Kernel.Copy.Clone {
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
        ///
        /// - Throws: ``Kernel/Copy/Error`` on failure.

        public static func file(
            from sourcePath: borrowing Path.Borrowed,
            to destPath: borrowing Path.Borrowed
        ) throws(Darwin.Kernel.Copy.Error) {
            try unsafe sourcePath.withUnsafePointer { srcCString throws(Darwin.Kernel.Copy.Error) in
                try unsafe destPath.withUnsafePointer { dstCString throws(Darwin.Kernel.Copy.Error) in
                    let result = unsafe clonefile(UnsafeRawPointer(srcCString).assumingMemoryBound(to: CChar.self), UnsafeRawPointer(dstCString).assumingMemoryBound(to: CChar.self), 0)
                    guard result == 0 else {
                        throw Darwin.Kernel.Copy.Error(posixErrno: errno)
                    }
                }
            }
        }
    }

#endif
