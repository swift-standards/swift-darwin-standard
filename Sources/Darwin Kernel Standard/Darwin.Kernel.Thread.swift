// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-darwin-standard open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-darwin-standard project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Darwin_Standard_Core

extension Darwin_Standard_Core.Darwin.Kernel {
    /// Darwin thread mechanisms.
    ///
    /// Home for Darwin-specific (non-POSIX) thread vocabulary — for example, the
    /// pthread QoS-override (`_np`) extension exposed as ``QoS``. POSIX-shared
    /// thread concepts live under `ISO_9945.Kernel.Thread` per
    /// [PLAT-ARCH-007]; this namespace carries only Darwin's own thread API
    /// surface per [PLAT-ARCH-008k]'s Spec/Policy Namespace Split.
    public enum Thread: Sendable {}
}
