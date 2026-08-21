#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

    public import Darwin_Standard_Core
    public import Loader_Primitives
    internal import Tagged_Primitives
    internal import Cardinal_Primitives
    internal import Ordinal_Primitives
    internal import Darwin.Mach
    internal import MachO

    extension Darwin_Standard_Core.Darwin.Loader {

        public enum Section: Sendable {}
    }

    extension Darwin_Standard_Core.Darwin.Loader.Section {

        public typealias Name = Loader.Section.Name

        public typealias Bounds = Loader.Section.Bounds
    }

    extension Darwin_Standard_Core.Darwin.Loader.Section {

        public static func withDataBytes<R: ~Copyable>(
            for name: Name,
            in header: Darwin_Standard_Core.Darwin.Loader.Image.Header,
            _ body: (UnsafeRawBufferPointer) -> R
        ) -> R? {
            guard let machO = name.machO else {
                return nil
            }

            var size: CUnsignedLong = 0

            guard
                let start = unsafe getsectiondata(
                    header.header64,
                    machO.segment.utf8Start,
                    machO.section.utf8Start,
                    &size
                ), size > 0
            else {
                return nil
            }

            let buffer = unsafe UnsafeRawBufferPointer(
                start: start,
                count: Int(clamping: size)
            )

            return unsafe body(buffer)
        }

        public static func withData<R: ~Copyable>(
            for name: Name,
            in header: Darwin_Standard_Core.Darwin.Loader.Image.Header,
            _ body: (Bounds) -> R
        ) -> R? {
            guard let machO = name.machO else {
                return nil
            }

            var size: CUnsignedLong = 0

            guard
                let start = unsafe getsectiondata(
                    header.header64,
                    machO.segment.utf8Start,
                    machO.section.utf8Start,
                    &size
                ), size > 0
            else {
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

        public static func data(
            for name: Name,
            in header: Darwin_Standard_Core.Darwin.Loader.Image.Header
        ) -> Bounds? {
            withData(for: name, in: header) { bounds in
                bounds
            }
        }
    }

    extension Darwin_Standard_Core.Darwin.Loader.Section {

        public static func all(_ name: Name) -> AllSectionsSequence {
            AllSectionsSequence(name: name)
        }
    }

    extension Darwin_Standard_Core.Darwin.Loader.Section {

        @safe
        public struct AllSectionsSequence: @unsafe Sequence {
            let name: Name
        }
    }

    extension Darwin_Standard_Core.Darwin.Loader.Section.AllSectionsSequence {
        public func makeIterator() -> Iterator {
            Iterator(name: name, currentIndex: .zero)
        }
    }

    extension Darwin_Standard_Core.Darwin.Loader.Section.AllSectionsSequence {

        @safe
        public struct Iterator: @unsafe IteratorProtocol {
            let name: Darwin_Standard_Core.Darwin.Loader.Section.Name
            var currentIndex: Darwin_Standard_Core.Darwin.Loader.Image.Index
        }
    }

    extension Darwin_Standard_Core.Darwin.Loader.Section.AllSectionsSequence.Iterator {
        public mutating func next() -> Darwin_Standard_Core.Darwin.Loader.Section.Bounds? {
            let end = Darwin_Standard_Core.Darwin.Loader.Image.count.map(Ordinal.init)

            while currentIndex < end {
                let index = currentIndex
                currentIndex += .one

                guard let header = Darwin_Standard_Core.Darwin.Loader.Image.header(at: index) else {
                    continue
                }

                guard !header.isInSharedCache else {
                    continue
                }

                if let bounds = Darwin_Standard_Core.Darwin.Loader.Section.data(
                    for: name,
                    in: header
                ) {
                    return bounds
                }
            }

            return nil
        }
    }

#endif
