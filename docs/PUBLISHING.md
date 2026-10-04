# Publishing OpenZeus

OpenZeus publishes the `openzeus` npm package.

Stable public baseline: **1.2.0**. The OpenZeus 2 refocus is currently
unreleased and contains breaking surface changes.

## Preconditions

Do not publish from a refocus branch until the release/version decision is
explicitly approved.

The release commit must have green CI for the exact SHA.

## Preflight

Use Node **22.19+** for the package toolchain.

```bash
npm install --ignore-scripts --no-audit --no-fund
npm test
node tests/plugin.mjs
./bin/openzeus validate --ci
npm pack --dry-run
npm publish --dry-run
```

Expected package contents include:

- `src/plugin.js` — native OpenCode V2 plugin entrypoint;
- `agents/OpenZeus.md` — transitional agent bootstrap;
- `skills/` — five focused skills loaded by the plugin;
- `bin/openzeus` — extensionless npm CLI executable;
- `scripts/audit.mjs`;
- `scripts/inspect.mjs`;
- `scripts/migrate.mjs`;
- `scripts/create-utils.sh`;
- `scripts/install-agent.sh`;
- `scripts/validate.sh`;
- `README.md`;
- `LICENSE`;
- `package.json`.

Do not ship `.beads/`, local config, credentials, tests, or contributor-only
state.

## Local package smoke test

After `npm pack`, install the generated tarball into an isolated prefix or
test environment.

At minimum verify:

```bash
openzeus help
openzeus audit --help
openzeus inspect --help
openzeus migrate --help
openzeus validate --ci

export OPENCODE_CONFIG_DIR="$(mktemp -d)"
openzeus install-agent
cmp agents/OpenZeus.md "$OPENCODE_CONFIG_DIR/agents/OpenZeus.md"
```

The native plugin entrypoint is covered independently by
`node tests/plugin.mjs` against the real `@opencode/plugin` dependency.

## Publish

Publishing mutates the npm registry. Require explicit maintainer authorization.

```bash
npm whoami
npm publish
npm view openzeus version
```

## OpenCode runtime verification

Only after the new npm version is confirmed live:

```bash
opencode plugin add openzeus
opencode plugin list
openzeus install-agent
```

Start OpenCode and verify that:

- the five `zeus-*` skills are present;
- the `openzeus_runtime` tool is available to the OpenZeus agent;
- `@OpenZeus` loads from the bootstrapped agent file;
- a simple live-runtime query returns safe inventory without raw prompts,
  skill bodies, command templates, plugin options, or credentials.

## Release metadata

After registry verification:

1. create a tag pointing exactly at the green release commit;
2. create the matching GitHub Release;
3. verify npm latest, tag, release and CI all point to the intended version;
4. update `docs/CHANGELOG.md`.
