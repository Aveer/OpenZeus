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

detect_project_type() {
  if [[ -f "$target_dir/package.json" ]]; then
    echo "npm"
  elif [[ -f "$target_dir/Makefile" || -f "$target_dir/makefile" ]]; then
    echo "make"
  elif [[ -f "$target_dir/pyproject.toml" || -f "$target_dir/setup.cfg" || -f "$target_dir/setup.py" ]]; then
    echo "python"
  else
    echo "generic"
  fi
}

detect_npm_command() {
  local file="$target_dir/package.json"
  if [[ -f "$file" ]]; then
    grep -Eq '"test"[[:space:]]*:[[:space:]]*"' "$file" && echo "npm test" || true
    grep -Eq '"build"[[:space:]]*:[[:space:]]*"' "$file" && echo "npm run build" || true
  fi
}

detect_make_command() {
  local file
  for file in "$target_dir/Makefile" "$target_dir/makefile"; do
    [[ -f "$file" ]] || continue
    grep -Eq '^[[:space:]]*test[[:space:]]*:' "$file" && echo "make test" || true
    grep -Eq '^[[:space:]]*build[[:space:]]*:' "$file" && echo "make build" || true
    break
  done
}

detect_python_test_command() {
  if [[ -f "$target_dir/pyproject.toml" || -f "$target_dir/setup.cfg" || -f "$target_dir/setup.py" ]]; then
    echo "pytest"
  fi
}

detect_test_command() {
  local npm_test make_test python_test
  npm_test="$(detect_npm_command | grep -m1 '^.*test.*$' || true)"
  make_test="$(detect_make_command | grep -m1 '^.*test.*$' || true)"
  python_test="$(detect_python_test_command || true)"
  if [[ -n "$npm_test" ]]; then
    echo "$npm_test"
  elif [[ -n "$make_test" ]]; then
    echo "$make_test"
  elif [[ -n "$python_test" ]]; then
    echo "$python_test"
  fi
}

detect_build_command() {
  local npm_build make_build
  npm_build="$(detect_npm_command | grep -m1 'build' || true)"
  make_build="$(detect_make_command | grep -m1 'build' || true)"
  if [[ -n "$npm_build" ]]; then
    echo "$npm_build"
  elif [[ -n "$make_build" ]]; then
    echo "$make_build"
  fi
}

project_type="$(detect_project_type)"
test_command="$(detect_test_command)"
build_command="$(detect_build_command)"

test_md=$'---\ndescription: Run the project test suite\n---\n\n# /test\n\nRun the most relevant checks for $ARGUMENTS and report the result.\n\n## Detected command\n'
if [[ -n "$test_command" ]]; then
  test_md+=$'Use: `'
  test_md+="$test_command"
  test_md+=$'`\n\n'
else
  test_md+=$'No obvious test command was detected. Inspect the project docs or package scripts, then run the safest available test command.\n\n'
fi
test_md+=$'## Template\nUse $ARGUMENTS to describe the scope, such as `unit`, `smoke`, or `all`.\n'

build_md=$'---\ndescription: Build or validate the project\n---\n\n# /build\n\nUse $ARGUMENTS to describe what should be built or validated.\n\n## Detected command\n'
if [[ -n "$build_command" ]]; then
  build_md+=$'Use: `'
  build_md+="$build_command"
  build_md+=$'`\n\n'
else
  build_md+=$'No obvious build command was detected. Use the project’s documented build or validation flow, or a safe no-op validation step.\n\n'
fi
build_md+=$'## Template\nPrefer a safe build or validation command, then report what changed.\n'

context_md=$'---\nname: project-context\ndescription: Local project context, conventions, and workflow notes\n---\n\n# Project Context\n\nUse this skill to capture project-specific conventions, paths, and validation steps.\n\n## Detected project\n'
context_md+=$'Type: '
context_md+="$project_type"
context_md+=$'\n'
if [[ -n "$test_command" ]]; then
  context_md+=$'Test command: '
  context_md+="$test_command"
  context_md+=$'\n'
fi
if [[ -n "$build_command" ]]; then
  context_md+=$'Build command: '
  context_md+="$build_command"
  context_md+=$'\n'
fi
context_md+=$'\nKeep notes focused on safe, repeatable local workflows.\n'

write_file() {
  local path="$1" content="$2"
  if [[ -e "$path" && "$force" == false ]]; then printf 'SKIP %s\n' "$path"; return 0; fi
  if [[ "$dry_run" == true ]]; then printf 'DRY-RUN: no files written: %s\n' "$path"; return 0; fi
  mkdir -p "$(dirname "$path")"
  printf '%s' "$content" > "$path"
}

write_file "$opencode_dir/agents/project-guide.md" $'---\ndescription: Project guidance and safety rules\nmode: subagent\npermission:\n  edit: ask\n  bash: ask\n---\n\n# Project Guide\n\nUse this agent to understand the project before making changes.\n'
write_file "$opencode_dir/commands/test.md" "$test_md"
write_file "$opencode_dir/commands/build.md" "$build_md"
write_file "$opencode_dir/skills/project-context/SKILL.md" "$context_md"
write_file "$opencode_dir/README.md" $'# .opencode Starter\n\nThis project-local OpenCode directory contains starter assets for safe local workflows.\n'

if [[ "$dry_run" == true ]]; then
  echo "dry-run complete for $opencode_dir (no files written)"
else
  echo "initialized $opencode_dir"
fi
