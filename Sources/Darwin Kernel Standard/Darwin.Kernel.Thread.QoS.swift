#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

    public import Darwin_Standard_Core
    internal import Darwin

    extension Darwin_Standard_Core.Darwin.Kernel.Thread {

        public struct QoS: Hashable, Sendable {

            public let rawValue: UInt32
        }
    }

    extension Darwin_Standard_Core.Darwin.Kernel.Thread.QoS {

        public static let userInteractive = Self(rawValue: QOS_CLASS_USER_INTERACTIVE.rawValue)

        public static let userInitiated = Self(rawValue: QOS_CLASS_USER_INITIATED.rawValue)

        public static let `default` = Self(rawValue: QOS_CLASS_DEFAULT.rawValue)

        public static let utility = Self(rawValue: QOS_CLASS_UTILITY.rawValue)

        public static let background = Self(rawValue: QOS_CLASS_BACKGROUND.rawValue)

        public static let unspecified = Self(rawValue: QOS_CLASS_UNSPECIFIED.rawValue)
    }

    extension Darwin_Standard_Core.Darwin.Kernel.Thread.QoS {

        public init?(priority: UInt32) {
            switch priority {
            case QOS_CLASS_USER_INTERACTIVE.rawValue,
                QOS_CLASS_USER_INITIATED.rawValue,
                QOS_CLASS_DEFAULT.rawValue,
                QOS_CLASS_UTILITY.rawValue,
                QOS_CLASS_BACKGROUND.rawValue:
                self.init(rawValue: priority)

            default:
                return nil
            }
        }
    }

    extension Darwin_Standard_Core.Darwin.Kernel.Thread.QoS {

        internal var qosClass: qos_class_t? {
            switch rawValue {
            case QOS_CLASS_USER_INTERACTIVE.rawValue: return QOS_CLASS_USER_INTERACTIVE
            case QOS_CLASS_USER_INITIATED.rawValue: return QOS_CLASS_USER_INITIATED
            case QOS_CLASS_DEFAULT.rawValue: return QOS_CLASS_DEFAULT
            case QOS_CLASS_UTILITY.rawValue: return QOS_CLASS_UTILITY
            case QOS_CLASS_BACKGROUND.rawValue: return QOS_CLASS_BACKGROUND
            default: return nil
            }
        }

        public func withOverride(_ body: () -> Void) {
            guard let qosClass = self.qosClass else {
                body()
                return
            }
            let token = unsafe pthread_override_qos_class_start_np(pthread_self(), qosClass, 0)
            body()
            unsafe _ = pthread_override_qos_class_end_np(token)
        }
    }

#endif
