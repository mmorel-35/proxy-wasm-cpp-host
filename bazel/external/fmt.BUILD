# SPDX-License-Identifier: Apache-2.0
# Build file for fmt library

load("@rules_cc//cc:defs.bzl", "cc_library")

package(default_visibility = ["//visibility:public"])

cc_library(
    name = "fmt",
    srcs = [],  # Header-only mode
    hdrs = glob([
        "include/fmt/*.h",
    ]),
    defines = [
        "FMT_HEADER_ONLY=1",  # Use header-only mode
        "FMT_USE_NONTYPE_TEMPLATE_ARGS=0",  # Disable C++20 NTTP for better compatibility
    ],
    includes = ["include"],
    strip_include_prefix = "include",
)
