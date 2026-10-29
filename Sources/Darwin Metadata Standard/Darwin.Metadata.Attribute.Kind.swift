public import Darwin_Standard_Core

extension Darwin_Standard_Core::Darwin.Metadata.Attribute {

    /// The kind of value a Spotlight metadata attribute takes, as the attribute reference states it
    /// ("a CFString", "a CFArray of CFStrings").
    public indirect enum Kind: Sendable, Hashable {

        /// A string (`CFString`).
        case string

        /// An array whose elements are all of one kind (`CFArray`).
        case array(Kind)
    }
}
