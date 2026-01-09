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

licenses(["notice"])  # Apache 2

package(default_visibility = ["//visibility:public"])

# LLVM libraries needed by WAMR JIT.
# This replaces the foreign_cc cmake build of LLVM with native Bazel builds.
# Uses select() for CPU-specific libraries only.
cc_library(
    name = "llvm_wamr_lib",
    deps = [
        "@llvm-project//llvm:Analysis",
        "@llvm-project//llvm:BitReader",
        "@llvm-project//llvm:BitWriter",
        "@llvm-project//llvm:CodeGen",
        "@llvm-project//llvm:Core",
        "@llvm-project//llvm:ExecutionEngine",
        "@llvm-project//llvm:IPO",
        "@llvm-project//llvm:IRReader",
        "@llvm-project//llvm:InstCombine",
        "@llvm-project//llvm:Instrumentation",
        "@llvm-project//llvm:JITLink",
        "@llvm-project//llvm:Linker",
        "@llvm-project//llvm:MC",
        "@llvm-project//llvm:MCJIT",
        "@llvm-project//llvm:Object",
        "@llvm-project//llvm:OrcJIT",
        "@llvm-project//llvm:Passes",
        "@llvm-project//llvm:Scalar",
        "@llvm-project//llvm:Support",
        "@llvm-project//llvm:Target",
        "@llvm-project//llvm:TransformUtils",
        "@llvm-project//llvm:Vectorize",
    ] + select({
        "@platforms//cpu:x86_64": [
            "@llvm-project//llvm:X86AsmParser",
            "@llvm-project//llvm:X86CodeGen",
            "@llvm-project//llvm:X86Disassembler",
        ],
        "@platforms//cpu:aarch64": [
            "@llvm-project//llvm:AArch64AsmParser",
            "@llvm-project//llvm:AArch64CodeGen",
            "@llvm-project//llvm:AArch64Disassembler",
        ],
        "//conditions:default": [
            "@llvm-project//llvm:X86AsmParser",
            "@llvm-project//llvm:X86CodeGen",
            "@llvm-project//llvm:X86Disassembler",
        ],
    }),
)

# Generate minimal CMake config for WAMR to find Bazel-built LLVM.
# WAMR's CMake build uses find_package(LLVM), so we need to provide
# a minimal LLVMConfig.cmake that points to our Bazel-built libraries.
genrule(
    name = "llvm_cmake_config_gen",
    outs = ["llvm_cmake_config/LLVMConfig.cmake"],
    cmd = """
    mkdir -p $(@D)
    cat > $@ << 'EOF'
# Generated LLVMConfig.cmake for Bazel-built LLVM
# This minimal config allows WAMR's CMake build to find LLVM.

set(LLVM_FOUND TRUE)
set(LLVM_PACKAGE_VERSION "19.1.0")
set(LLVM_VERSION_MAJOR 19)
set(LLVM_VERSION_MINOR 1)
set(LLVM_VERSION_PATCH 0)

# LLVM include and library directories are provided via Bazel deps
# so we set these to empty/placeholder values
set(LLVM_INCLUDE_DIRS "")
set(LLVM_LIBRARY_DIRS "")
set(LLVM_DEFINITIONS "")
set(LLVM_ENABLE_EH OFF)
set(LLVM_ENABLE_RTTI OFF)

# Provide llvm_map_components_to_libnames function
# WAMR calls this, but we provide libraries via Bazel deps, not CMake
function(llvm_map_components_to_libnames out_libs)
    # All LLVM libraries are provided via Bazel cc_library deps
    # so this is effectively a no-op for our build
    set($${out_libs} "" PARENT_SCOPE)
endfunction()

# Mark as found so WAMR's CMake configuration succeeds
set(LLVM_CMAKE_DIR "$${CMAKE_CURRENT_LIST_DIR}")
EOF
    """,
)

# Filegroup to make the CMake config available to WAMR's build
filegroup(
    name = "llvm_cmake_config",
    srcs = [":llvm_cmake_config_gen"],
)
