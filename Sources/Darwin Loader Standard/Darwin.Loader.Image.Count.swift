#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

    public import Darwin_Standard_Core
    public import Tagged
    public import Cardinal

    extension Darwin_Standard_Core.Darwin.Loader.Image {

        public typealias Count = Tagged<Darwin_Standard_Core.Darwin.Loader.Image, Cardinal>
    }

#endif
