# Contributing to OpenZeus

Thank you for your interest in contributing to OpenZeus! This guide will help you get started.

## Development Setup

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd OpenZeus
   ```

2. **Install dependencies:**
   ```bash
   # Ensure OpenCode is installed
   npm install -g opencode-ai
   
   # Test the installation
   ./install.sh
   ```

3. **Test your setup:**
   ```bash
   opencode run "@OpenZeus system health check"
   ```

## Project Structure

- **`agents/`** - Agent definitions (main OpenZeus agent)
- **`skills/`** - Zeus skill bundles (domain-specific capabilities)
- **`commands/`** - Custom slash commands for workflows
- **`docs/`** - Documentation and cached references
- **`prompts/`** - System prompts and templates

## Contributing Guidelines

### Adding New Skills

1. **Create skill directory:**
   ```bash
   mkdir skills/zeus-[domain]
   ```

2. **Create SKILL.md with YAML frontmatter:**
   ```markdown
   ---
   name: zeus-[domain]
   description: Brief description of the skill's purpose
   ---
   
   # zeus-[domain] (Skill)
   
   Purpose: Detailed purpose and capabilities
   
   ## [Content sections...]
   ```

3. **Update OpenZeus agent triggers:**
   - Add trigger keywords to `agents/OpenZeus.md`
   - Update skill loading patterns
   - Add to multi-skill workflows if applicable

### Adding Commands

1. **Create command file:**
   ```bash
   touch commands/zeus-[name].md
   ```

2. **Use standard command format:**
   ```markdown
   ---
   name: zeus-[name]
   description: What this command does
   ---
   
   # Zeus [Name] Command
   
   [Command template and usage]
   ```

### Code Quality Standards

- **Markdown**: Use consistent formatting with YAML frontmatter
- **Documentation**: All new features must be documented
- **Testing**: Test changes with actual OpenCode installation
- **Git**: Use clear, descriptive commit messages

### Commit Message Format

```
type(scope): description

- feat(skills): add zeus-[domain] skill for [capability]
- fix(agent): resolve skill loading issue
- docs(readme): update installation instructions
- refactor(commands): improve zeus-kanban workflow
```

### Testing Changes

1. **Test locally:**
   ```bash
   ./install.sh
   opencode run "@OpenZeus [test your changes]"
   ```

2. **Validate skills load:**
   ```bash
   opencode run "@OpenZeus load zeus-[new-skill] and test functionality"
   ```

3. **Check integration:**
   - Ensure no conflicts with existing skills
   - Test auto-loading based on triggers
   - Verify documentation accuracy

## Skill Development Best Practices

### Skill Structure
- **Purpose**: Clear, single-responsibility principle
- **Documentation**: Comprehensive usage instructions
- **Triggers**: Specific, non-overlapping keywords
- **Content**: Well-organized sections with examples

### Multi-Skill Workflows
When creating skills that work together:
1. Define clear interfaces between skills
2. Document recommended loading sequences
3. Add workflow patterns to OpenZeus agent
4. Test skill combinations thoroughly

### Documentation Standards
- Use tables for structured information
- Include code examples where applicable
- Provide clear usage instructions
- Add troubleshooting sections for complex skills

## Release Process

1. **Feature branches:**
   ```bash
   git checkout -b feature/zeus-[feature-name]
   # Make changes
   git commit -m "feat(skills): add zeus-[feature] skill"
   ```

2. **Testing:**
   - Install and test all changes
   - Verify backward compatibility
   - Check documentation accuracy

3. **Pull Request:**
   - Provide clear description of changes
   - Include testing instructions
   - Reference any related issues

## Community

- **Discussions**: Use GitHub Discussions for questions
- **Issues**: Report bugs and request features via GitHub Issues
- **Discord**: Join OpenCode Discord for real-time support

## License

By contributing to OpenZeus, you agree that your contributions will be licensed under the MIT License.

---

**Happy Contributing!** 🏛️⚡