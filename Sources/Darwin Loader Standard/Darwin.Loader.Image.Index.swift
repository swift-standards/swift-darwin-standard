#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

    public import Darwin_Standard_Core
    public import Tagged
    public import Ordinal

    extension Darwin_Standard_Core.Darwin.Loader.Image {

        public typealias Index = Tagged<Darwin_Standard_Core.Darwin.Loader.Image, Ordinal>
    }

#endif
