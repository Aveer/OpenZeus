# Contributing to OpenZeus

Thanks for contributing. Keep changes small, documented, and tested against the OpenCode asset layout.

## Setup

```bash
git clone https://github.com/Aveer/OpenZeus.git
cd OpenZeus
npm install
./scripts/install.sh
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
./scripts/sync-utils.sh status
```

For manual runtime testing:

```bash
./scripts/install.sh
opencode run "@OpenZeus help"
```

## Sync

```bash
./scripts/sync-utils.sh status   # inspect
./scripts/sync-utils.sh push     # repo → config
./scripts/sync-utils.sh pull     # config → repo
./scripts/sync-utils.sh auto     # safe one-way sync or conflict refusal
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
