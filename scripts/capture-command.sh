#!/bin/bash
set -euo pipefail

name=""
prompt=""
target_dir="${OPENCODE_CONFIG_DIR:-${OPENZEUS_CONFIG_DIR:-${HOME}/.config/opencode}}"
dry_run=false
force=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) [[ $# -ge 2 && "$2" != --* ]] || { echo "Missing value for --name" >&2; exit 1; }; name="$2"; shift ;;
    --prompt) [[ $# -ge 2 && "$2" != --* ]] || { echo "Missing value for --prompt" >&2; exit 1; }; prompt="$2"; shift ;;
    --target) [[ $# -ge 2 && "$2" != --* ]] || { echo "Missing value for --target" >&2; exit 1; }; target_dir="$2"; shift ;;
    --dry-run) dry_run=true ;;
    --force) force=true ;;
    -h|--help) echo "Usage: capture-command.sh --name NAME --prompt TEXT [--target DIR] [--dry-run] [--force]"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

[[ "$name" =~ ^[a-z0-9][a-z0-9._-]*$ ]] || { echo "Invalid name: $name" >&2; exit 1; }
[[ -n "$prompt" ]] || prompt="$(cat)"
[[ -n "$name" && -n "$prompt" ]] || { echo "missing name/prompt" >&2; exit 1; }

path="$target_dir/commands/$name.md"
desc="Generated command for ${name//-/ } from prompt"
content=$(cat <<EOF
---
description: $desc
---

# Command: /$name

## Prompt

$prompt

## Input



Use \$ARGUMENTS as the complete user input.
EOF
)

if [[ "$dry_run" == true ]]; then
  echo "DRY-RUN: no files written: $path"
  exit 0
fi

mkdir -p "$target_dir/commands"

if [[ -e "$path" && "$force" != true ]]; then
  echo "SKIP existing: $path"
  exit 0
fi

printf '%s\n' "$content" | sed 's/^Use \\$ARGUMENTS/Use $ARGUMENTS/' > "$path"
echo "Created $path"
