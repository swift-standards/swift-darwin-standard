public import ISO_9945_Core

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

    extension ISO_9945.Kernel {
        /// Spec-literal alias for ``Kernel/Event/Queue`` matching the
        /// `kqueue(2)` man-page name (per [API-NAME-003] specification-
        /// mirroring). The nested form ``Kernel/Event/Queue`` fits the broader
        /// ``Kernel/Event`` namespace; this alias is the surface used in
        /// public documentation (`swift-darwin/README.md`,
        /// `swift-kernel/README.md`) and is the consumer-facing name. Both
        /// forms resolve to the same type — pick whichever reads better at
        /// the call site.
        public typealias Kqueue = ISO_9945.Kernel.Event.Queue
    }

#endif
