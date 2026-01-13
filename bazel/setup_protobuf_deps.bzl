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

"""Setup protobuf dependencies as required by protobuf 33.2+."""

load("@rules_java//java:rules_java_deps.bzl", "rules_java_dependencies")
load("@rules_java//java:repositories.bzl", "rules_java_toolchains")

def setup_protobuf_deps():
    """Initialize rules_java dependencies required by protobuf 33.2+."""
    rules_java_dependencies()
    rules_java_toolchains()
