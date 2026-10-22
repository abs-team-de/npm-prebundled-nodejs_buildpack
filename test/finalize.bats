#!/usr/bin/env bats
# ================================================================
# Tests for bin/finalize
#
# These tests run finalize in isolation by providing a minimal
# BUILD_DIR with the expected structure. Node.js must be available
# on PATH for the smoke test; we skip the node-dependent checks
# by not providing a resolvable dependency.
# ================================================================

load test_helper/common_setup

setup() {
  setup_common
  # finalize needs node on PATH — use the system node if available
  export PATH="${DEPS_DIR}/${DEPS_IDX}/node/bin:${DEPS_DIR}/${DEPS_IDX}/bin:${PATH}"
}

teardown() {
  teardown_common
}

@test "finalize: passes with valid structure" {
  create_package_json "$BUILD_DIR"
  create_node_modules "$BUILD_DIR" express
  # Create .bin directory to avoid find error
  mkdir -p "${BUILD_DIR}/node_modules/.bin"

  run "${BUILDPACK_DIR}/bin/finalize" "$BUILD_DIR" "$CACHE_DIR" "$DEPS_DIR" "$DEPS_IDX"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Validation passed"* ]]
}

@test "finalize: fails when package.json is missing" {
  create_node_modules "$BUILD_DIR" express
  mkdir -p "${BUILD_DIR}/node_modules/.bin"

  run "${BUILDPACK_DIR}/bin/finalize" "$BUILD_DIR" "$CACHE_DIR" "$DEPS_DIR" "$DEPS_IDX"
  [ "$status" -eq 1 ]
  [[ "$output" == *"package.json not found"* ]]
}

@test "finalize: fails when node_modules is missing" {
  create_package_json "$BUILD_DIR"

  run "${BUILDPACK_DIR}/bin/finalize" "$BUILD_DIR" "$CACHE_DIR" "$DEPS_DIR" "$DEPS_IDX"
  [ "$status" -eq 1 ]
  [[ "$output" == *"node_modules/ directory not found"* ]]
}

@test "finalize: fails when node_modules is empty" {
  create_package_json "$BUILD_DIR"
  mkdir -p "${BUILD_DIR}/node_modules"

  run "${BUILDPACK_DIR}/bin/finalize" "$BUILD_DIR" "$CACHE_DIR" "$DEPS_DIR" "$DEPS_IDX"
  [ "$status" -eq 1 ]
  [[ "$output" == *"appears empty"* ]]
}

@test "finalize: empty check ignores npm metadata (.bin, .package-lock.json)" {
  create_package_json "$BUILD_DIR"
  mkdir -p "${BUILD_DIR}/node_modules/.bin"
  echo '{}' > "${BUILD_DIR}/node_modules/.package-lock.json"

  run "${BUILDPACK_DIR}/bin/finalize" "$BUILD_DIR" "$CACHE_DIR" "$DEPS_DIR" "$DEPS_IDX"
  [ "$status" -eq 1 ]
  [[ "$output" == *"appears empty"* ]]
}

# ── Symlinks ─────────────────────────────────────────────────────

@test "finalize: passes with npm .bin symlinks into a package" {
  create_package_json "$BUILD_DIR"
  create_node_modules "$BUILD_DIR" express
  create_symlink "$BUILD_DIR" ../express/index.js node_modules/.bin/express

  run "${BUILDPACK_DIR}/bin/finalize" "$BUILD_DIR" "$CACHE_DIR" "$DEPS_DIR" "$DEPS_IDX"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Validation passed"* ]]
  # .bin targets are made executable
  [ -x "${BUILD_DIR}/node_modules/express/index.js" ]
}

@test "finalize: passes with a workspace link to a folder inside the app" {
  create_package_json "$BUILD_DIR"
  create_node_modules "$BUILD_DIR" express
  mkdir -p "${BUILD_DIR}/packages/shared"
  create_symlink "$BUILD_DIR" ../../packages/shared node_modules/@myorg/shared

  run "${BUILDPACK_DIR}/bin/finalize" "$BUILD_DIR" "$CACHE_DIR" "$DEPS_DIR" "$DEPS_IDX"
  [ "$status" -eq 0 ]
}

@test "finalize: fails on a workspace link pointing outside the app" {
  create_package_json "$BUILD_DIR"
  create_node_modules "$BUILD_DIR" express
  mkdir -p "${TEST_TEMP}/packages/shared"
  create_symlink "$BUILD_DIR" ../../../packages/shared node_modules/@myorg/shared

  run "${BUILDPACK_DIR}/bin/finalize" "$BUILD_DIR" "$CACHE_DIR" "$DEPS_DIR" "$DEPS_IDX"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Found 1 broken symlink(s)"* ]]
  [[ "$output" == *"node_modules/@myorg/shared -> ../../../packages/shared (outside the app)"* ]]
  [[ "$output" != *"Validation passed"* ]]
}

@test "finalize: fails on a dangling symlink" {
  create_package_json "$BUILD_DIR"
  create_node_modules "$BUILD_DIR" express
  create_symlink "$BUILD_DIR" ../missing/cli.js node_modules/.bin/missing

  run "${BUILDPACK_DIR}/bin/finalize" "$BUILD_DIR" "$CACHE_DIR" "$DEPS_DIR" "$DEPS_IDX"
  [ "$status" -eq 1 ]
  [[ "$output" == *"node_modules/.bin/missing -> ../missing/cli.js (dangling)"* ]]
}

@test "finalize: fails on an absolute symlink to the CI checkout" {
  create_package_json "$BUILD_DIR"
  create_node_modules "$BUILD_DIR" express
  create_symlink "$BUILD_DIR" /__ci_checkout__/packages/shared node_modules/shared

  run "${BUILDPACK_DIR}/bin/finalize" "$BUILD_DIR" "$CACHE_DIR" "$DEPS_DIR" "$DEPS_IDX"
  [ "$status" -eq 1 ]
  [[ "$output" == *"(dangling)"* ]]
}

@test "finalize: fails on a broken link inside an in-app workspace package" {
  create_package_json "$BUILD_DIR"
  create_node_modules "$BUILD_DIR" express
  mkdir -p "${BUILD_DIR}/packages/shared/node_modules"
  create_symlink "$BUILD_DIR" ../../packages/shared node_modules/@myorg/shared
  create_symlink "$BUILD_DIR" ../../../../outside packages/shared/node_modules/other

  run "${BUILDPACK_DIR}/bin/finalize" "$BUILD_DIR" "$CACHE_DIR" "$DEPS_DIR" "$DEPS_IDX"
  [ "$status" -eq 1 ]
  [[ "$output" == *"packages/shared/node_modules/other -> ../../../../outside"* ]]
}

@test "finalize: fails when a nested node_modules is itself a link outside the app" {
  create_package_json "$BUILD_DIR"
  create_node_modules "$BUILD_DIR" express
  mkdir -p "${BUILD_DIR}/packages/shared" "${TEST_TEMP}/outside"
  create_symlink "$BUILD_DIR" ../../packages/shared node_modules/@myorg/shared
  create_symlink "$BUILD_DIR" ../../../outside packages/shared/node_modules

  run "${BUILDPACK_DIR}/bin/finalize" "$BUILD_DIR" "$CACHE_DIR" "$DEPS_DIR" "$DEPS_IDX"
  [ "$status" -eq 1 ]
  [[ "$output" == *"packages/shared/node_modules -> ../../../outside (outside the app)"* ]]
}

@test "finalize: lists at most 20 broken links and still prints the remedy" {
  create_package_json "$BUILD_DIR"
  create_node_modules "$BUILD_DIR" express
  # Enough output to fill a pipe buffer, so an early-closing reader would break the pipe
  local long
  long=$(printf "x%.0s" {1..200})
  for i in $(seq 1 400); do
    create_symlink "$BUILD_DIR" "../missing/${long}${i}" "node_modules/.bin/${long}${i}"
  done

  run "${BUILDPACK_DIR}/bin/finalize" "$BUILD_DIR" "$CACHE_DIR" "$DEPS_DIR" "$DEPS_IDX"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Found 400 broken symlink(s)"* ]]
  [[ "$output" == *"... and 380 more"* ]]
  [[ "$output" == *"Validation failed with 1 error(s)"* ]]
}

# ── Smoke test ───────────────────────────────────────────────────

@test "finalize: smoke test resolves the first dependency" {
  command -v node >/dev/null || skip "node not on PATH"
  create_package_json "$BUILD_DIR"
  create_node_modules "$BUILD_DIR" express

  run "${BUILDPACK_DIR}/bin/finalize" "$BUILD_DIR" "$CACHE_DIR" "$DEPS_DIR" "$DEPS_IDX"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Dependency smoke test passed (resolved 'express')"* ]]
}

@test "finalize: smoke test does not evaluate the dependency name as code" {
  command -v node >/dev/null || skip "node not on PATH"
  # Spliced into a JS string this would exit 0 before resolving anything
  create_package_json "$BUILD_DIR" "{\"name\":\"t\",\"dependencies\":{\"x'+process.exit(0)+'\":\"1\"}}"
  create_node_modules "$BUILD_DIR" express

  run "${BUILDPACK_DIR}/bin/finalize" "$BUILD_DIR" "$CACHE_DIR" "$DEPS_DIR" "$DEPS_IDX"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Could not resolve"* ]]
  [[ "$output" != *"smoke test passed"* ]]
}

@test "finalize: smoke test does not parse the dependency name as a node option" {
  command -v node >/dev/null || skip "node not on PATH"
  # Without an option terminator node would print its version and exit 0
  create_package_json "$BUILD_DIR" '{"name":"t","dependencies":{"--version":"1"}}'
  create_node_modules "$BUILD_DIR" express

  run "${BUILDPACK_DIR}/bin/finalize" "$BUILD_DIR" "$CACHE_DIR" "$DEPS_DIR" "$DEPS_IDX"
  [ "$status" -eq 0 ]
  [[ "$output" == *"Could not resolve '--version'"* ]]
}
