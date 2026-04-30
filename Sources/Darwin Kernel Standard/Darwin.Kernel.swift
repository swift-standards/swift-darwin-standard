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
public import ISO_9945_Core

extension Darwin_Standard_Core.Darwin {
    /// Darwin kernel mechanisms — typealias to the iso-9945 L2 `Kernel`
    /// namespace (G6.D parallel roots).
    public typealias Kernel = ISO_9945_Core.Kernel
}
