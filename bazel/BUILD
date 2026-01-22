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

load("@bazel_skylib//lib:selects.bzl", "selects")
load(":v8_transition.bzl", "v8_lib_no_pointer_compression")

package(default_visibility = ["//visibility:public"])

config_setting(
    name = "engine_null",
    values = {"define": "engine=null"},
)

config_setting(
    name = "engine_v8",
    values = {"define": "engine=v8"},
)

config_setting(
    name = "engine_wamr",
    values = {"define": "engine=wamr"},
)

config_setting(
    name = "engine_wasmedge",
    values = {"define": "engine=wasmedge"},
)

config_setting(
    name = "engine_wasmtime",
    values = {"define": "engine=wasmtime"},
)

config_setting(
    name = "multiengine",
    values = {"define": "engine=multi"},
)

# LLVM mode configuration (orthogonal to engine choice)
config_setting(
    name = "llvm_mode_interpreter",
    values = {"define": "llvm_mode=interpreter"},
)

config_setting(
    name = "llvm_mode_jit",
    values = {"define": "llvm_mode=jit"},
)

config_setting(
    name = "llvm_mode_aot",
    values = {"define": "llvm_mode=aot"},
)

# Legacy aliases for backward compatibility (only for settings that existed in upstream)
config_setting(
    name = "engine_wamr_interp_legacy",
    values = {"define": "engine=wamr-interp"},
)

config_setting(
    name = "engine_wamr_jit_legacy",
    values = {"define": "engine=wamr-jit"},
)

# Unified engine selectors that support both new and legacy syntax
selects.config_setting_group(
    name = "engine_wamr_interp",
    match_any = [
        ":engine_wamr",  # New: --define=engine=wamr (without llvm_mode)
        ":engine_wamr_interp_legacy",  # Legacy: --define=engine=wamr-interp
    ],
)

# New syntax: wamr + JIT mode
selects.config_setting_group(
    name = "engine_wamr_with_jit",
    match_all = [
        ":engine_wamr",
        ":llvm_mode_jit",
    ],
)

# Unified selector supporting both new and legacy syntax
selects.config_setting_group(
    name = "engine_wamr_jit",
    match_any = [
        ":engine_wamr_with_jit",  # New: --define=engine=wamr --define=llvm_mode=jit
        ":engine_wamr_jit_legacy",  # Legacy: --define=engine=wamr-jit
    ],
)

selects.config_setting_group(
    name = "engine_wasmedge_aot",
    match_all = [
        ":engine_wasmedge",
        ":llvm_mode_aot",
    ],
)

config_setting(
    name = "requested_crypto_system",
    values = {"define": "crypto=system"},
)

config_setting(
    name = "linux_s390x",
    values = {"cpu": "s390x"},
)

selects.config_setting_group(
    name = "crypto_system",
    match_any = [
        ":requested_crypto_system",
        ":linux_s390x",
    ],
)

# V8 library with pointer compression disabled using V8's Starlark transition.
# This avoids the need to patch V8's default pointer compression setting.
v8_lib_no_pointer_compression(
    name = "wee8_no_pointer_compression",
    library = "@v8//:wee8",
)

exports_files(["tsan_suppressions.txt"])
