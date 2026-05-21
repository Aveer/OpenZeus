#!/bin/bash

set -euo pipefail

dry_run=false
force=false
target_dir="$(pwd)"

help() { cat <<EOF
Usage: init-project.sh [--target DIR] [--dry-run] [--force]
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      if [[ $# -lt 2 || "$2" == --* ]]; then
        echo "Missing value for --target" >&2
        exit 1
      fi
      target_dir="$2"
      shift ;;
    --dry-run) dry_run=true ;;
    --force) force=true ;;
    -h|--help|help) help; exit 0 ;;
    *) echo "Unknown option: $1" >&2; help; exit 1 ;;
  esac
  shift
done

opencode_dir="$target_dir/.opencode"

write_file() {
  local path="$1" content="$2"
  if [[ -e "$path" && "$force" == false ]]; then printf 'SKIP %s\n' "$path"; return 0; fi
  if [[ "$dry_run" == true ]]; then printf 'DRY-RUN: no files written: %s\n' "$path"; return 0; fi
  mkdir -p "$(dirname "$path")"
  printf '%s' "$content" > "$path"
}

write_file "$opencode_dir/agents/project-guide.md" $'---\ndescription: Project guidance and safety rules\nmode: subagent\npermission:\n  edit: ask\n  bash: ask\n---\n\n# Project Guide\n\nUse this agent to understand the project before making changes.\n'
write_file "$opencode_dir/commands/test.md" $'---\ndescription: Run the project test suite\n---\n\n# /test\n\nRun the most relevant checks for $ARGUMENTS and report the result.\n\n## Template\nUse $ARGUMENTS to describe the scope, such as `unit`, `smoke`, or `all`.\n'
write_file "$opencode_dir/commands/build.md" $'---\ndescription: Build or validate the project\n---\n\n# /build\n\nUse $ARGUMENTS to describe what should be built or validated.\n\n## Template\nPrefer a safe build or validation command, then report what changed.\n'
write_file "$opencode_dir/skills/project-context/SKILL.md" $'---\nname: project-context\ndescription: Local project context, conventions, and workflow notes\n---\n\n# Project Context\n\nUse this skill to capture project-specific conventions, paths, and validation steps.\n'
write_file "$opencode_dir/README.md" $'# .opencode Starter\n\nThis project-local OpenCode directory contains starter assets for safe local workflows.\n'

if [[ "$dry_run" == true ]]; then
  echo "dry-run complete for $opencode_dir (no files written)"
else
  echo "initialized $opencode_dir"
fi
