# OpenCode Configuration Documentation
Last Updated: Mar 21 2026
Source: https://opencode.ai/docs/config/

## Quick Reference

### Config Locations (Precedence Order)
1. Remote config (from `.well-known/opencode`) - organizational defaults
2. Global config (`~/.config/opencode/opencode.json`) - user preferences
3. Custom config (`OPENCODE_CONFIG` env var) - custom overrides
4. Project config (`opencode.json` in project) - project-specific settings
5. `.opencode` directories - agents, commands, plugins
6. Inline config (`OPENCODE_CONFIG_CONTENT` env var) - runtime overrides

### Key Schema Options
- `$schema`: "https://opencode.ai/config.json"
- `provider`: LLM provider configuration
- `model`: Primary model selection
- `tools`: Tool permissions (write, bash, etc.)
- `agent`: Custom agent definitions
- `permission`: Permission settings (ask, allow, deny)
- `compaction`: Context compaction behavior
- `plugin`: Plugin list
- `instructions`: Rule/instruction files

### Config Merge Behavior
Configuration files are MERGED together, not replaced. Later configs override earlier ones only for conflicting keys.
