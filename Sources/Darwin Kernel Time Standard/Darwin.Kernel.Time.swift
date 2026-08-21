#if canImport(Darwin)
    import Darwin

    extension timespec {

        package init(_ duration: Duration) {
            let (seconds, attoseconds) = duration.components
            let nanoseconds = attoseconds / 1_000_000_000
            self.init(tv_sec: Int(seconds), tv_nsec: Int(nanoseconds))
        }

        package init?(_ duration: Duration?) {
            guard let duration else { return nil }
            self.init(duration)
        }
    }

#endif
