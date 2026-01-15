# SPDX-License-Identifier: Apache-2.0
# Build file for spdlog library

load("@rules_cc//cc:defs.bzl", "cc_library")

package(default_visibility = ["//visibility:public"])

cc_library(
    name = "spdlog",
    srcs = glob([
        "src/*.cpp",
    ]),
    hdrs = glob([
        "include/spdlog/**/*.h",
    ]),
    defines = [
        "SPDLOG_COMPILED_LIB",
        # Use spdlog's bundled fmt to avoid C++20 conflicts
    ],
    includes = ["include"],
    strip_include_prefix = "include",
)
