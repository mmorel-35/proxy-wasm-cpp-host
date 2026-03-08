# Bazel Central Registry (BCR) Configuration

This directory contains configuration for publishing `proxy_wasm_cpp_host` to the
[Bazel Central Registry](https://registry.bazel.build/).

## Files

- `metadata.template.json`: Module metadata (homepage, maintainers, repository).
- `source.template.json`: Archive source template used to generate `source.json`
  for each release.
- `presubmit.yml`: CI matrix used by the BCR bot to verify module compatibility.

## Publishing a new version

New versions are published automatically when a version tag (`v*.*.*`) is pushed
to the upstream repository. The workflow is defined in
`.github/workflows/publish-to-bcr.yml`.

### Manual publishing

To publish manually from the GitHub UI:

1. Navigate to **Actions → Publish to BCR**.
2. Click **Run workflow**.
3. Enter the tag name (e.g., `v0.2.5`).
4. Click **Run workflow**.

The workflow uses [publish-to-bcr](https://github.com/bazel-contrib/publish-to-bcr)
to open a PR against the BCR repository.

## Requirements

- The repository must have a `BCR_PUBLISH_TOKEN` secret configured.
- The token must have write access to the BCR repository.
- Each release must have a corresponding git tag and GitHub Release.
