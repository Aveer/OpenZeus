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

for script in "$root/scripts/install.sh" "$root/scripts/sync-utils.sh" "$root/scripts/create-utils.sh" "$root/scripts/setup-hooks.sh" "$root/scripts/doctor.sh" "$root/scripts/init-project.sh" "$root/scripts/setup.sh" "$root/scripts/validate.sh" "$root/scripts/capture-command.sh" "$root/scripts/diff.sh" "$root/scripts/upgrade.sh" "$root/bin/openzeus"; do
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
assert_file_contains "$config/agents/demo-agent.md" 'permission:'
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
[[ -x "$install_dir/sync-utils.sh" && -x "$install_dir/create-utils.sh" && -x "$install_dir/setup-hooks.sh" && -x "$install_dir/doctor.sh" && -x "$install_dir/init-project.sh" ]]

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
[[ -f "$core_install/agents/OpenZeus.md" && -d "$core_install/skills/zeus-core" && ! -d "$core_install/skills/zeus-swarm" ]]
[[ -f "$core_install/commands/zeus-git-commit.md" && ! -f "$core_install/commands/zeus-kanban.md" ]]
core_doctor_out="$(OPENCODE_CONFIG_DIR="$core_install" "$root/bin/openzeus" doctor)"
[[ "$core_doctor_out" == *"OpenZeus doctor: ok"* ]]
OPENCODE_CONFIG_DIR="$core_install" "$root/bin/openzeus" diff --ci >/dev/null
core_upgrade_config="$tmp/core-upgrade-config"
OPENCODE_CONFIG_DIR="$core_upgrade_config" "$root/scripts/install.sh" --core >/dev/null
OPENCODE_CONFIG_DIR="$core_upgrade_config" "$root/bin/openzeus" upgrade --apply >/dev/null
[[ -f "$core_upgrade_config/commands/zeus-git-commit.md" && ! -f "$core_upgrade_config/commands/zeus-kanban.md" ]]
[[ "$(<"$core_upgrade_config/.openzeus-install-profile")" == core ]]
OPENCODE_CONFIG_DIR="$core_upgrade_config" "$root/bin/openzeus" doctor >/dev/null
OPENCODE_CONFIG_DIR="$core_upgrade_config" "$root/bin/openzeus" diff --ci >/dev/null
printf '%s\n' all > "$core_upgrade_config/.openzeus-install-profile"
OPENCODE_CONFIG_DIR="$core_upgrade_config" "$root/bin/openzeus" rollback --apply >/dev/null
[[ "$(<"$core_upgrade_config/.openzeus-install-profile")" == core ]]
OPENCODE_CONFIG_DIR="$core_upgrade_config" "$root/bin/openzeus" doctor >/dev/null
OPENCODE_CONFIG_DIR="$core_upgrade_config" "$root/bin/openzeus" diff --ci >/dev/null
extras_install="$tmp/extras-install"
OPENCODE_CONFIG_DIR="$extras_install" "$root/scripts/install.sh" --extras >/dev/null
[[ ! -d "$extras_install/skills/zeus-core" && -d "$extras_install/skills/zeus-swarm" ]]
[[ ! -f "$extras_install/commands/zeus-git-commit.md" && -f "$extras_install/commands/zeus-kanban.md" ]]

type_mismatch_config="$tmp/type-mismatch-config"
"$root/scripts/install.sh" --target "$type_mismatch_config" >/dev/null
rm -f "$type_mismatch_config/commands/zeus-git-commit.md"
mkdir -p "$type_mismatch_config/commands/zeus-git-commit.md"
printf '%s\n' 'nested stale file' > "$type_mismatch_config/commands/zeus-git-commit.md/stale.txt"
"$root/scripts/install.sh" --force --backup --target "$type_mismatch_config" >/dev/null
[[ -f "$type_mismatch_config/commands/zeus-git-commit.md" ]]
assert_file_contains "$type_mismatch_config/commands/zeus-git-commit.md" 'description:'
type_backup_found=false
for backup in "$type_mismatch_config"/commands/zeus-git-commit.md.bak.*; do
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
printf '%s\n' 'different skill' > "$drift_config/skills/zeus-core/SKILL.md"
printf '%s\n' 'different command' > "$drift_config/commands/zeus-git-commit.md"
printf '%s\n' 'different helper' > "$drift_config/doctor.sh"
chmod -x "$drift_config/init-project.sh"
drift_fix_plan_out="$(OPENCODE_CONFIG_DIR="$drift_config" "$root/bin/openzeus" doctor --fix-plan)"
[[ "$drift_fix_plan_out" == *"WARN OpenZeus agent missing from config"* ]]
[[ "$drift_fix_plan_out" == *"WARN skill zeus-core differs in config"* ]]
[[ "$drift_fix_plan_out" == *"WARN command zeus-git-commit.md differs in config"* ]]
[[ "$drift_fix_plan_out" == *"WARN helper doctor.sh differs in config"* ]]
[[ "$drift_fix_plan_out" == *"WARN helper init-project.sh is not executable in config"* ]]
[[ "$drift_fix_plan_out" == *"openzeus install"* ]]
[[ "$drift_fix_plan_out" == *"openzeus install --force --backup"* ]]
[[ "$drift_fix_plan_out" == *"openzeus sync status"* ]]
[[ "$drift_fix_plan_out" == *"chmod +x $drift_config/init-project.sh"* ]]
[[ "$drift_fix_plan_out" != *"(none; no fixes required)" ]]

ci_doctor_fail=0
OPENCODE_CONFIG_DIR="$drift_config" "$root/bin/openzeus" doctor --ci >/dev/null || ci_doctor_fail=$?
[[ "$ci_doctor_fail" -ne 0 ]]

setup_project="$tmp/setup-project"
mkdir -p "$setup_project"
setup_plan_out="$($root/bin/openzeus setup --plan --target "$setup_project")"
[[ "$setup_plan_out" == *"Detected stack:"* && "$setup_plan_out" == *"Proposed files:"* && "$setup_plan_out" == *"Apply: openzeus setup --apply"* ]]
recipe_plan_out="$($root/bin/openzeus setup --plan --target "$setup_project" --recipe python)"
[[ "$recipe_plan_out" == *"recipe python"* ]]
(cd "$setup_project" && "$root/bin/openzeus" setup --apply --target "$setup_project" >/dev/null)
[[ -f "$setup_project/.opencode/agents/project-guide.md" && -f "$setup_project/.opencode/context/architecture.md" && -f "$setup_project/.opencode/context/commands.md" && -f "$setup_project/.opencode/context/testing.md" ]]
recipe_project="$tmp/recipe-project"
mkdir -p "$recipe_project"
"$root/bin/openzeus" setup --apply --target "$recipe_project" --recipe python >/dev/null
assert_file_contains "$recipe_project/.opencode/commands/test.md" 'pytest'
assert_file_contains "$recipe_project/.opencode/context/architecture.md" 'Recipe: python'
assert_file_contains "$recipe_project/.opencode/context/commands.md" 'Test: pytest'
context_dry_run="$($root/bin/openzeus context init --target "$setup_project" --dry-run)"
[[ "$context_dry_run" == *"DRY-RUN:"* ]]

recipes_out="$($root/bin/openzeus recipes)"
[[ "$recipes_out" == *"node:"* && "$recipes_out" == *"solo-dev:"* ]]

validate_fail=0
OPENCODE_CONFIG_DIR="$drift_config" "$root/bin/openzeus" validate --ci >/dev/null || validate_fail=$?
[[ "$validate_fail" -ne 0 ]]

bad_project="$tmp/bad-project"
mkdir -p "$bad_project/.opencode/agents" "$bad_project/.opencode/skills/badskill" "$bad_project/.opencode/commands"
cat > "$bad_project/.opencode/agents/bad.md" <<'EOF'
---
description: bad
mode: allow
tools: yes
permission: allow
---
EOF
cat > "$bad_project/.opencode/skills/badskill/SKILL.md" <<'EOF'
---
name: badskill
---
EOF
cat > "$bad_project/.opencode/commands/bad.md" <<'EOF'
---
---
EOF
validate_project_fail=0
$root/bin/openzeus validate --project "$bad_project" --ci >/dev/null || validate_project_fail=$?
[[ "$validate_project_fail" -ne 0 ]]

capture_dir="$tmp/capture"
mkdir -p "$capture_dir"
capture_out="$($root/bin/openzeus capture-command --name release-note --prompt 'write release notes' --target "$capture_dir")"
[[ "$capture_out" == *"Created"* && -f "$capture_dir/commands/release-note.md" ]]
[[ "$(<"$capture_dir/commands/release-note.md")" == *"write release notes"* && "$(<"$capture_dir/commands/release-note.md")" == *'$ARGUMENTS'* ]]
capture_dry_out="$($root/bin/openzeus capture-command --name release-note --prompt 'dry' --target "$capture_dir" --dry-run)"
[[ "$capture_dry_out" == *"DRY-RUN: no files written"* ]]
capture_empty_dir="$tmp/capture-dry-empty"
capture_empty_out="$($root/bin/openzeus capture-command --name dry-only --prompt 'dry only' --target "$capture_empty_dir" --dry-run)"
[[ "$capture_empty_out" == *"DRY-RUN"* && ! -e "$capture_empty_dir" ]]

diff_out="$(OPENCODE_CONFIG_DIR="$config" "$root/bin/openzeus" diff --summary || true)"
[[ "$diff_out" == *"issue(s)"* ]]
extra_diff_config="$tmp/extra-diff-config"
OPENCODE_CONFIG_DIR="$extra_diff_config" "$root/scripts/install.sh" >/dev/null
mkdir -p "$extra_diff_config/skills/zeus-local-extra"
printf '%s\n' 'local' > "$extra_diff_config/skills/zeus-local-extra/SKILL.md"
extra_diff_out="$(OPENCODE_CONFIG_DIR="$extra_diff_config" "$root/bin/openzeus" diff)"
[[ "$extra_diff_out" == *"EXTRA zeus-local-extra"* ]]
rm -f "$extra_diff_config/upgrade.sh"
helper_diff_fail=0
OPENCODE_CONFIG_DIR="$extra_diff_config" "$root/bin/openzeus" diff --ci >/dev/null || helper_diff_fail=$?
[[ "$helper_diff_fail" -ne 0 ]]

upgrade_config="$tmp/upgrade-config"
OPENCODE_CONFIG_DIR="$upgrade_config" "$root/scripts/install.sh" >/dev/null
printf '%s\n' 'changed' > "$upgrade_config/agents/OpenZeus.md"
mkdir -p "$upgrade_config/.openzeus-backups"
before_backup_count=$(find "$upgrade_config/.openzeus-backups" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l | tr -d ' ')
upgrade_out="$(OPENCODE_CONFIG_DIR="$upgrade_config" "$root/bin/openzeus" upgrade --dry-run)"
after_backup_count=$(find "$upgrade_config/.openzeus-backups" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l | tr -d ' ')
[[ "$upgrade_out" == *"Would backup"* && "$before_backup_count" == "$after_backup_count" ]]
upgrade_apply_out="$(OPENCODE_CONFIG_DIR="$upgrade_config" "$root/bin/openzeus" upgrade --apply)"
[[ "$upgrade_apply_out" == *"OpenZeus assets installed"* ]]
after_apply_backup_count=$(find "$upgrade_config/.openzeus-backups" -mindepth 1 -maxdepth 1 2>/dev/null | wc -l | tr -d ' ')
[[ "$after_apply_backup_count" -gt "$after_backup_count" ]]
rollback_dry_out="$(OPENCODE_CONFIG_DIR="$upgrade_config" "$root/bin/openzeus" rollback --dry-run)"
[[ "$rollback_dry_out" == *"Would restore"* ]]
printf '%s\n' 'mutated after backup' > "$upgrade_config/agents/OpenZeus.md"
rollback_apply_out="$(OPENCODE_CONFIG_DIR="$upgrade_config" "$root/bin/openzeus" rollback --apply)"
[[ "$rollback_apply_out" == *"restored"* ]]
assert_file_contains "$upgrade_config/agents/OpenZeus.md" 'changed'

status_out="$(OPENCODE_CONFIG_DIR="$config" "$root/bin/openzeus" status)"
[[ "$status_out" == *"Package root:"* && "$status_out" == *"OpenZeus agent:"* ]]

clean_config="$tmp/clean-config"
OPENCODE_CONFIG_DIR="$clean_config" "$root/scripts/install.sh" >/dev/null
sync_clean_out="$(OPENCODE_CONFIG_DIR="$clean_config" "$root/bin/openzeus" status)"
[[ "$sync_clean_out" == *"Sync drift: clean"* ]]

empty_config="$tmp/empty-config"
mkdir -p "$empty_config"
sync_missing_out="$(OPENCODE_CONFIG_DIR="$empty_config" "$root/bin/openzeus" status)"
[[ "$sync_missing_out" == *"Sync drift:"* && "$sync_missing_out" != *"clean"* ]]

printf '%s\n' 'drift' >> "$config/agents/OpenZeus.md"
sync_drift_out="$(OPENCODE_CONFIG_DIR="$config" "$root/bin/openzeus" status)"
[[ "$sync_drift_out" == *"Sync drift:"* && "$sync_drift_out" != *"clean"* && "$sync_drift_out" == *"Next:"* ]]

list_out="$(OPENCODE_CONFIG_DIR="$config" "$root/bin/openzeus" list all)"
[[ "$list_out" == *"agents/OpenZeus.md"* && "$list_out" == *"zeus-git-commit.md"* ]]

skills_list_out="$(OPENCODE_CONFIG_DIR="$config" "$root/bin/openzeus" list skills)"
[[ "$skills_list_out" == *"skill: zeus-core"* && "$skills_list_out" != *"command:"* && "$skills_list_out" != *"agent:"* ]]
commands_list_out="$(OPENCODE_CONFIG_DIR="$config" "$root/bin/openzeus" list commands)"
[[ "$commands_list_out" == *"command: zeus-git-commit.md"* && "$commands_list_out" != *"skill:"* && "$commands_list_out" != *"agent:"* ]]
agents_list_out="$(OPENCODE_CONFIG_DIR="$config" "$root/bin/openzeus" list agents)"
[[ "$agents_list_out" == *"agent: agents/OpenZeus.md"* && "$agents_list_out" != *"skill:"* && "$agents_list_out" != *"command:"* ]]

different_skill_dir="$tmp/diff-skill"
mkdir -p "$different_skill_dir"
cp -R "$root/skills/zeus-core" "$different_skill_dir/zeus-core"
printf '%s\n' 'extra' > "$different_skill_dir/zeus-core/extra.md"
mkdir -p "$config/skills"
cp -R "$different_skill_dir/zeus-core" "$config/skills/"
skill_diff_list="$(OPENCODE_CONFIG_DIR="$config" "$root/bin/openzeus" list skills)"
[[ "$skill_diff_list" == *"skill: zeus-core [different]"* ]]

examples_out="$("$root/bin/openzeus" examples)"
[[ "$examples_out" == *"openzeus init-project"* && "$examples_out" == *"openzeus doctor --fix-plan"* && "$examples_out" == *"@OpenZeus audit"* ]]

project_dir="$tmp/project"
mkdir -p "$project_dir"
"$root/bin/openzeus" init-project --target "$project_dir" >/dev/null
[[ -f "$project_dir/.opencode/agents/project-guide.md" ]]
[[ -f "$project_dir/.opencode/commands/test.md" ]]
[[ -f "$project_dir/.opencode/commands/build.md" ]]
[[ -f "$project_dir/.opencode/skills/project-context/SKILL.md" ]]
[[ -f "$project_dir/.opencode/README.md" ]]
assert_file_contains "$project_dir/.opencode/agents/project-guide.md" 'mode: subagent'
assert_file_contains "$project_dir/.opencode/commands/test.md" '$ARGUMENTS'
assert_file_contains "$project_dir/.opencode/commands/test.md" 'No obvious test command'
assert_file_contains "$project_dir/.opencode/commands/build.md" 'No obvious build command'
assert_file_contains "$project_dir/.opencode/skills/project-context/SKILL.md" 'Type: generic'

printf '%s\n' 'keep' > "$project_dir/.opencode/README.md"
"$root/bin/openzeus" init-project --target "$project_dir" >/dev/null
assert_file_contains "$project_dir/.opencode/README.md" 'keep'
"$root/bin/openzeus" init-project --force --target "$project_dir" >/dev/null
assert_file_contains "$project_dir/.opencode/README.md" 'Starter'

npm_project="$tmp/npm-project"
mkdir -p "$npm_project"
cat > "$npm_project/package.json" <<'EOF'
{
  "name": "npm-project",
  "scripts": {
    "test": "echo npm test",
    "build": "echo npm build"
  }
}
EOF
(cd "$npm_project" && "$root/bin/openzeus" init-project >/dev/null)
assert_file_contains "$npm_project/.opencode/commands/test.md" 'npm test'
assert_file_contains "$npm_project/.opencode/commands/build.md" 'npm run build'
assert_file_contains "$npm_project/.opencode/skills/project-context/SKILL.md" 'Type: npm'

make_project="$tmp/make-project"
mkdir -p "$make_project"
cat > "$make_project/Makefile" <<'EOF'
test: deps
	@echo make test

build: assets
	@echo make build
EOF
(cd "$make_project" && "$root/bin/openzeus" init-project >/dev/null)
assert_file_contains "$make_project/.opencode/commands/test.md" 'make test'
assert_file_contains "$make_project/.opencode/commands/build.md" 'make build'
assert_file_contains "$make_project/.opencode/skills/project-context/SKILL.md" 'Type: make'

python_project="$tmp/python-project"
mkdir -p "$python_project"
touch "$python_project/pyproject.toml"
(cd "$python_project" && "$root/bin/openzeus" init-project >/dev/null)
assert_file_contains "$python_project/.opencode/commands/test.md" 'pytest'
assert_file_contains "$python_project/.opencode/commands/build.md" 'No obvious build command'
assert_file_contains "$python_project/.opencode/skills/project-context/SKILL.md" 'Type: python'

printf '%s\n' 'keep command' > "$python_project/.opencode/commands/test.md"
(cd "$python_project" && "$root/bin/openzeus" init-project >/dev/null)
assert_file_contains "$python_project/.opencode/commands/test.md" 'keep command'
(cd "$python_project" && "$root/bin/openzeus" init-project --force >/dev/null)
assert_file_contains "$python_project/.opencode/commands/test.md" 'pytest'

dry_run_project="$tmp/dry-run-project"
mkdir -p "$dry_run_project"
(cd "$dry_run_project" && "$root/bin/openzeus" init-project --dry-run >/dev/null)
[[ ! -e "$dry_run_project/.opencode" ]]

missing_config="$tmp/missing-config"
fix_plan_out="$(OPENCODE_CONFIG_DIR="$missing_config" "$root/bin/openzeus" doctor --fix-plan)"
[[ "$fix_plan_out" == *"Suggested commands:"* && "$fix_plan_out" == *"openzeus install"* ]]
[[ "$fix_plan_out" != *"chmod +x scripts/init-project.sh"* ]]

empty_existing_config="$tmp/existing-empty-config"
mkdir -p "$empty_existing_config"
empty_fix_plan_out="$(OPENCODE_CONFIG_DIR="$empty_existing_config" "$root/bin/openzeus" doctor --fix-plan)"
[[ "$empty_fix_plan_out" == *"OpenZeus doctor: warnings"* && "$empty_fix_plan_out" == *"openzeus install"* ]]

mkdir -p "$tmp/bin"
ln -s "$root/bin/openzeus" "$tmp/bin/openzeus"
"$tmp/bin/openzeus" help >/dev/null
"$tmp/bin/openzeus" doctor >/dev/null

echo ok
