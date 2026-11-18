---
name: 'gh pr merge of a workflow-file change needs the workflow token scope, even with --admin'
description: 'gh pr merge of a workflow-file change needs the workflow token scope, even with --admin'
type: lesson
agent: nexus
created: 2026-11-18
reviewed: 2026-11-18
sources:
  - .github/workflows/major-tag.yml
---

## Compiled Truth

What happens: merging a PR that adds or changes a file under `.github/workflows/` with the gh CLI fails, even with `--admin`, with "refusing to allow an OAuth App to create or update workflow ... without `workflow` scope" unless the gh token has the workflow scope.
How we found out: merging the PR that added the major-tag workflow in the pnpm buildpack (work item #12747); this repo adds the same file.
What to do: run `gh auth refresh -h github.com -s workflow` (device-code login), then merge. This refreshes the stored gh login only; if GH_TOKEN or GITHUB_TOKEN supplies the token, that token itself needs the workflow scope.

## Links
<!-- relations: supersedes, contradicts, depends-on, refines, relates-to · provenance: EXTRACTED, INFERRED, AMBIGUOUS · see references/recall-and-capture-workflow.md -->


---

## Timeline

- 2026-11-18 | Created: gh pr merge of a workflow-file change needs the workflow token scope, even with --admin
