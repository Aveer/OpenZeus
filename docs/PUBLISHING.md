# Publishing OpenZeus

OpenZeus publishes the `openzeus` npm package. Current package version: **1.1.0**.

## Preflight

```bash
npm test
openzeus validate --ci
openzeus doctor --ci
openzeus diff --summary --ci
npm pack --dry-run
```

Confirm the package includes the expected assets:

- `bin/openzeus`
- `agents/`
- `commands/`
- `docs/`
- `skills/`
- `scripts/`
- `tests/`

## Local Package Test

```bash
npm pack
npm install -g ./openzeus-1.1.0.tgz
openzeus help
openzeus install --core --dry-run
openzeus install --all --dry-run
openzeus setup --plan --recipe node --target /tmp/openzeus-publish-smoke
openzeus validate --ci
openzeus doctor --fix-plan
openzeus diff --summary
```

## Publish

Publishing mutates the npm registry. Do it only from a clean worktree and with explicit maintainer approval.

```bash
npm login
npm publish
```

## After Publish

```bash
npm view openzeus version
npm install -g openzeus
openzeus help
openzeus validate --ci
```

Update release notes in `docs/CHANGELOG.md` when cutting a release.
