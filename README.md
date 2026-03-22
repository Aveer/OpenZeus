# OpenZeus

**Master of OpenCode — Ruler of the OpenCode realm**

OpenZeus is an advanced AI agent for OpenCode that provides comprehensive system-level operations, documentation management, and autonomous configuration management. Built with extensive skills, agents, and commands for optimal OpenCode workflow orchestration.

![OpenZeus](./OpenZeus.png)

## Features

- **🏛️ Master Agent**: Comprehensive OpenCode knowledge and operation
- **🛠️ 15 Zeus Skills**: Specialized skill bundles for different domains
- **⚡ Smart Commands**: Custom commands for common workflows  
- **📚 Documentation Cache**: Offline OpenCode documentation access
- **🔧 Self-Optimization**: Continuous performance monitoring and improvement
- **🎯 Proactive Intelligence**: Auto-detection of user intent and skill loading

## Project Structure

```
OpenZeus/
├── agents/              # Agent definitions
│   └── OpenZeus.md     # Main OpenZeus agent
├── commands/           # Custom commands  
│   ├── zeus-kanban.md
│   ├── zeus-git-commit.md
│   └── zeus-roadmap.md
├── skills/             # Zeus skill bundles
│   ├── zeus-core/      # Core OpenCode knowledge
│   ├── zeus-agents/    # Agent creation workflows
│   ├── zeus-commands/  # Command creation workflows
│   ├── zeus-skills/    # Skill creation workflows
│   ├── zeus-context/   # Context management
│   ├── zeus-self/      # Self-diagnostics
│   └── ... (15 total)
├── docs/               # Documentation
│   ├── docs-cache/     # Cached OpenCode documentation
│   └── zeus-maintenance.md
├── prompts/            # System prompts
│   └── openzeus.txt
└── README.md          # This file
```

## Installation

### Manual Installation

1. Copy the OpenZeus agent to your OpenCode agents directory:
```bash
cp agents/OpenZeus.md ~/.config/opencode/agents/
```

2. Copy Zeus skills to your skills directory:
```bash
cp -r skills/zeus-* ~/.config/opencode/skills/
```

3. Copy commands (optional):
```bash
cp commands/zeus-*.md ~/.config/opencode/commands/
```

### Automated Installation

```bash
# Coming soon: installation script
./install.sh
```

## Usage

### As Primary Agent

Use OpenZeus as your main agent by adding to your `opencode.json`:

```json
{
  "default_agent": "OpenZeus"
}
```

### Via @mention

Invoke OpenZeus in any conversation:
```
@OpenZeus help me configure my OpenCode setup
```

### Key Capabilities

- **System Configuration**: Expert OpenCode config management
- **Agent Creation**: Generate custom agents with proper templates
- **Command Creation**: Create slash commands for workflows
- **Skill Management**: Create and manage skill bundles
- **Performance Monitoring**: Session diagnostics and optimization
- **Documentation**: Instant access to OpenCode docs (cached)

## Zeus Skills Overview

| Skill | Purpose |
|-------|---------|
| **zeus-core** | Exhaustive OpenCode knowledge reference |
| **zeus-agents** | Agent creation templates and workflows |
| **zeus-commands** | Custom command creation patterns |
| **zeus-skills** | Skill bundle creation guide |
| **zeus-context** | Context management and compression |
| **zeus-self** | Runtime diagnostics and self-optimization |
| **zeus-docker** | Docker and containerization expertise |
| **zeus-swarm** | Multi-agent orchestration |
| **zeus-llm** | Local model setup and configuration |
| **zeus-omo** | oh-my-opencode-slim integration |
| **zeus-beads** | Beads task tracking workflows |
| **zeus-sql** | Database and SQL operations |
| **zeus-oac** | OpenCode ecosystem integration |
| **zeus-upskill** | Self-improvement and skill expansion |

## Configuration

OpenZeus automatically loads appropriate skills based on user intent. Key trigger patterns:

- **"config", "opencode.json"** → zeus-core
- **"create agent"** → zeus-agents + zeus-core  
- **"create command"** → zeus-commands + zeus-core
- **"docker", "container"** → zeus-docker + zeus-core
- **"analyze self", "optimize"** → zeus-self + zeus-context

## Development

### Adding New Skills

1. Create skill in `skills/zeus-[name]/SKILL.md`
2. Update OpenZeus.md skill loading guide
3. Add trigger keywords to behavior rules

### Contributing

1. Fork the repository
2. Create feature branch
3. Add skills, commands, or enhancements
4. Test with OpenCode
5. Submit pull request

## License

MIT License - see LICENSE file for details

## Support

- **Documentation**: Check `docs/` directory
- **Issues**: GitHub Issues
- **Discussions**: OpenCode Discord community

---

*OpenZeus - Where AI meets system mastery* ⚡