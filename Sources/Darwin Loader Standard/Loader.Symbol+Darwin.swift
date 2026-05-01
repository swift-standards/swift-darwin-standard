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

#if canImport(Darwin)

public import Loader_Primitives
internal import String_Primitives
internal import Darwin
internal import CDarwinKernelShim

// MARK: - dlsym Handle Conversion

extension Loader.Symbol.Scope {
    /// Converts scope to the `dlsym` handle pointer for Darwin.
    ///
    /// Uses constants from `<dlfcn.h>` via `CDarwinKernelShim`.
    @unsafe
    fileprivate var dlsymHandle: UnsafeMutableRawPointer? {
        switch unsafe self {
        case .handle(let h):
            return unsafe h.rawValue
        case .default:
            return unsafe swift_RTLD_DEFAULT()
        case .next:
            return unsafe swift_RTLD_NEXT()
        }
    }
}

// MARK: - Symbol Lookup

extension Loader.Symbol {
    /// Looks up a symbol in a library or scope on Darwin.
    ///
    /// Wraps `dlsym(3)`.
    ///
    /// - Parameters:
    ///   - name: The symbol name.
    ///   - scope: Where to search — a loaded `Handle` or special scope.
    /// - Returns: Pointer to the symbol.
    /// - Throws: `Loader.Error.symbol` if not found.
    ///
    /// ## Pointer Lifetime
    ///
    /// - Returned `UnsafeRawPointer` is valid only while the owning library remains loaded.
    /// - Caller is responsible for correct casting and calling convention.
    @unsafe
    public static func lookup(
        name: Swift.String,
        in scope: Scope
    ) throws(Loader.Error) -> UnsafeRawPointer {
        // Manual NUL-terminated UTF-8 buffer: withCString does not preserve
        // typed throws on Swift 6.3, so we use the same pattern as
        // Darwin.Kernel.File.Attributes.Extended.copyAll.
        var utf8 = Array(name.utf8)
        utf8.append(0)
        return try unsafe utf8.withUnsafeBufferPointer { buffer throws(Loader.Error) in
            let cName = unsafe UnsafeRawPointer(buffer.baseAddress!).assumingMemoryBound(to: CChar.self)
            return try unsafe lookup(name: cName, in: scope)
        }
    }

    /// Looks up a symbol in a library or scope on Darwin (raw C-string variant).
    ///
    /// Wraps `dlsym(3)`.
    ///
    /// - Parameters:
    ///   - name: The symbol name (C string).
    ///   - scope: Where to search — a loaded `Handle` or special scope.
    /// - Returns: Pointer to the symbol.
    /// - Throws: `Loader.Error.symbol` if not found.
    ///
    /// ## Pointer Lifetime
    ///
    /// - Returned `UnsafeRawPointer` is valid only while the owning library remains loaded.
    /// - Caller is responsible for correct casting and calling convention.
    @unsafe
    internal static func lookup(
        name: UnsafePointer<CChar>,
        in scope: Scope
    ) throws(Loader.Error) -> UnsafeRawPointer {
        _ = unsafe dlerror()

        let sym = unsafe dlsym(scope.dlsymHandle, name)

        if let errorCStr = unsafe dlerror() {
            let u8Ptr = unsafe UnsafeRawPointer(errorCStr).assumingMemoryBound(to: UInt8.self)
            let view = unsafe String_Primitives.String.Borrowed(u8Ptr, count: String_Primitives.String.length(of: u8Ptr))
            throw .symbol(unsafe Loader.Message(copying: view))
        }

        guard let sym = unsafe sym else {
            throw .symbol(Loader.Message(ascii: "symbol resolved to NULL (no dlerror)"))
        }

        return UnsafeRawPointer(sym)
    }
}

#endif
