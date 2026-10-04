#!/bin/bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

assert_file_contains() {
  local file="$1" expected="$2" content
  content="$(<"$file")"
  [[ "$content" == *"$expected"* ]]
}

assert_no_non_zeus_entries() {
  local dir="$1" kind="$2" entry
  for entry in "$dir"/*; do
    [[ -e "$entry" ]] || continue
    case "$kind:$(basename "$entry")" in
      skill:zeus-*) ;;
      command:zeus-*.md) ;;
      *) echo "unexpected entry: $entry" >&2; return 1 ;;
    esac
  done
}

grep -q '^  audit)' "$root/bin/openzeus"
grep -q '^  inspect)' "$root/bin/openzeus"

for script in "$root/scripts/install.sh" "$root/scripts/sync-utils.sh" "$root/scripts/create-utils.sh" "$root/scripts/setup-hooks.sh" "$root/scripts/doctor.sh" "$root/scripts/validate.sh" "$root/scripts/diff.sh" "$root/scripts/upgrade.sh" "$root/bin/openzeus"; do
  [[ -x "$script" ]] || { echo "not executable: $script" >&2; exit 1; }
  bash -n "$script"
done

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
assert_file_contains "$config/agents/demo-agent.md" 'permissions:'
assert_file_contains "$config/agents/demo-agent.md" 'action: shell'
"$root/scripts/create-utils.sh" --config "$config" skill demo-skill 'desc'
assert_file_contains "$config/skills/demo-skill/SKILL.md" 'name: demo-skill'
"$root/scripts/create-utils.sh" --config "$config" command demo-command 'desc'
assert_file_contains "$config/commands/demo-command.md" '$ARGUMENTS'
printf '%s\n' 'keep command' > "$config/commands/demo-command.md"
"$root/scripts/create-utils.sh" --config "$config" command demo-command 'new desc' >/dev/null
assert_file_contains "$config/commands/demo-command.md" 'keep command'
"$root/scripts/create-utils.sh" --force --config "$config" command demo-command 'forced desc' >/dev/null
assert_file_contains "$config/commands/demo-command.md" 'forced desc'

default_create_config="$tmp/default-create-config"
outside_dir="$tmp/outside-project"
mkdir -p "$outside_dir"
(cd "$outside_dir" && OPENCODE_CONFIG_DIR="$default_create_config" "$root/bin/openzeus" create command outside-command 'outside desc' >/dev/null)
[[ -f "$default_create_config/commands/outside-command.md" ]]
[[ ! -f "$root/commands/outside-command.md" ]]

OPENCODE_CONFIG_DIR="$config" "$root/scripts/install.sh" --dry-run --target "$install_dir" >/dev/null
[[ ! -e "$install_dir" ]]
OPENCODE_CONFIG_DIR="$config" "$root/scripts/install.sh" --target "$install_dir" >/dev/null
[[ -f "$install_dir/agents/OpenZeus.md" ]]
assert_no_non_zeus_entries "$install_dir/skills" skill
assert_no_non_zeus_entries "$install_dir/commands" command
[[ -x "$install_dir/sync-utils.sh" && -x "$install_dir/create-utils.sh" && -x "$install_dir/setup-hooks.sh" && -x "$install_dir/doctor.sh" ]]

printf '%s\n' 'local change' > "$install_dir/agents/OpenZeus.md"
OPENCODE_CONFIG_DIR="$config" "$root/scripts/install.sh" --target "$install_dir" >/dev/null
assert_file_contains "$install_dir/agents/OpenZeus.md" 'local change'
OPENCODE_CONFIG_DIR="$config" "$root/scripts/install.sh" --force --backup --target "$install_dir" >/dev/null
backup_found=false
for backup in "$install_dir"/agents/OpenZeus.md.bak.*; do
  [[ -e "$backup" ]] || continue
  backup_found=true
done
[[ "$backup_found" == true ]]

env_install="$tmp/env-install"
OPENCODE_CONFIG_DIR="$env_install" "$root/scripts/install.sh" >/dev/null
[[ -f "$env_install/agents/OpenZeus.md" ]]

core_install="$tmp/core-install"
OPENCODE_CONFIG_DIR="$core_install" "$root/scripts/install.sh" --core >/dev/null
[[ -f "$core_install/agents/OpenZeus.md" && -d "$core_install/skills/zeus-diagnostics" && -d "$core_install/skills/zeus-migration" ]]
core_doctor_out="$(OPENCODE_CONFIG_DIR="$core_install" "$root/bin/openzeus" doctor)"
[[ "$core_doctor_out" == *"OpenZeus doctor: ok"* ]]
OPENCODE_CONFIG_DIR="$core_install" "$root/bin/openzeus" diff --ci >/dev/null
core_upgrade_config="$tmp/core-upgrade-config"
OPENCODE_CONFIG_DIR="$core_upgrade_config" "$root/scripts/install.sh" --core >/dev/null
OPENCODE_CONFIG_DIR="$core_upgrade_config" "$root/bin/openzeus" upgrade --apply >/dev/null
[[ "$(<"$core_upgrade_config/.openzeus-install-profile")" == core ]]
OPENCODE_CONFIG_DIR="$core_upgrade_config" "$root/bin/openzeus" doctor >/dev/null
OPENCODE_CONFIG_DIR="$core_upgrade_config" "$root/bin/openzeus" diff --ci >/dev/null
printf '%s\n' all > "$core_upgrade_config/.openzeus-install-profile"
OPENCODE_CONFIG_DIR="$core_upgrade_config" "$root/bin/openzeus" rollback --apply >/dev/null
[[ "$(<"$core_upgrade_config/.openzeus-install-profile")" == core ]]
OPENCODE_CONFIG_DIR="$core_upgrade_config" "$root/bin/openzeus" doctor >/dev/null
OPENCODE_CONFIG_DIR="$core_upgrade_config" "$root/bin/openzeus" diff --ci >/dev/null
legacy_extras_install="$tmp/legacy-extras-install"
OPENCODE_CONFIG_DIR="$legacy_extras_install" "$root/scripts/install.sh" --extras >/dev/null 2>&1
[[ -d "$legacy_extras_install/skills/zeus-diagnostics" && -d "$legacy_extras_install/skills/zeus-migration" ]]

type_mismatch_config="$tmp/type-mismatch-config"
"$root/scripts/install.sh" --target "$type_mismatch_config" >/dev/null
rm -rf "$type_mismatch_config/skills/zeus-diagnostics"
printf '%s\n' 'stale file' > "$type_mismatch_config/skills/zeus-diagnostics"
"$root/scripts/install.sh" --force --backup --target "$type_mismatch_config" >/dev/null
[[ -d "$type_mismatch_config/skills/zeus-diagnostics" ]]
[[ -f "$type_mismatch_config/skills/zeus-diagnostics/SKILL.md" ]]
type_backup_found=false
for backup in "$type_mismatch_config"/skills/zeus-diagnostics.bak.*; do
  [[ -e "$backup" ]] || continue
  type_backup_found=true
done
[[ "$type_backup_found" == true ]]

git init -q "$repo"
(cd "$repo" && "$root/scripts/setup-hooks.sh" --dry-run >/dev/null)
(cd "$repo" && "$root/scripts/setup-hooks.sh" >/dev/null)
[[ -x "$repo/.git/hooks/post-merge" && -x "$repo/.git/hooks/pre-push" ]]
assert_file_contains "$repo/.git/hooks/post-merge" '$repo_root/scripts/sync-utils.sh'

sync_config="$tmp/sync-config"
mkdir -p "$sync_config"
status_out="$(OPENCODE_CONFIG_DIR="$config" "$root/scripts/sync-utils.sh" --repo "$repo" --config "$sync_config" status || true)"
[[ "$status_out" == *"MISSING config:agents/OpenZeus.md"* ]]
OPENCODE_CONFIG_DIR="$config" "$root/scripts/sync-utils.sh" --dry-run --repo "$repo" --config "$sync_config" push >/dev/null
[[ ! -e "$sync_config/agents/OpenZeus.md" ]]
OPENCODE_CONFIG_DIR="$config" "$root/scripts/sync-utils.sh" --repo "$repo" --config "$sync_config" push >/dev/null
OPENCODE_CONFIG_DIR="$config" "$root/scripts/sync-utils.sh" --repo "$repo" --config "$sync_config" status >/dev/null
[[ -f "$sync_config/skills/zeus-alpha/reference.md" ]]

printf '%s\n' 'config conflict' > "$sync_config/agents/OpenZeus.md"
if OPENCODE_CONFIG_DIR="$config" "$root/scripts/sync-utils.sh" --repo "$repo" --config "$sync_config" push >/dev/null 2>&1; then
  echo "expected sync conflict" >&2
  exit 1
fi
OPENCODE_CONFIG_DIR="$config" "$root/scripts/sync-utils.sh" --force --backup --repo "$repo" --config "$sync_config" push >/dev/null
backup_found=false
for backup in "$sync_config"/agents/OpenZeus.md.bak.*; do
  [[ -e "$backup" ]] || continue
  backup_found=true
done
[[ "$backup_found" == true ]]

auto_config="$tmp/auto-config"
mkdir -p "$auto_config"
auto_out="$(OPENCODE_CONFIG_DIR="$config" "$root/scripts/sync-utils.sh" --repo "$repo" --config "$auto_config" auto)"
[[ "$auto_out" == *"repo -> config"* ]]
[[ -f "$auto_config/agents/OpenZeus.md" ]]

doctor_out="$(OPENCODE_CONFIG_DIR="$install_dir" "$root/bin/openzeus" doctor)"
[[ "$doctor_out" == *"OpenZeus doctor: ok"* ]]

drift_config="$tmp/drift-config"
cp -R "$install_dir" "$drift_config"
rm -f "$drift_config/agents/OpenZeus.md"
printf '%s\n' 'different skill' > "$drift_config/skills/zeus-diagnostics/SKILL.md"
printf '%s\n' 'different helper' > "$drift_config/doctor.sh"
drift_fix_plan_out="$(OPENCODE_CONFIG_DIR="$drift_config" "$root/bin/openzeus" doctor --fix-plan)"
[[ "$drift_fix_plan_out" == *"WARN OpenZeus agent missing from config"* ]]
[[ "$drift_fix_plan_out" == *"WARN skill zeus-diagnostics differs in config"* ]]
[[ "$drift_fix_plan_out" == *"WARN helper doctor.sh differs in config"* ]]
[[ "$drift_fix_plan_out" == *"openzeus install"* ]]
[[ "$drift_fix_plan_out" == *"openzeus install --force --backup"* ]]
[[ "$drift_fix_plan_out" == *"openzeus sync status"* ]]
[[ "$drift_fix_plan_out" != *"(none; no fixes required)" ]]

ci_doctor_fail=0
OPENCODE_CONFIG_DIR="$drift_config" "$root/bin/openzeus" doctor --ci >/dev/null || ci_doctor_fail=$?
[[ "$ci_doctor_fail" -ne 0 ]]

missing_config="$tmp/missing-config"
fix_plan_out="$(OPENCODE_CONFIG_DIR="$missing_config" "$root/bin/openzeus" doctor --fix-plan)"
[[ "$fix_plan_out" == *"Suggested commands:"* && "$fix_plan_out" == *"openzeus install"* ]]

empty_existing_config="$tmp/existing-empty-config"
mkdir -p "$empty_existing_config"
empty_fix_plan_out="$(OPENCODE_CONFIG_DIR="$empty_existing_config" "$root/bin/openzeus" doctor --fix-plan)"
[[ "$empty_fix_plan_out" == *"OpenZeus doctor: warnings"* && "$empty_fix_plan_out" == *"openzeus install"* ]]

mkdir -p "$tmp/bin"
ln -s "$root/bin/openzeus" "$tmp/bin/openzeus"
"$tmp/bin/openzeus" help >/dev/null
"$tmp/bin/openzeus" doctor >/dev/null

inspect_home="$tmp/inspect-home"
inspect_config="$tmp/inspect-config"
inspect_project="$tmp/inspect-project"
mkdir -p "$inspect_home" "$inspect_config/agents" "$inspect_config/skills/shared" "$inspect_project/.opencode/skills/shared" "$inspect_project/.opencode/commands"
git init -q "$inspect_project"

cat > "$inspect_config/agents/legacy.md" <<'EOF'
---
description: legacy
mode: subagent
permission:
  bash: ask
---
EOF

cat > "$inspect_config/skills/shared/SKILL.md" <<'EOF'
---
name: Shared
description: Global shared skill.
---
EOF

cat > "$inspect_project/.opencode/skills/shared/SKILL.md" <<'EOF'
---
name: Shared
description: Project shared skill.
---
EOF

cat > "$inspect_project/.opencode/commands/legacy-command.md" <<'EOF'
---
description: legacy command
subtask: true
---
Run something.
EOF

inspect_json="$tmp/inspect.json"
OPENCODE_CONFIG_DIR="$inspect_config" "$root/bin/openzeus" inspect --target "$inspect_project" --json > "$inspect_json"
test_node="${OPENZEUS_NODE:-${npm_node_execpath:-}}"
[[ -n "$test_node" ]] || test_node="$(command -v node)"
"$test_node" -e '
const fs = require("fs");
const d = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
if (d.mode !== "filesystem") process.exit(1);
const collision = d.collisions.find(x => x.type === "skill" && x.id === "shared");
if (!collision || !collision.winner.source.startsWith("project-opencode:")) process.exit(2);
if (!d.warnings.some(x => x.code === "legacy_agent_permission")) process.exit(3);
if (!d.warnings.some(x => x.code === "legacy_command_subtask")) process.exit(4);
if (!d.inventory.skills.some(x => x.id === "shared" && x.winner === true)) process.exit(5);
' "$inspect_json"

inspect_human="$(OPENCODE_CONFIG_DIR="$inspect_config" "$root/bin/openzeus" inspect --target "$inspect_project")"
[[ "$inspect_human" == *"OpenZeus inspect (filesystem view)"* ]]
[[ "$inspect_human" == *"Collisions: 1"* ]]

audit_json="$tmp/audit.json"
OPENCODE_CONFIG_DIR="$inspect_config" "$root/bin/openzeus" audit --target "$inspect_project" --json > "$audit_json"
"$test_node" -e '
const fs = require("fs");
const d = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
if (d.status !== "warning") process.exit(1);
if (d.summary.warnings < 2) process.exit(2);
if (!d.findings.some(x => x.code === "legacy_agent_permission")) process.exit(3);
if (!d.findings.some(x => x.code === "legacy_command_subtask")) process.exit(4);
' "$audit_json"

audit_ci=0
OPENCODE_CONFIG_DIR="$inspect_config" "$root/bin/openzeus" audit --target "$inspect_project" --ci >/dev/null || audit_ci=$?
[[ "$audit_ci" -eq 1 ]]

audit_clean="$tmp/audit-clean"
mkdir -p "$audit_clean"
OPENCODE_CONFIG_DIR="$audit_clean" "$root/bin/openzeus" audit --target "$audit_clean" --ci >/dev/null
echo ok
