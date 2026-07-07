// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-darwin-standard open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-darwin-standard project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)

    public import Darwin_Standard_Core
    internal import Darwin

    extension Darwin_Standard_Core.Darwin.Kernel.Thread {
        /// A Darwin Quality-of-Service scheduling class.
        ///
        /// Wraps the kernel's `qos_class_t`. The raw value is stored as `UInt32`
        /// (the native width of `qos_class_t`) rather than the C typedef itself, so
        /// the platform C type does not leak across the L2 boundary per
        /// [PLAT-ARCH-015] / [PLAT-ARCH-005a].
        ///
        /// The valid classes are the six exposed as static constants. Construct
        /// from a raw task-priority value with ``init(priority:)`` and apply a
        /// scoped thread override with ``withOverride(_:)``. The `qos_class_t`
        /// bridging and the `pthread` override primitives are kept internal to
        /// this L2 target; nothing on the public surface names a C type.
        public struct QoS: Hashable, Sendable {
            /// The `qos_class_t` raw value, expressed as `UInt32` so the platform
            /// C typedef does not appear on the API surface ([PLAT-ARCH-015]).
            public let rawValue: UInt32

            internal init(rawValue: UInt32) {
                self.rawValue = rawValue
            }
        }
    }

    // MARK: - Darwin QoS classes

    extension Darwin_Standard_Core.Darwin.Kernel.Thread.QoS {
        /// User-interactive class (`QOS_CLASS_USER_INTERACTIVE`).
        public static let userInteractive = Self(rawValue: QOS_CLASS_USER_INTERACTIVE.rawValue)

        /// User-initiated class (`QOS_CLASS_USER_INITIATED`).
        public static let userInitiated = Self(rawValue: QOS_CLASS_USER_INITIATED.rawValue)

        /// Default class (`QOS_CLASS_DEFAULT`).
        public static let `default` = Self(rawValue: QOS_CLASS_DEFAULT.rawValue)

        /// Utility class (`QOS_CLASS_UTILITY`).
        public static let utility = Self(rawValue: QOS_CLASS_UTILITY.rawValue)

        /// Background class (`QOS_CLASS_BACKGROUND`).
        public static let background = Self(rawValue: QOS_CLASS_BACKGROUND.rawValue)

        /// Unspecified class (`QOS_CLASS_UNSPECIFIED`). Overriding a thread to the
        /// unspecified class is not meaningful, so ``init(priority:)`` and
        /// ``withOverride(_:)`` treat it as "no override".
        public static let unspecified = Self(rawValue: QOS_CLASS_UNSPECIFIED.rawValue)
    }

    // MARK: - Priority mapping

    extension Darwin_Standard_Core.Darwin.Kernel.Thread.QoS {
        /// Creates the QoS class corresponding to a raw task-priority value, or
        /// `nil` when no override is meaningful.
        ///
        /// Swift concurrency job/task priority raw values coincide with the
        /// `QOS_CLASS_*` raw values. Returns `nil` for `unspecified` (0) and for
        /// any value that is not one of the five override-eligible classes
        /// (user-interactive, user-initiated, default, utility, background) — so a
        /// stray priority bit never drives the override to an unmapped class. This
        /// mirrors the drain-path priority-escalation policy.
        ///
        /// - Parameter priority: A raw task-priority value, for example
        ///   `UInt32(job.priority.rawValue)`.
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

    // MARK: - Scoped thread override

    extension Darwin_Standard_Core.Darwin.Kernel.Thread.QoS {
        /// The Darwin `qos_class_t` for this class, or `nil` when the raw value is
        /// not an override-eligible class (for example, `unspecified`). Internal so the C
        /// typedef never appears on the public surface ([PLAT-ARCH-005a]).
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

        /// Runs `body` with the calling thread's QoS overridden to this class for
        /// the duration of the call, then reverts.
        ///
        /// Best-effort and non-throwing: if this class is not override-eligible
        /// (for example, `unspecified`), `body` runs with no adjustment. Otherwise the call
        /// is bracketed by `pthread_override_qos_class_start_np` /
        /// `pthread_override_qos_class_end_np`. The Darwin SDK imports the start
        /// primitive as returning a non-optional `pthread_override_t`, so — as in
        /// the original executor-layer implementation — the token is applied
        /// unconditionally; there is no NULL return to branch on at the Swift
        /// level. This preserves the ignore-failure semantics of the drain-path
        /// priority-escalation mechanism (the Sha-Rajkumar-Lehoczky 1990 PIP bound
        /// applied at the executor layer).
        ///
        /// - Parameter body: The work to run under the QoS override.
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
