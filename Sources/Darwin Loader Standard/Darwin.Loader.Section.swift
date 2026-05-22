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
public import Loader_Primitives
internal import Tagged_Primitives
internal import Cardinal_Primitives
internal import Ordinal_Primitives
internal import Ordinal_Primitives
internal import Darwin.Mach
internal import MachO

extension Darwin_Standard_Core.Darwin.Loader {
    /// Darwin section enumeration interface.
    ///
    /// Provides access to Mach-O section data via dyld APIs.
    public enum Section: Sendable {}
}

// MARK: - Type Aliases

extension Darwin_Standard_Core.Darwin.Loader.Section {
    /// Section name type.
    public typealias Name = Loader.Section.Name

    /// Section bounds type.
    public typealias Bounds = Loader.Section.Bounds
}

// MARK: - Borrow-First APIs

extension Darwin_Standard_Core.Darwin.Loader.Section {

    /// Canonical primitive: scoped access to section data bytes.
    ///
    /// This is the most primitive API. It provides scoped access to the
    /// raw section bytes. The closure receives an `UnsafeRawBufferPointer`
    /// that is valid only for the duration of the closure.
    ///
    /// - Parameters:
    ///   - name: The section name (must be a Mach-O section).
    ///   - header: The Mach-O image header.
    ///   - body: A closure that processes the section data. Non-throwing.
    /// - Returns: The result of the closure, or `nil` if the section is not found.
    ///
    /// ## Thread Safety
    ///
    /// This function is thread-safe. The buffer passed to the closure is
    /// valid for the lifetime of the loaded image (and thus for the
    /// duration of the closure).
    public static func withDataBytes<R: ~Copyable>(
        for name: Name,
        in header: Darwin_Standard_Core.Darwin.Loader.Image.Header,
        _ body: (UnsafeRawBufferPointer) -> R
    ) -> R? {
        guard let machO = name.machO else {
            return nil
        }

        var size: CUnsignedLong = 0

        guard let start = unsafe getsectiondata(
            header.header64,
            machO.segment.utf8Start,
            machO.section.utf8Start,
            &size
        ), size > 0 else {
            return nil
        }

        let buffer = unsafe UnsafeRawBufferPointer(
            start: start,
            count: Int(clamping: size)
        )

        return unsafe body(buffer)
    }

    /// Convenience: scoped access to section bounds.
    ///
    /// This API provides scoped access to the full section bounds including
    /// the image address for pointer rebasing.
    ///
    /// - Parameters:
    ///   - name: The section name (must be a Mach-O section).
    ///   - header: The Mach-O image header.
    ///   - body: A closure that processes the section bounds. Non-throwing.
    /// - Returns: The result of the closure, or `nil` if the section is not found.
    public static func withData<R: ~Copyable>(
        for name: Name,
        in header: Darwin_Standard_Core.Darwin.Loader.Image.Header,
        _ body: (Bounds) -> R
    ) -> R? {
        guard let machO = name.machO else {
            return nil
        }

        var size: CUnsignedLong = 0

        guard let start = unsafe getsectiondata(
            header.header64,
            machO.segment.utf8Start,
            machO.section.utf8Start,
            &size
        ), size > 0 else {
            return nil
        }

        let buffer = unsafe UnsafeRawBufferPointer(
            start: start,
            count: Int(clamping: size)
        )

        let bounds = unsafe Bounds(
            imageAddress: header.rawValue,
            buffer: buffer
        )

        return body(bounds)
    }

    /// Owned convenience: reads section data from a Mach-O image header.
    ///
    /// This is the simplest API. For callers that need to process the
    /// data without storing it, prefer `withDataBytes` or `withData`
    /// for explicit scoping.
    ///
    /// - Parameters:
    ///   - name: The section name (must be a Mach-O section).
    ///   - header: The Mach-O image header.
    /// - Returns: Section bounds, or `nil` if the section is not found.
    ///
    /// ## Thread Safety
    ///
    /// This function is thread-safe. The returned buffer is valid
    /// for the lifetime of the loaded image.
    ///
    /// ## Example
    ///
    /// ```swift
    /// if let bounds = Darwin.Loader.Section.data(
    ///     for: .swiftTestContent,
    ///     in: header
    /// ) {
    ///     // Process section data
    /// }
    /// ```
    public static func data(
        for name: Name,
        in header: Darwin_Standard_Core.Darwin.Loader.Image.Header
    ) -> Bounds? {
        withData(for: name, in: header) { bounds in
            bounds
        }
    }
}

// MARK: - Section Enumeration

extension Darwin_Standard_Core.Darwin.Loader.Section {
    /// All section bounds of the given name across all loaded images.
    ///
    /// - Parameter name: The section to find.
    /// - Returns: A sequence of section bounds from all images containing
    ///   the specified section.
    ///
    /// ## Performance
    ///
    /// This function iterates all loaded images. Images in the dyld
    /// shared cache are skipped as they typically do not contain
    /// user-defined metadata sections.
    ///
    /// ## Example
    ///
    /// ```swift
    /// for bounds in Darwin.Loader.Section.all(.swiftTestContent) {
    ///     // Process each section
    /// }
    /// ```
    public static func all(_ name: Name) -> AllSectionsSequence {
        AllSectionsSequence(name: name)
    }
}

// MARK: - AllSectionsSequence

extension Darwin_Standard_Core.Darwin.Loader.Section {
    /// A sequence that enumerates sections across all loaded images.
    // SAFETY: Encapsulates unsafe internals behind a safe API; see
    // SAFETY: [MEM-SAFE-024] for the absorber-pattern taxonomy.
    @safe
    public struct AllSectionsSequence: @unsafe Sequence {
        let name: Name

        init(name: Name) {
            self.name = name
        }

        public func makeIterator() -> Iterator {
            Iterator(name: name, currentIndex: .zero)
        }

        // SAFETY: Encapsulates unsafe internals behind a safe API; see
        // SAFETY: [MEM-SAFE-024] for the absorber-pattern taxonomy.
        @safe
        public struct Iterator: @unsafe IteratorProtocol {
            let name: Name
            var currentIndex: Darwin_Standard_Core.Darwin.Loader.Image.Index

            init(name: Name, currentIndex: Darwin_Standard_Core.Darwin.Loader.Image.Index) {
                self.name = name
                self.currentIndex = currentIndex
            }

            public mutating func next() -> Bounds? {
                let end = Darwin_Standard_Core.Darwin.Loader.Image.count.map(Ordinal.init)

                while currentIndex < end {
                    let index = currentIndex
                    currentIndex += .one

                    guard let header = Darwin_Standard_Core.Darwin.Loader.Image.header(at: index) else {
                        continue
                    }

                    // Skip images in the shared cache (system libraries)
                    guard !header.isInSharedCache else {
                        continue
                    }

                    if let bounds = Darwin_Standard_Core.Darwin.Loader.Section.data(for: name, in: header) {
                        return bounds
                    }
                }

                return nil
            }
        }
    }
}

#endif
