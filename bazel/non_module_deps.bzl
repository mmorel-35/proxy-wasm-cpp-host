# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""Module extension for non-BCR (Bazel Central Registry) dependencies.

This extension creates external repositories for dependencies that are either:
  - Not available in BCR at all
  - Available in BCR but at wrong versions for this project
  - Requiring custom BUILD files or patches not compatible with BCR

Note: Unlike WORKSPACE, module extensions cannot use maybe() to skip existing
repos. Each http_archive call here creates a new repo unconditionally. This is
safe because Bzlmod manages repo uniqueness across the dependency graph.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

def _non_module_deps_impl(mctx):
    # ── Core C++ dependencies not in BCR ──────────────────────────────────────

    http_archive(
        name = "boringssl",
        # 2023-08-28 (master-with-bazel)
        sha256 = "f1f421738e9ba39dd88daf8cf3096ddba9c53e2b6b41b32fff5a3ff82f4cd162",
        strip_prefix = "boringssl-45cf810dbdbd767f09f8cb0b0fcccd342c39041f",
        urls = ["https://github.com/google/boringssl/archive/45cf810dbdbd767f09f8cb0b0fcccd342c39041f.tar.gz"],
    )

    http_archive(
        name = "proxy_wasm_cpp_sdk",
        sha256 = "26c4c0f9f645de7e789dc92f113d7352ee54ac43bb93ae3a8a22945f1ce71590",
        strip_prefix = "proxy-wasm-cpp-sdk-7465dee8b2953beebff99f6dc3720ad0c79bab99",
        urls = ["https://github.com/proxy-wasm/proxy-wasm-cpp-sdk/archive/7465dee8b2953beebff99f6dc3720ad0c79bab99.tar.gz"],
    )

    # Compile DB dependencies.
    http_archive(
        name = "bazel_compdb",
        sha256 = "acd2a9eaf49272bb1480c67d99b82662f005b596a8c11739046a4220ec73c4da",
        strip_prefix = "bazel-compilation-database-40864791135333e1446a04553b63cbe744d358d0",
        url = "https://github.com/grailbio/bazel-compilation-database/archive/40864791135333e1446a04553b63cbe744d358d0.tar.gz",
    )

    http_archive(
        name = "envoy_toolshed",
        sha256 = "e2252e46e64417d5cedd9f1eb34a622bce5e13b43837e5fe051c83066b0a400b",
        strip_prefix = "toolshed-bazel-bins-v0.1.13/bazel",
        url = "https://github.com/envoyproxy/toolshed/archive/refs/tags/bazel-bins-v0.1.13.tar.gz",
    )

    # ── V8 and its dependencies ───────────────────────────────────────────────

    http_archive(
        name = "v8",
        urls = ["https://github.com/v8/v8/archive/refs/tags/14.4.258.16.tar.gz"],
        integrity = "sha256-igwEEi6kcb2q7EodzjJasjCx/6LRMiFTVWfDKcNB+Xw=",
        strip_prefix = "v8-14.4.258.16",
        patches = [
            "@@proxy_wasm_cpp_host//bazel/external:v8.patch",
        ],
        patch_args = ["-p1"],
        patch_cmds = [
            "find ./src ./include -type f -exec sed -i.bak -e 's!#include \"third_party/simdutf/simdutf.h\"!#include \"simdutf.h\"!' {} \\;",
            "find ./src ./include -type f -exec sed -i.bak -e 's!#include \"third_party/fp16/src/include/fp16.h\"!#include \"fp16.h\"!' {} \\;",
            "find ./src ./include -type f -exec sed -i.bak -e 's!#include \"third_party/dragonbox/src/include/dragonbox/dragonbox.h\"!#include \"dragonbox/dragonbox.h\"!' {} \\;",
            "find ./src ./include -type f -exec sed -i.bak -e 's!#include \"third_party/fast_float/src/include/fast_float/!#include \"fast_float/!' {} \\;",
        ],
    )

    # fast_float 7.0.0 is not available in BCR (only 6.1.6 and 8.0.2).
    http_archive(
        name = "fast_float",
        sha256 = "d2a08e722f461fe699ba61392cd29e6b23be013d0f56e50c7786d0954bffcb17",
        urls = [
            "https://github.com/fastfloat/fast_float/archive/refs/tags/v7.0.0.tar.gz",
        ],
        strip_prefix = "fast_float-7.0.0",
    )

    # dragonbox uses a custom BUILD file (no native Bazel support upstream).
    http_archive(
        name = "dragonbox",
        urls = [
            "https://github.com/jk-jeon/dragonbox/archive/6c7c925b571d54486b9ffae8d9d18a822801cbda.zip",
        ],
        strip_prefix = "dragonbox-6c7c925b571d54486b9ffae8d9d18a822801cbda",
        sha256 = "2f10448d665355b41f599e869ac78803f82f13b070ce7ef5ae7b5cceb8a178f3",
        build_file = "@@proxy_wasm_cpp_host//bazel/external:dragonbox.BUILD",
    )

    # fp16 uses a custom BUILD file.
    http_archive(
        name = "fp16",
        urls = [
            "https://github.com/Maratyszcza/FP16/archive/0a92994d729ff76a58f692d3028ca1b64b145d91.zip",
        ],
        strip_prefix = "FP16-0a92994d729ff76a58f692d3028ca1b64b145d91",
        sha256 = "e66e65515fa09927b348d3d584c68be4215cfe664100d01c9dbc7655a5716d70",
        build_file = "@@proxy_wasm_cpp_host//bazel/external:fp16.BUILD",
    )

    # simdutf 7.3.0 is not available in BCR (no version exists in BCR).
    http_archive(
        name = "simdutf",
        sha256 = "512374f8291d3daf102ccd0ad223b1a8318358f7c1295efd4d9a3abbb8e4b6ff",
        urls = [
            "https://github.com/simdutf/simdutf/releases/download/v7.3.0/singleheader.zip",
        ],
        build_file = "@@proxy_wasm_cpp_host//bazel/external:simdutf.BUILD",
    )

    http_archive(
        name = "intel_ittapi",
        strip_prefix = "ittapi-a3911fff01a775023a06af8754f9ec1e5977dd97",
        sha256 = "1d0dddfc5abb786f2340565c82c6edd1cff10c917616a18ce62ee0b94dbc2ed4",
        urls = ["https://github.com/intel/ittapi/archive/a3911fff01a775023a06af8754f9ec1e5977dd97.tar.gz"],
        build_file = "@@proxy_wasm_cpp_host//bazel/external:intel_ittapi.BUILD",
    )

    # ── WAMR and its dependencies ─────────────────────────────────────────────

    http_archive(
        name = "com_github_bytecodealliance_wasm_micro_runtime",
        build_file = "@@proxy_wasm_cpp_host//bazel/external:wamr.BUILD",
        # WAMR-2.4.1
        sha256 = "ca18bbf304f47287bf43707564db63b8908dd6d0d6ac40bb39271a7144def4cc",
        strip_prefix = "wasm-micro-runtime-WAMR-2.4.1",
        url = "https://github.com/bytecodealliance/wasm-micro-runtime/archive/refs/tags/WAMR-2.4.1.zip",
        patches = ["@@proxy_wasm_cpp_host//bazel/external:wamr.patch"],
        patch_args = ["-p1"],
    )

    http_archive(
        name = "llvm-raw",
        build_file = "@@proxy_wasm_cpp_host//bazel/external:wamr_llvm.BUILD",
        sha256 = "5042522b49945bc560ff9206f25fb87980a9b89b914193ca00d961511ff0673c",
        strip_prefix = "llvm-project-19.1.0.src",
        url = "https://github.com/llvm/llvm-project/releases/download/llvmorg-19.1.0/llvm-project-19.1.0.src.tar.xz",
    )

    # LLVM external dependencies for native Bazel build.
    http_archive(
        name = "llvm_zlib",
        build_file = "@llvm-raw//utils/bazel/third_party_build:zlib-ng.BUILD",
        sha256 = "e36bb346c00472a1f9ff2a0a4643e590a254be6379da7cddd9daeb9a7f296731",
        strip_prefix = "zlib-ng-2.0.7",
        urls = [
            "https://github.com/zlib-ng/zlib-ng/archive/refs/tags/2.0.7.zip",
        ],
    )

    http_archive(
        name = "llvm_zstd",
        build_file = "@llvm-raw//utils/bazel/third_party_build:zstd.BUILD",
        sha256 = "7c42d56fac126929a6a85dbc73ff1db2411d04f104fae9bdea51305663a83fd0",
        strip_prefix = "zstd-1.5.2",
        urls = [
            "https://github.com/facebook/zstd/releases/download/v1.5.2/zstd-1.5.2.tar.gz",
        ],
    )

    # ── WasmEdge ──────────────────────────────────────────────────────────────
    # fmt and spdlog dependencies are satisfied via bazel_dep in MODULE.bazel.

    http_archive(
        name = "com_github_wasmedge_wasmedge",
        build_file = "@@proxy_wasm_cpp_host//bazel/external:wasmedge.BUILD",
        sha256 = "2354d90a67e3eb396179663bdc0b457abbbc70dca967ec4528f211599a49f62a",
        strip_prefix = "WasmEdge-0.16.1",
        url = "https://github.com/WasmEdge/WasmEdge/archive/refs/tags/0.16.1.tar.gz",
        patches = ["@@proxy_wasm_cpp_host//bazel/external:wasmedge.patch"],
        patch_args = ["-p1"],
    )

    # ── Wasmtime ──────────────────────────────────────────────────────────────

    http_archive(
        name = "com_github_bytecodealliance_wasmtime",
        build_file = "@@proxy_wasm_cpp_host//bazel/external:wasmtime.BUILD",
        sha256 = "2ccb49bb3bfa4d86907ad4c80d1147aef6156c7b6e3f7f14ed02a39de9761155",
        strip_prefix = "wasmtime-24.0.0",
        url = "https://github.com/bytecodealliance/wasmtime/archive/v24.0.0.tar.gz",
    )

non_module_deps = module_extension(
    implementation = _non_module_deps_impl,
)
