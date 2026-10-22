# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [1.0.0](https://github.com/abs-team-de/npm-prebundled-nodejs_buildpack/releases/tag/v1.0.0) - 2026-10-22

### Added

- `bin/detect` matches apps with `package.json` and `node_modules/`
- `bin/supply` downloads Node.js from nodejs.org, checks it against `SHASUMS256.txt`, caches it and links `node`, `npm` and `npx`
- `engines.node` resolves to the newest matching linux-x64 release on nodejs.org; exact versions are pinned, `>=X` installs the newest LTS, and unsupported ranges fail staging. `NODE_OVERRIDE_VERSION` skips resolution
- Default Node.js version 24.22.1 (Active LTS, includes the [October 2026 security releases](https://nodejs.org/en/blog/vulnerability/october-2026-security-releases))
- `profile.d/000_node.sh` sets `PATH`, `NODE_ENV=production`, `--max-old-space-size` at 75% of the memory limit and `SSL_CERT_DIR`, and is also copied to `$BUILD_DIR/.profile.d/`
- `bin/finalize` validates the app and fails on symlinks in `node_modules` that are dangling or point outside the app directory; npm's `.bin` links are allowed
- `bin/release` provides the default `web` command from `scripts.start`, `server.js` or `index.js`
- Reads `package.json` with `jq`, so it runs on cflinuxfs4 and cflinuxfs5, which ship no Python interpreter
- Bats test suite, run in CI on `ubuntu-latest` and inside the cflinuxfs4 and cflinuxfs5 images
