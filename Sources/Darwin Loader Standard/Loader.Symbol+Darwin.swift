#if canImport(Darwin)

    public import Loader
    internal import String
    internal import Darwin
    internal import Darwin_Kernel_Shims

    extension Loader.Symbol.Scope {

        @unsafe
        fileprivate var dlsymHandle: UnsafeMutableRawPointer? {
            switch unsafe self {
            case .handle(let h):
                return unsafe h.rawValue

            case .default:
                return unsafe swift_RTLD_DEFAULT()

            case .next:
                return unsafe swift_RTLD_NEXT()
            }
        }
    }

    extension Loader.Symbol {

        @unsafe
        public static func lookup(
            name: Swift.String,
            in scope: Scope
        ) throws(Loader.Error) -> UnsafeRawPointer {

            var utf8 = Array(name.utf8)
            utf8.append(0)
            return try utf8.withUnsafeBufferPointer { buffer throws(Loader.Error) in
                let cName = unsafe UnsafeRawPointer(buffer.baseAddress!).assumingMemoryBound(
                    to: CChar.self
                )
                return try unsafe lookup(name: cName, in: scope)
            }
        }

        @unsafe
        internal static func lookup(
            name: UnsafePointer<CChar>,
            in scope: Scope
        ) throws(Loader.Error) -> UnsafeRawPointer {
            _ = unsafe dlerror()

            let sym = unsafe dlsym(scope.dlsymHandle, name)

            if let errorCStr = unsafe dlerror() {
                let u8Ptr = unsafe UnsafeRawPointer(errorCStr).assumingMemoryBound(to: UInt8.self)
                let view = unsafe String.String.Borrowed(
                    u8Ptr,
                    count: String.String.length(of: u8Ptr)
                )
                throw .symbol(unsafe Loader.Message(copying: view))
            }

            guard let sym = unsafe sym else {
                throw .symbol(Loader.Message(ascii: "symbol resolved to NULL (no dlerror)"))
            }

            return UnsafeRawPointer(sym)
        }
    }

#endif
