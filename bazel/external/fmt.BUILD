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
        "FMT_HEADER_ONLY=1",  # Use header-only mode to avoid compilation issues
    ],
    includes = ["include"],
    strip_include_prefix = "include",
)
