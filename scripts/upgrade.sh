#!/bin/bash
set -euo pipefail

cmd="upgrade"
dry_run=false
apply=false
config_dir="${OPENCODE_CONFIG_DIR:-${OPENZEUS_CONFIG_DIR:-${HOME}/.config/opencode}}"
backup_dir=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    upgrade) cmd="upgrade" ;;
    rollback) cmd="rollback" ;;
    --apply) apply=true ;;
    --dry-run) dry_run=true ;;
    --backup) [[ $# -ge 2 && "$2" != --* ]] || { echo "Missing value for --backup" >&2; exit 1; }; backup_dir="$2"; shift ;;
    -h|--help) echo "Usage: upgrade.sh upgrade|rollback [--dry-run] [--backup DIR]"; exit 0 ;;
  esac
  shift
done

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
backup_dir="${backup_dir:-$config_dir/.openzeus-backups}"

latest_backup() {
  local b latest=""
  for b in "$backup_dir"/*; do
    [[ -e "$b" ]] || continue
    [[ -z "$latest" || "$b" > "$latest" ]] && latest="$b"
  done
  [[ -n "$latest" ]] || return 1
  printf '%s\n' "$latest"
}

create_backup() {
  local backup="$1"
  mkdir -p "$backup"
  for path in $(managed_paths); do
    [[ -e "$config_dir/$path" ]] || continue
    mkdir -p "$backup/$(dirname "$path")"
    cp -R "$config_dir/$path" "$backup/$path"
  done
}

managed_paths() {
  printf '%s\n' .openzeus-install-profile
  printf '%s\n' agents/OpenZeus.md
  local item
  for item in "$root"/skills/zeus-*; do [[ -d "$item" ]] && printf '%s\n' "skills/$(basename "$item")"; done
  for item in "$root"/commands/zeus-*.md; do [[ -f "$item" ]] && printf '%s\n' "commands/$(basename "$item")"; done
  printf '%s\n' sync-utils.sh create-utils.sh setup-hooks.sh doctor.sh init-project.sh setup.sh validate.sh capture-command.sh diff.sh upgrade.sh
}

restore_backup() {
  local backup="$1" path=""
  mkdir -p "$config_dir"
  for path in $(managed_paths); do
    rm -rf "$config_dir/$path"
    [[ -e "$backup/$path" ]] || continue
    mkdir -p "$config_dir/$(dirname "$path")"
    cp -R "$backup/$path" "$config_dir/$path"
  done
}

case "$cmd" in
  upgrade)
    if [[ "$dry_run" == true || "$apply" != true ]]; then
      echo "Would backup $config_dir to $backup_dir and run openzeus install --force --backup"
      [[ "$apply" != true ]] && echo "Apply with: openzeus upgrade --apply"
      exit 0
    fi
    install_profile="all"
    [[ -f "$config_dir/.openzeus-install-profile" ]] && IFS= read -r install_profile < "$config_dir/.openzeus-install-profile"
    install_args=(--force --backup --target "$config_dir")
    case "$install_profile" in
      core) install_args+=(--core) ;;
      extras) install_args+=(--extras) ;;
      *) install_args+=(--all) ;;
    esac
    mkdir -p "$backup_dir"
    ts="$(date +%Y%m%d%H%M%S)"
    backup="$backup_dir/install-$ts"
    create_backup "$backup"
    echo "backup: $backup"
    "$root/scripts/install.sh" "${install_args[@]}"
    ;;
  rollback)
    b="$(latest_backup || true)"
    [[ -n "$b" ]] || { echo "no backup"; exit 1; }
    if [[ "$dry_run" == true || "$apply" != true ]]; then
      echo "Would restore $b to $config_dir"
      [[ "$apply" != true ]] && echo "Apply with: openzeus rollback --apply"
      exit 0
    fi
    restore_backup "$b"
    echo "restored $b"
    ;;
esac
