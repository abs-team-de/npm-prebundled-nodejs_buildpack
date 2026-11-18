# decisions
- [Apps without engines.node get the default range 24.x, resolved at staging, not a pinned version](decisions/apps_without_engines_node_get_the_default_range_24_x_resolved_at_staging_not_a_pinned_version.md)
- [Apps reference the buildpack via the moving major tag #v1, moved to the newest stable release](decisions/apps_reference_the_buildpack_via_the_moving_major_tag_v1_moved_to_the_newest_stable_release.md)
- [Detect requires only package.json and node_modules, no lockfile or pnpm check](decisions/detect_requires_only_package_json_and_node_modules_no_lockfile_or_pnpm_check.md)
- [Finalize allows in-tree node_modules symlinks, fails dangling or out-of-tree ones](decisions/finalize_allows_in_tree_node_modules_symlinks_fails_dangling_or_out_of_tree_ones.md)
- [Staging is prebundled only: no npm ci at staging, no mode switch](decisions/staging_is_prebundled_only_no_npm_ci_at_staging_no_mode_switch.md)

# lessons
- [Concurrency groups keep one pending run: reconcile the major tag to the newest release, fetch it first](lessons/concurrency_groups_keep_one_pending_run_reconcile_the_major_tag_to_the_newest_release_fetch_it_first.md)
- [gh pr merge of a workflow-file change needs the workflow token scope, even with --admin](lessons/gh_pr_merge_of_a_workflow_file_change_needs_the_workflow_token_scope_even_with_admin.md)
- [In cflinuxfs images /app is a symlink: copy with cp -a /app/. not cp -a /app](lessons/in_cflinuxfs_images_app_is_a_symlink_copy_its_contents_not_the_link.md)
