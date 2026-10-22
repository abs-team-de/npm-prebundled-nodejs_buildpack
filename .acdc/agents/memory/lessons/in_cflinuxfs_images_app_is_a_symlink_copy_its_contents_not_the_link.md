---
name: 'In cflinuxfs images /app is a symlink: copy with cp -a /app/. not cp -a /app'
description: 'In cflinuxfs images /app is a symlink: copy with cp -a /app/. not cp -a /app'
type: lesson
agent: nexus
created: 2026-10-22
reviewed: 2026-10-22
sources: ["v1.0.0 acceptance run in cloudfoundry/cflinuxfs5, e2e staging script outside the repo, 2026-10-22"]
---

## Compiled Truth

What happens: In the cloudfoundry/cflinuxfs4 and cflinuxfs5 docker images, /app is a symlink to /home/vcap/app. If you mount an app with `-v ...:/app`, `cp -a /app dest` copies the symlink, not the app. The next write then fails with "Read-only file system".
How we found out: During the v1.0.0 acceptance run in cloudfoundry/cflinuxfs5, the copy produced `$W/build -> /home/vcap/app` (a symlink). Docker had put the read-only bind mount at /home/vcap/app, so supply's `mkdir $BUILD_DIR/.profile.d` and the package.json rewrite failed with "Read-only file system". `ls -la` showed the copied symlink, and `mount` showed the mount at /home/vcap/app.
What to do: Copy with `cp -a /app/. dest` (or use /home/vcap/app) in any staging run inside those images.

## Links
<!-- relations: supersedes, contradicts, depends-on, refines, relates-to · provenance: EXTRACTED, INFERRED, AMBIGUOUS · see references/recall-and-capture-workflow.md -->

---

## Timeline

- 2026-10-22 | Created: In cflinuxfs images /app is a symlink: copy with cp -a /app/. not cp -a /app
