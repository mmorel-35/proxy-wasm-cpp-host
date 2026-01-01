# Bazel Compilation on s390x Architecture

## Problem Summary

When building Bazel 7.7.1 from source on s390x architecture under QEMU emulation, GCC experiences segmentation faults during compilation. The error specifically occurred when compiling `src/main/native/process.cc`:

```
gcc: internal compiler error: Segmentation fault signal terminated program cc1plus
```

## Root Cause Analysis

1. **GCC Under QEMU**: GCC on s390x under QEMU emulation is known to have stability issues, particularly with optimization enabled
2. **Hardcoded Optimization Flags**: The Bazel source has `-O2` optimization hardcoded in `tools/cpp/unix_cc_configure.bzl` 
3. **Flag Override Issue**: Simply adding `-O0` to `.bazelrc` was insufficient because the toolchain configuration's hardcoded flags took precedence

## Solution

The fix involves patching three key areas of the Bazel 7.7.1 source:

### 1. Toolchain Configuration (`tools/cpp/unix_cc_configure.bzl`)

Replace the hardcoded `-O2` with `-O0` and add anti-inlining flags:

```python
# Before:
"-O2",

# After:
# Workaround for GCC segmentation faults on s390x under QEMU emulation
"-O0",

# Additional flags to prevent inlining which can cause GCC crashes  
"-fno-inline",
"-fno-inline-functions",
```

### 2. Build Configuration (`.bazelrc`)

Add defensive compilation flags:

```
# Workaround for GCC segmentation faults on s390x under QEMU emulation
# Disable optimization and limit parallelism during bootstrap
build --jobs=1
build --copt=-O0
build --host_copt=-O0
build --copt=-g0
build --host_copt=-g0
build --copt=-fno-inline
build --host_copt=-fno-inline
build --copt=-fno-inline-functions
build --host_copt=-fno-inline-functions
```

### 3. Module Dependencies (`MODULE.bazel`)

Add the `bazel_features` dependency required for Bazel 7.7.1:

```python
bazel_dep(name = "bazel_features", version = "1.11.0")

# ...

single_version_override(
    module_name = "bazel_features",
    version = "1.11.0",
)
```

## Best Practices for Bazel on s390x

1. **Disable Optimization**: Use `-O0` instead of `-O2` or `-O3` to prevent compiler crashes
2. **Limit Inlining**: Add `-fno-inline` and `-fno-inline-functions` to reduce complexity
3. **Disable Debug Symbols**: Use `-g0` to reduce memory pressure during compilation
4. **Limit Parallelism**: Use `--jobs=1` to reduce concurrent compiler processes
5. **Patch at Source**: Modify toolchain configuration files, not just build flags, to ensure settings are applied

## Technical Details

### Why Toolchain Configuration?

Bazel's C++ toolchain configuration in `unix_cc_configure.bzl` defines the default compilation flags. These are applied before user-specified flags in `.bazelrc`, making them the authoritative source for optimization levels during bootstrap compilation.

### Why These Specific Flags?

- **-O0**: Completely disables optimization, preventing complex code transformations that trigger GCC bugs
- **-fno-inline**: Prevents function inlining, reducing compilation complexity
- **-fno-inline-functions**: Prevents automatic inlining of functions, further reducing complexity
- **-g0**: Removes debug information generation, reducing memory usage
- **--jobs=1**: Limits concurrent compilation, reducing memory pressure on emulated systems

### QEMU Emulation Context

When building for s390x on non-s390x hardware, QEMU user-mode emulation is used. This adds overhead and can expose bugs in compilers that are otherwise stable on native hardware. The combination of:
- Complex C++ code
- Aggressive optimization (-O2)
- Function inlining
- QEMU's emulation layer

...can trigger segmentation faults in GCC's cc1plus compiler.

## Testing the Patch

The patch can be tested with both `git apply` and the standard `patch` command:

```bash
# Using git apply
cd /path/to/bazel-7.7.1-dist
git apply bazel-v7.7.1.patch

# Using patch command (as used in Dockerfile)
cd /path/to/bazel-7.7.1-dist
patch -p1 < bazel-v7.7.1.patch
```

## References

- GCC on s390x under QEMU: Known issues with optimization levels
- Bazel toolchain configuration: `tools/cpp/unix_cc_configure.bzl`
- Bazel compilation flags: `.bazelrc` format and precedence
- Docker multi-arch builds: QEMU user-mode emulation behavior
