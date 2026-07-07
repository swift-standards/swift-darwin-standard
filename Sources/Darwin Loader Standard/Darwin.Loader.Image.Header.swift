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

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

    public import Darwin_Standard_Core
    internal import Darwin.Mach
    internal import MachO

    extension Darwin_Standard_Core.Darwin.Loader.Image {
        // WHY: Category D (SP-5) — pointer-backed value type; storage is
        // WHY: private/internal; the type's safe API never lets the raw pointer
        // WHY: escape, and lifetime invariants are enforced by init/deinit pairing.
        /// Represents a Mach-O image header.
        ///
        /// Wraps the platform-specific header pointer for 64-bit images.
        ///
        /// All modern Apple platforms are 64-bit.
        ///
        /// ## Thread Safety
        ///
        /// This type is `Sendable` and can be shared across threads.
        ///
        /// The underlying header pointer is valid while the image remains loaded.
        @safe
        public struct Header: Sendable, Equatable {
            /// The raw header pointer.
            public nonisolated(unsafe) let rawValue: UnsafeRawPointer

            /// Creates an image header from a raw pointer.
            ///
            /// - Parameter rawValue: Pointer to the Mach-O header.
            @unsafe
            @inlinable
            public init(rawValue: UnsafeRawPointer) {
                unsafe (self.rawValue = rawValue)
            }

            /// Whether this image is in the dyld shared cache.
            ///
            /// Images in the shared cache are system images and typically
            /// do not contain user-defined metadata sections.
            public var isInSharedCache: Bool {
                let header64 = unsafe rawValue.assumingMemoryBound(to: mach_header_64.self)
                return unsafe (header64.pointee.flags & UInt32(MH_DYLIB_IN_CACHE)) != 0
            }

            /// Equatable conformance based on pointer identity.
            @inlinable
            public static func == (lhs: Self, rhs: Self) -> Bool {
                unsafe lhs.rawValue == rhs.rawValue
            }
        }
    }

    // MARK: - Internal Accessors

    extension Darwin_Standard_Core.Darwin.Loader.Image.Header {
        /// The typed header pointer (64-bit). Internal use only.
        @unsafe
        internal var header64: UnsafePointer<mach_header_64> {
            unsafe rawValue.assumingMemoryBound(to: mach_header_64.self)
        }
    }

#endif
