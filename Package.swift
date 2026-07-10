// swift-tools-version: 6.3.3

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
        .package(url: "https://github.com/swift-primitives/swift-time-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-loader-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-string-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-error-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-random-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-tagged-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-cardinal-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-ordinal-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-iso/swift-iso-9945.git", branch: "main"),
    ],
    targets: [

        // MARK: - Core
        .target(
            name: "Darwin Standard Core",
            dependencies: [
                .product(name: "ISO 9945 Core", package: "swift-iso-9945"),
            ]
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
                .product(name: "Random Primitives", package: "swift-random-primitives"),
                .product(name: "Time Primitives", package: "swift-time-primitives"),
                .product(name: "ISO 9945 Kernel", package: "swift-iso-9945"),
                .product(name: "ISO 9945 Kernel Thread", package: "swift-iso-9945"),
            ]
        ),

        // MARK: - Kernel Event
        .target(
            name: "Darwin Kernel Event Standard",
            dependencies: [
                .target(name: "Darwin Standard Core"),
                .target(name: "Darwin Kernel Time Standard"),
                .product(name: "Error Primitives", package: "swift-error-primitives"),
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
                .product(name: "String Primitives", package: "swift-string-primitives"),
                .product(name: "Tagged Primitives", package: "swift-tagged-primitives"),
                .product(name: "Cardinal Primitives", package: "swift-cardinal-primitives"),
                .product(name: "Ordinal Primitives", package: "swift-ordinal-primitives"),
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
            ],
            path: "Tests/Support"
        ),

        // MARK: - Tests
        .testTarget(
            name: "Darwin Kernel Event Standard Tests",
            dependencies: [
                "Darwin Kernel Event Standard",
                .product(name: "ISO 9945 Kernel Test Support", package: "swift-iso-9945"),
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
