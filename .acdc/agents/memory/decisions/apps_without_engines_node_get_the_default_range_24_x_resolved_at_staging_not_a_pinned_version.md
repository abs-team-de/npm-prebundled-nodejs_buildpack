---
name: 'Apps without engines.node get the default range 24.x, resolved at staging, not a pinned version'
description: 'Apps without engines.node get the default range 24.x, resolved at staging, not a pinned version'
type: decision
agent: nexus
created: 2026-11-18
reviewed: 2026-11-18
sources:
  - lib/utils.sh:62-108
  - bin/supply:29-32
  - README.md
---

## Compiled Truth

Decision: An app without engines.node, or with a bare operator such as `>=`, gets the default range `24.x` (NODE_DEFAULT_RANGE), resolved at staging via nodejs.org to the newest Node.js 24 release. Maintainer, work item #12747, same as the pnpm buildpack.
Why: in the November 2026 security release the pinned-default bump to 24.22.3 was merged but never released, so apps stayed unpatched.
Rejected: a pinned default version bumped per Node.js security release, because each bump needs a buildpack release before any app gets the patch.
Accepted cost: unless NODE_OVERRIDE_VERSION is set, staging fetches nodejs.org/dist/index.json even for apps without engines.node; the Node version can change on a plain restage.
Revisit when: Node.js 24 reaches end of life (April 2028); the default range must then move to the next LTS major through a buildpack release.

## Links
<!-- relations: supersedes, contradicts, depends-on, refines, relates-to · provenance: EXTRACTED, INFERRED, AMBIGUOUS · see references/recall-and-capture-workflow.md -->
- relates-to: [moving major tag #v1](apps_reference_the_buildpack_via_the_moving_major_tag_v1_moved_to_the_newest_stable_release.md) (EXTRACTED)

---

## Timeline

- 2026-11-18 | Created: Apps without engines.node get the default range 24.x, resolved at staging, not a pinned version
