# SPDX-License-Identifier: Apache-2.0
# Build file for simdjson library

load("@rules_cc//cc:defs.bzl", "cc_library")

package(default_visibility = ["//visibility:public"])

cc_library(
    name = "simdjson",
    srcs = ["singleheader/simdjson.cpp"],
    hdrs = ["singleheader/simdjson.h"],
    strip_include_prefix = "singleheader",
)
