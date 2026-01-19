# Wasmtime Cargo Vendor Patching

## Overview

The wasmtime-c-api-impl crate needs to be built as a `rust_static_library` instead of 
`rust_library` for proper prefixed linking support. However, the cargo-bazel tool 
automatically generates BUILD files with `rust_library` by default.

## Solution

This directory contains a helper script `vendor_and_patch.sh` that automates the process
of running the crates vendor and applying the necessary patch.

### Usage

To update the vendored crates (including when repinning dependencies):

```bash
./bazel/cargo/wasmtime/vendor_and_patch.sh --repin
```

To update vendored crates without repinning:

```bash
./bazel/cargo/wasmtime/vendor_and_patch.sh
```

### What the script does

1. Runs `bazel run //bazel/cargo/wasmtime:crates_vendor` with any provided arguments
2. Patches the generated `BUILD.wasmtime-c-api-impl-*.bazel` file to replace:
   - `rust_library` with `rust_static_library` in the load statement
   - `rust_library(` with `rust_static_library(` in the rule definition

### Manual patching

If you need to patch manually after running crates_vendor directly:

```bash
bazel run //bazel/cargo/wasmtime:crates_vendor -- --repin

sed -i.bak \
  -e 's/load("@rules_rust\/\/rust:defs.bzl", "rust_library")/load("@rules_rust\/\/rust:defs.bzl", "rust_static_library")/' \
  -e 's/^rust_library(/rust_static_library(/' \
  bazel/cargo/wasmtime/remote/BUILD.wasmtime-c-api-impl-*.bazel

rm bazel/cargo/wasmtime/remote/BUILD.wasmtime-c-api-impl-*.bazel.bak
```

## Why is this necessary?

The wasmtime C API requires prefixed symbols to avoid conflicts with other WebAssembly 
runtimes. This prefixing is done at the link level using a static library, which requires
the use of `rust_static_library` instead of the default `rust_library`.

See `bazel/cargo/wasmtime/Cargo.toml` for more details.
