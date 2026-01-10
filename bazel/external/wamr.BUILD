# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

load("@rules_cc//cc:defs.bzl", "cc_library")
load("@rules_foreign_cc//foreign_cc:defs.bzl", "cmake")

licenses(["notice"])  # Apache 2

package(default_visibility = ["//visibility:public"])

filegroup(
    name = "srcs",
    srcs = glob(["**"]),
)

cmake(
    name = "wamr_lib_cmake",
    # Use data to provide LLVM toolchain for CMake find_package(LLVM)
    # The hermetic LLVM toolchain includes proper CMake configs that WAMR can use
    data = select({
        "@proxy_wasm_cpp_host//bazel:engine_wamr_jit": [
            "@llvm_toolchain_llvm//:all_includes",
            "@llvm_toolchain_llvm//:bin",
            "@llvm_toolchain_llvm//:lib",
        ],
        "//conditions:default": [],
    }),
    # Set CMAKE_PREFIX_PATH to help CMake find the hermetic LLVM
    # This is more standard than setting LLVM_DIR directly
    env = select({
        "@proxy_wasm_cpp_host//bazel:engine_wamr_jit": {
            "CMAKE_PREFIX_PATH": "$$EXT_BUILD_DEPS/copy_llvm_toolchain_llvm",
        },
        "//conditions:default": {},
    }),
    generate_args = [
        # disable WASI
        "-DWAMR_BUILD_LIBC_WASI=0",
        "-DWAMR_BUILD_LIBC_BUILTIN=0",
        # MVP
        "-DWAMR_BUILD_BULK_MEMORY=1",
        "-DWAMR_BUILD_REF_TYPES=1",
        "-DWAMR_BUILD_TAIL_CALL=1",
        # WAMR private features
        "-DWAMR_BUILD_MULTI_MODULE=0",
        # Some tests have indicated that the following three factors have
        #   a minimal impact on performance.
        # - Get function names from name section
        "-DWAMR_BUILD_CUSTOM_NAME_SECTION=1",
        "-DWAMR_BUILD_LOAD_CUSTOM_SECTION=1",
        # - Show Wasm call stack if met a trap
        "-DWAMR_BUILD_DUMP_CALL_STACK=1",
        # Cache module files
        "-DWAMR_BUILD_WASM_CACHE=0",
        "-GNinja",
    ] + select({
        "@proxy_wasm_cpp_host//bazel:engine_wamr_jit": [
            # WAMR's CMake will find LLVM via CMAKE_PREFIX_PATH
            # No need to set LLVM_DIR explicitly
            "-DWAMR_BUILD_AOT=1",
            "-DWAMR_BUILD_FAST_INTERP=0",
            "-DWAMR_BUILD_INTERP=0",
            "-DWAMR_BUILD_JIT=1",
            "-DWAMR_BUILD_SIMD=1",
            # linux perf. only for jit and aot
            # "-DWAMR_BUILD_LINUX_PERF=1",
        ],
        "//conditions:default": [
            "-DWAMR_BUILD_AOT=0",
            "-DWAMR_BUILD_FAST_INTERP=1",
            "-DWAMR_BUILD_INTERP=1",
            "-DWAMR_BUILD_JIT=0",
            "-DWAMR_BUILD_SIMD=0",
        ],
    }),
    lib_source = ":srcs",
    out_static_libs = ["libiwasm.a"],
)

# Wrapper library that adds LLVM dependencies for linking
cc_library(
    name = "wamr_lib",
    linkopts = select({
        "@proxy_wasm_cpp_host//bazel:engine_wamr_jit": ["-ldl"],
        "//conditions:default": [],
    }),
    deps = [":wamr_lib_cmake"] + select({
        "@proxy_wasm_cpp_host//bazel:engine_wamr_jit": [
            "@llvm-raw//:llvm_wamr_lib",
        ],
        "//conditions:default": [],
    }),
)
