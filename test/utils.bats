#!/usr/bin/env bats
# ================================================================
# Tests for lib/utils.sh
# ================================================================

load test_helper/common_setup

setup() {
  setup_common
}

teardown() {
  teardown_common
}

# ── resolve_node_version ─────────────────────────────────────────

@test "resolve_node_version: exact version passes through without lookup" {
  NODE_INDEX_URL="file:///nonexistent"
  run resolve_node_version "20.18.0"
  [ "$status" -eq 0 ]
  [ "$output" = "20.18.0" ]
}

@test "resolve_node_version: = prefix is an exact version" {
  run resolve_node_version "=20.18.0"
  [ "$output" = "20.18.0" ]
}

@test "resolve_node_version: empty string returns default" {
  run resolve_node_version ""
  [ "$output" = "24.22.1" ]
}

@test "resolve_node_version: major resolves to newest release of that major" {
  run resolve_node_version "22"
  [ "$output" = "22.23.4" ]
}

@test "resolve_node_version: skips releases without a linux-x64 build" {
  run resolve_node_version "24"
  [ "$output" = "24.22.1" ]
}

@test "resolve_node_version: major.minor resolves to newest patch" {
  run resolve_node_version "20.18"
  [ "$output" = "20.18.3" ]
}

@test "resolve_node_version: .x wildcard on major" {
  run resolve_node_version "22.x"
  [ "$output" = "22.23.4" ]
}

@test "resolve_node_version: .x wildcard on minor" {
  run resolve_node_version "20.18.x"
  [ "$output" = "20.18.3" ]
}

@test "resolve_node_version: ^ resolves to newest release of the same major" {
  run resolve_node_version "^20.18.0"
  [ "$output" = "20.20.2" ]
}

@test "resolve_node_version: ~ resolves to newest patch of the same minor" {
  run resolve_node_version "~20.18.0"
  [ "$output" = "20.18.3" ]
}

@test "resolve_node_version: >= resolves to newest LTS release" {
  run resolve_node_version ">=20.18.0"
  [ "$output" = "24.22.1" ]
}

@test "resolve_node_version: fails when nothing matches" {
  run resolve_node_version "^19"
  [ "$status" -eq 1 ]
  [[ "$output" == *"No Node.js release"* ]]
}

@test "resolve_node_version: fails when the release index is unreachable" {
  NODE_INDEX_URL="file:///nonexistent"
  run resolve_node_version "24"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Could not fetch"* ]]
}

@test "resolve_node_version: rejects range with space (>=20 <21)" {
  run resolve_node_version ">=20 <21"
  [ "$status" -eq 1 ]
}

@test "resolve_node_version: rejects OR range (18 || 20)" {
  run resolve_node_version "18 || 20"
  [ "$status" -eq 1 ]
}

@test "resolve_node_version: rejects hyphen range (18 - 20)" {
  run resolve_node_version "18 - 20"
  [ "$status" -eq 1 ]
}

@test "resolve_node_version: rejects lone star (*)" {
  run resolve_node_version "*"
  [ "$status" -eq 1 ]
}

# ── read_package_field ───────────────────────────────────────────

@test "read_package_field: reads top-level field" {
  create_package_json "$BUILD_DIR"
  run read_package_field "${BUILD_DIR}/package.json" "name"
  [ "$output" = "test-app" ]
}

@test "read_package_field: reads nested field (engines.node)" {
  create_package_json "$BUILD_DIR"
  run read_package_field "${BUILD_DIR}/package.json" "engines.node"
  [ "$output" = "20.18.0" ]
}

@test "read_package_field: reads scripts.start" {
  create_package_json "$BUILD_DIR"
  run read_package_field "${BUILD_DIR}/package.json" "scripts.start"
  [ "$output" = "node server.js" ]
}

@test "read_package_field: returns empty for missing field" {
  create_package_json "$BUILD_DIR"
  run read_package_field "${BUILD_DIR}/package.json" "nonexistent"
  [ "$output" = "" ]
}

@test "read_package_field: returns empty for missing file" {
  run read_package_field "${BUILD_DIR}/missing.json" "name"
  [ "$output" = "" ]
}

@test "read_package_field: returns empty when valid JSON is followed by garbage" {
  create_package_json "$BUILD_DIR" '{"scripts":{"start":"node app.js"}}junk'
  run read_package_field "${BUILD_DIR}/package.json" "scripts.start"
  [ "$output" = "" ]
}

@test "read_package_field: returns empty for concatenated JSON documents" {
  create_package_json "$BUILD_DIR" '{"scripts":{"start":"a"}}{"scripts":{"start":"b"}}'
  run read_package_field "${BUILD_DIR}/package.json" "scripts.start"
  [ "$output" = "" ]
}

# ── read_first_dependency ────────────────────────────────────────

@test "read_first_dependency: returns first dependency" {
  create_package_json "$BUILD_DIR"
  run read_first_dependency "${BUILD_DIR}/package.json"
  [ "$output" = "express" ]
}

@test "read_first_dependency: returns empty when no dependencies" {
  create_package_json "$BUILD_DIR" '{"name":"test","version":"1.0.0"}'
  run read_first_dependency "${BUILD_DIR}/package.json"
  [ "$output" = "" ]
}

@test "read_first_dependency: returns empty for missing file" {
  run read_first_dependency "${BUILD_DIR}/missing.json"
  [ "$output" = "" ]
}

@test "read_first_dependency: returns empty when valid JSON is followed by garbage" {
  create_package_json "$BUILD_DIR" '{"dependencies":{"express":"^4"}}junk'
  run read_first_dependency "${BUILD_DIR}/package.json"
  [ "$output" = "" ]
}
