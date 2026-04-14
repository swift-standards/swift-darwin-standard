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

extension Darwin_Standard_Core.Darwin.Memory {
    /// Allocation namespace for Darwin memory allocation tracking.
    public enum Allocation: Sendable {}
}
