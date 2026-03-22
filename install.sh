#!/bin/bash

# OpenZeus Installation Script
# Installs OpenZeus agent, skills, and commands to OpenCode configuration

set -e

OPENCODE_DIR="$HOME/.config/opencode"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🏛️  OpenZeus Installation Script"
echo "================================"

# Check if OpenCode config directory exists
if [ ! -d "$OPENCODE_DIR" ]; then
    echo "❌ OpenCode configuration directory not found at $OPENCODE_DIR"
    echo "   Please install and configure OpenCode first."
    exit 1
fi

echo "✅ Found OpenCode configuration at $OPENCODE_DIR"

# Create directories if they don't exist
mkdir -p "$OPENCODE_DIR/agents"
mkdir -p "$OPENCODE_DIR/skills"
mkdir -p "$OPENCODE_DIR/commands"

echo "📁 Created necessary directories"

# Install OpenZeus agent
echo "🤖 Installing OpenZeus agent..."
cp -f "$SCRIPT_DIR/agents/OpenZeus.md" "$OPENCODE_DIR/agents/"
echo "   ✅ Installed agents/OpenZeus.md"

# Install Zeus skills
echo "🛠️  Installing Zeus skills..."
for skill_dir in "$SCRIPT_DIR/skills"/zeus-*; do
    if [ -d "$skill_dir" ]; then
        skill_name=$(basename "$skill_dir")
        cp -rf "$skill_dir" "$OPENCODE_DIR/skills/"
        echo "   ✅ Installed skills/$skill_name"
    fi
done

# Install Zeus commands (optional)
echo "⚡ Installing Zeus commands..."
for command_file in "$SCRIPT_DIR/commands"/zeus-*.md; do
    if [ -f "$command_file" ]; then
        command_name=$(basename "$command_file")
        cp -f "$command_file" "$OPENCODE_DIR/commands/"
        echo "   ✅ Installed commands/$command_name"
    fi
done

# Install documentation cache (optional)
if [ -d "$SCRIPT_DIR/docs/docs-cache" ]; then
    echo "📚 Installing documentation cache..."
    mkdir -p "$OPENCODE_DIR/docs-cache"
    cp -rf "$SCRIPT_DIR/docs/docs-cache"/* "$OPENCODE_DIR/docs-cache/" 2>/dev/null || true
    echo "   ✅ Installed documentation cache"
fi

echo ""
echo "🎉 OpenZeus installation complete!"
echo ""
echo "Usage:"
echo "  • Set as default agent: Add \"default_agent\": \"OpenZeus\" to opencode.json"
echo "  • Use via @mention: @OpenZeus help me configure OpenCode"
echo "  • Access skills: Available automatically based on context"
echo "  • Use commands: /zeus-kanban, /zeus-roadmap, /zeus-git-commit"
echo ""
echo "📖 See README.md for full documentation"
echo "🏛️  Welcome to the realm of OpenZeus!"