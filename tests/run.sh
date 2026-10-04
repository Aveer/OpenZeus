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

for script in "$root/bin/openzeus" "$root/scripts/create-utils.sh" "$root/scripts/install-agent.sh" "$root/scripts/validate.sh"; do
  [[ -x "$script" ]]
  bash -n "$script"
done
[[ -x "$root/scripts/inspect.mjs" ]]
[[ -x "$root/scripts/audit.mjs" ]]
[[ -f "$root/src/plugin.js" ]]

"$root/bin/openzeus" help | grep -q 'install-agent'
"$root/bin/openzeus" help | grep -q 'audit'
"$root/bin/openzeus" help | grep -q 'inspect'

config="$tmp/config"

"$root/bin/openzeus" create --dry-run --config "$config" agent demo-agent "Demo agent" >/dev/null
[[ ! -e "$config/agents/demo-agent.md" ]]

"$root/bin/openzeus" create --config "$config" agent demo-agent "Demo agent" >/dev/null
assert_file_contains "$config/agents/demo-agent.md" 'permissions:'
assert_file_contains "$config/agents/demo-agent.md" 'action: shell'
if grep -q '^permission:' "$config/agents/demo-agent.md"; then
  echo "legacy permission generated" >&2
  exit 1
fi

"$root/bin/openzeus" create --config "$config" skill demo-skill "Use for demo work" >/dev/null
assert_file_contains "$config/skills/demo-skill/SKILL.md" 'name: demo-skill'
assert_file_contains "$config/skills/demo-skill/SKILL.md" 'description:'

"$root/bin/openzeus" create --config "$config" command demo-command "Demo command" >/dev/null
assert_file_contains "$config/commands/demo-command.md" '$ARGUMENTS'

agent_config="$tmp/agent-config"
"$root/bin/openzeus" install-agent --dry-run --target "$agent_config" >/dev/null
[[ ! -e "$agent_config" ]]

"$root/bin/openzeus" install-agent --target "$agent_config" >/dev/null
cmp -s "$root/agents/OpenZeus.md" "$agent_config/agents/OpenZeus.md"

printf '%s\n' 'local customization' > "$agent_config/agents/OpenZeus.md"
install_fail=0
"$root/bin/openzeus" install-agent --target "$agent_config" >/dev/null 2>&1 || install_fail=$?
[[ "$install_fail" -eq 1 ]]
assert_file_contains "$agent_config/agents/OpenZeus.md" 'local customization'

"$root/bin/openzeus" install-agent --force --backup --target "$agent_config" >/dev/null
cmp -s "$root/agents/OpenZeus.md" "$agent_config/agents/OpenZeus.md"
backup_found=false
for backup in "$agent_config"/agents/OpenZeus.md.bak.*; do
  [[ -e "$backup" ]] || continue
  backup_found=true
done
[[ "$backup_found" == true ]]

"$root/bin/openzeus" validate --ci >/dev/null

bad_project="$tmp/bad-project"
mkdir -p "$bad_project/.opencode/agents" "$bad_project/.opencode/commands" "$bad_project/.opencode/skills/bad"
cat > "$bad_project/.opencode/agents/legacy.md" <<'EOF'
---
description: legacy
mode: subagent
permission:
  bash: ask
---
EOF
cat > "$bad_project/.opencode/commands/legacy.md" <<'EOF'
---
description: legacy
subtask: true
---
EOF
cat > "$bad_project/.opencode/skills/bad/SKILL.md" <<'EOF'
---
name: bad
---
EOF
validation_fail=0
"$root/bin/openzeus" validate --project "$bad_project" --ci >/dev/null || validation_fail=$?
[[ "$validation_fail" -eq 1 ]]

inspect_config="$tmp/inspect-config"
inspect_project="$tmp/inspect-project"
mkdir -p "$inspect_config/agents" "$inspect_config/skills/shared" "$inspect_project/.opencode/skills/shared" "$inspect_project/.opencode/commands"
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
EOF

test_node="${OPENZEUS_NODE:-${npm_node_execpath:-}}"
[[ -n "$test_node" ]] || test_node="$(command -v node)"

inspect_json="$tmp/inspect.json"
OPENCODE_CONFIG_DIR="$inspect_config" "$root/bin/openzeus" inspect --target "$inspect_project" --json > "$inspect_json"
"$test_node" -e '
const fs = require("fs");
const d = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
if (d.mode !== "filesystem") process.exit(1);
const collision = d.collisions.find(x => x.type === "skill" && x.id === "shared");
if (!collision || !collision.winner.source.startsWith("project-opencode:")) process.exit(2);
if (!d.warnings.some(x => x.code === "legacy_agent_permission")) process.exit(3);
if (!d.warnings.some(x => x.code === "legacy_command_subtask")) process.exit(4);
' "$inspect_json"

audit_json="$tmp/audit.json"
OPENCODE_CONFIG_DIR="$inspect_config" "$root/bin/openzeus" audit --target "$inspect_project" --json > "$audit_json"
"$test_node" -e '
const fs = require("fs");
const d = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
if (d.status !== "warning") process.exit(1);
if (d.summary.warnings < 2) process.exit(2);
' "$audit_json"

audit_ci=0
OPENCODE_CONFIG_DIR="$inspect_config" "$root/bin/openzeus" audit --target "$inspect_project" --ci >/dev/null || audit_ci=$?
[[ "$audit_ci" -eq 1 ]]

clean_project="$tmp/clean-project"
mkdir -p "$clean_project"
OPENCODE_CONFIG_DIR="$tmp/clean-config" "$root/bin/openzeus" audit --target "$clean_project" --ci >/dev/null

echo ok
