# Changelog

All notable OpenZeus changes are documented here.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) with [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Product-facing guided UX around setup audit, status inspection, repo initialization, examples, asset listing, and safe sync workflows.
- Documentation for `openzeus doctor --fix-plan`, `openzeus status`, `openzeus list`, `openzeus examples`, and `openzeus init-project --dry-run`.

### Changed
- Reposition OpenZeus as a guided OpenCode setup/audit/generation product instead of only an asset pack.
- Update OpenZeus agent guidance toward outcome workflows: audit setup, initialize projects, generate commands/assets, and diagnose loading or sync issues.
- Align OpenCode asset docs with current modes: `primary`, `subagent`, `all`.
- Tighten documented git/publishing safety gates around push and registry mutations.
- Clarify supported command syntax: `$ARGUMENTS`, positional arguments, shell injection, and `@file` references.

## [1.1.0]

### Added
- `openzeus` CLI entrypoint.
- Package coverage for `bin/`, `agents/`, `commands/`, `skills/`, `scripts/`, and `tests/`.
- Updated validation via `npm test`.

### Changed
- NPM package metadata and installation flow now center on `openzeus`.

## [1.0.0] - 2024-03-22

### Added
- OpenZeus agent for OpenCode operations.
- 15 Zeus skill bundles:
  - `zeus-core`, `zeus-agents`, `zeus-commands`, `zeus-skills`, `zeus-upskill`
  - `zeus-context`, `zeus-self`, `zeus-swarm`, `zeus-omo`, `zeus-beads`, `zeus-oac`
  - `zeus-docker`, `zeus-sql`, `zeus-llm`, `zeus-boston-terrier`
- Slash commands:
  - `/zeus-kanban`
  - `/zeus-git-commit`
  - `/zeus-roadmap`
  - `/zeus-improve-project`
- Install and sync utilities:
  - `scripts/install.sh`
  - `scripts/sync-utils.sh`
  - `scripts/create-utils.sh`
  - `scripts/setup-hooks.sh`

### Notes
- OpenZeus provides local Markdown assets and helper scripts. Claims about future self-optimization, dashboards, or documentation caching should be treated as roadmap unless implemented in the package.
