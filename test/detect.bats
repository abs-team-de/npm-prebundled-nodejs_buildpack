#!/usr/bin/env bats
# ================================================================
# Tests for bin/detect
# ================================================================

load test_helper/common_setup

setup() {
  setup_common
}

teardown() {
  teardown_common
}

@test "detect: succeeds when package.json AND node_modules exist" {
  create_package_json "$BUILD_DIR"
  create_node_modules "$BUILD_DIR" express

  run "${BUILDPACK_DIR}/bin/detect" "$BUILD_DIR"
  [ "$status" -eq 0 ]
  [ "$output" = "npm-prebundled" ]
}

@test "detect: fails when only package.json exists (no node_modules)" {
  create_package_json "$BUILD_DIR"

  run "${BUILDPACK_DIR}/bin/detect" "$BUILD_DIR"
  [ "$status" -eq 1 ]
  [[ "$output" == *"node_modules missing"* ]]
}

@test "detect: fails when only node_modules exists (no package.json)" {
  create_node_modules "$BUILD_DIR" express

  run "${BUILDPACK_DIR}/bin/detect" "$BUILD_DIR"
  [ "$status" -eq 1 ]
}

@test "detect: fails when neither package.json nor node_modules exist" {
  run "${BUILDPACK_DIR}/bin/detect" "$BUILD_DIR"
  [ "$status" -eq 1 ]
}
