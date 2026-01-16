# Copyright 2025 Google LLC
# SPDX-License-Identifier: Apache-2.0
#
# Repository rule to setup WasmEdge with multiple BUILD files

"""Repository rule for WasmEdge with native Bazel BUILD files."""

def _wasmedge_repository_impl(ctx):
    """Implementation of wasmedge_repository rule.
    
    This rule downloads WasmEdge, applies C++20 compatibility patches,
    and copies the comprehensive BUILD.bazel file for native Bazel
    compilation using rules_cc.
    """
    # Download and extract WasmEdge
    ctx.download_and_extract(
        url = ctx.attr.url,
        sha256 = ctx.attr.sha256,
        stripPrefix = ctx.attr.strip_prefix,
    )
    
    # Apply C++20 compatibility patch
    for patch in ctx.attr.patches:
        ctx.patch(patch, strip = 1)
    
    # Copy the main BUILD file
    content = ctx.read(ctx.attr._build_file)
    ctx.file("BUILD.bazel", content, executable = False)

wasmedge_repository = repository_rule(
    implementation = _wasmedge_repository_impl,
    attrs = {
        "url": attr.string(mandatory = True),
        "sha256": attr.string(mandatory = True),
        "strip_prefix": attr.string(mandatory = True),
        "patches": attr.label_list(allow_files = True),
        "_build_file": attr.label(
            default = Label("@proxy_wasm_cpp_host//bazel/external/wasmedge:BUILD.bazel"),
            allow_single_file = True,
        ),
    },
)
