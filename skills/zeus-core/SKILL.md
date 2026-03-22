---
name: zeus-core
description: Exhaustive OpenCode knowledge reference. Config paths, schema, URL mappings, built-in agents/commands, troubleshooting, and authoritative answers about OpenCode internals.
---

---

## Path Reference — OpenCode Config Directory

### Global Config Root: `~/.config/opencode/`

| File / Directory | Purpose |
|---|---|
| `opencode.json` | Main user config: providers, models, agents, plugins, commands, runtime options |
| `opencode.json.bak` | Backup of main config |
| `opencode.jsonc` | Same as `.json` but supports comments |
| `tui.json` | TUI-specific settings: theme, keybinds, scroll speed |
| `agent_hive.json` | Agent hive state (local registration/metadata for hive features) |
| `oh-my-opencode-slim.json` | oh-my-opencode-slim integration config |
| `agents/` | Custom agent definitions (`.md` markdown files) |
| `commands/` | Custom command templates (`.md` markdown files) |
| `skills/` | Local agent skill bundles (`.md` + supporting files) |
| `plugins/` | Custom plugin files |

### Per-Project Config Root: `<repo>/.opencode/`

| File / Directory | Purpose |
|---|---|
| `agents/` | Project-specific agent definitions |
| `commands/` | Project-specific command templates |
| `skills/` | Project-specific skills |
| `plugins/` | Project-specific plugins |

---

## Config Precedence (later overrides earlier)

1. Remote (`/.well-known/opencode`) — organizational defaults
2. Global (`~/.config/opencode/`) — user preferences
3. Custom env (`OPENCODE_CONFIG`) — runtime overrides
4. Project (`.opencode/`) — project-specific settings
5. Inline env (`OPENCODE_CONFIG_CONTENT`) — runtime overrides

Config files are **merged**, not replaced. Non-conflicting keys from all configs are preserved.

---

## Complete URL Reference

### OpenCode Core Docs

| Topic | URL |
|---|---|
| Config schema | https://opencode.ai/docs/config/ |
| Agents | https://opencode.ai/docs/agents/ |
| Commands | https://opencode.ai/docs/commands/ |
| Tools | https://opencode.ai/docs/tools/ |
| Permissions | https://opencode.ai/docs/permissions/ |
| Skills | https://opencode.ai/docs/skills/ |
| Plugins | https://opencode.ai/docs/plugins/ |
| Models | https://opencode.ai/docs/models/ |
| Providers | https://opencode.ai/docs/providers/ |
| MCP servers | https://opencode.ai/docs/mcp-servers/ |
| LSP servers | https://opencode.ai/docs/lsp/ |
| Themes | https://opencode.ai/docs/themes/ |
| Keybinds | https://opencode.ai/docs/keybinds/ |
| TUI | https://opencode.ai/docs/tui/ |
| CLI | https://opencode.ai/docs/cli/ |
| Rules | https://opencode.ai/docs/rules/ |
| Enterprise | https://opencode.ai/docs/enterprise/ |
| Troubleshooting | https://opencode.ai/docs/troubleshooting/ |
| Windows/WSL | https://opencode.ai/docs/windows-wsl |

### OpenCode Integrations

| Topic | URL |
|---|---|
| GitHub | https://opencode.ai/docs/github/ |
| GitLab | https://opencode.ai/docs/gitlab/ |
| Share | https://opencode.ai/docs/share/ |

### Topic → URL Mapping (for proactive fetching)

| Keyword(s) | Fetch this URL |
|---|---|
| `agent`, `subagent`, `primary`, `@mention` | https://opencode.ai/docs/agents/ |
| `command`, `/`, custom command | https://opencode.ai/docs/commands/ |
| `permission`, `allow`, `deny`, `ask` | https://opencode.ai/docs/permissions/ |
| `skill`, `bundle` | https://opencode.ai/docs/skills/ |
| `config`, `json`, `opencode.json` | https://opencode.ai/docs/config/ |
| `model`, `provider`, `llama-swap` | https://opencode.ai/docs/models/ |
| `tool`, `edit`, `write`, `bash` | https://opencode.ai/docs/tools/ |
| `plugin` | https://opencode.ai/docs/plugins/ |
| `mcp`, `server` | https://opencode.ai/docs/mcp-servers/ |
| `lsp`, `diagnostic` | https://opencode.ai/docs/lsp/ |
| `theme`, `color` | https://opencode.ai/docs/themes/ |
| `keybind`, `shortcut` | https://opencode.ai/docs/keybinds/ |
| `tui`, `terminal` | https://opencode.ai/docs/tui/ |
| `cli`, `command line` | https://opencode.ai/docs/cli/ |
| `rule`, `instruction` | https://opencode.ai/docs/rules/ |
| `github`, `gitlab` | https://opencode.ai/docs/github/ or /gitlab/ |
| `share` | https://opencode.ai/docs/share/ |
| `troubleshoot`, `error`, `bug` | https://opencode.ai/docs/troubleshooting/ |

---

## Config File Format Reference

### JSON vs JSONC

| Format | Supports comments | Extension |
|---|---|---|
| JSON | No | `.json` |
| JSONC | Yes | `.jsonc` |

JSONC example:
```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  // This is a comment
  "model": "opencode-go/big-pickle",
  "plugin": ["oh-my-opencode-slim"]
}
```

### Variable Substitution

```json
{
  "model": "{env:OPENCODE_MODEL}",
  "apiKey": "{env:ANTHROPIC_API_KEY}",
  "instructions": ["{file:./custom-instructions.md}"]
}
```

- `{env:VAR_NAME}` — substitute environment variable
- `{file:path}` — substitute file contents

---

## Agent Config Schema

```json
{
  "agent": {
    "my-agent": {
      "description": "What this agent does (required)",
      "mode": "subagent",        // primary | subagent | all
      "model": "provider/model",  // optional override
      "steps": 20,               // max iterations
      "temperature": 0.1,        // 0.0-1.0
      "hidden": false,           // hide from @ autocomplete
      "permission": {
        "edit": "allow",
        "write": "allow",
        "webfetch": "allow",
        "bash": {
          "*": "ask",
          "git status *": "allow"
        }
      },
      "aliases": ["short", "alias"],
      "display_name": "My Agent"
    }
  }
}
```

---

## Command Config Schema

```json
{
  "command": {
    "my-command": {
      "template": "Prompt template body...",
      "description": "What this command does (required)",
      "agent": "general",
      "model": "provider/model",
      "subtask": false
    }
  }
}
```

---

## Schema Validation Command

```bash
# Validate JSON syntax
python3 -c "import json; json.load(open('/path/to/config.json')); print('Valid')"

# Validate with schema
python3 -c "import json, jsonschema; data=json.load(open('opencode.json')); jsonschema.validate(data, open('https://opencode.ai/config.json'))"
```

---

## Common Troubleshooting Commands

| Problem | Fix |
|---|---|
| Config not loading | Check file path: `~/.config/opencode/opencode.json` |
| JSON invalid | Run: `python3 -c "import json; json.load(open('/path'))"` |
| Agent not appearing | Restart OpenCode or run `opencode agent reload` |
| Command not found | Check file is in `commands/` with `.md` extension |
| Changes not applied | Configs merge at runtime; restart OpenCode |
| Permission denied | Check `permission` settings in agent config |

---

## Built-in Agents

| Agent | Mode | Description |
|---|---|---|
| `build` | primary | Default development agent, all tools enabled |
| `plan` | primary | Restricted agent for analysis, asks before changes |
| `general` | subagent | General-purpose subagent, full tool access |
| `explore` | subagent | Fast read-only codebase explorer |
| `compaction` | primary | Hidden: context compaction agent |
| `title` | primary | Hidden: session title generator |
| `summary` | primary | Hidden: session summarizer |

---

## Built-in Commands

| Command | Description |
|---|---|
| `/init` | Initialize a project |
| `/undo` | Undo last change |
| `/redo` | Redo last undone change |
| `/share` | Share conversation |
| `/help` | Show help |

---

End of skill.
