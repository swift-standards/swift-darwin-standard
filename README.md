# Darwin Standard

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Typed value surfaces over the Darwin platform in Swift — kernel, event, time, loader, and memory standards organized as a family of importable modules under a single package.

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/swift-standards/swift-darwin-standard.git", branch: "main")
]
```

Add a product to your target — for example the kernel standard:

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "Darwin Kernel Standard", package: "swift-darwin-standard")
    ]
)
```

The package also vends `Darwin Kernel Event Standard`, `Darwin Kernel Time Standard`, `Darwin Loader Standard`, and `Darwin Memory Standard`.

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
