// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

public import Kernel_Event_Primitives

extension Kernel {
    /// Backwards-compatible alias for ``Kernel/Event/Queue``.
    public typealias Kqueue = Kernel.Event.Queue
}

#endif
