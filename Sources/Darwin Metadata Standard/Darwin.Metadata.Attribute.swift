public import Darwin_Standard_Core

extension Darwin_Standard_Core::Darwin.Metadata {

    /// A Spotlight metadata attribute: its name as `MDItem.h` spells it, and the kind of value it takes.
    public struct Attribute: Sendable, Hashable {

        /// The attribute's name, for example `kMDItemTitle`.
        public let name: Swift::String

        /// The kind of value the attribute takes.
        public let kind: Kind

        public init(name: Swift::String, kind: Kind) {
            self.name = name
            self.kind = kind
        }
    }
}

extension Darwin_Standard_Core::Darwin.Metadata.Attribute {

    /// The extended attribute that carries this attribute on a file: `com.apple.metadata:<name>`.
    public var extended: Extended {
        Extended(self)
    }
}

extension Darwin_Standard_Core::Darwin.Metadata.Attribute {

    /// `kMDItemTitle`: the title of the item. A string.
    public static let kMDItemTitle = Self(name: "kMDItemTitle", kind: .string)

    /// `kMDItemAuthors`: the authors, or for a letter its senders. An array of strings.
    public static let kMDItemAuthors = Self(name: "kMDItemAuthors", kind: .array(.string))

    /// `kMDItemRecipients`: the recipients of the item. An array of strings.
    public static let kMDItemRecipients = Self(name: "kMDItemRecipients", kind: .array(.string))

    /// `kMDItemDescription`: a description of the content of the item. A string.
    public static let kMDItemDescription = Self(name: "kMDItemDescription", kind: .string)
}
