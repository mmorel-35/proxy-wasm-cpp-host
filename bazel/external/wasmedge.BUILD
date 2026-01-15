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

# Native Bazel BUILD file for WasmEdge runtime
# Based on https://github.com/mmorel-35/WasmEdge/pull/1

load("@rules_cc//cc:defs.bzl", "cc_library")

licenses(["notice"])  # Apache 2

package(default_visibility = ["//visibility:public"])

# Common library
cc_library(
    name = "common",
    srcs = [
        "lib/common/errinfo.cpp",
        "lib/common/hash.cpp",
        "lib/common/hexstr.cpp",
        "lib/common/spdlog.cpp",
    ],
    hdrs = glob([
        "include/common/*.h",
        "include/common/*.hpp",
    ]),
    includes = ["include"],
    deps = [
        "@spdlog",
    ],
)

# System library
cc_library(
    name = "system",
    srcs = [
        "lib/system/allocator.cpp",
        "lib/system/fault.cpp",
        "lib/system/mmap.cpp",
        "lib/system/path.cpp",
        "lib/system/stacktrace.cpp",
    ],
    hdrs = glob(["include/system/*.h"]),
    includes = ["include"],
    linkopts = select({
        "@platforms//os:windows": ["-ldbghelp"],
        "//conditions:default": [],
    }),
    deps = [
        ":common",
    ],
)

# Program Options library
cc_library(
    name = "po",
    srcs = glob(["lib/po/*.cpp"]),
    hdrs = glob(["include/po/*.h"]),
    includes = ["include"],
    deps = [
        ":common",
    ],
)

# Loader library  
cc_library(
    name = "loader",
    srcs = glob([
        "lib/loader/*.cpp",
        "lib/loader/filemgr/*.cpp",
    ]),
    hdrs = glob([
        "include/loader/*.h",
        "include/loader/filemgr/*.h",
    ]),
    includes = ["include"],
    deps = [
        ":common",
        ":system",
        "@simdjson",
    ],
)

# Validator library
cc_library(
    name = "validator",
    srcs = glob(["lib/validator/*.cpp"]),
    hdrs = glob(["include/validator/*.h"]),
    includes = ["include"],
    deps = [
        ":common",
    ],
)

# Executor library
cc_library(
    name = "executor",
    srcs = glob(["lib/executor/**/*.cpp"]),
    hdrs = glob(["include/executor/*.h"]),
    includes = ["include"],
    deps = [
        ":common",
        ":system",
    ],
)

# WASI host module
cc_library(
    name = "host_wasi",
    srcs = glob(["lib/host/wasi/*.cpp"]) + select({
        "@platforms//os:linux": glob(["lib/host/wasi/linux/*.cpp"]),
        "@platforms//os:macos": glob(["lib/host/wasi/darwin/*.cpp"]),
        "@platforms//os:windows": glob(["lib/host/wasi/win/*.cpp"]),
        "//conditions:default": [],
    }),
    hdrs = glob(["include/host/wasi/*.h"]),
    includes = ["include"],
    deps = [
        ":common",
        ":executor",
        ":system",
    ],
)

# Plugin library
cc_library(
    name = "plugin",
    srcs = glob(["lib/plugin/*.cpp"]),
    hdrs = glob(["include/plugin/*.h"]),
    includes = ["include"],
    deps = [
        ":common",
        ":loader",
    ],
)

# WASI Logging plugin
cc_library(
    name = "plugin_wasi_logging",
    srcs = glob(["lib/plugin/wasi_logging/*.cpp"]),
    hdrs = glob(["include/plugin/wasi_logging/*.h"]),
    includes = ["include"],
    deps = [
        ":common",
        ":plugin",
    ],
)

# VM library
cc_library(
    name = "vm",
    srcs = glob(["lib/vm/*.cpp"]),
    hdrs = glob(["include/vm/*.h"]),
    includes = ["include"],
    deps = [
        ":common",
        ":executor",
        ":host_wasi",
        ":loader",
        ":plugin",
        ":validator",
    ],
)

# Driver library
cc_library(
    name = "driver",
    srcs = glob(["lib/driver/*.cpp"]),
    hdrs = glob(["include/driver/*.h"]),
    includes = ["include"],
    deps = [
        ":common",
        ":po",
        ":vm",
    ],
)

# API library (main entry point)
cc_library(
    name = "wasmedge_lib",
    srcs = ["lib/api/wasmedge.cpp"],
    hdrs = glob(["include/api/wasmedge/*.h"]),
    includes = [
        "include",
        "include/api",
    ],
    deps = [
        ":driver",
        ":vm",
    ],
)
