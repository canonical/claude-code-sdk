#!/usr/bin/env bash
# Recompute CHECKSUMS for the per-platform `claude` binaries at the version
# pinned in VERSION, and rewrite the top-level CHECKSUMS file. Each line is
# keyed on the platform string (linux-x64, linux-arm64), not a filename.
#
# Intended to run on a Renovate VERSION-bump PR (see
# .github/workflows/update-checksums.yml), but safe to run manually.
set -euo pipefail

cd "$(dirname "$0")/.."

VERSION="$(cat VERSION)"
BASE="https://downloads.claude.ai/claude-code-releases/${VERSION}"

PLATFORMS=(
  linux-x64
  linux-arm64
)

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

{
  for PLATFORM in "${PLATFORMS[@]}"; do
    curl -fsSL -o "$TMP/$PLATFORM" "$BASE/$PLATFORM/claude"
    printf '%s  %s\n' "$(sha256sum "$TMP/$PLATFORM" | cut -d' ' -f1)" "$PLATFORM"
  done
} > CHECKSUMS
