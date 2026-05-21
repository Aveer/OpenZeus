# Publishing OpenZeus

OpenZeus publishes the `openzeus` npm package. Current package version: **1.1.0**.

## Preflight

```bash
npm test
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
```

Update release notes in `docs/CHANGELOG.md` when cutting a release.
