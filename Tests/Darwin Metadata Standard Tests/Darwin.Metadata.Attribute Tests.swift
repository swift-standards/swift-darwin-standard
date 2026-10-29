import Darwin_Metadata_Standard
import Testing

extension Darwin.Metadata.Attribute {
    @Suite
    struct Test {
        @Suite struct Unit {}
    }
}

extension Darwin.Metadata.Attribute.Test.Unit {
    @Test
    func `the attributes carry Apple's names`() {
        #expect(Darwin.Metadata.Attribute.kMDItemTitle.name == "kMDItemTitle")
        #expect(Darwin.Metadata.Attribute.kMDItemAuthors.name == "kMDItemAuthors")
        #expect(Darwin.Metadata.Attribute.kMDItemRecipients.name == "kMDItemRecipients")
        #expect(Darwin.Metadata.Attribute.kMDItemDescription.name == "kMDItemDescription")
    }

    @Test
    func `title and description take a string, authors and recipients an array of strings`() {
        #expect(Darwin.Metadata.Attribute.kMDItemTitle.kind == .string)
        #expect(Darwin.Metadata.Attribute.kMDItemAuthors.kind == .array(.string))
        #expect(Darwin.Metadata.Attribute.kMDItemRecipients.kind == .array(.string))
        #expect(Darwin.Metadata.Attribute.kMDItemDescription.kind == .string)
    }

    @Test
    func `an array of strings is not a string`() {
        #expect(Darwin.Metadata.Attribute.Kind.array(.string) != .string)
    }

    @Test
    func `the extended attribute is com.apple.metadata followed by the name`() {
        #expect(Darwin.Metadata.Attribute.Extended.prefix == "com.apple.metadata:")
        #expect(Darwin.Metadata.Attribute.kMDItemTitle.extended.name == "com.apple.metadata:kMDItemTitle")
        #expect(Darwin.Metadata.Attribute.kMDItemAuthors.extended.name == "com.apple.metadata:kMDItemAuthors")
        #expect(Darwin.Metadata.Attribute.kMDItemRecipients.extended.name == "com.apple.metadata:kMDItemRecipients")
        #expect(Darwin.Metadata.Attribute.kMDItemDescription.extended.name == "com.apple.metadata:kMDItemDescription")
    }
}
