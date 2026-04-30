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
public import Cardinal_Primitives

extension Darwin_Standard_Core.Darwin.Loader.Image {
    /// The number of currently-loaded Mach-O images, as a typed
    /// `Tagged<Image, Cardinal>` per [PLAT-ARCH-005a] / [INFRA-101].
    ///
    /// Distinct at the type level from arbitrary `Cardinal` quantities
    /// (link counts, byte counts, etc.); the `Image` phantom tag carries
    /// the "image count" domain meaning. Cardinal-protocol arithmetic
    /// (`+`, `<`, `.zero`, `.one`, `.subtract.saturating`) lifts to this
    /// type via `Cardinal.Protocol` per [INFRA-100].
    public typealias Count = Tagged<Darwin_Standard_Core.Darwin.Loader.Image, Cardinal>
}

#endif
