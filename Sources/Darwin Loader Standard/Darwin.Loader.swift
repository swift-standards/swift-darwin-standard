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

@_exported public import Darwin_Standard_Core
@_exported public import Loader_Primitives

extension Darwin_Standard_Core.Darwin {
    /// Darwin dynamic loader interface.
    ///
    /// Provides access to Darwin-specific dyld functionality including:
    /// - Image enumeration via `_dyld_image_count` / `_dyld_get_image_header`
    /// - Section data via `getsectiondata`
    /// - Image load callbacks via `_dyld_register_func_for_add_image`
    ///
    /// ## Semantic Correctness
    ///
    /// These APIs are userspace dyld interfaces, NOT kernel syscalls.
    ///
    /// They are implemented by `libSystem.B.dylib` and the dyld runtime.
    ///
    /// ## Thread Safety
    ///
    /// Image enumeration is thread-safe. The returned data is valid
    /// while the containing image remains loaded.
    public enum Loader: Sendable {}
}
