# Copyright 2022 Google LLC
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

"""Starlark rule to apply V8's pointer compression transition to a cc_library.

This rule wraps V8's v8_disable_pointer_compression transition (designed for
binaries) so it can be applied to cc_library targets. The transition sets
v8_enable_pointer_compression to False for the wrapped library and its
dependencies.
"""

load("@v8//:bazel/v8-non-pointer-compression.bzl", "v8_disable_pointer_compression")

def _v8_lib_no_pointer_compression_impl(ctx):
    """Forward the providers from the library with pointer compression disabled."""
    # The transition may create a list of configured targets, take the first one
    library = ctx.attr.library[0] if type(ctx.attr.library) == type([]) else ctx.attr.library
    return [library[CcInfo], library[DefaultInfo]]

v8_lib_no_pointer_compression = rule(
    implementation = _v8_lib_no_pointer_compression_impl,
    attrs = {
        "library": attr.label(
            cfg = v8_disable_pointer_compression,
            providers = [CcInfo],
            doc = "The V8 library to build with pointer compression disabled",
        ),
        "_allowlist_function_transition": attr.label(
            default = "@bazel_tools//tools/allowlists/function_transition_allowlist",
        ),
    },
    provides = [CcInfo],
    doc = """Wraps a V8 library target with pointer compression disabled.

    This rule applies V8's Starlark transition to disable pointer compression,
    which avoids the need to patch V8's default pointer compression setting.
    The transition ensures v8_enable_pointer_compression is set to False for
    the library and all its dependencies.
    """,
)
