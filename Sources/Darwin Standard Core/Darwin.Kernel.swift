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

extension Darwin {
    /// Darwin kernel mechanisms — distinct nominal type per [PLAT-ARCH-008k]
    /// Spec/Policy Namespace Split. Darwin-specific spec content (BSD-derived
    /// syscalls like `arc4random_buf`, `sysctl`, `F_BARRIERFSYNC`/`F_FULLFSYNC`)
    /// lives here; POSIX-shared content stays at `ISO_9945.Kernel`. Resolves
    /// the [PLAT-ARCH-018] silent typealias-conflict hazard between
    /// `Darwin.Kernel` and `ISO_9945.Kernel`.
    ///
    /// Declared in `Darwin Standard Core` (moved from `Darwin Kernel Standard`
    /// by swift-standards/swift-darwin-standard#3) so every target that
    /// re-anchors a hoisted ISO_9945 vocabulary family onto `Darwin.Kernel`
    /// — including `Darwin Kernel Event Standard`, which does not depend on
    /// `Darwin Kernel Standard` — can reach this root through the `Darwin
    /// Standard Core` dependency it already has.
    public enum Kernel: Sendable {}
}
