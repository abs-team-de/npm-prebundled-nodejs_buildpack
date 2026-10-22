#!/usr/bin/env bats
# ================================================================
# Tests for bin/release
# ================================================================

load test_helper/common_setup

setup() {
  setup_common
}

teardown() {
  teardown_common
}

@test "release: uses scripts.start when present" {
  create_package_json "$BUILD_DIR"

  run "${BUILDPACK_DIR}/bin/release" "$BUILD_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"node server.js"* ]]
}

@test "release: falls back to server.js when no start script" {
  create_package_json "$BUILD_DIR" '{"name":"test","version":"1.0.0"}'
  touch "${BUILD_DIR}/server.js"

  run "${BUILDPACK_DIR}/bin/release" "$BUILD_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"node server.js"* ]]
}

@test "release: falls back to index.js when no start script or server.js" {
  create_package_json "$BUILD_DIR" '{"name":"test","version":"1.0.0"}'
  touch "${BUILD_DIR}/index.js"

  run "${BUILDPACK_DIR}/bin/release" "$BUILD_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"node index.js"* ]]
}

@test "release: defaults to 'node server.js' when nothing found" {
  create_package_json "$BUILD_DIR" '{"name":"test","version":"1.0.0"}'

  run "${BUILDPACK_DIR}/bin/release" "$BUILD_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"node server.js"* ]]
}

@test "release: output is valid YAML" {
  create_package_json "$BUILD_DIR"

  run "${BUILDPACK_DIR}/bin/release" "$BUILD_DIR"
  [ "$status" -eq 0 ]
  [[ "$output" == *"---"* ]]
  [[ "$output" == *"default_process_types:"* ]]
  [[ "$output" == *"web:"* ]]
}

@test "release: escapes quotes in start command" {
  create_package_json "$BUILD_DIR" '{"name":"test","version":"1.0.0","scripts":{"start":"node -e \"console.log(1)\""}}'

  run "${BUILDPACK_DIR}/bin/release" "$BUILD_DIR"
  [ "$status" -eq 0 ]
  # The JSON-escaped value should contain escaped quotes
  [[ "$output" == *'\"'* ]]
}

@test "release: escapes non-ASCII characters in start command" {
  create_package_json "$BUILD_DIR" '{"name":"test","version":"1.0.0","scripts":{"start":"node x\u0085y.js"}}'

  run "${BUILDPACK_DIR}/bin/release" "$BUILD_DIR"
  [ "$status" -eq 0 ]
  # U+0085 must stay escaped, YAML would fold a raw one into a line break
  [[ "$output" == *'web: "node x\u0085y.js"'* ]]
}
