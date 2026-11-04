# swift-darwin-standard

Use this package when you need what Darwin offers beyond POSIX: kqueue, file cloning, extended attributes, `sysctl`, the images and sections dyld has loaded, and Spotlight metadata attribute names. Each area is its own product. Start from `Darwin.Kernel.Event.Queue` for kqueue, `Darwin.Kernel.File.Clone` or `Darwin.Kernel.Copy.Clone` for cloning, `Darwin.File.Stats` for file status with birth time, `Darwin.Loader.Image` and `Darwin.Loader.Section` for loaded images, and `Darwin.Metadata.Attribute` for Spotlight. For calls POSIX already defines, use swift-iso-9945.

## Laws

- `Darwin.File.Stats` reads a negative device number, such as the -1 Darwin reports for a socket, as its 32-bit unsigned bit pattern instead of trapping.
- `Darwin.Kernel.Copy.Clone.file(from:to:)` reports both `EACCES` and `EPERM` as a permission failure, and `EINVAL`, `ENOTSUP`, `EOPNOTSUPP` and `ENOSYS` all as unsupported. Any errno without its own meaning is passed through with its code.
- `Darwin.Kernel.Event.Queue.Event.Data` holds a pointer's bit pattern. A nil pointer becomes zero, and zero turns back into a nil pointer.
- For `Darwin.Kernel.Event.Queue.Flags` and `Darwin.Kernel.Event.Queue.Filter.Flags`, `contains(_:)` asks whether every bit of its argument is set, so any value contains `none`. Combining a flag with itself or with `none` leaves it unchanged.
- With `Darwin Kernel System Standard`, `CPU.Core.count` is the number of physical cores and is never less than one. `CPU.NUMA.state` is always unavailable, because Darwin exposes no NUMA topology.
- A Spotlight attribute is carried on a file by the extended attribute named `com.apple.metadata:` followed by the attribute's name, such as `com.apple.metadata:kMDItemTitle`.
