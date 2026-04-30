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

extension Darwin_Standard_Core.Darwin {
    /// Darwin kernel mechanisms — distinct nominal type per [PLAT-ARCH-008k]
    /// Spec/Policy Namespace Split. Darwin-specific spec content (BSD-derived
    /// syscalls like `arc4random_buf`, `sysctl`, `F_BARRIERFSYNC`/`F_FULLFSYNC`)
    /// lives here; POSIX-shared content stays at `ISO_9945.Kernel`. Resolves
    /// the [PLAT-ARCH-018] silent typealias-conflict hazard between
    /// `Darwin.Kernel` and `ISO_9945.Kernel`.
    public enum Kernel: Sendable {}
}
