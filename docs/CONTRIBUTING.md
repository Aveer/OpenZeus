# Contributing to OpenZeus

Thanks for contributing. Keep changes small, documented, and tested against the OpenCode asset layout.

## Setup

```bash
git clone https://github.com/Aveer/OpenZeus.git
cd OpenZeus
npm install
./scripts/install.sh --all
openzeus validate --ci
```

Use `${OPENCODE_CONFIG_DIR:-~/.config/opencode}` for global OpenCode assets.

## Project Structure

| Path | Purpose |
|---|---|
| `agents/` | Agent definitions, including `OpenZeus.md` |
| `commands/` | Slash command templates |
| `skills/` | Zeus skill bundles (`skills/<name>/SKILL.md`) |
| `scripts/` | Install/sync/create/hook utilities |
| `docs/` | Contributor and publishing docs |
| `codemap.md` | Repository architecture map |

## Common Changes

Prefer guided workflows in user-facing docs and examples:

```bash
openzeus setup --plan --target .
openzeus validate --ci
openzeus doctor --fix-plan
openzeus diff --summary
```

Document `--plan`, `--dry-run`, `--fix-plan`, or `--ci` behavior before commands that write files or fail automation.

### Add a skill

```bash
mkdir -p skills/zeus-example
$EDITOR skills/zeus-example/SKILL.md
```

```markdown
---
name: zeus-example
description: Short purpose statement
---

# Zeus Example

## Usage

Concrete examples first.
```

Then update README skill listings and OpenZeus routing if the skill should be public.

### Add a command

```bash
$EDITOR commands/zeus-example.md
```

```markdown
---
description: What this command does
agent: OpenZeus
---

# Zeus Example

Workflow instructions.

**User's input**: $ARGUMENTS
```

### Add or update an agent

```bash
$EDITOR agents/Example.md
```

Use current OpenCode modes: `primary`, `subagent`, or `all`. Grant minimal permissions.

## Validate

```bash
npm test
openzeus validate --ci
openzeus validate --ci --project .
openzeus doctor --ci
openzeus diff --summary --ci
./scripts/sync-utils.sh status
```

For manual runtime testing:

```bash
./scripts/install.sh --core
openzeus list all
openzeus examples
openzeus setup --plan --recipe node --target /tmp/openzeus-smoke
openzeus setup --apply --recipe node --target /tmp/openzeus-smoke --dry-run
openzeus capture-command --name smoke --prompt 'Echo $ARGUMENTS' --target /tmp/openzeus-smoke/.opencode --dry-run
openzeus context init --target /tmp/openzeus-smoke --dry-run
opencode run "@OpenZeus help"
```

Use install profiles deliberately:

```bash
openzeus install --core --dry-run
openzeus install --extras --dry-run
openzeus install --all --dry-run
```

`doctor`, `diff`, and `upgrade` respect the saved `.openzeus-install-profile`.

## Sync

```bash
./scripts/sync-utils.sh status   # inspect
./scripts/sync-utils.sh push     # repo → config
./scripts/sync-utils.sh pull     # config → repo
./scripts/sync-utils.sh auto     # safe one-way sync or conflict refusal
```

CLI equivalents:

```bash
openzeus sync status
openzeus sync auto
```

## Commit Style

Use clear, imperative commit messages:

```text
docs(readme): update install flow
fix(commands): require push confirmation
feat(skills): add zeus-example skill
```

## Pull Requests

- Explain what changed and why.
- Include validation output.
- Note any sync or install behavior changes.
- Do not include secrets, generated caches, or unrelated formatting churn.

## License

Contributions are licensed under the MIT License.
