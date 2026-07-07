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
    public import Tagged_Primitives
    public import Cardinal_Primitives
    public import Ordinal_Primitives
    internal import Darwin.Mach
    internal import MachO

    extension Darwin_Standard_Core.Darwin.Loader {
        /// Image-related operations for the dynamic loader.
        public enum Image {}
    }

    extension Darwin_Standard_Core.Darwin.Loader.Image {
        /// The number of images currently loaded in the process.
        ///
        /// This value can change as images are loaded or unloaded.
        ///
        /// ## Thread Safety
        ///
        /// This property is thread-safe. However, the count may change
        /// between reading it and iterating through images.
        public static var count: Count {
            Count(_unchecked: Cardinal(UInt(_dyld_image_count())))
        }

        /// Gets the Mach-O header for an image by index.
        ///
        /// - Parameter index: The image index (`Ordinal.zero ..< count.map(Ordinal.init)`).
        ///
        /// - Returns: The image header, or `nil` if the index is invalid.
        ///
        /// ## Thread Safety
        ///
        /// This function is thread-safe. The returned header is valid
        /// while the image remains loaded.
        public static func header(at index: Index) -> Header? {
            guard let header = unsafe _dyld_get_image_header(UInt32(truncatingIfNeeded: index.underlying.rawValue)) else {
                return nil
            }
            return unsafe Header(rawValue: UnsafeRawPointer(header))
        }

        /// Gets the virtual memory slide for an image by index.
        ///
        /// The slide is the difference between the image's actual load address
        /// and its preferred load address.
        ///
        /// - Parameter index: The image index (`Ordinal.zero ..< count.map(Ordinal.init)`).
        ///
        /// - Returns: The slide value.
        public static func slide(at index: Index) -> Int {
            _dyld_get_image_vmaddr_slide(UInt32(truncatingIfNeeded: index.underlying.rawValue))
        }

        /// Gets the file path for an image by index.
        ///
        /// - Parameter index: The image index (`Ordinal.zero ..< count.map(Ordinal.init)`).
        ///
        /// - Returns: The file path as a C string, or `nil` if unavailable.
        @unsafe
        internal static func path(at index: Index) -> UnsafePointer<CChar>? {
            unsafe _dyld_get_image_name(UInt32(truncatingIfNeeded: index.underlying.rawValue))
        }
    }

    // MARK: - Borrow-First APIs

    extension Darwin_Standard_Core.Darwin.Loader.Image {

        /// Canonical primitive: scoped access to image path bytes.
        ///
        /// This is the most primitive API. It provides zero-copy access to the
        /// raw path bytes returned by `_dyld_get_image_name`. The closure
        /// receives a `Span` that does NOT include the NUL terminator.
        ///
        /// - Parameters:
        ///   - index: The image index (`0 ..< count.rawValue`).
        ///   - body: A closure that processes the path bytes. Non-throwing.
        ///
        /// - Returns: The result of the closure, or `nil` if the image is unavailable.
        public static func withPathBytes<R: ~Copyable>(
            at index: Index,
            _ body: (Swift.Span<CChar>) -> R
        ) -> R? {
            guard let ptr = unsafe _dyld_get_image_name(UInt32(truncatingIfNeeded: index.underlying.rawValue)) else {
                return nil
            }

            // Find length
            var length = 0
            while (unsafe ptr[length]) != 0 {
                length += 1
            }

            let span = unsafe Span(_unsafeStart: ptr, count: length)
            return body(span)
        }

        /// Convenience: scoped access to image path as String.
        ///
        /// This API provides scoped access to the formatted path without
        /// escaping the pointer.
        ///
        /// - Parameters:
        ///   - index: The image index (`0 ..< count.rawValue`).
        ///   - body: A closure that processes the path string. Non-throwing.
        ///
        /// - Returns: The result of the closure, or `nil` if the image is unavailable.
        public static func withPath<R: ~Copyable>(
            at index: Index,
            _ body: (Swift.String) -> R
        ) -> R? {
            guard let ptr = unsafe _dyld_get_image_name(UInt32(truncatingIfNeeded: index.underlying.rawValue)) else {
                return nil
            }

            let str = unsafe Swift.String(cString: ptr)
            return body(str)
        }

        /// Owned convenience: gets the file path for an image by index.
        ///
        /// This is the simplest API but involves allocation. For callers that
        /// need to use the path temporarily, prefer `withPathBytes` or
        /// `withPath` to avoid allocation.
        ///
        /// - Parameter index: The image index (`0 ..< count.rawValue`).
        ///
        /// - Returns: The file path as an owned String, or `nil` if unavailable.
        public static func pathString(at index: Index) -> Swift.String? {
            withPath(at: index) { str in
                str
            }
        }
    }

#endif
