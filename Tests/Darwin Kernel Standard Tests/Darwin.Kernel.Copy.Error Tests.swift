#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    import Darwin
    import Error
    import Testing

    @testable import Darwin_Kernel_Standard

    extension Darwin.Kernel.Copy.Error {
        @Suite
        struct Test {
            @Suite struct Unit {}
            @Suite struct `Edge Case` {}
        }
    }

    extension Darwin.Kernel.Copy.Error.Test.Unit {
        @Test
        func `clonefile(2) errnos with a meaning keep their case`() {
            #expect(Darwin.Kernel.Copy.Error(posixErrno: EBADF) == .invalidDescriptor)
            #expect(Darwin.Kernel.Copy.Error(posixErrno: EXDEV) == .crossDevice)
            #expect(Darwin.Kernel.Copy.Error(posixErrno: ENOSPC) == .noSpace)
            #expect(Darwin.Kernel.Copy.Error(posixErrno: EIO) == .io)
            #expect(Darwin.Kernel.Copy.Error(posixErrno: EACCES) == .permissionDenied)
            #expect(Darwin.Kernel.Copy.Error(posixErrno: EPERM) == .permissionDenied)
            #expect(Darwin.Kernel.Copy.Error(posixErrno: ENOENT) == .notFound)
            #expect(Darwin.Kernel.Copy.Error(posixErrno: EEXIST) == .exists)
        }

        @Test
        func `clonefile(2) unsupported errnos report unsupported`() {
            #expect(Darwin.Kernel.Copy.Error(posixErrno: EINVAL) == .unsupported)
            #expect(Darwin.Kernel.Copy.Error(posixErrno: ENOTSUP) == .unsupported)
            #expect(Darwin.Kernel.Copy.Error(posixErrno: EOPNOTSUPP) == .unsupported)
            #expect(Darwin.Kernel.Copy.Error(posixErrno: ENOSYS) == .unsupported)
        }
    }

    extension Darwin.Kernel.Copy.Error.Test.`Edge Case` {
        @Test
        func `clonefile(2) errnos without a case pass through as platform errors`() {
            for errno in [ENOTDIR, EROFS, ELOOP, ENAMETOOLONG, EDQUOT, EFAULT] {
                #expect(Darwin.Kernel.Copy.Error(posixErrno: errno) == .platform(code: .posix(errno)))
            }
        }
    }
#endif
