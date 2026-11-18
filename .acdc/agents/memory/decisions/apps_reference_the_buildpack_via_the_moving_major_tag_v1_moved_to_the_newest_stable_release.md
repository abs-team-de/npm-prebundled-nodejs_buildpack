---
name: 'Apps reference the buildpack via the moving major tag #v1, moved to the newest stable release'
description: 'Apps reference the buildpack via the moving major tag #v1, moved to the newest stable release'
type: decision
agent: nexus
created: 2026-11-18
reviewed: 2026-11-18
sources:
  - .github/workflows/major-tag.yml
  - README.md:34-39
---

## Compiled Truth

Decision: Apps reference the buildpack through the moving major tag `#v1`. The major-tag workflow moves it on every published non-prerelease release, always to the newest published stable release of that major, not to the release that triggered the run. Chosen by the maintainer (work item #12747), same as the pnpm buildpack.
Why: buildpack fixes (including the default Node range) reach every app on its next deploy or restage without a commit per app.
Rejected: each app pins an exact tag (e.g. `#v1.0.1`), because every buildpack fix then needed a commit in every app repository.
Accepted cost: a restage can pick up a new buildpack release. An exact tag pins only the buildpack; a reproducible Node also needs an exact engines.node.
Revisit when: apps need reproducible staging by default, or a breaking change needs a `v2` major.

## Links
<!-- relations: supersedes, contradicts, depends-on, refines, relates-to · provenance: EXTRACTED, INFERRED, AMBIGUOUS · see references/recall-and-capture-workflow.md -->
- relates-to: [default range 24.x](apps_without_engines_node_get_the_default_range_24_x_resolved_at_staging_not_a_pinned_version.md) (EXTRACTED)
- relates-to: [concurrency lesson](../lessons/concurrency_groups_keep_one_pending_run_reconcile_the_major_tag_to_the_newest_release_fetch_it_first.md) (EXTRACTED)
- relates-to: [[processes/release-workflow]] (EXTRACTED)

---

## Timeline

- 2026-11-18 | Created: Apps reference the buildpack via the moving major tag #v1, moved to the newest stable release
