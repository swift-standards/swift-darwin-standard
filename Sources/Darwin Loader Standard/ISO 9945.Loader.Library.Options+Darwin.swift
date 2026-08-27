public import ISO_9945_Core
public import ISO_9945_Loader
public import Loader_Vocabulary

#if canImport(Darwin)

    internal import Darwin

    extension ISO_9945.Loader.Library.Options {

        public static let noLoad = Self(rawValue: RTLD_NOLOAD)

        public static let noDelete = Self(rawValue: RTLD_NODELETE)
    }

#endif
