#!/bin/bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config_dir="${OPENCODE_CONFIG_DIR:-${OPENZEUS_CONFIG_DIR:-${HOME}/.config/opencode}}"
status=0
fix_plan=false
missing_executables=()
warnings=0
needs_install=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --fix-plan) fix_plan=true ;;
        -h|--help|help) echo "Usage: doctor.sh [--fix-plan]"; exit 0 ;;
    esac
    shift
done

fail() {
    echo "FAIL $1"
    status=1
}

warn() {
    echo "WARN $1"
    warnings=$((warnings + 1))
}

contains() {
    local file="$1"
    local pattern="$2"
    grep -q "$pattern" "$file"
}

first_line_is_frontmatter() {
    local file="$1"
    local first=""
    [[ -f "$file" ]] || return 1
    IFS= read -r first < "$file" || true
    [[ "$first" == "---" ]]
}

for file in \
    "$root_dir/bin/openzeus" \
    "$root_dir/scripts/install.sh" \
    "$root_dir/scripts/sync-utils.sh" \
    "$root_dir/scripts/create-utils.sh" \
    "$root_dir/scripts/setup-hooks.sh" \
    "$root_dir/scripts/init-project.sh" \
    "$root_dir/scripts/doctor.sh"; do
    if [[ ! -x "$file" ]]; then
        fail "missing executable: $file"
        missing_executables+=("${file#$root_dir/}")
    fi
done

[[ -f "$root_dir/agents/OpenZeus.md" ]] || fail "missing agents/OpenZeus.md"
first_line_is_frontmatter "$root_dir/agents/OpenZeus.md" || fail "agents/OpenZeus.md missing frontmatter"
contains "$root_dir/agents/OpenZeus.md" '^description:' || fail "agents/OpenZeus.md missing description"
contains "$root_dir/agents/OpenZeus.md" '^mode:' || fail "agents/OpenZeus.md missing mode"

for skill in "$root_dir"/skills/zeus-*/SKILL.md; do
    [[ -f "$skill" ]] || continue
    first_line_is_frontmatter "$skill" || fail "$skill missing frontmatter"
    contains "$skill" '^name:' || fail "$skill missing name frontmatter"
    contains "$skill" '^description:' || fail "$skill missing description frontmatter"
done

for command in "$root_dir"/commands/zeus-*.md; do
    [[ -f "$command" ]] || continue
    first_line_is_frontmatter "$command" || fail "$command missing frontmatter"
    contains "$command" '^description:' || fail "$command missing description frontmatter"
done

contains "$root_dir/package.json" '"openzeus"[[:space:]]*:[[:space:]]*"bin/openzeus"' || fail "package.json missing openzeus bin"
contains "$root_dir/package.json" '"postinstall"' && fail "package.json should not run mutating postinstall"

if [[ ! -d "$config_dir" ]]; then
    warn "OpenCode config dir absent: $config_dir (install will create it)"
    needs_install=true
else
    if [[ ! -f "$config_dir/agents/OpenZeus.md" ]]; then
        warn "OpenZeus agent missing from config: $config_dir/agents/OpenZeus.md"
        needs_install=true
    fi

    config_skill_count=0
    config_command_count=0
    [[ -d "$config_dir/skills" ]] && config_skill_count=$(find "$config_dir/skills" -maxdepth 1 -mindepth 1 -type d -name 'zeus-*' | wc -l | tr -d ' ')
    [[ -d "$config_dir/commands" ]] && config_command_count=$(find "$config_dir/commands" -maxdepth 1 -type f -name 'zeus-*.md' | wc -l | tr -d ' ')
    if [[ "$config_skill_count" -eq 0 ]]; then
        warn "No Zeus skills installed in config: $config_dir/skills"
        needs_install=true
    fi
    if [[ "$config_command_count" -eq 0 ]]; then
        warn "No Zeus commands installed in config: $config_dir/commands"
        needs_install=true
    fi
fi

if [[ "$status" -eq 0 && "$warnings" -eq 0 ]]; then
    echo "OpenZeus doctor: ok"
elif [[ "$status" -eq 0 ]]; then
    echo "OpenZeus doctor: warnings"
fi

if [[ "$fix_plan" == true ]]; then
    echo "Suggested commands:"
    suggestions=0
    if [[ "$needs_install" == true ]]; then
        echo "  openzeus install"
        suggestions=$((suggestions + 1))
    fi
    for file in "${missing_executables[@]}"; do
        echo "  chmod +x $file"
        suggestions=$((suggestions + 1))
    done
    if [[ "$status" -ne 0 ]]; then
        echo "  inspect FAIL lines above, fix the referenced package files, then rerun openzeus doctor --fix-plan"
        suggestions=$((suggestions + 1))
    fi
    if [[ "$suggestions" -eq 0 ]]; then
        echo "  (none; no fixes required)"
    fi
fi

exit "$status"
