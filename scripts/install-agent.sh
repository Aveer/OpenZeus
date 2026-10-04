#!/bin/bash
set -euo pipefail

dry_run=false
force=false
backup=false
target_dir="${OPENCODE_CONFIG_DIR:-${OPENZEUS_CONFIG_DIR:-${XDG_CONFIG_HOME:-${HOME}/.config}/opencode}}"

usage() {
  cat <<EOF
Usage: install-agent.sh [--dry-run] [--force] [--backup] [--target DIR]

Installs only agents/OpenZeus.md. OpenZeus skills and runtime tools are owned
by the native OpenCode V2 plugin.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) dry_run=true ;;
    --force) force=true ;;
    --backup) backup=true ;;
    --target)
      [[ $# -ge 2 && "$2" != --* ]] || { echo "Missing value for --target" >&2; exit 1; }
      target_dir="$2"
      shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
  shift
done

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
src="$root/agents/OpenZeus.md"
dst="$target_dir/agents/OpenZeus.md"

[[ -f "$src" ]] || { echo "OpenZeus agent source missing: $src" >&2; exit 1; }

if [[ "$dry_run" == true ]]; then
  echo "DRY-RUN: install $src -> $dst"
  exit 0
fi

mkdir -p "$(dirname "$dst")"

if [[ -f "$dst" ]] && cmp -s "$src" "$dst"; then
  echo "OpenZeus agent already current: $dst"
  exit 0
fi

if [[ -e "$dst" && "$force" != true ]]; then
  echo "Existing OpenZeus agent differs; not overwritten: $dst" >&2
  echo "Use --force, optionally with --backup, after reviewing the difference." >&2
  exit 1
fi

if [[ -e "$dst" && "$backup" == true ]]; then
  backup_path="${dst}.bak.$(date +%Y%m%d%H%M%S)"
  cp -p "$dst" "$backup_path"
  echo "backup: $backup_path"
fi

rm -f "$dst"
cp -f "$src" "$dst"
echo "OpenZeus agent installed: $dst"
echo "Plugin requirement: opencode plugin add openzeus"
