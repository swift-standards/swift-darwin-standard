// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-darwin-standard open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-darwin-standard project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// Cycle 19 cross-L2 sibling visibility:
// Per [PLAT-ARCH-007] darwin-standard depends on iso-9945 (POSIX shared base).
// This package-scope typealias gives darwin-standard's syscall sources a
// resolvable `Kernel.Descriptor` name without requiring per-file imports of
// ISO_9945_Core. Internal-package visibility (no consumer leakage; the L3
// swift-kernel umbrella provides the public typealias for downstream).
public import ISO_9945_Core

extension Kernel {
    package typealias Descriptor = ISO_9945.Kernel.Descriptor
}
