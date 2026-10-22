---
name: 'Staging is prebundled only: no npm ci at staging, no mode switch'
description: 'Staging is prebundled only: no npm ci at staging, no mode switch'
type: decision
agent: nexus
created: 2026-10-22
reviewed: 2026-10-22
sources: [README.md, bin/supply, bin/finalize]
---

## Compiled Truth

Decision: Prebundled only. CI runs `npm ci --omit=dev`, the MTAR ships node_modules, staging installs nothing.
Why: Staging on SAP BTP then needs no npm registry access and no package-lock.json in the module dir. Avoiding those is why this buildpack exists instead of the standard nodejs-buildpack.
Rejected: `npm ci --omit=dev` at staging because it needs registry access from BTP staging and a lockfile in the module dir, and it is close to the standard nodejs-buildpack; both modes behind an env-var switch because it adds code and tests with no stated need.
Revisit when: a consumer has a concrete need for staging-time installs.

## Links
<!-- relations: supersedes, contradicts, depends-on, refines, relates-to · provenance: EXTRACTED, INFERRED, AMBIGUOUS · see references/recall-and-capture-workflow.md -->

---

## Timeline

- 2026-10-22 | Created: Staging is prebundled only: no npm ci at staging, no mode switch
