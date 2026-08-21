#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

    public import Darwin_Standard_Core
    public import Tagged_Primitives
    import Cardinal_Primitives
    import Ordinal_Primitives
    internal import Darwin.Mach
    internal import MachO

    extension Darwin_Standard_Core.Darwin.Loader {

        public enum Image {}
    }

    extension Darwin_Standard_Core.Darwin.Loader.Image {

        public static var count: Count {
            Count(_unchecked: Cardinal(UInt(_dyld_image_count())))
        }

        public static func header(at index: Index) -> Header? {
            guard
                let header = unsafe _dyld_get_image_header(
                    UInt32(truncatingIfNeeded: index.underlying.rawValue)
                )
            else {
                return nil
            }
            return unsafe Header(rawValue: UnsafeRawPointer(header))
        }

        public static func slide(at index: Index) -> Int {
            _dyld_get_image_vmaddr_slide(UInt32(truncatingIfNeeded: index.underlying.rawValue))
        }

        @unsafe
        internal static func path(at index: Index) -> UnsafePointer<CChar>? {
            unsafe _dyld_get_image_name(UInt32(truncatingIfNeeded: index.underlying.rawValue))
        }
    }

    extension Darwin_Standard_Core.Darwin.Loader.Image {

        public static func withPathBytes<R: ~Copyable>(
            at index: Index,
            _ body: (Swift.Span<CChar>) -> R
        ) -> R? {
            guard
                let ptr = unsafe _dyld_get_image_name(
                    UInt32(truncatingIfNeeded: index.underlying.rawValue)
                )
            else {
                return nil
            }

            var length = 0
            while (unsafe ptr[length]) != 0 {
                length += 1
            }

            let span = unsafe Span(_unsafeStart: ptr, count: length)
            return body(span)
        }

        public static func withPath<R: ~Copyable>(
            at index: Index,
            _ body: (Swift.String) -> R
        ) -> R? {
            guard
                let ptr = unsafe _dyld_get_image_name(
                    UInt32(truncatingIfNeeded: index.underlying.rawValue)
                )
            else {
                return nil
            }

            let str = unsafe Swift.String(cString: ptr)
            return body(str)
        }

        public static func pathString(at index: Index) -> Swift.String? {
            withPath(at: index) { str in
                str
            }
        }
    }

#endif
