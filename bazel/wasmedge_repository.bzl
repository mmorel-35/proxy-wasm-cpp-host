# Copyright 2025 Google LLC
# SPDX-License-Identifier: Apache-2.0
#
# Repository rule to setup WasmEdge with multiple BUILD files

"""Repository rule for WasmEdge with native Bazel BUILD files."""

def _wasmedge_repository_impl(ctx):
    """Implementation of wasmedge_repository rule.
    
    This rule downloads WasmEdge, applies C++20 compatibility patches,
    and copies BUILD.bazel files throughout the source tree for native
    Bazel compilation using rules_cc.
    """
    # Download and extract WasmEdge
    ctx.download_and_extract(
        url = ctx.attr.url,
        sha256 = ctx.attr.sha256,
        stripPrefix = ctx.attr.strip_prefix,
    )
    
    # Apply C++20 compatibility patch
    ctx.patch(ctx.attr.patches[0], strip = 1)
    
    # Copy BUILD files to appropriate locations
    build_files = {
        "BUILD.bazel": "",
        "include.BUILD.bazel": "include/BUILD.bazel",
        "common.BUILD.bazel": "lib/common/BUILD.bazel",
        "system.BUILD.bazel": "lib/system/BUILD.bazel",
        "po.BUILD.bazel": "lib/po/BUILD.bazel",
        "loader.BUILD.bazel": "lib/loader/BUILD.bazel",
        "validator.BUILD.bazel": "lib/validator/BUILD.bazel",
        "executor.BUILD.bazel": "lib/executor/BUILD.bazel",
        "host.BUILD.bazel": "lib/host/BUILD.bazel",
        "plugin.BUILD.bazel": "lib/plugin/BUILD.bazel",
        "vm.BUILD.bazel": "lib/vm/BUILD.bazel",
        "api.BUILD.bazel": "lib/api/BUILD.bazel",
    }
    
    for source_name, dest in build_files.items():
        # Find the label for this file in _build_files
        label = None
        for lbl, name in ctx.attr._build_files.items():
            if name == source_name:
                label = lbl
                break
        if label:
            ctx.template(
                dest,
                label,
                substitutions = {},
                executable = False,
            )

wasmedge_repository = repository_rule(
    implementation = _wasmedge_repository_impl,
    attrs = {
        "url": attr.string(mandatory = True),
        "sha256": attr.string(mandatory = True),
        "strip_prefix": attr.string(mandatory = True),
        "patches": attr.label_list(allow_files = True),
        "_build_files": attr.label_keyed_string_dict(
            default = {
                Label("@proxy_wasm_cpp_host//bazel/external/wasmedge:BUILD.bazel"): "BUILD.bazel",
                Label("@proxy_wasm_cpp_host//bazel/external/wasmedge:include.BUILD.bazel"): "include.BUILD.bazel",
                Label("@proxy_wasm_cpp_host//bazel/external/wasmedge:common.BUILD.bazel"): "common.BUILD.bazel",
                Label("@proxy_wasm_cpp_host//bazel/external/wasmedge:system.BUILD.bazel"): "system.BUILD.bazel",
                Label("@proxy_wasm_cpp_host//bazel/external/wasmedge:po.BUILD.bazel"): "po.BUILD.bazel",
                Label("@proxy_wasm_cpp_host//bazel/external/wasmedge:loader.BUILD.bazel"): "loader.BUILD.bazel",
                Label("@proxy_wasm_cpp_host//bazel/external/wasmedge:validator.BUILD.bazel"): "validator.BUILD.bazel",
                Label("@proxy_wasm_cpp_host//bazel/external/wasmedge:executor.BUILD.bazel"): "executor.BUILD.bazel",
                Label("@proxy_wasm_cpp_host//bazel/external/wasmedge:host.BUILD.bazel"): "host.BUILD.bazel",
                Label("@proxy_wasm_cpp_host//bazel/external/wasmedge:plugin.BUILD.bazel"): "plugin.BUILD.bazel",
                Label("@proxy_wasm_cpp_host//bazel/external/wasmedge:vm.BUILD.bazel"): "vm.BUILD.bazel",
                Label("@proxy_wasm_cpp_host//bazel/external/wasmedge:api.BUILD.bazel"): "api.BUILD.bazel",
            },
        ),
    },
)
