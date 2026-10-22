#!/usr/bin/env bats
# ================================================================
# Tests for bin/supply (version resolution only — no downloads)
# ================================================================

load test_helper/common_setup

setup() {
  setup_common
}

teardown() {
  teardown_common
}

@test "supply: unsupported engines.node range fails with a clear error" {
  create_package_json "$BUILD_DIR" '{"name":"test","engines":{"node":">=18 <21"}}'

  run "${BUILDPACK_DIR}/bin/supply" "$BUILD_DIR" "$CACHE_DIR" "$DEPS_DIR" "$DEPS_IDX"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unsupported engines.node constraint"* ]]
  [[ "$output" != *"Downloading Node.js"* ]]
}

@test "supply: NODE_OVERRIDE_VERSION skips engines.node resolution" {
  create_package_json "$BUILD_DIR" '{"name":"test","engines":{"node":">=18 <21"}}'
  # Pre-seed the cache with an unreadable tarball so supply stops right after resolution
  echo "not a tarball" > "${CACHE_DIR}/node-v24.22.1-linux-x64.tar.gz"

  NODE_OVERRIDE_VERSION=24.22.1 run "${BUILDPACK_DIR}/bin/supply" "$BUILD_DIR" "$CACHE_DIR" "$DEPS_DIR" "$DEPS_IDX"
  [[ "$output" == *"Node.js version: v24.22.1"* ]]
  [[ "$output" != *"Unsupported engines.node constraint"* ]]
}
