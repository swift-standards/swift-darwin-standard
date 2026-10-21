#if canImport(Darwin)
    import Darwin_Kernel_Shims
    public import Darwin_Standard_Core

    extension Darwin_Standard_Core::Darwin {

        public enum Identity {}
    }

    extension Darwin_Standard_Core::Darwin.Identity {

        public enum UUID {}
    }

    extension Darwin_Standard_Core::Darwin.Identity.UUID {

        public typealias Bytes = (
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
            UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
        )

        public static func parse(_ string: Swift::String) -> Bytes? {
            var bytes: Bytes = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
            let result = string.withCString { cString in
                withUnsafeMutableBytes(of: &bytes) { buffer in
                    guard let base = buffer.baseAddress else {
                        preconditionFailure("A 16-byte tuple has a base address")
                    }
                    return unsafe swift_uuid_parse(
                        cString,
                        base.assumingMemoryBound(to: UInt8.self)
                    )
                }
            }
            return result == 0 ? bytes : nil
        }

        public static let unparseLength: Int = 36

        public static func withUnparsedBytes<R: ~Copyable>(
            _ bytes: Bytes,
            uppercase: Bool = false,
            _ body: (Swift::Span<CChar>) -> R
        ) -> R {
            var output = (
                CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0),
                CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0),
                CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0),
                CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0),
                CChar(0), CChar(0), CChar(0), CChar(0), CChar(0)
            )
            withUnsafeBytes(of: bytes) { input in
                guard let inputBase = input.baseAddress else {
                    preconditionFailure("A 16-byte tuple has a base address")
                }
                withUnsafeMutableBytes(of: &output) { outputBuffer in
                    guard let outputBase = outputBuffer.baseAddress else {
                        preconditionFailure("A 37-byte tuple has a base address")
                    }
                    let outputPtr = unsafe outputBase.assumingMemoryBound(
                        to: CChar.self
                    )
                    if uppercase {
                        unsafe swift_uuid_unparse_upper(
                            inputBase.assumingMemoryBound(to: UInt8.self),
                            outputPtr
                        )
                    } else {
                        unsafe swift_uuid_unparse_lower(
                            inputBase.assumingMemoryBound(to: UInt8.self),
                            outputPtr
                        )
                    }
                }
            }
            return withUnsafeBytes(of: output) { buffer in
                guard let base = buffer.baseAddress else {
                    preconditionFailure("A 37-byte tuple has a base address")
                }
                let ptr = unsafe base.assumingMemoryBound(to: CChar.self)
                let span = unsafe Span(_unsafeStart: ptr, count: 36)
                return body(span)
            }
        }

        public static func withUnparsed<R: ~Copyable>(
            _ bytes: Bytes,
            uppercase: Bool = false,
            _ body: (Swift::String) -> R
        ) -> R {
            var output = (
                CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0),
                CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0),
                CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0),
                CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0), CChar(0),
                CChar(0), CChar(0), CChar(0), CChar(0), CChar(0)
            )
            withUnsafeBytes(of: bytes) { input in
                guard let inputBase = input.baseAddress else {
                    preconditionFailure("A 16-byte tuple has a base address")
                }
                withUnsafeMutableBytes(of: &output) { outputBuffer in
                    guard let outputBase = outputBuffer.baseAddress else {
                        preconditionFailure("A 37-byte tuple has a base address")
                    }
                    let outputPtr = unsafe outputBase.assumingMemoryBound(
                        to: CChar.self
                    )
                    if uppercase {
                        unsafe swift_uuid_unparse_upper(
                            inputBase.assumingMemoryBound(to: UInt8.self),
                            outputPtr
                        )
                    } else {
                        unsafe swift_uuid_unparse_lower(
                            inputBase.assumingMemoryBound(to: UInt8.self),
                            outputPtr
                        )
                    }
                }
            }
            return withUnsafeBytes(of: output) { buffer in
                guard let base = buffer.baseAddress else {
                    preconditionFailure("A 37-byte tuple has a base address")
                }
                let ptr = unsafe base.assumingMemoryBound(to: CChar.self)
                let str = unsafe Swift::String(cString: ptr)
                return body(str)
            }
        }

        public static func unparse(_ bytes: Bytes, uppercase: Bool = false) -> Swift::String {
            withUnparsed(bytes, uppercase: uppercase) { str in
                str
            }
        }
    }
#endif
