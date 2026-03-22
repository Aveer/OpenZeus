# Changelog

All notable changes to OpenZeus will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-03-22

### Added
- **Core OpenZeus Agent**: Master agent for comprehensive OpenCode operations
- **14 Zeus Skills**: Specialized skill bundles covering all OpenCode domains
  - `zeus-core`: Exhaustive OpenCode knowledge reference
  - `zeus-agents`: Agent creation templates and workflows
  - `zeus-commands`: Custom command creation utilities  
  - `zeus-skills`: Skill creation workflows
  - `zeus-upskill`: Self-improvement and skill registration
  - `zeus-context`: Context management and optimization
  - `zeus-self`: Runtime introspection and diagnostics
  - `zeus-swarm`: Multi-agent orchestration capabilities
  - `zeus-docker`: Docker and containerization expertise
  - `zeus-sql`: Database and SQL operation guides
  - `zeus-llm`: Local LLM setup (llama.cpp, Ollama)
  - `zeus-omo`: oh-my-opencode-slim integration
  - `zeus-beads`: Beads issue tracking integration
  - `zeus-oac`: OpenAgentsControl integration

- **Bidirectional Sync System**: Automatic sync between OpenZeus repository and OpenCode config
  - `sync-utils.sh`: Comprehensive sync management utilities
  - Auto-detection of OpenZeus repository location
  - Smart timestamp-based sync direction detection
  - Status checking with file comparison
  - Selective sync for zeus-* namespaced items

- **Context-Aware Creation**: Intelligent location detection for new agents/skills/commands
  - `create-utils.sh`: Context-aware creation utilities
  - Automatic OpenZeus repo detection across filesystem
  - User choice prompts with repo vs config options
  - Auto-sync integration after creation
  - Non-interactive flags for automation

- **Custom Zeus Commands**: 
  - `/zeus-kanban`: Project kanban board generator
  - `/zeus-git-commit`: Smart git commit helper
  - `/zeus-roadmap`: Project roadmap generation

- **Git Automation**:
  - `setup-hooks.sh`: Git hooks installer
  - post-merge hook: Auto-sync repo → config after git pull
  - pre-push hook: Pull config → repo before git push

- **NPM/Bun Package Support**:
  - Global installation with `npm install -g openzeus`
  - CLI binaries: `openzeus-sync`, `openzeus-create`, `openzeus-setup`
  - OpenCode plugin configuration support
  - Automated installation with postinstall script

### Features
- **Proactive Skill Loading**: Auto-detection of user intent and automatic skill loading
- **Self-Optimization**: Continuous performance monitoring and improvement
- **Documentation Integration**: Cached OpenCode documentation for offline access
- **Context Management**: Intelligent conversation compression and optimization
- **Cross-Platform Support**: Linux and macOS compatibility

### Installation Methods
- NPM/Bun global installation
- OpenCode plugin configuration
- Manual repository installation
- Automated setup with install script

### Performance
- Optimized skill loading based on usage patterns
- Efficient context management with compression
- Fast repo detection and sync operations
- Minimal overhead for background operations

### Documentation
- Comprehensive README with installation and usage examples
- Detailed skill documentation for all 14 Zeus skills
- OpenCode plugin configuration examples
- Troubleshooting guide and common solutions

## [Unreleased]

### Planned
- Integration with additional OpenCode plugins
- Enhanced self-learning capabilities  
- Extended skill library
- Web dashboard for sync management
- Multi-repository sync support

---

## Release Notes

### 1.0.0 Release Highlights

OpenZeus 1.0.0 represents the first stable release of the comprehensive OpenCode management system. This release focuses on:

1. **Complete OpenCode Coverage**: Every aspect of OpenCode is covered by specialized Zeus skills
2. **Bidirectional Sync**: Seamless integration between development and deployment environments
3. **Context Intelligence**: Smart detection of user intent and automatic capability loading
4. **Professional Distribution**: NPM/Bun package support for easy installation and updates

This release establishes OpenZeus as the definitive solution for OpenCode workflow automation and management.