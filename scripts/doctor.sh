#!/bin/bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config_dir="${OPENCODE_CONFIG_DIR:-${OPENZEUS_CONFIG_DIR:-${HOME}/.config/opencode}}"
status=0
fix_plan=false
missing_executables=()
config_executable_fixes=()
warnings=0
needs_install=false
needs_force_backup=false
needs_sync_status=false

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

compare_installed_file() {
    local label="$1"
    local package_path="$2"
    local config_path="$3"

    if [[ ! -e "$config_path" ]]; then
        warn "$label missing from config: $config_path"
        needs_install=true
        return 0
    fi

    if [[ -f "$package_path" && -f "$config_path" ]]; then
        if ! cmp -s "$package_path" "$config_path"; then
            warn "$label differs in config: $config_path"
            needs_force_backup=true
            needs_sync_status=true
        fi
        return 0
    fi

    if [[ -d "$package_path" && -d "$config_path" ]]; then
        if ! diff -qr "$package_path" "$config_path" >/dev/null; then
            warn "$label differs in config: $config_path"
            needs_force_backup=true
            needs_sync_status=true
        fi
        return 0
    fi

    warn "$label differs in config: $config_path"
    needs_force_backup=true
    needs_sync_status=true
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
    compare_installed_file "OpenZeus agent" "$root_dir/agents/OpenZeus.md" "$config_dir/agents/OpenZeus.md"

    for skill in "$root_dir"/skills/zeus-*/SKILL.md; do
        [[ -f "$skill" ]] || continue
        skill_name="$(basename "$(dirname "$skill")")"
        compare_installed_file "skill $skill_name" "$root_dir/skills/$skill_name" "$config_dir/skills/$skill_name"
    done

    for command in "$root_dir"/commands/zeus-*.md; do
        [[ -f "$command" ]] || continue
        command_name="$(basename "$command")"
        compare_installed_file "command $command_name" "$root_dir/commands/$command_name" "$config_dir/commands/$command_name"
    done

    for helper in sync-utils.sh create-utils.sh setup-hooks.sh doctor.sh init-project.sh; do
        helper_path="$config_dir/$helper"
        compare_installed_file "helper $helper" "$root_dir/scripts/$helper" "$helper_path"
        if [[ -f "$helper_path" && ! -x "$helper_path" ]]; then
            warn "helper $helper is not executable in config: $helper_path"
            config_executable_fixes+=("$helper_path")
        fi
    done
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
    if [[ "$needs_force_backup" == true ]]; then
        echo "  openzeus install --force --backup"
        suggestions=$((suggestions + 1))
    fi
    if [[ "$needs_sync_status" == true ]]; then
        echo "  openzeus sync status"
        suggestions=$((suggestions + 1))
    fi
    for file in "${missing_executables[@]}"; do
        echo "  chmod +x $file"
        suggestions=$((suggestions + 1))
    done
    for file in "${config_executable_fixes[@]}"; do
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
