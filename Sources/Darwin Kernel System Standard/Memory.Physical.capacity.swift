#if canImport(Darwin)

    public import Memory
    internal import Darwin_Kernel_Standard

    extension Memory.Physical {

        /// The installed memory in bytes, `sysctl hw.memsize`. A failed read reports zero.
        public static var capacity: Memory.Capacity {
            let value: UInt64
            do throws(Darwin.Kernel.Sysctl.Error) {
                value = try Darwin.Kernel.Sysctl.byName("hw.memsize", as: UInt64.self)
            } catch {
                value = 0
            }
            guard let bytes = UInt(exactly: value) else {
                preconditionFailure("hw.memsize is not representable as UInt")
            }
            return Memory.Capacity(_unchecked: Cardinal(bytes))
        }
    }

#endif
