#!/bin/bash

# OpenZeus Sync Utilities
# Handles bidirectional sync between OpenZeus repo and OpenCode config

set -e

OPENCODE_DIR="$HOME/.config/opencode"
OPENZEUS_REPO=""

# Auto-detect OpenZeus repository location
detect_zeus_repo() {
    # Method 1: Check if we're in OpenZeus repo
    if [[ "$(basename "$(pwd)")" == "OpenZeus" && -f "agents/OpenZeus.md" ]]; then
        OPENZEUS_REPO="$(pwd)"
        return 0
    fi
    
    # Method 2: Check common locations
    local common_paths=(
        "$HOME/projects/OpenZeus"
        "$HOME/OpenZeus" 
        "$HOME/code/OpenZeus"
        "$HOME/src/OpenZeus"
    )
    
    for path in "${common_paths[@]}"; do
        if [[ -d "$path" && -f "$path/agents/OpenZeus.md" ]]; then
            OPENZEUS_REPO="$path"
            return 0
        fi
    done
    
    # Method 3: Ask git for OpenZeus remotes
    local git_repos=$(find "$HOME" -name ".git" -type d 2>/dev/null | head -20)
    for git_dir in $git_repos; do
        local repo_dir=$(dirname "$git_dir")
        if git -C "$repo_dir" remote get-url origin 2>/dev/null | grep -q "OpenZeus"; then
            if [[ -f "$repo_dir/agents/OpenZeus.md" ]]; then
                OPENZEUS_REPO="$repo_dir"
                return 0
            fi
        fi
    done
    
    return 1
}

# Push from repo to config (repo → config)
push_to_config() {
    echo "🔄 Syncing OpenZeus repo → OpenCode config..."
    
    if [[ ! -d "$OPENZEUS_REPO" ]]; then
        echo "❌ OpenZeus repo not found at: $OPENZEUS_REPO"
        return 1
    fi
    
    # Sync agents
    if [[ -d "$OPENZEUS_REPO/agents" ]]; then
        mkdir -p "$OPENCODE_DIR/agents"
        cp -f "$OPENZEUS_REPO/agents"/*.md "$OPENCODE_DIR/agents/" 2>/dev/null || true
        echo "   ✅ Synced agents"
    fi
    
    # Sync skills  
    if [[ -d "$OPENZEUS_REPO/skills" ]]; then
        mkdir -p "$OPENCODE_DIR/skills"
        for skill_dir in "$OPENZEUS_REPO/skills"/zeus-*; do
            if [[ -d "$skill_dir" ]]; then
                skill_name=$(basename "$skill_dir")
                cp -rf "$skill_dir" "$OPENCODE_DIR/skills/"
                echo "   ✅ Synced skills/$skill_name"
            fi
        done
    fi
    
    # Sync commands
    if [[ -d "$OPENZEUS_REPO/commands" ]]; then
        mkdir -p "$OPENCODE_DIR/commands"
        cp -f "$OPENZEUS_REPO/commands"/zeus-*.md "$OPENCODE_DIR/commands/" 2>/dev/null || true
        echo "   ✅ Synced commands"
    fi
}

# Pull from config to repo (config → repo) 
pull_from_config() {
    echo "🔄 Syncing OpenCode config → OpenZeus repo..."
    
    if [[ ! -d "$OPENZEUS_REPO" ]]; then
        echo "❌ OpenZeus repo not found at: $OPENZEUS_REPO"
        return 1
    fi
    
    local changes=false
    
    # Pull agents (OpenZeus.md specifically)
    if [[ -f "$OPENCODE_DIR/agents/OpenZeus.md" ]]; then
        mkdir -p "$OPENZEUS_REPO/agents"
        if ! cmp -s "$OPENCODE_DIR/agents/OpenZeus.md" "$OPENZEUS_REPO/agents/OpenZeus.md"; then
            cp -f "$OPENCODE_DIR/agents/OpenZeus.md" "$OPENZEUS_REPO/agents/"
            echo "   ✅ Updated agents/OpenZeus.md"
            changes=true
        fi
    fi
    
    # Pull skills (zeus-* only)
    if [[ -d "$OPENCODE_DIR/skills" ]]; then
        mkdir -p "$OPENZEUS_REPO/skills"
        for skill_dir in "$OPENCODE_DIR/skills"/zeus-*; do
            if [[ -d "$skill_dir" ]]; then
                skill_name=$(basename "$skill_dir")
                local repo_skill="$OPENZEUS_REPO/skills/$skill_name"
                
                # Check if skill is different
                if [[ ! -d "$repo_skill" ]] || ! diff -r "$skill_dir" "$repo_skill" >/dev/null 2>&1; then
                    cp -rf "$skill_dir" "$OPENZEUS_REPO/skills/"
                    echo "   ✅ Updated skills/$skill_name"
                    changes=true
                fi
            fi
        done
    fi
    
    # Pull commands (zeus-* only)
    if [[ -d "$OPENCODE_DIR/commands" ]]; then
        mkdir -p "$OPENZEUS_REPO/commands"
        for cmd_file in "$OPENCODE_DIR/commands"/zeus-*.md; do
            if [[ -f "$cmd_file" ]]; then
                cmd_name=$(basename "$cmd_file")
                local repo_cmd="$OPENZEUS_REPO/commands/$cmd_name"
                
                if ! cmp -s "$cmd_file" "$repo_cmd"; then
                    cp -f "$cmd_file" "$OPENZEUS_REPO/commands/"
                    echo "   ✅ Updated commands/$cmd_name"
                    changes=true
                fi
            fi
        done
    fi
    
    if [[ "$changes" == "true" ]]; then
        echo ""
        echo "📝 Changes detected. Consider committing to git:"
        echo "   cd '$OPENZEUS_REPO'"
        echo "   git add -A && git commit -m 'sync: pull external changes from config'"
    else
        echo "   ℹ️  No changes detected"
    fi
}

# Status check - show sync state
status() {
    echo "📊 OpenZeus Sync Status"
    echo "======================="
    
    if detect_zeus_repo; then
        echo "✅ OpenZeus repo: $OPENZEUS_REPO"
    else
        echo "❌ OpenZeus repo: Not found"
        return 1
    fi
    
    echo "✅ Config dir: $OPENCODE_DIR"
    echo ""
    
    # Compare key files
    echo "File Comparison (Repo vs Config):"
    echo "--------------------------------"
    
    # OpenZeus.md
    if [[ -f "$OPENZEUS_REPO/agents/OpenZeus.md" && -f "$OPENCODE_DIR/agents/OpenZeus.md" ]]; then
        if cmp -s "$OPENZEUS_REPO/agents/OpenZeus.md" "$OPENCODE_DIR/agents/OpenZeus.md"; then
            echo "✅ OpenZeus.md: In sync"
        else
            echo "⚠️  OpenZeus.md: Out of sync"
        fi
    else
        echo "❌ OpenZeus.md: Missing files"
    fi
    
    # Skills count
    local repo_skills=$(find "$OPENZEUS_REPO/skills" -name "zeus-*" -type d 2>/dev/null | wc -l)
    local config_skills=$(find "$OPENCODE_DIR/skills" -name "zeus-*" -type d 2>/dev/null | wc -l)
    if [[ "$repo_skills" -eq "$config_skills" ]]; then
        echo "✅ Zeus skills: $repo_skills skills in both locations"
    else
        echo "⚠️  Zeus skills: Repo=$repo_skills, Config=$config_skills"
    fi
    
    # Commands count  
    local repo_cmds=$(find "$OPENZEUS_REPO/commands" -name "zeus-*.md" 2>/dev/null | wc -l)
    local config_cmds=$(find "$OPENCODE_DIR/commands" -name "zeus-*.md" 2>/dev/null | wc -l)
    if [[ "$repo_cmds" -eq "$config_cmds" ]]; then
        echo "✅ Zeus commands: $repo_cmds commands in both locations"  
    else
        echo "⚠️  Zeus commands: Repo=$repo_cmds, Config=$config_cmds"
    fi
}

# Show usage
usage() {
    echo "OpenZeus Sync Utilities"
    echo ""
    echo "Usage: $0 <command>"
    echo ""
    echo "Commands:"
    echo "  push      Push changes from OpenZeus repo to OpenCode config"
    echo "  pull      Pull changes from OpenCode config to OpenZeus repo" 
    echo "  status    Show sync status and detect differences"
    echo "  auto      Auto-detect and sync in appropriate direction"
    echo "  install   Same as push (compatibility with install.sh)"
    echo ""
    echo "Examples:"
    echo "  $0 status         # Check if repo and config are in sync"
    echo "  $0 push          # After modifying files in OpenZeus repo"
    echo "  $0 pull          # After OpenZeus creates new skills in other projects"
    echo "  $0 auto          # Smart sync based on timestamps"
}

# Auto sync - detect which direction to sync
auto_sync() {
    if ! detect_zeus_repo; then
        echo "❌ Cannot auto-sync: OpenZeus repo not found"
        return 1
    fi
    
    echo "🤖 Auto-detecting sync direction..."
    
    # Compare timestamps to determine direction
    local repo_newest=0
    local config_newest=0
    
    # Find newest file in repo
    if [[ -d "$OPENZEUS_REPO" ]]; then
        repo_newest=$(find "$OPENZEUS_REPO" -name "*.md" -path "*/agents/*" -o -path "*/skills/*" -o -path "*/commands/*" -exec stat -c %Y {} \; 2>/dev/null | sort -n | tail -1)
    fi
    
    # Find newest file in config
    if [[ -d "$OPENCODE_DIR" ]]; then
        config_newest=$(find "$OPENCODE_DIR" -name "*.md" -path "*/agents/*" -o -path "*/skills/zeus-*" -o -path "*/commands/*" -exec stat -c %Y {} \; 2>/dev/null | sort -n | tail -1)
    fi
    
    if [[ "$repo_newest" -gt "$config_newest" ]]; then
        echo "📤 Repo is newer → pushing to config"
        push_to_config
    elif [[ "$config_newest" -gt "$repo_newest" ]]; then
        echo "📥 Config is newer → pulling to repo"
        pull_from_config
    else
        echo "✅ Already in sync"
    fi
}

# Main command dispatcher
main() {
    if ! detect_zeus_repo; then
        echo "⚠️  Warning: OpenZeus repository not found"
        echo "   Searched: current dir, ~/projects/OpenZeus, git remotes"
        echo "   Some commands may not work properly"
        echo ""
    fi
    
    case "${1:-status}" in
        push|install)
            push_to_config
            ;;
        pull)
            pull_from_config
            ;;
        status)
            status
            ;;
        auto)
            auto_sync
            ;;
        help|--help|-h)
            usage
            ;;
        *)
            echo "❌ Unknown command: $1"
            echo ""
            usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"