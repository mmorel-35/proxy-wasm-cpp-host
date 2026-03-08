# WebAssembly for Proxies (C++ host implementation)

## Bazel Build System

This project supports both the legacy **WORKSPACE** build system and the
modern **Bzlmod** dependency management system.

### Bzlmod (recommended for new integrations)

Bzlmod is enabled by default in Bazel 7+ and uses `MODULE.bazel` for
dependency declarations.

**Build with Bzlmod:**
```
bazel build //...
```

**Explicit flag (if your project disables Bzlmod):**
```
bazel build --enable_bzlmod //...
```

**Using as a dependency (in your MODULE.bazel):**
```starlark
bazel_dep(name = "proxy-wasm-cpp-host", version = "X.Y.Z")
```

### Legacy WORKSPACE

For backward compatibility, the legacy `WORKSPACE` file is retained.

**Build with WORKSPACE mode:**
```
bazel build --noenable_bzlmod //...
```

**Using as a dependency (in your WORKSPACE):**
```starlark
load("@proxy_wasm_cpp_host//bazel:repositories.bzl", "proxy_wasm_cpp_host_repositories")
proxy_wasm_cpp_host_repositories()

load("@proxy_wasm_cpp_host//bazel:dependencies.bzl", "proxy_wasm_cpp_host_dependencies")
proxy_wasm_cpp_host_dependencies()
```

## How to Contribute

See [CONTRIBUTING](CONTRIBUTING.md).
