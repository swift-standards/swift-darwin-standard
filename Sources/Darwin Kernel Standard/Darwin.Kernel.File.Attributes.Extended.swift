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

public import Kernel_File_Primitives
@_spi(Syscall) public import Kernel_Descriptor_Primitives
internal import Darwin

// MARK: - Attributes.Extended Namespace
// Extends Kernel.File.Attributes directly (Kernel = Kernel_Primitives.Kernel).
// Accessible via Darwin.Kernel.File.Attributes.Extended through the typealias.

extension Kernel.File.Attributes {
    /// Extended attribute operations (Darwin xattr API).
    public enum Extended {}
}

// MARK: - Error

extension Kernel.File.Attributes.Extended {
    /// Error type for extended attribute operations.
    public struct Error: Swift.Error, Sendable {
        public let code: Error_Primitives.Error.Code

        public init(code: Error_Primitives.Error.Code) {
            self.code = code
        }

        /// Attribute not found.
        public static let notFound = Error(code: .posix(ENOATTR))

        /// No space for attribute.
        public static let noSpace = Error(code: .posix(ENOSPC))

        /// Permission denied.
        public static let permissionDenied = Error(code: .posix(EACCES))

        /// Creates an error from the current errno.
        @usableFromInline
        internal static func current() -> Self {
            Self(code: .posix(errno))
        }
    }
}

// MARK: - List Operations

extension Kernel.File.Attributes.Extended {
    /// Lists extended attribute names on a file (raw C-string path variant).
    ///
    /// - Parameters:
    ///   - path: Path to the file as a C string.
    ///   - followSymlinks: If true, follows symlinks (default: true).
    /// - Returns: Array of attribute names.
    /// - Throws: `Error` on failure.
    @_spi(Syscall)
    @unsafe
    public static func list(
        path: UnsafePointer<CChar>,
        followSymlinks: Bool = true
    ) throws(Error) -> [Swift.String] {
        let options: Int32 = followSymlinks ? 0 : XATTR_NOFOLLOW

        // First call to get required buffer size
        let size = unsafe listxattr(path, nil, 0, options)
        guard size >= 0 else {
            throw .current()
        }

        if size == 0 {
            return []
        }

        // Allocate buffer and get names
        var buffer = [CChar](repeating: 0, count: size)
        let result = unsafe listxattr(path, &buffer, size, options)
        guard result >= 0 else {
            throw .current()
        }

        // Parse null-separated names
        return parseNullSeparatedStrings(buffer, count: result)
    }

    /// Lists extended attribute names on an open file descriptor.
    ///
    /// - Parameter fd: The file descriptor.
    /// - Returns: Array of attribute names.
    /// - Throws: `Error` on failure.
    @_spi(Syscall)
    public static func list(
        _ fd: Int32
    ) throws(Error) -> [Swift.String] {
        // First call to get required buffer size
        let size = flistxattr(fd, nil, 0, 0)
        guard size >= 0 else {
            throw .current()
        }

        if size == 0 {
            return []
        }

        // Allocate buffer and get names
        var buffer = [CChar](repeating: 0, count: size)
        let result = unsafe flistxattr(fd, &buffer, size, 0)
        guard result >= 0 else {
            throw .current()
        }

        return parseNullSeparatedStrings(buffer, count: result)
    }
}

// MARK: - Get Operations

extension Kernel.File.Attributes.Extended {
    /// Gets an extended attribute value by path (raw C-string variant).
    ///
    /// - Parameters:
    ///   - name: The attribute name as a C string.
    ///   - path: Path to the file as a C string.
    ///   - followSymlinks: If true, follows symlinks (default: true).
    /// - Returns: The attribute value as bytes.
    /// - Throws: `Error` on failure.
    @_spi(Syscall)
    @unsafe
    public static func get(
        name: UnsafePointer<CChar>,
        path: UnsafePointer<CChar>,
        followSymlinks: Bool = true
    ) throws(Error) -> [UInt8] {
        let options: Int32 = followSymlinks ? 0 : XATTR_NOFOLLOW

        // First call to get required buffer size
        let size = unsafe getxattr(path, name, nil, 0, 0, options)
        guard size >= 0 else {
            throw .current()
        }

        if size == 0 {
            return []
        }

        // Allocate buffer and get value
        var buffer = [UInt8](repeating: 0, count: size)
        let result = unsafe getxattr(path, name, &buffer, size, 0, options)
        guard result >= 0 else {
            throw .current()
        }

        return Array(buffer.prefix(result))
    }

    /// Gets an extended attribute value by file descriptor (raw C-string name variant).
    ///
    /// - Parameters:
    ///   - name: The attribute name as a C string.
    ///   - descriptor: The file descriptor.
    /// - Returns: The attribute value as bytes.
    /// - Throws: `Error` on failure.
    @_spi(Syscall)
    @unsafe
    public static func get(
        name: UnsafePointer<CChar>,
        _ fd: Int32
    ) throws(Error) -> [UInt8] {
        // First call to get required buffer size
        let size = unsafe fgetxattr(fd, name, nil, 0, 0, 0)
        guard size >= 0 else {
            throw .current()
        }

        if size == 0 {
            return []
        }

        // Allocate buffer and get value
        var buffer = [UInt8](repeating: 0, count: size)
        let result = unsafe fgetxattr(fd, name, &buffer, size, 0, 0)
        guard result >= 0 else {
            throw .current()
        }

        return Array(buffer.prefix(result))
    }
}

// MARK: - Set Operations

extension Kernel.File.Attributes.Extended {
    /// Sets an extended attribute by path (raw C-string variant).
    ///
    /// - Parameters:
    ///   - name: The attribute name as a C string.
    ///   - value: The attribute value.
    ///   - path: Path to the file as a C string.
    ///   - followSymlinks: If true, follows symlinks (default: true).
    /// - Throws: `Error` on failure.
    @_spi(Syscall)
    @unsafe
    public static func set(
        name: UnsafePointer<CChar>,
        value: UnsafeRawBufferPointer,
        path: UnsafePointer<CChar>,
        followSymlinks: Bool = true
    ) throws(Error) {
        let options: Int32 = followSymlinks ? 0 : XATTR_NOFOLLOW

        let result = unsafe setxattr(
            path,
            name,
            value.baseAddress,
            value.count,
            0,
            options
        )
        guard result == 0 else {
            throw .current()
        }
    }

    /// Sets an extended attribute by file descriptor (raw C-string name variant).
    ///
    /// - Parameters:
    ///   - name: The attribute name as a C string.
    ///   - value: The attribute value.
    ///   - descriptor: The file descriptor.
    /// - Throws: `Error` on failure.
    @_spi(Syscall)
    @unsafe
    public static func set(
        name: UnsafePointer<CChar>,
        value: UnsafeRawBufferPointer,
        _ fd: Int32
    ) throws(Error) {
        let result = unsafe fsetxattr(
            fd,
            name,
            value.baseAddress,
            value.count,
            0,
            0
        )
        guard result == 0 else {
            throw .current()
        }
    }
}

// MARK: - Remove Operations

extension Kernel.File.Attributes.Extended {
    /// Removes an extended attribute by path (raw C-string variant).
    ///
    /// - Parameters:
    ///   - name: The attribute name as a C string.
    ///   - path: Path to the file as a C string.
    ///   - followSymlinks: If true, follows symlinks (default: true).
    /// - Throws: `Error` on failure.
    @_spi(Syscall)
    @unsafe
    public static func remove(
        name: UnsafePointer<CChar>,
        path: UnsafePointer<CChar>,
        followSymlinks: Bool = true
    ) throws(Error) {
        let options: Int32 = followSymlinks ? 0 : XATTR_NOFOLLOW

        let result = unsafe removexattr(path, name, options)
        guard result == 0 else {
            throw .current()
        }
    }

    /// Removes an extended attribute by file descriptor (raw C-string name variant).
    ///
    /// - Parameters:
    ///   - name: The attribute name as a C string.
    ///   - descriptor: The file descriptor.
    /// - Throws: `Error` on failure.
    @_spi(Syscall)
    @unsafe
    public static func remove(
        name: UnsafePointer<CChar>,
        _ fd: Int32
    ) throws(Error) {
        let result = unsafe fremovexattr(fd, name, 0)
        guard result == 0 else {
            throw .current()
        }
    }
}

// MARK: - Copy Operation

extension Kernel.File.Attributes.Extended {
    /// Copies all extended attributes from one descriptor to another.
    ///
    /// - Parameters:
    ///   - source: Source file descriptor.
    ///   - destination: Destination file descriptor.
    /// - Throws: `Error` on failure.
    @_spi(Syscall)
    public static func copyAll(
        fromFd source: Int32,
        toFd destination: Int32
    ) throws(Error) {
        let names = try list(source)

        for name in names {
            // Use manual C string conversion to avoid untyped throws in withCString
            var utf8 = Array(name.utf8)
            utf8.append(0)
            try unsafe utf8.withUnsafeBufferPointer { buffer throws(Error) in
                let namePtr = unsafe UnsafeRawPointer(buffer.baseAddress!).assumingMemoryBound(to: CChar.self)
                let value = try unsafe get(name: namePtr, source)
                // Use withUnsafeBufferPointer for typed throws support
                try unsafe value.withUnsafeBufferPointer { valueBuffer throws(Error) in
                    try unsafe set(
                        name: namePtr,
                        value: UnsafeRawBufferPointer(valueBuffer),
                        destination
                    )
                }
            }
        }
    }
}

// MARK: - Helpers

extension Kernel.File.Attributes.Extended {
    /// Parses a buffer of null-separated strings.
    private static func parseNullSeparatedStrings(_ buffer: [CChar], count: Int) -> [Swift.String] {
        var names: [Swift.String] = []
        var start = 0

        for i in 0..<count {
            if buffer[i] == 0 {
                if i > start {
                    let slice = buffer[start..<i]
                    if let name = Swift.String(validating: Array(slice), as: UTF8.self) {
                        names.append(name)
                    }
                }
                start = i + 1
            }
        }

        return names
    }

    /// Invokes `body` with a NUL-terminated C string for the given name.
    ///
    /// `Swift.String.withCString` does not preserve typed throws on Swift 6.3,
    /// so this helper uses the same manual NUL-terminated UTF-8 buffer pattern
    /// as ``copyAll(from:to:)``.
    @unsafe
    fileprivate static func withCName<R, E: Swift.Error>(
        _ name: Swift.String,
        _ body: (UnsafePointer<CChar>) throws(E) -> R
    ) throws(E) -> R {
        var utf8 = Array(name.utf8)
        utf8.append(0)
        return try unsafe utf8.withUnsafeBufferPointer { buffer throws(E) in
            let ptr = unsafe UnsafeRawPointer(buffer.baseAddress!).assumingMemoryBound(to: CChar.self)
            return try unsafe body(ptr)
        }
    }
}

// MARK: - Safe Path/Name Overloads

extension Kernel.File.Attributes.Extended {
    /// Lists extended attribute names on a file.
    ///
    /// - Parameters:
    ///   - path: Path to the file.
    ///   - followSymlinks: If true, follows symlinks (default: true).
    /// - Returns: Array of attribute names.
    /// - Throws: `Error` on failure.
    public static func list(
        path: borrowing Kernel.Path.Borrowed,
        followSymlinks: Bool = true
    ) throws(Error) -> [Swift.String] {
        try unsafe path.withUnsafePointer { pathPtr throws(Error) in
            try unsafe list(
                path: UnsafeRawPointer(pathPtr).assumingMemoryBound(to: CChar.self),
                followSymlinks: followSymlinks
            )
        }
    }

    /// Gets an extended attribute value by path.
    ///
    /// - Parameters:
    ///   - name: The attribute name.
    ///   - path: Path to the file.
    ///   - followSymlinks: If true, follows symlinks (default: true).
    /// - Returns: The attribute value as bytes.
    /// - Throws: `Error` on failure.
    public static func get(
        name: Swift.String,
        path: borrowing Kernel.Path.Borrowed,
        followSymlinks: Bool = true
    ) throws(Error) -> [UInt8] {
        try unsafe withCName(name) { namePtr throws(Error) in
            try unsafe path.withUnsafePointer { pathPtr throws(Error) in
                try unsafe get(
                    name: namePtr,
                    path: UnsafeRawPointer(pathPtr).assumingMemoryBound(to: CChar.self),
                    followSymlinks: followSymlinks
                )
            }
        }
    }

    /// Gets an extended attribute value by file descriptor (raw fd variant).
    ///
    /// - Parameters:
    ///   - name: The attribute name.
    ///   - fd: The file descriptor.
    /// - Returns: The attribute value as bytes.
    /// - Throws: `Error` on failure.
    @_spi(Syscall)
    public static func get(
        name: Swift.String,
        _ fd: Int32
    ) throws(Error) -> [UInt8] {
        try unsafe withCName(name) { namePtr throws(Error) in
            try unsafe get(name: namePtr, fd)
        }
    }

    /// Sets an extended attribute by path.
    ///
    /// - Parameters:
    ///   - name: The attribute name.
    ///   - value: The attribute value.
    ///   - path: Path to the file.
    ///   - followSymlinks: If true, follows symlinks (default: true).
    /// - Throws: `Error` on failure.
    public static func set(
        name: Swift.String,
        value: UnsafeRawBufferPointer,
        path: borrowing Kernel.Path.Borrowed,
        followSymlinks: Bool = true
    ) throws(Error) {
        try unsafe withCName(name) { namePtr throws(Error) in
            try unsafe path.withUnsafePointer { pathPtr throws(Error) in
                try unsafe set(
                    name: namePtr,
                    value: value,
                    path: UnsafeRawPointer(pathPtr).assumingMemoryBound(to: CChar.self),
                    followSymlinks: followSymlinks
                )
            }
        }
    }

    /// Sets an extended attribute by file descriptor (raw fd variant).
    ///
    /// - Parameters:
    ///   - name: The attribute name.
    ///   - value: The attribute value.
    ///   - fd: The file descriptor.
    /// - Throws: `Error` on failure.
    @_spi(Syscall)
    public static func set(
        name: Swift.String,
        value: UnsafeRawBufferPointer,
        _ fd: Int32
    ) throws(Error) {
        try unsafe withCName(name) { namePtr throws(Error) in
            try unsafe set(name: namePtr, value: value, fd)
        }
    }

    /// Removes an extended attribute by path.
    ///
    /// - Parameters:
    ///   - name: The attribute name.
    ///   - path: Path to the file.
    ///   - followSymlinks: If true, follows symlinks (default: true).
    /// - Throws: `Error` on failure.
    public static func remove(
        name: Swift.String,
        path: borrowing Kernel.Path.Borrowed,
        followSymlinks: Bool = true
    ) throws(Error) {
        try unsafe withCName(name) { namePtr throws(Error) in
            try unsafe path.withUnsafePointer { pathPtr throws(Error) in
                try unsafe remove(
                    name: namePtr,
                    path: UnsafeRawPointer(pathPtr).assumingMemoryBound(to: CChar.self),
                    followSymlinks: followSymlinks
                )
            }
        }
    }

    /// Removes an extended attribute by file descriptor (raw fd variant).
    ///
    /// - Parameters:
    ///   - name: The attribute name.
    ///   - fd: The file descriptor.
    /// - Throws: `Error` on failure.
    @_spi(Syscall)
    public static func remove(
        name: Swift.String,
        _ fd: Int32
    ) throws(Error) {
        try unsafe withCName(name) { namePtr throws(Error) in
            try unsafe remove(name: namePtr, fd)
        }
    }
}

// MARK: - Typed Convenience (Phase 1.5)
//
// Adds typed `borrowing Kernel.Descriptor` overloads alongside the existing
// raw `_ fd: Int32` @_spi(Syscall) SPI forms. Each typed overload delegates
// to the corresponding raw form via `descriptor._rawValue`.

extension Kernel.File.Attributes.Extended {
    /// Lists extended attribute names on a typed descriptor.
    public static func list(
        _ descriptor: borrowing Kernel.Descriptor
    ) throws(Error) -> [Swift.String] {
        try list(descriptor._rawValue)
    }

    /// Gets an extended attribute value from a typed descriptor.
    public static func get(
        name: Swift.String,
        _ descriptor: borrowing Kernel.Descriptor
    ) throws(Error) -> [UInt8] {
        try get(name: name, descriptor._rawValue)
    }

    /// Sets an extended attribute on a typed descriptor.
    @unsafe
    public static func set(
        name: Swift.String,
        value: UnsafeRawBufferPointer,
        _ descriptor: borrowing Kernel.Descriptor
    ) throws(Error) {
        try unsafe set(name: name, value: value, descriptor._rawValue)
    }

    /// Removes an extended attribute from a typed descriptor.
    public static func remove(
        name: Swift.String,
        _ descriptor: borrowing Kernel.Descriptor
    ) throws(Error) {
        try remove(name: name, descriptor._rawValue)
    }

    /// Copies all extended attributes from one typed descriptor to another.
    public static func copyAll(
        from source: borrowing Kernel.Descriptor,
        to destination: borrowing Kernel.Descriptor
    ) throws(Error) {
        try copyAll(fromFd: source._rawValue, toFd: destination._rawValue)
    }
}

#endif // canImport(Darwin)
