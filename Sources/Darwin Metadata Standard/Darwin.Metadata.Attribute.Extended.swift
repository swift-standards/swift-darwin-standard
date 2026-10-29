public import Darwin_Standard_Core

extension Darwin_Standard_Core::Darwin.Metadata.Attribute {

    /// The extended attribute that carries a Spotlight metadata attribute on a file.
    ///
    /// Spotlight's importers read a file's `com.apple.metadata:` extended attributes as metadata attributes of the
    /// same name, each value a binary property list of the attribute's kind.
    public struct Extended: Sendable, Hashable {

        /// The extended attribute's name: `com.apple.metadata:` followed by the attribute's name.
        public let name: Swift::String

        public init(_ attribute: Darwin_Standard_Core::Darwin.Metadata.Attribute) {
            self.name = Self.prefix + attribute.name
        }
    }
}

extension Darwin_Standard_Core::Darwin.Metadata.Attribute.Extended {

    /// The prefix every Spotlight metadata extended attribute's name begins with.
    public static let prefix: Swift::String = "com.apple.metadata:"
}
