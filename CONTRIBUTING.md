# Contributing

Thank you for your interest in contributing to the npm-prebundled-nodejs_buildpack.

## Getting Started

1. Fork the repository
2. Clone your fork
3. Create a feature branch from `master`

## Branching Strategy

- `master` is protected and requires pull requests with at least 1 approval
- Create feature branches for all changes:

```bash
git checkout -b feat/my-feature master
```

### Branch naming convention

- `feat/description` — New features
- `fix/description` — Bug fixes
- `docs/description` — Documentation changes
- `refactor/description` — Code restructuring

## Commit Messages

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
type(scope): description #<WorkItemId>
```

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Examples:**

```
feat(finalize): report dangling symlinks #1234
fix(supply): handle missing engines.node #1234
docs(readme): add configuration examples #1234
```

## Pull Request Process

1. Ensure your branch is up to date with `master`
2. Write clear commit messages following the convention above
3. Open a pull request with:
   - A descriptive title
   - Summary of changes
   - Test plan describing how to verify the changes
4. Wait for at least 1 approval before merging

## Code of Conduct

- Be respectful and constructive in discussions
- Focus on the technical merit of contributions
- Welcome newcomers and help them get started

## License

By contributing, you agree that your contributions will be licensed under the [Apache License 2.0](LICENSE).
