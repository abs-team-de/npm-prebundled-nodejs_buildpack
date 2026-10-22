#!/usr/bin/env bash
# ================================================================
# Shared setup and helpers for Bats tests
# ================================================================

# Resolve paths relative to the repo root
BUILDPACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

setup_common() {
  TEST_TEMP="$(mktemp -d)"
  BUILD_DIR="${TEST_TEMP}/build"
  CACHE_DIR="${TEST_TEMP}/cache"
  DEPS_DIR="${TEST_TEMP}/deps"
  DEPS_IDX="0"
  mkdir -p "$BUILD_DIR" "$CACHE_DIR" "${DEPS_DIR}/${DEPS_IDX}"

  # CF stacks ship no python3 interpreter — shadow it so any use fails here too
  mkdir -p "${TEST_TEMP}/stubs"
  printf '#!/bin/sh\necho "python3 is not available on CF stacks" >&2\nexit 127\n' > "${TEST_TEMP}/stubs/python3"
  chmod +x "${TEST_TEMP}/stubs/python3"
  export PATH="${TEST_TEMP}/stubs:${PATH}"

  # Resolve engines.node against a trimmed copy of nodejs.org/dist/index.json
  export NODE_INDEX_URL="file://${BUILDPACK_DIR}/test/fixtures/node-index.json"

  # Source shared utilities
  source "${BUILDPACK_DIR}/lib/utils.sh"
}

teardown_common() {
  rm -rf "$TEST_TEMP"
}

# ── Helpers ──────────────────────────────────────────────────────

create_package_json() {
  local dir="$1"
  shift
  # Accept raw JSON content as the second argument
  if [ $# -gt 0 ]; then
    echo "$1" > "${dir}/package.json"
  else
    cat > "${dir}/package.json" <<'JSON'
{
  "name": "test-app",
  "version": "1.0.0",
  "engines": { "node": "20.18.0" },
  "scripts": { "start": "node server.js" },
  "dependencies": { "express": "^4.18.0" }
}
JSON
  fi
}

create_node_modules() {
  local dir="$1"
  shift
  mkdir -p "${dir}/node_modules"
  # Create fake packages passed as arguments
  for pkg in "$@"; do
    mkdir -p "${dir}/node_modules/${pkg}"
    echo '{"name":"'"${pkg}"'","version":"1.0.0","main":"index.js"}' > "${dir}/node_modules/${pkg}/package.json"
    echo "module.exports = {};" > "${dir}/node_modules/${pkg}/index.js"
  done
}

# Usage: create_symlink "$BUILD_DIR" <target> <link path relative to the app>
create_symlink() {
  local dir="$1" target="$2" link="$3"
  mkdir -p "$(dirname "${dir}/${link}")"
  ln -s "$target" "${dir}/${link}"
}
