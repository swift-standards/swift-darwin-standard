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

    // MARK: - Capability Probing

    extension ISO_9945.Kernel.File.Clone.Capability {
        /// Probes whether the filesystem at the given path supports cloning.
        public static func probe(at path: borrowing Path.Borrowed) throws(ISO_9945.Kernel.File.Clone.Error.Syscall) -> ISO_9945.Kernel.File.Clone.Capability {
            try unsafe path.withUnsafePointer { cString throws(ISO_9945.Kernel.File.Clone.Error.Syscall) in
                var statfsBuf = statfs()
                let result = unsafe statfs(UnsafeRawPointer(cString).assumingMemoryBound(to: CChar.self), &statfsBuf)

                guard result == 0 else {
                    throw ISO_9945.Kernel.File.Clone.Error.Syscall.platform(code: .posix(errno), operation: .statfs)
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

    extension ISO_9945.Kernel.File.Clone.Metadata {
        /// Gets the size of a file.
        public static func size(at path: borrowing Path.Borrowed) throws(ISO_9945.Kernel.File.Clone.Error.Syscall) -> Int {
            try unsafe path.withUnsafePointer { cString throws(ISO_9945.Kernel.File.Clone.Error.Syscall) in
                var statBuf = stat()
                let result = unsafe stat(UnsafeRawPointer(cString).assumingMemoryBound(to: CChar.self), &statBuf)

                guard result == 0 else {
                    throw ISO_9945.Kernel.File.Clone.Error.Syscall.platform(code: .posix(errno), operation: .stat)
                }

                return Int(statBuf.st_size)
            }
        }
    }

    // MARK: - Clonefile

    extension ISO_9945.Kernel.File.Clone {
        /// macOS clonefile() operations.
        public enum Clonefile {
            /// Attempts to clone a file using clonefile().
            public static func attempt(
                source: borrowing Path.Borrowed,
                destination: borrowing Path.Borrowed
            ) throws(ISO_9945.Kernel.File.Clone.Error.Syscall) -> Bool {
                try unsafe source.withUnsafePointer { srcCString throws(ISO_9945.Kernel.File.Clone.Error.Syscall) in
                    try unsafe destination.withUnsafePointer { dstCString throws(ISO_9945.Kernel.File.Clone.Error.Syscall) in
                        let result = unsafe clonefile(UnsafeRawPointer(srcCString).assumingMemoryBound(to: CChar.self), UnsafeRawPointer(dstCString).assumingMemoryBound(to: CChar.self), 0)

                        if result == 0 {
                            return true
                        }

                        let err = errno
                        if err == ENOTSUP {
                            return false
                        }

                        throw ISO_9945.Kernel.File.Clone.Error.Syscall.platform(code: .posix(err), operation: .clonefile)
                    }
                }
            }
        }

        /// macOS copyfile() operations.
        public enum Copyfile {
            /// Copies a file using copyfile() with COPYFILE_CLONE flag.
            public static func clone(
                source: borrowing Path.Borrowed,
                destination: borrowing Path.Borrowed
            ) throws(ISO_9945.Kernel.File.Clone.Error.Syscall) {
                try unsafe source.withUnsafePointer { srcCString throws(ISO_9945.Kernel.File.Clone.Error.Syscall) in
                    try unsafe destination.withUnsafePointer { dstCString throws(ISO_9945.Kernel.File.Clone.Error.Syscall) in
                        let srcPtr = unsafe UnsafeRawPointer(srcCString).assumingMemoryBound(to: CChar.self)
                        let dstPtr = unsafe UnsafeRawPointer(dstCString).assumingMemoryBound(to: CChar.self)

                        var statBuf = stat()
                        let destExists = unsafe (stat(dstPtr, &statBuf) == 0)
                        if destExists {
                            throw ISO_9945.Kernel.File.Clone.Error.Syscall.platform(code: .posix(EEXIST), operation: .copyfile)
                        }

                        let result = unsafe copyfile(srcPtr, dstPtr, nil, copyfile_flags_t(COPYFILE_CLONE | COPYFILE_ALL))

                        guard result == 0 else {
                            throw ISO_9945.Kernel.File.Clone.Error.Syscall.platform(code: .posix(errno), operation: .copyfile)
                        }
                    }
                }
            }

            /// Copies a file using copyfile() without clone attempt.
            public static func data(
                source: borrowing Path.Borrowed,
                destination: borrowing Path.Borrowed
            ) throws(ISO_9945.Kernel.File.Clone.Error.Syscall) {
                try unsafe source.withUnsafePointer { srcCString throws(ISO_9945.Kernel.File.Clone.Error.Syscall) in
                    try unsafe destination.withUnsafePointer { dstCString throws(ISO_9945.Kernel.File.Clone.Error.Syscall) in
                        let srcPtr = unsafe UnsafeRawPointer(srcCString).assumingMemoryBound(to: CChar.self)
                        let dstPtr = unsafe UnsafeRawPointer(dstCString).assumingMemoryBound(to: CChar.self)

                        var statBuf = stat()
                        let destExists = unsafe (stat(dstPtr, &statBuf) == 0)
                        if destExists {
                            throw ISO_9945.Kernel.File.Clone.Error.Syscall.platform(code: .posix(EEXIST), operation: .copyfile)
                        }

                        let result = unsafe copyfile(srcPtr, dstPtr, nil, copyfile_flags_t(COPYFILE_DATA))

                        guard result == 0 else {
                            throw ISO_9945.Kernel.File.Clone.Error.Syscall.platform(code: .posix(errno), operation: .copyfile)
                        }
                    }
                }
            }
        }
    }

#endif
