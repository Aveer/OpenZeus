#!/bin/bash
set -euo pipefail

ci=false
project_dir=""
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config_dir="${OPENCODE_CONFIG_DIR:-${OPENZEUS_CONFIG_DIR:-${HOME}/.config/opencode}}"
status=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ci) ci=true ;;
    --project) project_dir="$2"; shift ;;
    -h|--help) echo "Usage: validate.sh [--ci] [--project DIR]"; exit 0 ;;
  esac
  shift
done

fail(){ echo "FAIL $1"; status=1; }
warn(){ echo "WARN $1"; }

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
      grep -Eq '^mode:[[:space:]]*(primary|subagent|all)$' "$file" || true
      grep -Eq '^mode:[[:space:]]*' "$file" && ! grep -Eq '^mode:[[:space:]]*(primary|subagent|all)$' "$file" && fail "invalid mode: $file"
      ;;
    command)
      grep -Eq '^description:[[:space:]]*' "$file" || fail "missing description: $file"
      ;;
  esac
  grep -Eq '^tools:[[:space:]]*' "$file" && fail "deprecated tools: $file" || true
  grep -Eq '^permission:[[:space:]]*allow$' "$file" && fail "unsafe permission allow: $file" || true
}

if [[ -z "$project_dir" ]]; then
  for s in "$root"/scripts/*.sh "$root/bin/openzeus"; do
    [[ -f "$s" ]] || continue
    [[ -x "$s" ]] || fail "not executable: $s"
    bash -n "$s" || fail "shell syntax: $s"
  done
  for f in "$root/agents/OpenZeus.md"; do validate_asset "$f" agent; done
  for f in "$root"/skills/zeus-*/SKILL.md; do [[ -e "$f" ]] || continue; validate_asset "$f" skill; done
  for f in "$root"/commands/zeus-*.md; do [[ -e "$f" ]] || continue; validate_asset "$f" command; done
  if [[ -d "$config_dir" ]]; then
    drift="$($root/scripts/diff.sh --summary || true)"
    if [[ "$drift" != "0 issue(s)" ]]; then
      warn "config drift detected"
      [[ "$ci" == true ]] && status=1
    fi
  fi
else
  for f in "$project_dir/.opencode/agents"/*.md; do [[ -e "$f" ]] || continue; validate_asset "$f" agent; done
  for f in "$project_dir/.opencode/commands"/*.md; do [[ -e "$f" ]] || continue; validate_asset "$f" command; done
  for f in "$project_dir/.opencode/skills"/*/SKILL.md; do [[ -e "$f" ]] || continue; validate_asset "$f" skill; done
fi

[[ "$ci" == true && "$status" -ne 0 ]] && exit 1
exit "$status"
