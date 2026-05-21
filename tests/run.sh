#!/bin/bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

assert_file_contains() {
    local file="$1"
    local expected="$2"
    local content=""
    content="$(<"$file")"
    [[ "$content" == *"$expected"* ]]
}

assert_no_non_zeus_entries() {
    local dir="$1"
    local kind="$2"
    local entry=""

    for entry in "$dir"/*; do
        [[ -e "$entry" ]] || continue
        case "$kind:$(basename "$entry")" in
            skill:zeus-*) ;;
            command:zeus-*.md) ;;
            *) echo "unexpected entry: $entry" >&2; return 1 ;;
        esac
    done
}

chmod +x "$root"/scripts/*.sh "$root/bin/openzeus"
bash -n \
    "$root/scripts/install.sh" \
    "$root/scripts/sync-utils.sh" \
    "$root/scripts/create-utils.sh" \
    "$root/scripts/setup-hooks.sh" \
    "$root/scripts/doctor.sh" \
    "$root/bin/openzeus"

config="$tmp/config"
repo="$tmp/repo"
install_dir="$tmp/install"
mkdir -p "$config" "$repo/agents" "$repo/skills/zeus-alpha" "$repo/skills/other" "$repo/commands"

cat > "$repo/agents/OpenZeus.md" <<'EOF'
---
description: repo agent
mode: subagent
permission:
  edit: ask
  bash: ask
---
EOF
printf '%s\n' 'repo skill' > "$repo/skills/zeus-alpha/SKILL.md"
printf '%s\n' 'support' > "$repo/skills/zeus-alpha/reference.md"
printf '%s\n' 'skip skill' > "$repo/skills/other/SKILL.md"
printf '%s\n' 'repo command' > "$repo/commands/zeus-one.md"
printf '%s\n' 'skip command' > "$repo/commands/not-zeus.md"

"$root/scripts/create-utils.sh" --dry-run --config "$config" agent demo-agent 'desc' >/dev/null
[[ ! -e "$config/agents/demo-agent.md" ]]
"$root/scripts/create-utils.sh" --config "$config" agent demo-agent 'desc'
assert_file_contains "$config/agents/demo-agent.md" 'mode: subagent'
assert_file_contains "$config/agents/demo-agent.md" 'permission:'
"$root/scripts/create-utils.sh" --config "$config" skill demo-skill 'desc'
assert_file_contains "$config/skills/demo-skill/SKILL.md" 'name: demo-skill'
"$root/scripts/create-utils.sh" --config "$config" command demo-command 'desc'
assert_file_contains "$config/commands/demo-command.md" '$ARGUMENTS'

"$root/scripts/install.sh" --dry-run --target "$install_dir" >/dev/null
[[ ! -e "$install_dir" ]]
"$root/scripts/install.sh" --target "$install_dir" >/dev/null
[[ -f "$install_dir/agents/OpenZeus.md" ]]
assert_no_non_zeus_entries "$install_dir/skills" skill
assert_no_non_zeus_entries "$install_dir/commands" command
[[ -x "$install_dir/sync-utils.sh" && -x "$install_dir/create-utils.sh" && -x "$install_dir/setup-hooks.sh" && -x "$install_dir/doctor.sh" ]]

printf '%s\n' 'local change' > "$install_dir/agents/OpenZeus.md"
"$root/scripts/install.sh" --target "$install_dir" >/dev/null
assert_file_contains "$install_dir/agents/OpenZeus.md" 'local change'
"$root/scripts/install.sh" --force --backup --target "$install_dir" >/dev/null
backup_found=false
for backup in "$install_dir"/agents/OpenZeus.md.bak.*; do
    [[ -e "$backup" ]] || continue
    backup_found=true
done
[[ "$backup_found" == true ]]

env_install="$tmp/env-install"
OPENCODE_CONFIG_DIR="$env_install" "$root/scripts/install.sh" >/dev/null
[[ -f "$env_install/agents/OpenZeus.md" ]]

git init -q "$repo"
(cd "$repo" && "$root/scripts/setup-hooks.sh" --dry-run >/dev/null)
(cd "$repo" && "$root/scripts/setup-hooks.sh" >/dev/null)
[[ -x "$repo/.git/hooks/post-merge" && -x "$repo/.git/hooks/pre-push" ]]
assert_file_contains "$repo/.git/hooks/post-merge" '$repo_root/scripts/sync-utils.sh'

sync_config="$tmp/sync-config"
mkdir -p "$sync_config"
status_out="$($root/scripts/sync-utils.sh --repo "$repo" --config "$sync_config" status || true)"
[[ "$status_out" == *"MISSING config:agents/OpenZeus.md"* ]]
"$root/scripts/sync-utils.sh" --dry-run --repo "$repo" --config "$sync_config" push >/dev/null
[[ ! -e "$sync_config/agents/OpenZeus.md" ]]
"$root/scripts/sync-utils.sh" --repo "$repo" --config "$sync_config" push >/dev/null
"$root/scripts/sync-utils.sh" --repo "$repo" --config "$sync_config" status >/dev/null
[[ -f "$sync_config/skills/zeus-alpha/reference.md" ]]

printf '%s\n' 'config conflict' > "$sync_config/agents/OpenZeus.md"
if "$root/scripts/sync-utils.sh" --repo "$repo" --config "$sync_config" push >/dev/null 2>&1; then
    echo "expected sync conflict" >&2
    exit 1
fi
"$root/scripts/sync-utils.sh" --force --backup --repo "$repo" --config "$sync_config" push >/dev/null
backup_found=false
for backup in "$sync_config"/agents/OpenZeus.md.bak.*; do
    [[ -e "$backup" ]] || continue
    backup_found=true
done
[[ "$backup_found" == true ]]

auto_config="$tmp/auto-config"
mkdir -p "$auto_config"
auto_out="$($root/scripts/sync-utils.sh --repo "$repo" --config "$auto_config" auto)"
[[ "$auto_out" == *"repo -> config"* ]]
[[ -f "$auto_config/agents/OpenZeus.md" ]]

doctor_out="$("$root/bin/openzeus" doctor)"
[[ "$doctor_out" == *"OpenZeus doctor: ok"* ]]

mkdir -p "$tmp/bin"
ln -s "$root/bin/openzeus" "$tmp/bin/openzeus"
"$tmp/bin/openzeus" help >/dev/null
"$tmp/bin/openzeus" doctor >/dev/null

echo ok
