// swift-tools-version: 6.4

import PackageDescription

let package = Package(
    name: "swift-darwin-standard",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
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
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swift-molecules/swift-time.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-loader-vocabulary.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-string.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-error.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-random.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-tagged.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-cardinal.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-ordinal.git",
            branch: "main"
        ),
        .package(url: "https://github.com/swift-iso/swift-iso-9945.git", branch: "main"),
    ],
    targets: [

        .target(
            name: "Darwin Standard Core",
            dependencies: [
                .product(name: "ISO 9945 Core", package: "swift-iso-9945")
            ]
        ),

        .target(
            name: "Darwin Kernel Shims",
            dependencies: []
        ),
        .target(
            name: "Darwin Memory Shims",
            dependencies: []
        ),

        .target(
            name: "Darwin Kernel Standard",
            dependencies: [
                .target(name: "Darwin Standard Core"),
                .target(name: "Darwin Kernel Shims"),
                .product(name: "Random", package: "swift-random"),
                .product(name: "Time", package: "swift-time"),
                .product(name: "Error", package: "swift-error"),
                .product(name: "ISO 9945 Kernel", package: "swift-iso-9945"),
                .product(name: "ISO 9945 Kernel Thread", package: "swift-iso-9945"),
            ]
        ),

        .target(
            name: "Darwin Kernel Event Standard",
            dependencies: [
                .target(name: "Darwin Standard Core"),
                .target(name: "Darwin Kernel Time Standard"),
                .product(name: "Error", package: "swift-error"),
                .product(name: "ISO 9945 Kernel", package: "swift-iso-9945"),
            ]
        ),

        .target(
            name: "Darwin Kernel Time Standard",
            dependencies: [
                .target(name: "Darwin Standard Core")
            ]
        ),

        .target(
            name: "Darwin Loader Standard",
            dependencies: [
                .target(name: "Darwin Standard Core"),
                .target(name: "Darwin Kernel Shims"),
                .product(name: "Loader", package: "swift-loader-vocabulary"),
                .product(name: "String", package: "swift-string"),
                .product(name: "Tagged", package: "swift-tagged"),
                .product(name: "Cardinal", package: "swift-cardinal"),
                .product(name: "Ordinal", package: "swift-ordinal"),
                .product(name: "ISO 9945 Core", package: "swift-iso-9945"),
                .product(name: "ISO 9945 Loader", package: "swift-iso-9945"),
            ]
        ),

        .target(
            name: "Darwin Memory Standard",
            dependencies: [
                .target(name: "Darwin Standard Core"),
                .target(name: "Darwin Memory Shims"),
            ]
        ),

        .target(
            name: "Darwin Kernel Standard Test Support",
            dependencies: [
                "Darwin Kernel Standard"
            ],
            path: "Tests/Support"
        ),

        .testTarget(
            name: "Darwin Kernel Event Standard Tests",
            dependencies: [
                "Darwin Kernel Event Standard",
                .target(name: "Darwin Standard Core"),
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
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
