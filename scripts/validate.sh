#!/bin/bash
set -euo pipefail

ci=false
project_dir=""
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
status=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ci) ci=true ;;
    --project)
      [[ $# -ge 2 && "$2" != --* ]] || { echo "Missing value for --project" >&2; exit 1; }
      project_dir="$2"
      shift ;;
    -h|--help) echo "Usage: validate.sh [--ci] [--project DIR]"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
  shift
done

fail(){ echo "FAIL $1"; status=1; }

validate_asset(){
  local file="$1" kind="$2"
  [[ -f "$file" ]] || { fail "missing $file"; return; }
  grep -q '^---$' "$file" || fail "frontmatter missing: $file"

  case "$kind" in
    skill)
      grep -Eq '^name:[[:space:]]*' "$file" || fail "missing name: $file"
      grep -Eq '^description:[[:space:]]*' "$file" || fail "missing description: $file"
      ;;
    agent)
      grep -Eq '^description:[[:space:]]*' "$file" || fail "missing description: $file"
      grep -Eq '^mode:[[:space:]]*' "$file" &&
        ! grep -Eq '^mode:[[:space:]]*(primary|subagent|all)$' "$file" &&
        fail "invalid mode: $file"
      for legacy in permission tools temperature top_p prompt disable maxSteps; do
        grep -Eq "^$legacy:[[:space:]]*" "$file" &&
          fail "legacy agent field $legacy: $file" || true
      done
      ;;
    command)
      grep -Eq '^description:[[:space:]]*' "$file" || fail "missing description: $file"
      grep -Eq '^subtask:[[:space:]]*' "$file" &&
        fail "legacy command field subtask: $file" || true
      ;;
  esac
}

if [[ -z "$project_dir" ]]; then
  for script in "$root/bin/openzeus" "$root/scripts/create-utils.sh" "$root/scripts/install-agent.sh" "$root/scripts/validate.sh"; do
    [[ -x "$script" ]] || fail "not executable: $script"
    bash -n "$script" || fail "shell syntax: $script"
  done
  for script in "$root/scripts/inspect.mjs" "$root/scripts/audit.mjs"; do
    [[ -x "$script" ]] || fail "not executable: $script"
  done
  [[ -f "$root/src/plugin.js" ]] || fail "missing src/plugin.js"
  validate_asset "$root/agents/OpenZeus.md" agent
  for file in "$root"/skills/zeus-*/SKILL.md; do
    [[ -e "$file" ]] || continue
    validate_asset "$file" skill
  done
else
  for file in "$project_dir/.opencode/agents"/*.md; do
    [[ -e "$file" ]] || continue
    validate_asset "$file" agent
  done
  for file in "$project_dir/.opencode/commands"/*.md; do
    [[ -e "$file" ]] || continue
    validate_asset "$file" command
  done
  for file in "$project_dir/.opencode/skills"/*/SKILL.md; do
    [[ -e "$file" ]] || continue
    validate_asset "$file" skill
  done
fi

[[ "$ci" == true && "$status" -ne 0 ]] && exit 1
exit "$status"
