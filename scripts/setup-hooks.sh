#!/bin/bash
# Setup Git hooks for OpenZeus auto-sync

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HOOKS_DIR="$SCRIPT_DIR/.git/hooks"

echo "🪝 Setting up OpenZeus git hooks..."

# Create post-merge hook
cat > "$HOOKS_DIR/post-merge" << 'EOF'
#!/bin/bash
# OpenZeus post-merge hook
# Automatically syncs OpenZeus repo changes to OpenCode config after git pull/merge

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"

# Only run if we're in an OpenZeus repo
if [[ -f "$SCRIPT_DIR/agents/OpenZeus.md" && -f "$SCRIPT_DIR/sync-utils.sh" ]]; then
    echo "🔄 OpenZeus post-merge: syncing changes to config..."
    "$SCRIPT_DIR/sync-utils.sh" push
    echo "✅ Sync complete"
fi
EOF

chmod +x "$HOOKS_DIR/post-merge"
echo "✅ Created post-merge hook: auto-sync after git pull"

# Create pre-push hook for pull sync
cat > "$HOOKS_DIR/pre-push" << 'EOF'
#!/bin/bash
# OpenZeus pre-push hook
# Pulls any external changes from config before pushing

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)"

# Only run if we're in an OpenZeus repo
if [[ -f "$SCRIPT_DIR/agents/OpenZeus.md" && -f "$SCRIPT_DIR/sync-utils.sh" ]]; then
    echo "🔄 OpenZeus pre-push: checking for external changes..."
    "$SCRIPT_DIR/sync-utils.sh" pull
fi
EOF

chmod +x "$HOOKS_DIR/pre-push"
echo "✅ Created pre-push hook: pull external changes before push"

echo ""
echo "🎯 Git hooks installed!"
echo "• post-merge: Auto-sync repo → config after git pull"
echo "• pre-push: Pull config → repo before git push"
echo ""
echo "To disable: rm .git/hooks/{post-merge,pre-push}"