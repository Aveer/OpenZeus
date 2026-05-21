#!/bin/bash
set -euo pipefail

dry_run=false
force=false

usage() {
    cat <<EOF
Usage: setup-hooks.sh [--dry-run] [--force]

Installs optional Git hooks into the current repository:
  post-merge  syncs repo -> config after pulls/merges
  pre-push    runs sync status and warns about divergence
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) dry_run=true ;;
        --force) force=true ;;
        -h|--help|help) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
    esac
    shift
done

repo_root="$(git rev-parse --show-toplevel)"
hooks_path="$(git -C "$repo_root" rev-parse --git-path hooks)"
case "$hooks_path" in
    /*) hooks_dir="$hooks_path" ;;
    *) hooks_dir="$repo_root/$hooks_path" ;;
esac

write_hook() {
    local path="$1"
    local body="$2"

    if [[ "$dry_run" == true ]]; then
        printf 'WRITE %s\n' "$path"
        return 0
    fi

    if [[ -e "$path" && "$force" != true ]]; then
        echo "skip existing hook: $path"
        return 0
    fi

    mkdir -p "$(dirname "$path")"
    printf '%s\n' "$body" > "$path"
    chmod +x "$path"
    echo "installed hook: $path"
}

post_merge='#!/bin/bash
set -euo pipefail
repo_root="$(git rev-parse --show-toplevel)"
if [[ -x "$repo_root/scripts/sync-utils.sh" ]]; then
    "$repo_root/scripts/sync-utils.sh" push
fi'

pre_push='#!/bin/bash
set -euo pipefail
repo_root="$(git rev-parse --show-toplevel)"
if [[ -x "$repo_root/scripts/sync-utils.sh" ]]; then
    "$repo_root/scripts/sync-utils.sh" status || {
        echo "OpenZeus sync status has differences; run scripts/sync-utils.sh status" >&2
    }
fi'

write_hook "$hooks_dir/post-merge" "$post_merge"
write_hook "$hooks_dir/pre-push" "$pre_push"

echo "OpenZeus hooks configured in $hooks_dir"
