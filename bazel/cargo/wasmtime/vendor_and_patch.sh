#!/usr/bin/env bash
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

# This script runs the crates_vendor target and then patches the generated
# wasmtime-c-api-impl BUILD file to use rust_static_library instead of
# rust_library, as required for prefixed linking.

set -euo pipefail

# Run the crates_vendor target
bazel run //bazel/cargo/wasmtime:crates_vendor "$@"

# Patch the generated BUILD file to use rust_static_library
sed -i.bak \
  -e 's/load("@rules_rust\/\/rust:defs.bzl", "rust_library")/load("@rules_rust\/\/rust:defs.bzl", "rust_static_library")/' \
  -e 's/^rust_library(/rust_static_library(/' \
  bazel/cargo/wasmtime/remote/BUILD.wasmtime-c-api-impl-*.bazel

# Remove backup file
rm -f bazel/cargo/wasmtime/remote/BUILD.wasmtime-c-api-impl-*.bazel.bak

echo "Successfully patched wasmtime-c-api-impl to use rust_static_library"
