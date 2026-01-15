# SPDX-License-Identifier: Apache-2.0
# Build file for fmt library

load("@rules_cc//cc:defs.bzl", "cc_library")

package(default_visibility = ["//visibility:public"])

cc_library(
    name = "fmt",
    srcs = glob([
        "src/*.cc",
    ]),
    hdrs = glob([
        "include/fmt/*.h",
    ]),
    copts = [
        "-std=c++20",
    ],
    includes = ["include"],
    strip_include_prefix = "include",
)
