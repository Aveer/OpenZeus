#!/bin/bash
set -euo pipefail

dry_run=false
force=false
repo_dir=""
config_dir="${OPENCODE_CONFIG_DIR:-${OPENZEUS_CONFIG_DIR:-${HOME}/.config/opencode}}"
location=""
type=""
script_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
    cat <<EOF
Usage: create-utils.sh [--dry-run] [--force] [--repo [DIR]] [--config [DIR]] <agent|skill|command> <name> [description] [template]

Creates valid OpenCode asset templates. If no location is specified and the
current directory is the OpenZeus source repository, files are created in that
repo; otherwise they are created in the OpenCode config directory. Existing
files are skipped unless --force is supplied.
EOF
}

is_type() {
    [[ "$1" == agent || "$1" == skill || "$1" == command ]]
}

yaml_quote() {
    local value="$1"
    value="${value//\\/\\\\}"
    value="${value//\"/\\\"}"
    printf '"%s"' "$value"
}

current_openzeus_repo() {
    local root=""
    if root="$(git -C "$(pwd)" rev-parse --show-toplevel 2>/dev/null)" && [[ -f "$root/agents/OpenZeus.md" ]]; then
        printf '%s' "$root"
        return 0
    fi
    return 1
}

detect_repo() {
    if [[ -n "$repo_dir" ]]; then
        printf '%s' "$repo_dir"
        return 0
    fi

    current_openzeus_repo
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) dry_run=true ;;
        --force) force=true ;;
        --repo)
            location="repo"
            if [[ $# -gt 1 && "$2" != --* ]] && ! is_type "$2"; then
                repo_dir="$2"
                shift
            fi
            ;;
        --config)
            location="config"
            if [[ $# -gt 1 && "$2" != --* ]] && ! is_type "$2"; then
                config_dir="$2"
                shift
            fi
            ;;
        -h|--help|help) usage; exit 0 ;;
        agent|skill|command) type="$1" ;;
        *) break ;;
    esac
    shift
done

if [[ -z "$type" || $# -lt 1 ]]; then
    usage >&2
    exit 1
fi

name="$1"
description="${2:-Useful OpenCode asset for $name.}"
template="${3:-Use \$ARGUMENTS as the complete command input.}"

if [[ ! "$name" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]]; then
    echo "Invalid name: $name" >&2
    exit 1
fi

if [[ -z "$location" ]]; then
    if repo_dir="$(current_openzeus_repo 2>/dev/null)"; then
        location="repo"
    else
        location="config"
    fi
fi

target_root() {
    if [[ "$location" == repo ]]; then
        detect_repo || { echo "OpenZeus repo not found; pass --repo DIR" >&2; exit 1; }
    else
        printf '%s' "$config_dir"
    fi
}

write_file() {
    local path="$1"
    local content="$2"

    if [[ "$dry_run" == true ]]; then
        if [[ -e "$path" && "$force" == false ]]; then
            printf 'SKIP existing: %s\n' "$path"
        else
            printf 'WRITE %s\n' "$path"
        fi
        return 0
    fi

    mkdir -p "$(dirname "$path")"
    if [[ -e "$path" && "$force" == false ]]; then
        printf 'SKIP existing: %s\n' "$path"
        return 0
    fi

    printf '%s\n' "$content" > "$path"
    printf 'Created %s\n' "$path"
}

case "$type" in
    agent)
        write_file "$(target_root)/agents/$name.md" "---
description: $(yaml_quote "$description")
mode: subagent
permission:
  edit: ask
  bash: ask
---

You are $name, a focused OpenCode subagent.

## Purpose

$description

## Operating Rules

- Stay within the delegated scope.
- Ask before editing files or running mutating shell commands.
- Prefer small, reversible changes.
- Return a concise summary with verification evidence.
"
        ;;
    skill)
        if [[ ! "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
            echo "Skill names must be lowercase kebab-case: $name" >&2
            exit 1
        fi
        write_file "$(target_root)/skills/$name/SKILL.md" "---
name: $name
description: $(yaml_quote "$description")
---

# $name

## Summary

$description

## When to Use

Use this skill when the user asks for workflows related to $name.

## Workflow

1. Identify the relevant files, tools, or docs.
2. Apply the smallest useful pattern.
3. Verify the result before reporting success.

---

End of skill.
"
        ;;
    command)
        write_file "$(target_root)/commands/$name.md" "---
description: $(yaml_quote "$description")
---

# Command: /$name

Use \$ARGUMENTS as the full user request. Positional arguments such as \$1 and \$2 may be used when the command needs structured inputs.

## Prompt

$template

## Input

\$ARGUMENTS
"
        ;;
esac
