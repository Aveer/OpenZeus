#!/bin/bash
set -euo pipefail

dry_run=false
force=false
backup=false
target_dir="${OPENCODE_CONFIG_DIR:-${HOME}/.config/opencode}"

usage() {
    cat <<EOF
Usage: install.sh [--dry-run] [--force] [--backup] [--target DIR]

Installs only OpenZeus-owned assets:
  agents/OpenZeus.md
  skills/zeus-*/
  commands/zeus-*.md
  sync/create/hooks/doctor/init-project helper scripts

By default, existing differing files are skipped. Use --force to overwrite;
pair --force with --backup to preserve existing destinations first.
EOF
}

require_value() {
    local flag="$1"
    local value="${2:-}"
    if [[ -z "$value" || "$value" == --* ]]; then
        echo "Missing value for $flag" >&2
        exit 1
    fi
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) dry_run=true ;;
        --force) force=true ;;
        --backup) backup=true ;;
        --target)
            require_value "$1" "${2:-}"
            target_dir="$2"
            shift
            ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
    esac
    shift
done

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

backup_existing() {
    local dst="$1"
    [[ "$backup" == true && -e "$dst" ]] || return 0

    local bak="${dst}.bak.$(date +%Y%m%d%H%M%S)"
    if [[ -d "$dst" ]]; then
        cp -R "$dst" "$bak"
    else
        cp -p "$dst" "$bak"
    fi
    echo "backup: $bak"
}

same_file() {
    [[ -f "$1" && -f "$2" ]] && cmp -s "$1" "$2"
}

same_dir() {
    [[ -d "$1" && -d "$2" ]] && diff -qr "$1" "$2" >/dev/null
}

copy_file_safe() {
    local src="$1"
    local dst="$2"
    local mode="${3:-}"

    if [[ "$dry_run" == true ]]; then
        echo "copy file: $src -> $dst"
        return 0
    fi

    mkdir -p "$(dirname "$dst")"
    if [[ -e "$dst" ]]; then
        same_file "$src" "$dst" && return 0
        if [[ "$force" != true ]]; then
            echo "skip existing: $dst"
            return 0
        fi
        backup_existing "$dst"
        rm -rf "$dst"
    fi

    cp -f "$src" "$dst"
    if [[ "$mode" == executable ]]; then
        chmod +x "$dst"
    fi
    return 0
}

copy_dir_safe() {
    local src="$1"
    local dst="$2"

    if [[ "$dry_run" == true ]]; then
        echo "copy dir: $src -> $dst"
        return 0
    fi

    mkdir -p "$(dirname "$dst")"
    if [[ -e "$dst" ]]; then
        same_dir "$src" "$dst" && return 0
        if [[ "$force" != true ]]; then
            echo "skip existing: $dst"
            return 0
        fi
        backup_existing "$dst"
        rm -rf "$dst"
    fi

    cp -R "$src" "$dst"
}

if [[ "$dry_run" == true ]]; then
    echo "mkdir -p $target_dir/agents $target_dir/skills $target_dir/commands"
else
    mkdir -p "$target_dir/agents" "$target_dir/skills" "$target_dir/commands"
fi

copy_file_safe "$script_dir/agents/OpenZeus.md" "$target_dir/agents/OpenZeus.md"

for skill_dir in "$script_dir"/skills/zeus-*; do
    [[ -d "$skill_dir" ]] || continue
    copy_dir_safe "$skill_dir" "$target_dir/skills/$(basename "$skill_dir")"
done

for command_file in "$script_dir"/commands/zeus-*.md; do
    [[ -f "$command_file" ]] || continue
    copy_file_safe "$command_file" "$target_dir/commands/$(basename "$command_file")"
done

for helper in sync-utils.sh create-utils.sh setup-hooks.sh doctor.sh init-project.sh; do
    [[ -f "$script_dir/scripts/$helper" ]] || continue
    copy_file_safe "$script_dir/scripts/$helper" "$target_dir/$helper" executable
done

if [[ "$dry_run" == true ]]; then
    echo "OpenZeus dry-run complete for $target_dir (no files written)"
else
    echo "OpenZeus assets installed to $target_dir"
fi
