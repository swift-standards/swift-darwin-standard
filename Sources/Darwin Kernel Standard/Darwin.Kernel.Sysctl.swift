#if canImport(Darwin)

    public import Darwin_Standard_Core
    public import Error
    internal import Darwin

    extension Darwin_Standard_Core.Darwin.Kernel {

        public enum Sysctl {}
    }

    extension Darwin_Standard_Core.Darwin.Kernel.Sysctl {

        public struct Error: Swift.Error, Sendable {
            public let code: Error.Error.Code

            public init(code: Error.Error.Code) {
                self.code = code
            }
        }
    }

    extension Darwin_Standard_Core.Darwin.Kernel.Sysctl.Error {

        @usableFromInline
        internal static func current() -> Self {
            Self(code: .posix(errno))
        }
    }

    extension Darwin_Standard_Core.Darwin.Kernel.Sysctl {

        public static func byName<T: FixedWidthInteger>(
            _ name: Swift.String,
            as type: T.Type = T.self
        ) throws(Error) -> T {
            var value = T(0)
            var size = MemoryLayout<T>.size

            var utf8 = Array(name.utf8)
            utf8.append(0)
            let result = utf8.withUnsafeBufferPointer { buffer -> Int32 in
                let namePtr = unsafe UnsafeRawPointer(buffer.baseAddress!).assumingMemoryBound(
                    to: CChar.self
                )
                return unsafe sysctlbyname(namePtr, &value, &size, nil, 0)
            }
            guard result == 0 else {
                throw .current()
            }
            return value
        }
    }

#endif
