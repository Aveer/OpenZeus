# Publishing Guide for OpenZeus

## Prerequisites

1. **NPM Account**: Create account at https://npmjs.com
2. **Authentication**: Login with `npm login`
3. **Organization Access**: Ensure you have publish rights (if using org scope)

## Pre-Publishing Checklist

- [ ] All tests pass: `npm test`
- [ ] Version updated in `package.json`
- [ ] `CHANGELOG.md` updated with new version
- [ ] `README.md` includes latest features
- [ ] Clean working directory: `git status`
- [ ] All changes committed and pushed

## Publishing Commands

### NPM Publishing

```bash
# Dry run to verify package contents
npm pack --dry-run

# Test package locally
npm pack
npm install -g openzeus-1.0.0.tgz

# Publish to NPM registry
npm publish

# Or publish with public access (if scoped)
npm publish --access public
```

### Bun Registry (Future)

```bash
# When Bun registry becomes available
bun publish
```

## Post-Publishing

1. **Verify Installation**: Test with `npm install -g openzeus`
2. **Update Documentation**: Ensure all links work
3. **Tag Release**: Create git tag for version
4. **GitHub Release**: Create release with changelog

## Version Management

### Semantic Versioning

- **Patch** (1.0.1): Bug fixes, minor improvements
- **Minor** (1.1.0): New features, backward compatible
- **Major** (2.0.0): Breaking changes

### NPM Version Commands

```bash
# Patch version (1.0.0 → 1.0.1)
npm version patch

# Minor version (1.0.0 → 1.1.0)  
npm version minor

# Major version (1.0.0 → 2.0.0)
npm version major

# Custom version
npm version 1.2.3
```

## OpenCode Plugin Distribution

### Method 1: Direct Plugin Reference

Users add to `opencode.json`:
```json
{
  "plugin": ["openzeus"]
}
```

### Method 2: Git URL (Development)

```json
{
  "plugin": ["https://github.com/Aveer/OpenZeus.git"]
}
```

## Automation (Future)

### GitHub Actions Workflow

```yaml
name: Publish Package
on:
  push:
    tags: ['v*']
jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
          registry-url: 'https://registry.npmjs.org'
      - run: npm ci
      - run: npm test
      - run: npm publish
        env:
          NODE_AUTH_TOKEN: ${{ secrets.NPM_TOKEN }}
```

## Troubleshooting

### Common Publishing Issues

| Error | Solution |
|-------|----------|
| `npm ERR! 403 Forbidden` | Check npm login and permissions |
| `npm ERR! Package already exists` | Update version number |
| `npm ERR! Invalid package.json` | Validate JSON syntax |
| `Files missing from package` | Check `.npmignore` and `files` array |

### Registry Issues

```bash
# Check current registry
npm config get registry

# Set NPM registry (if changed)
npm config set registry https://registry.npmjs.org/

# Clear cache if needed  
npm cache clean --force
```

## Current Status

**Ready to Publish**: Package is prepared and tested
**Next Step**: Run `npm publish` when ready to release

Package size: **48.0 kB** (158.4 kB unpacked)  
Files included: **26** (agents, skills, commands, utilities)  
Version: **1.0.0** (initial release)