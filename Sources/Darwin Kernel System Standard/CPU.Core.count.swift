#if canImport(Darwin)

    public import CPU
    internal import Darwin_Kernel_Standard

    extension CPU.Core {

        /// The physical cores, `sysctl hw.physicalcpu`. A failed read reports one core.
        public static var count: Count {
            let value: Int32
            do throws(Darwin.Kernel.Sysctl.Error) {
                value = try Darwin.Kernel.Sysctl.byName("hw.physicalcpu", as: Int32.self)
            } catch {
                value = 0
            }
            guard value > 0, let count = UInt(exactly: value) else {
                return Count(_unchecked: Cardinal(1 as UInt))
            }
            return Count(_unchecked: Cardinal(count))
        }
    }

#endif
