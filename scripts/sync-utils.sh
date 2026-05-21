#!/bin/bash
set -euo pipefail

dry_run=false
force=false
backup=false
repo_dir="${OPENZEUS_REPO:-}"
config_dir="${OPENCODE_CONFIG_DIR:-${HOME}/.config/opencode}"
command="status"
manifest_items=""

usage() {
    cat <<EOF
Usage: sync-utils.sh [--dry-run] [--force] [--backup] [--repo DIR] [--config DIR] <status|push|pull|auto>

Synchronizes only OpenZeus-owned assets:
  agents/OpenZeus.md
  skills/zeus-*/
  commands/zeus-*.md

By default, conflicting destination files are not overwritten. Use --force to
overwrite and --backup to preserve the old destination first.
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
        --repo)
            require_value "$1" "${2:-}"
            repo_dir="$2"
            shift
            ;;
        --config)
            require_value "$1" "${2:-}"
            config_dir="$2"
            shift
            ;;
        push|pull|status|auto) command="$1" ;;
        -h|--help|help) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
    esac
    shift
done

detect_repo() {
    if [[ -n "$repo_dir" && -f "$repo_dir/agents/OpenZeus.md" ]]; then
        return 0
    fi

    local root=""
    if root="$(git -C "$(pwd)" rev-parse --show-toplevel 2>/dev/null)" && [[ -f "$root/agents/OpenZeus.md" ]]; then
        repo_dir="$root"
        return 0
    fi

    root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    if [[ -f "$root/agents/OpenZeus.md" ]]; then
        repo_dir="$root"
        return 0
    fi

    echo "OpenZeus repository not found; pass --repo DIR" >&2
    return 1
}

item_label() {
    local item="$1"
    local type="${item%%:*}"
    local name="${item#*:}"

    case "$type" in
        agent) printf 'agents/%s' "$name" ;;
        skill) printf 'skills/%s' "$name" ;;
        command) printf 'commands/%s' "$name" ;;
    esac
}

item_path() {
    local base="$1"
    local item="$2"
    local type="${item%%:*}"
    local name="${item#*:}"

    case "$type" in
        agent) printf '%s/agents/%s' "$base" "$name" ;;
        skill) printf '%s/skills/%s' "$base" "$name" ;;
        command) printf '%s/commands/%s' "$base" "$name" ;;
    esac
}

append_item() {
    local item="$1"
    case "$manifest_items" in
        *$'\n'"$item"$'\n'*) return 0 ;;
    esac
    manifest_items+="$item"$'\n'
}

collect_manifest() {
    local base="$1"
    [[ -d "$base" ]] || return 0

    [[ -f "$base/agents/OpenZeus.md" ]] && append_item "agent:OpenZeus.md"

    local path=""
    for path in "$base"/skills/zeus-*; do
        [[ -d "$path" ]] || continue
        append_item "skill:$(basename "$path")"
    done

    for path in "$base"/commands/zeus-*.md; do
        [[ -f "$path" ]] || continue
        append_item "command:$(basename "$path")"
    done
}

build_manifest() {
    manifest_items=$'\n'
    collect_manifest "$repo_dir"
    collect_manifest "$config_dir"
}

same_item() {
    local left="$1"
    local right="$2"

    if [[ -f "$left" && -f "$right" ]]; then
        cmp -s "$left" "$right"
        return $?
    fi

    if [[ -d "$left" && -d "$right" ]]; then
        diff -qr "$left" "$right" >/dev/null
        return $?
    fi

    return 1
}

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

copy_item() {
    local src_base="$1"
    local dst_base="$2"
    local item="$3"
    local src dst label

    src="$(item_path "$src_base" "$item")"
    dst="$(item_path "$dst_base" "$item")"
    label="$(item_label "$item")"

    [[ -e "$src" ]] || return 0

    if [[ -e "$dst" ]]; then
        same_item "$src" "$dst" && return 0
        if [[ "$force" != true ]]; then
            echo "CONFLICT $label"
            return 1
        fi
    fi

    if [[ "$dry_run" == true ]]; then
        echo "copy $label"
        return 0
    fi

    mkdir -p "$(dirname "$dst")"
    backup_existing "$dst"
    rm -rf "$dst"

    if [[ -d "$src" ]]; then
        cp -R "$src" "$dst"
    else
        cp -f "$src" "$dst"
    fi
}

sync_direction() {
    local src_base="$1"
    local dst_base="$2"
    local item status=0

    build_manifest
    while IFS= read -r item; do
        [[ -n "$item" ]] || continue
        [[ -e "$(item_path "$src_base" "$item")" ]] || continue
        copy_item "$src_base" "$dst_base" "$item" || status=1
    done <<< "$manifest_items"

    return "$status"
}

show_status() {
    detect_repo
    build_manifest

    local item repo_path config_path status=0 label
    while IFS= read -r item; do
        [[ -n "$item" ]] || continue
        repo_path="$(item_path "$repo_dir" "$item")"
        config_path="$(item_path "$config_dir" "$item")"
        label="$(item_label "$item")"

        if [[ -e "$repo_path" && -e "$config_path" ]]; then
            if same_item "$repo_path" "$config_path"; then
                echo "OK $label"
            else
                echo "DIFF $label"
                status=1
            fi
        elif [[ -e "$repo_path" ]]; then
            echo "MISSING config:$label"
            status=1
        elif [[ -e "$config_path" ]]; then
            echo "MISSING repo:$label"
            status=1
        fi
    done <<< "$manifest_items"

    return "$status"
}

auto_sync() {
    detect_repo
    build_manifest

    local item repo_path config_path push_needed=false pull_needed=false conflict=false label
    while IFS= read -r item; do
        [[ -n "$item" ]] || continue
        repo_path="$(item_path "$repo_dir" "$item")"
        config_path="$(item_path "$config_dir" "$item")"
        label="$(item_label "$item")"

        if [[ -e "$repo_path" && -e "$config_path" ]]; then
            if ! same_item "$repo_path" "$config_path"; then
                echo "CONFLICT $label differs in both locations"
                conflict=true
            fi
        elif [[ -e "$repo_path" ]]; then
            push_needed=true
        elif [[ -e "$config_path" ]]; then
            pull_needed=true
        fi
    done <<< "$manifest_items"

    if [[ "$conflict" == true || ( "$push_needed" == true && "$pull_needed" == true ) ]]; then
        echo "Auto-sync refused: ambiguous bidirectional changes"
        return 1
    fi

    if [[ "$push_needed" == true ]]; then
        echo "Auto-sync direction: repo -> config"
        sync_direction "$repo_dir" "$config_dir"
    elif [[ "$pull_needed" == true ]]; then
        echo "Auto-sync direction: config -> repo"
        sync_direction "$config_dir" "$repo_dir"
    else
        echo "Already in sync"
    fi
}

case "$command" in
    status) show_status ;;
    push) detect_repo; sync_direction "$repo_dir" "$config_dir" ;;
    pull) detect_repo; sync_direction "$config_dir" "$repo_dir" ;;
    auto) auto_sync ;;
esac
