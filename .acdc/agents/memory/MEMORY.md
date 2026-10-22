# decisions
- [Detect requires only package.json and node_modules, no lockfile or pnpm check](decisions/detect_requires_only_package_json_and_node_modules_no_lockfile_or_pnpm_check.md)
- [Finalize allows in-tree node_modules symlinks, fails dangling or out-of-tree ones](decisions/finalize_allows_in_tree_node_modules_symlinks_fails_dangling_or_out_of_tree_ones.md)
- [Staging is prebundled only: no npm ci at staging, no mode switch](decisions/staging_is_prebundled_only_no_npm_ci_at_staging_no_mode_switch.md)

# lessons
- [In cflinuxfs images /app is a symlink: copy with cp -a /app/. not cp -a /app](lessons/in_cflinuxfs_images_app_is_a_symlink_copy_its_contents_not_the_link.md)
