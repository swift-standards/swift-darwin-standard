#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

    public import Darwin_Standard_Core
    public import Tagged_Primitives
    public import Cardinal_Primitives

    extension Darwin_Standard_Core.Darwin.Loader.Image {

        public typealias Count = Tagged<Darwin_Standard_Core.Darwin.Loader.Image, Cardinal>
    }

#endif
