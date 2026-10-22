---
title: 'Release the buildpack'
description: 'How to cut and publish a tagged release of this buildpack'
type: process
sources:
  - CHANGELOG.md
  - README.md
  - .github/workflows/ci.yml
  - "release of v1.0.0, matching the pnpm buildpack's convention"
updated: 2026-10-22
confidence: medium
---

## Summary

SAP BTP consumes this buildpack by git URL plus tag (`...npm-prebundled-nodejs_buildpack.git#vX.Y.Z`), so a release is an annotated tag on master plus a GitHub Release. CONTRIBUTING.md and README.md do not describe the process; this page does. It follows the pnpm buildpack's convention.

## Steps

1. **Prepare the change.**
   - Add a section to `CHANGELOG.md` by hand (Keep a Changelog): `## [X.Y.Z](<compare link>) - YYYY-MM-DD`.
   - Bump the `#vX.Y.Z` tag in README.md's mta.yaml usage example. It pins the tag, so forgetting it leaves the docs pointing at the old release.
2. **Merge to master** through a PR with 1 approving review (master is protected). Commits follow `type(scope): description #<AzureDevOpsWorkItemId>`.
3. **Stage end to end before tagging**, inside the `cloudfoundry/cflinuxfs5` image: detect, supply, finalize, release, then start the app via `.profile.d`.
   - Use an app built with `npm ci --omit=dev`.
   - Check that `engines.node` `^24.0.0`, `22` and empty resolve to the expected versions, and that `>=18 <21` fails before any download.
   - Wait for CI to pass on all three jobs (ubuntu-latest, cflinuxfs4, cflinuxfs5), see `.github/workflows/ci.yml`.
4. **Tag and publish.**
   - Create an annotated tag `vX.Y.Z` on the master commit and push it.
   - Create the GitHub Release with that version's CHANGELOG section as notes: `gh release create vX.Y.Z --notes-file <section file> --verify-tag`.
5. **Confirm reachability.** BTP fetches the buildpack anonymously, so the repository must stay public. Check: `git ls-remote https://github.com/abs-team-de/npm-prebundled-nodejs_buildpack.git refs/tags/vX.Y.Z`.

## Links

- `CHANGELOG.md`, `README.md` (mta.yaml example)
