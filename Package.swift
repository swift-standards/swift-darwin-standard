// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-darwin-standard",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(
            name: "Darwin Kernel Standard",
            targets: ["Darwin Kernel Standard"]
        ),
        .library(
            name: "Darwin Kernel Event Standard",
            targets: ["Darwin Kernel Event Standard"]
        ),
        .library(
            name: "Darwin Kernel Time Standard",
            targets: ["Darwin Kernel Time Standard"]
        ),
        .library(
            name: "Darwin Loader Standard",
            targets: ["Darwin Loader Standard"]
        ),
        .library(
            name: "Darwin Memory Standard",
            targets: ["Darwin Memory Standard"]
        ),
        .library(
            name: "Darwin Kernel Standard Test Support",
            targets: ["Darwin Kernel Standard Test Support"]
        )
    ],
    dependencies: [
        .package(path: "../../swift-primitives/swift-kernel-primitives"),
        .package(path: "../../swift-primitives/swift-time-primitives"),
        .package(path: "../../swift-primitives/swift-loader-primitives"),
        .package(path: "../../swift-primitives/swift-string-primitives"),
        .package(path: "../../swift-iso/swift-iso-9945"),
        // SDG(wraps): Darwin syscalls wrap errno
        // .package(path: "../swift-error-primitives"),
    ],
    targets: [

        // MARK: - Core
        .target(
            name: "Darwin Standard Core",
            dependencies: []
        ),

        // MARK: - C Shims
        .target(
            name: "CDarwinKernelShim",
            dependencies: []
        ),
        .target(
            name: "CDarwinMemoryShim",
            dependencies: []
        ),

        // MARK: - Kernel
        .target(
            name: "Darwin Kernel Standard",
            dependencies: [
                .target(name: "Darwin Standard Core"),
                .target(name: "CDarwinKernelShim"),
                .product(name: "Kernel File Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Random Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Thread Primitives", package: "swift-kernel-primitives"),
                .product(name: "Time Primitives", package: "swift-time-primitives"),
                .product(name: "ISO 9945 Kernel", package: "swift-iso-9945"),
            ]
        ),

        // MARK: - Kernel Event
        .target(
            name: "Darwin Kernel Event Standard",
            dependencies: [
                .target(name: "Darwin Standard Core"),
                .target(name: "Darwin Kernel Time Standard"),
                .product(name: "Kernel Descriptor Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Event Primitives", package: "swift-kernel-primitives"),
                .product(name: "Kernel Error Primitives", package: "swift-kernel-primitives"),
                .product(name: "ISO 9945 Kernel", package: "swift-iso-9945"),
            ]
        ),

        // MARK: - Kernel Time
        .target(
            name: "Darwin Kernel Time Standard",
            dependencies: [
                .target(name: "Darwin Standard Core"),
            ]
        ),

        // MARK: - Loader
        .target(
            name: "Darwin Loader Standard",
            dependencies: [
                .target(name: "Darwin Standard Core"),
                .target(name: "CDarwinKernelShim"),
                .product(name: "Loader Primitives", package: "swift-loader-primitives"),
                .product(name: "String Primitives", package: "swift-string-primitives")
            ]
        ),

        // MARK: - Memory
        .target(
            name: "Darwin Memory Standard",
            dependencies: [
                .target(name: "Darwin Standard Core"),
                .target(name: "CDarwinMemoryShim")
            ]
        ),

        // MARK: - Test Support
        .target(
            name: "Darwin Kernel Standard Test Support",
            dependencies: [
                "Darwin Kernel Standard",
                .product(name: "Kernel Primitives Test Support", package: "swift-kernel-primitives")
            ],
            path: "Tests/Support"
        ),

        // MARK: - Tests
        .testTarget(
            name: "Darwin Kernel Event Standard Tests",
            dependencies: [
                "Darwin Kernel Event Standard",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
