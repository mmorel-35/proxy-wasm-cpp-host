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

"""Setup bazel_features and rules_java internal repositories."""

load("@bazel_features//:deps.bzl", "bazel_features_deps")
load("@bazel_features//private:repos.bzl", "bazel_features_repos")
load("@rules_java//java:rules_java_deps.bzl", "rules_java_dependencies")

def setup_bazel_features():
    """Initialize bazel_features and rules_java internal repos (needed for WORKSPACE compat)."""
    bazel_features_deps()
    bazel_features_repos()
    rules_java_dependencies()
