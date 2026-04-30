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

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

public import Darwin_Standard_Core
public import Tagged_Primitives
public import Ordinal_Primitives

extension Darwin_Standard_Core.Darwin.Loader.Image {
    /// A position within the loaded-image list, as a typed
    /// `Tagged<Image, Ordinal>` per [PLAT-ARCH-005a] / [INFRA-102].
    ///
    /// Valid range: `Ordinal.zero ..< count.map(Ordinal.init)`.
    /// Ordinal-protocol arithmetic (`.successor`, `.predecessor`,
    /// `.advance`, `.distance`, `+`, `<`) lifts to this type via
    /// `Ordinal.Protocol` per [INFRA-100]. Cross-domain conversion
    /// from / to `Count` uses `.map(Ordinal.init)` / `.map(Cardinal.init)`
    /// per [INFRA-103].
    ///
    /// ## Validity
    ///
    /// The set of loaded images can change between observing
    /// ``Image/count`` and using an `Index`. Callers should treat any
    /// `Index` as potentially stale; accessor methods return
    /// `Optional` to surface invalid indices safely.
    public typealias Index = Tagged<Darwin_Standard_Core.Darwin.Loader.Image, Ordinal>
}

#endif
