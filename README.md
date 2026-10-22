# npm-prebundled-nodejs_buildpack

A custom Cloud Foundry buildpack for SAP BTP that deploys Node.js applications whose `node_modules` were installed by npm before deployment. It installs the Node.js runtime and validates the application. It never runs `npm install`, `npm ci` or `npm rebuild` at staging.

You install dependencies in CI with `npm ci --omit=dev` and ship them in the MTAR. Staging downloads Node.js from nodejs.org (and caches it), so it needs no access to an npm registry.

It replaces the standard [nodejs-buildpack](https://github.com/cloudfoundry/nodejs-buildpack) for apps built this way. For pnpm monorepos use [pnpm-prebundled-nodejs_buildpack](https://github.com/abs-team-de/pnpm-prebundled-nodejs_buildpack), which works the same way for `pnpm deploy` output.

## Features

- **No install at staging.** Staging runs no npm command against your dependencies, so it needs no registry access.
- **Node.js version resolution.** The buildpack reads `engines.node` from `package.json`. An exact version (`24.22.1`) is installed as-is. Anything else resolves at staging to the newest matching linux-x64 release in [nodejs.org/dist/index.json](https://nodejs.org/dist/index.json), so a redeploy picks up Node.js security releases. Major (`24`, `24.x`) and caret (`^24.3.0`) install the newest `24.*`. Major.minor (`24.3`, `24.3.x`) and tilde (`~24.3.0`) install the newest `24.3.*`. A lower bound (`>=20`) installs the newest LTS release. Ranges with spaces, `||` or hyphens (`>=18 <21`, `18 || 20`, `18 - 20`) and `*` fail staging.
- **Checksum.** The Node.js tarball is checked against the release's `SHASUMS256.txt`.
- **Memory tuning.** `--max-old-space-size` is set to 75% of the container memory limit.
- **Symlink check.** Staging fails on symlinks in `node_modules` that are dangling or point outside the app directory. npm's own `.bin` links pass.
- **Dependency smoke test.** Finalize resolves the first entry in `dependencies` before the app starts.
- **Staging cache.** Node.js downloads are cached between deployments.

## Usage

Reference the buildpack by its GitHub URL and tag in your `mta.yaml`:

```yaml
modules:
  - name: srv
    type: nodejs
    path: srv
    build-parameters:
      builder: custom
      commands:
        - npm ci --omit=dev
    parameters:
      buildpacks:
        - https://github.com/abs-team-de/npm-prebundled-nodejs_buildpack.git#v1.0.0
      memory: 512M
      disk_quota: 1024M
```

`mbt build` runs `npm ci --omit=dev` in `srv/`, and the MTAR then contains `srv/node_modules`. On SAP BTP customers can't run `cf create-buildpack`, which is why the buildpack is referenced by git URL.

## Expected application structure

```
srv/
├── package.json          # engines.node, scripts.start
├── package-lock.json     # needed by npm ci in CI, not read at staging
├── node_modules/         # from npm ci --omit=dev
│   ├── .bin/             # symlinks into packages, allowed
│   ├── express/
│   └── ...
└── server.js
```

## Symlinks, workspaces and file: dependencies

npm creates symlinks in `node_modules`. The links in `.bin/` point into packages in the same tree and work after deployment. npm also links workspace packages and `file:` dependencies to their source folder, for example `node_modules/@myorg/shared -> ../../packages/shared`. If that folder is outside the module path, the link has no target in the droplet and the app fails at runtime with `Cannot find module`.

Finalize therefore fails staging on any symlink in `node_modules` that is dangling or resolves outside the app directory, and lists the offending links. To fix:

- For `file:` dependencies, run `npm ci --omit=dev --install-links`, which copies them instead of linking.
- For workspace packages, depend on a tarball made with `npm pack`, or keep the shared code inside the app directory.

## Configuration

| Source | Field | Example | Purpose |
|--------|-------|---------|---------|
| `package.json` | `engines.node` | `"^24.22.1"` | Node.js version to install (default `24.22.1`) |
| `package.json` | `scripts.start` | `"node server.js"` | Default `web` command |
| Environment | `NODE_OVERRIDE_VERSION` | `24.22.1` | Install this exact version and skip `engines.node` |

npm and npx come with the installed Node.js and are on `PATH` at runtime. The buildpack doesn't read the `packageManager` field.

Without `scripts.start` the default `web` command is `node server.js`, or `node index.js` if only `index.js` exists. A `command` in `mta.yaml` overrides it.

## Staging output

```
-----> [npm-prebundled] Supply phase starting
       Node.js version: v24.22.1 (requested: '^24.0.0')
-----> [npm-prebundled] Downloading Node.js v24.22.1
       https://nodejs.org/dist/v24.22.1/node-v24.22.1-linux-x64.tar.gz
       SHA256 checksum verified
-----> [npm-prebundled] Supply phase complete
       node v24.22.1, npm 11.19.1
-----> [npm-prebundled] Finalize phase starting
-----> [npm-prebundled] Validating pre-bundled application structure...
       App name: srv
       node_modules: 68 top-level packages
       Start script: node server.js
       Dependency smoke test passed (resolved 'express')
-----> [npm-prebundled] Setting file permissions...
-----> [npm-prebundled] Validation passed — application is ready
-----> [npm-prebundled] No npm install executed. Pre-bundled dependencies will be used as-is.
```

## Runtime environment

The buildpack writes `.profile.d/000_node.sh`, which the CF launcher sources at container start. It sets:

| Variable | Value |
|----------|-------|
| `PATH` | Node.js `bin/` (node, npm, npx) prepended |
| `NODE_HOME` | Node.js install directory |
| `NODE_ENV` | `production` unless set |
| `NODE_OPTIONS` | `--max-old-space-size` at 75% of `MEMORY_LIMIT`, prepended to any existing value |
| `WEB_MEMORY`, `WEB_CONCURRENCY` | `512` and `1` unless set |
| `SSL_CERT_DIR` | `/etc/ssl/certs` unless set |

## Why not the standard nodejs-buildpack?

The Cloud Foundry `nodejs-buildpack` always runs `npm install` or `npm rebuild` during staging. This is compiled into its Go binary and can't be turned off by configuration. On SAP BTP customers can't upload a modified copy with `cf create-buildpack`. This buildpack is referenced by git URL and runs no install step.

## Compatibility

- **CF stack:** cflinuxfs5 (Ubuntu 24.04, the SAP BTP default) and cflinuxfs4 (Ubuntu 22.04). The buildpack needs `bash`, `curl`, `jq`, `tar` and `coreutils` from the stack. Neither stack ships a Python interpreter, and the buildpack doesn't use one.
- **Node.js:** any linux-x64 release on nodejs.org/dist. Node.js 20 is end-of-life.
- **SAP BTP:** Cloud Foundry environment.

## Repository structure

```
npm-prebundled-nodejs_buildpack/
├── bin/
│   ├── detect              # Matches apps with package.json + node_modules
│   ├── supply              # Installs Node.js, writes profile.d
│   ├── finalize            # Validates the pre-bundled app
│   └── release             # Default web command
├── lib/
│   └── utils.sh            # Logging, package.json reads, version resolution, symlink check
└── test/                   # Bats test suite
```

## Development

Tests use [Bats](https://github.com/bats-core/bats-core):

```bash
bats test/
```

CI runs the suite on `ubuntu-latest` and inside the `cloudfoundry/cflinuxfs4` and `cloudfoundry/cflinuxfs5` images. Version resolution tests read `test/fixtures/node-index.json` instead of nodejs.org.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## Security

See [SECURITY.md](SECURITY.md) for vulnerability reporting.

## License

[Apache-2.0](LICENSE)
