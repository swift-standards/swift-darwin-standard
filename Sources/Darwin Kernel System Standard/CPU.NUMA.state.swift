#if canImport(Darwin)

    public import CPU

    extension CPU.NUMA {

        /// Darwin exposes no NUMA topology.
        public static var state: State { .unavailable }
    }

#endif
