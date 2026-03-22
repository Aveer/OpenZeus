---
name: zeus-omo
description: Deep reference for oh-my-opencode-slim plugin: installation, configuration, cartography, tmux integration, and provider mappings.
---

**🔗 oh-my-opencode-slim Repository**: https://github.com/opencodetips/oh-my-opencode-slim

---

## oh-my-opencode-slim Overview

oh-my-opencode-slim is an OpenCode plugin that provides enhanced capabilities including:
- Provider configurations and model mappings
- Cartography (codebase understanding and mapping)
- tmux integration for session management
- Quick reference tools

---

## Installation

```bash
# Via npm
npm install -g oh-my-opencode-slim

# Or via pip
pip install oh-my-opencode-slim

# Verify installation
opencode --version
```

---

## Configuration File

The main config file is at: `~/.config/opencode/oh-my-opencode-slim.json`

```json
{
  "providerMappings": {
    "default": "llama-swap",
    "fast": "ollama",
    "power": "openai"
  },
  "cartography": {
    "enabled": true,
    "cacheDir": "~/.cache/oh-my-opencode-slim"
  },
  "tmux": {
    "enabled": false,
    "sessionName": "opencode"
  }
}
```

---

## Provider Configurations

### llama-swap Provider

```json
{
  "provider": {
    "llama-swap": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "llama-swap (local)",
      "options": {
        "baseURL": "http://localhost:5000/v1",
        "apiKey": "not-required"
      },
      "models": {
        "Qwen3.5-27B-Claude-Q4": {
          "name": "Qwen3.5-27B Claude Q4",
          "family": "qwen",
          "attachment": true,
          "tool_call": true,
          "reasoning": true,
          "limit": {
            "context": 196608,
            "output": 32768
          }
        }
      }
    }
  }
}
```

### Ollama Provider

```json
{
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama",
      "options": {
        "baseURL": "http://localhost:11434/v1",
        "apiKey": "not-required"
      },
      "models": {
        "llama3.2:1b": {
          "name": "LLaMA 3.2 1B",
          "family": "llama",
          "attachment": true,
          "tool_call": false
        }
      }
    }
  }
}
```

### OpenAI-Compatible Provider

```json
{
  "provider": {
    "openai-compatible": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Custom OpenAI-compatible",
      "options": {
        "baseURL": "https://api.example.com/v1",
        "apiKey": "{env:API_KEY}"
      },
      "models": {
        "my-model": {
          "name": "My Model",
          "family": "custom",
          "attachment": true,
          "tool_call": true
        }
      }
    }
  }
}
```

---

## Cartography

Cartography provides codebase understanding and hierarchical mapping.

### Enabling Cartography

```json
{
  "cartography": {
    "enabled": true,
    "depth": 3,
    "exclude": ["node_modules/**", "dist/**", ".git/**"]
  }
}
```

### Using Cartography

```bash
# Generate codemap
opencode cartography

# View specific directory
opencode cartography src/

# Export to file
opencode cartography --output codemap.md
```

### Cartography Output Format

```markdown
# Project Codemap

## src/
├── components/     # UI components
│   ├── Button.tsx
│   └── Modal.tsx
├── hooks/         # Custom React hooks
│   └── useAuth.ts
└── utils/         # Utility functions
    └── format.ts

## tests/
├── unit/
└── integration/
```

---

## tmux Integration

### Enable tmux Integration

```json
{
  "tmux": {
    "enabled": true,
    "sessionName": "opencode",
    "attachOnCreate": true
  }
}
```

### tmux Commands

```bash
# Start new session
tmux new -s opencode

# Attach to session
tmux attach -t opencode

# List sessions
tmux ls

# Detach from session
# Press: Ctrl+b, d
```

### Workflow with tmux

```
1. Create tmux session: tmux new -s work
2. Run opencode in tmux window 1
3. Run other tools in window 2+
4. Detach (Ctrl+b, d) to leave running
5. Reattach later: tmux attach -t work
```

---

## Quick Reference Commands

### Provider Switching

```bash
# Switch active provider
opencode provider set llama-swap

# List available providers
opencode provider list

# Show current provider
opencode provider show
```

### Model Switching

```bash
# Switch model
opencode model set qwen-7b

# List available models
opencode model list

# Show current model
opencode model show
```

---

## Troubleshooting

| Problem | Solution |
|---|---|
| Plugin not loading | Check plugin is in `opencode.json`: `"plugin": ["oh-my-opencode-slim"]` |
| Cartography slow | Exclude large directories in config |
| tmux not working | Ensure tmux is installed: `apt install tmux` |
| Provider not found | Verify baseURL is correct and server is running |
| Model not available | Pull model with provider's CLI (e.g., `ollama pull`) |

---

## Relevant URLs

| Resource | URL |
|---|---|
| oh-my-opencode-slim main | https://github.com/alvinunreal/oh-my-opencode-slim |
| Cartography docs | https://github.com/alvinunreal/oh-my-opencode-slim/blob/master/docs/cartography.md |
| Installation | https://github.com/alvinunreal/oh-my-opencode-slim/blob/master/docs/installation.md |
| Provider config | https://github.com/alvinunreal/oh-my-opencode-slim/blob/master/docs/provider-configurations.md |
| Quick reference | https://github.com/alvinunreal/oh-my-opencode-slim/blob/master/docs/quick-reference.md |
| tmux integration | https://github.com/alvinunreal/oh-my-opencode-slim/blob/master/docs/tmux-integration.md |

---

End of skill.
