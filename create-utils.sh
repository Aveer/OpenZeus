#!/bin/bash

# OpenZeus Context-Aware Creator
# Detects context and chooses appropriate creation location

set -e

OPENCODE_DIR="$HOME/.config/opencode"
OPENZEUS_REPO=""
CREATE_LOCATION="config"  # config | repo | ask

# Source sync utilities for repo detection
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
    
    return 1
}

# Determine where to create the item
determine_location() {
    local type="$1"  # agent | skill | command
    
    # If we're in OpenZeus repo, default to repo
    if [[ "$(basename "$(pwd)")" == "OpenZeus" && -f "agents/OpenZeus.md" ]]; then
        echo "📍 Detected OpenZeus repo context → creating in repo"
        CREATE_LOCATION="repo"
        OPENZEUS_REPO="$(pwd)"
        return 0
    fi
    
    # If OpenZeus repo is found elsewhere, ask user
    if detect_zeus_repo; then
        echo "📍 Found OpenZeus repo at: $OPENZEUS_REPO"
        echo ""
        echo "Where should I create this $type?"
        echo "[1] OpenZeus project repo (recommended — version controlled)"
        echo "[2] Global config (~/.config/opencode/) — local only"
        echo ""
        read -p "Choose [1-2]: " choice
        
        case "$choice" in
            1)
                CREATE_LOCATION="repo"
                echo "✅ Creating in OpenZeus repo"
                ;;
            2)
                CREATE_LOCATION="config"
                echo "✅ Creating in global config"
                ;;
            *)
                CREATE_LOCATION="config"
                echo "⚠️  Invalid choice, defaulting to global config"
                ;;
        esac
    else
        echo "📍 OpenZeus repo not found → creating in global config"
        CREATE_LOCATION="config"
    fi
}

# Get target directory based on location choice
get_target_dir() {
    local type="$1"  # agents | skills | commands
    
    if [[ "$CREATE_LOCATION" == "repo" && -n "$OPENZEUS_REPO" ]]; then
        echo "$OPENZEUS_REPO/$type"
    else
        echo "$OPENCODE_DIR/$type"
    fi
}

# Create agent with context awareness
create_agent() {
    local name="$1"
    local description="$2"
    
    determine_location "agent"
    
    local target_dir=$(get_target_dir "agents")
    mkdir -p "$target_dir"
    
    local agent_file="$target_dir/$name.md"
    
    echo "🤖 Creating agent: $name"
    echo "📁 Location: $agent_file"
    
    # Create agent content (simplified)
    cat > "$agent_file" << EOF
# Agent: $name

$description

---

## Instructions

[Agent instructions go here]

---

## Tools

- All standard tools available

---

## Examples

Example usage patterns...

---

End of agent.
EOF
    
    echo "✅ Agent '$name' created at $agent_file"
    
    # If created in repo, offer to sync
    if [[ "$CREATE_LOCATION" == "repo" ]]; then
        echo "🔄 Syncing to global config..."
        if [[ -f "$OPENZEUS_REPO/sync-utils.sh" ]]; then
            "$OPENZEUS_REPO/sync-utils.sh" push
        else
            cp -f "$agent_file" "$OPENCODE_DIR/agents/"
            echo "   ✅ Copied to ~/.config/opencode/agents/"
        fi
    fi
}

# Create skill with context awareness  
create_skill() {
    local name="$1"
    local description="$2"
    
    determine_location "skill"
    
    local target_dir=$(get_target_dir "skills")
    mkdir -p "$target_dir/$name"
    
    local skill_file="$target_dir/$name/SKILL.md"
    
    echo "🛠️  Creating skill: $name"
    echo "📁 Location: $skill_file"
    
    # Create skill content
    cat > "$skill_file" << EOF
# Skill: $name

# $name (Skill)

Purpose: $description

---

## Section 1

[Content goes here...]

---

## Section 2

[More content...]

---

End of skill.
EOF
    
    echo "✅ Skill '$name' created at $skill_file"
    
    # If created in repo, offer to sync
    if [[ "$CREATE_LOCATION" == "repo" ]]; then
        echo "🔄 Syncing to global config..."
        if [[ -f "$OPENZEUS_REPO/sync-utils.sh" ]]; then
            "$OPENZEUS_REPO/sync-utils.sh" push
        else
            cp -rf "$target_dir/$name" "$OPENCODE_DIR/skills/"
            echo "   ✅ Copied to ~/.config/opencode/skills/"
        fi
    fi
    
    # Update OpenZeus.md if it's a zeus-* skill
    if [[ "$name" == zeus-* ]]; then
        echo "📝 Adding to OpenZeus skill loading guide..."
        # TODO: Add logic to update OpenZeus.md
        echo "   ⚠️  Manual step: Add to OpenZeus.md skill table"
    fi
}

# Create command with context awareness
create_command() {
    local name="$1" 
    local description="$2"
    local template="$3"
    
    determine_location "command"
    
    local target_dir=$(get_target_dir "commands")
    mkdir -p "$target_dir"
    
    local command_file="$target_dir/$name.md"
    
    echo "⚡ Creating command: $name"
    echo "📁 Location: $command_file"
    
    # Create command content
    cat > "$command_file" << EOF
# Command: /$name

**Description**: $description

---

## Template

$template

---

## Usage

\`/$name [arguments]\`

---

## Examples

\`/$name example\` — Example usage

---

End of command.
EOF
    
    echo "✅ Command '$name' created at $command_file"
    
    # If created in repo, offer to sync
    if [[ "$CREATE_LOCATION" == "repo" ]]; then
        echo "🔄 Syncing to global config..."
        if [[ -f "$OPENZEUS_REPO/sync-utils.sh" ]]; then
            "$OPENZEUS_REPO/sync-utils.sh" push
        else
            cp -f "$command_file" "$OPENCODE_DIR/commands/"
            echo "   ✅ Copied to ~/.config/opencode/commands/"
        fi
    fi
}

# Show usage
usage() {
    echo "OpenZeus Context-Aware Creator"
    echo ""
    echo "Usage: $0 <type> <name> [description] [template]"
    echo ""
    echo "Types:"
    echo "  agent     Create an OpenCode agent"
    echo "  skill     Create an OpenCode skill"  
    echo "  command   Create an OpenCode command"
    echo ""
    echo "Examples:"
    echo "  $0 agent mybot 'My custom agent'"
    echo "  $0 skill myskill 'Domain expertise for X'"
    echo "  $0 command mycmd 'Custom command' 'Do something with {args}'"
    echo ""
    echo "Location Logic:"
    echo "  • In OpenZeus repo → creates in repo + syncs to config"
    echo "  • OpenZeus found → prompts user for location choice"
    echo "  • No OpenZeus → creates in global config only"
}

# Main function
main() {
    local type="$1"
    local name="$2" 
    local description="${3:-Default description}"
    local template="${4:-Default template}"
    
    case "$type" in
        agent)
            create_agent "$name" "$description"
            ;;
        skill)
            create_skill "$name" "$description"
            ;;
        command)
            create_command "$name" "$description" "$template"
            ;;
        help|--help|-h|"")
            usage
            ;;
        *)
            echo "❌ Unknown type: $type"
            echo ""
            usage
            exit 1
            ;;
    esac
}

# Non-interactive mode flag
if [[ "$1" == "--repo" ]]; then
    CREATE_LOCATION="repo"
    shift
elif [[ "$1" == "--config" ]]; then
    CREATE_LOCATION="config" 
    shift
fi

main "$@"