# OpenZeus

**Master of OpenCode — Ruler of the OpenCode realm**

OpenZeus is an advanced AI agent for OpenCode that provides comprehensive system-level operations, documentation management, and autonomous configuration management. Built with extensive skills, agents, and commands for optimal OpenCode workflow orchestration.

![OpenZeus](./OpenZeus.png)

## Features

- **🏛️ Master Agent**: Comprehensive OpenCode knowledge and operation
- **🛠️ 14 Zeus Skills**: Specialized skill bundles for different domains
- **⚡ Smart Commands**: Custom commands for common workflows  
- **🔄 Bidirectional Sync**: Automatic sync between repo and OpenCode config
- **📚 Documentation Cache**: Offline OpenCode documentation access
- **🔧 Self-Optimization**: Continuous performance monitoring and improvement
- **🎯 Proactive Intelligence**: Auto-detection of user intent and skill loading

## Installation

### Option 1: NPM (Recommended)

```bash
# Install globally with npm
npm install -g openzeus

# Or with bun (when available)
bun install -g openzeus
```

### Option 2: Manual Installation

```bash
# Clone repository
git clone https://github.com/Aveer/OpenZeus.git
cd OpenZeus

# Run installer
./install.sh

# Setup git hooks (optional)
./setup-hooks.sh
```

## Quick Start

### 1. Set as Default Agent

Add to your `~/.config/opencode/opencode.json`:

```json
{
  "default_agent": "OpenZeus"
}
```

### 2. Use via @mention

```bash
@OpenZeus help me configure OpenCode for my project
@OpenZeus create a new skill for Docker management  
@OpenZeus show me system health and performance
```

### 3. Access Zeus Skills

Skills load automatically based on context:

```bash
@OpenZeus I need help with Docker containers
# → Automatically loads zeus-docker skill

@OpenZeus create a new agent for my project  
# → Loads zeus-agents + zeus-core skills
```

### 4. Use Zeus Commands

```bash
/zeus-kanban          # Project kanban board
/zeus-git-commit      # Smart git commit helper
/zeus-roadmap         # Generate project roadmap
```

## Usage Examples

### Agent Creation
```bash
@OpenZeus create a new agent called "DataAnalyst" that specializes in SQL queries and data visualization

# → Creates agent with proper permissions and skills
# → Available immediately in OpenCode
```

### Skill Creation  
```bash
@OpenZeus create a skill for AWS management with EC2, S3, and Lambda operations

# → Creates zeus-aws skill bundle
# → Adds to OpenZeus skill loading guide automatically
```

### System Health
```bash
@OpenZeus check your system health and performance

# → Loads zeus-self skill
# → Runs comprehensive diagnostics
# → Reports configuration, capabilities, context health
```

### Docker Management
```bash
@OpenZeus help me containerize this Node.js application

# → Auto-loads zeus-docker skill
# → Creates Dockerfile, docker-compose.yml
# → Provides deployment instructions
```

### OpenCode Configuration
```bash
@OpenZeus configure OpenCode for my React project with TypeScript

# → Loads zeus-core skill
# → Sets up proper model, permissions, tools
# → Configures project-specific settings
```

## Development

### Testing Package Installation

```bash
# Test installation locally
npm pack
npm install -g openzeus-1.0.3.tgz

# Verify OpenZeus is available
@OpenZeus self
```

### Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/my-feature`
3. Make changes and test thoroughly
4. Run sync: `./sync-utils.sh push`
5. Commit: `git commit -am 'Add my feature'`
6. Push: `git push origin feature/my-feature`
7. Create Pull Request

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| `OpenZeus not available` | Run `npm install -g openzeus` and restart OpenCode |
| `Skills not loading` | Restart OpenCode or check `~/.config/opencode/skills/zeus-*` |
| `Config not found` | Install OpenCode first: https://opencode.ai/docs/ |
| `@OpenZeus not responding` | Add `"default_agent": "OpenZeus"` to `opencode.json` |

## License

MIT License - see LICENSE file for details.

## Links

- **Repository**: https://github.com/Aveer/OpenZeus
- **Issues**: https://github.com/Aveer/OpenZeus/issues  
- **OpenCode Docs**: https://opencode.ai/docs/
- **NPM Package**: https://npmjs.com/package/openzeus

---

**🏛️ Welcome to the realm of OpenZeus!**

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

- **Repository**: [GitHub.com/Aveer/OpenZeus](https://github.com/Aveer/OpenZeus)
- **Documentation**: Check `docs/` directory
- **Issues**: [GitHub Issues](https://github.com/Aveer/OpenZeus/issues)
- **Discussions**: OpenCode Discord community

---

*OpenZeus - Where AI meets system mastery* ⚡