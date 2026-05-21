#!/bin/bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
mode="plan"
recipe=""
target_dir="$(pwd)"
dry_run=false
force=false

recipes_help() {
  cat <<EOF
node: package.json, npm test/build commands, README cues
python: pyproject/setup.cfg workflow, pytest defaults
docs: docs-focused command set and notes
beads: issue-tracking context and status workflow
solo-dev: lightweight personal repo setup
EOF
}

require_value() {
  local flag="$1" value="${2:-}"
  if [[ -z "$value" || "$value" == --* ]]; then
    echo "Missing value for $flag" >&2
    exit 1
  fi
}

validate_recipe() {
  [[ -z "$recipe" ]] && return 0
  case "$recipe" in
    node|python|docs|beads|solo-dev) ;;
    *) echo "Unknown recipe: $recipe" >&2; recipes_help >&2; exit 1 ;;
  esac
}

makefile_path() {
  if [[ -f "$target_dir/Makefile" ]]; then
    printf '%s\n' "$target_dir/Makefile"
  elif [[ -f "$target_dir/makefile" ]]; then
    printf '%s\n' "$target_dir/makefile"
  fi
}

usage() { cat <<EOF
Usage: setup.sh [--plan|--apply] [--recipe NAME] [--target DIR] [--dry-run] [--force]
       setup.sh recipes
       setup.sh context init [--target DIR] [--dry-run] [--force]
EOF
}

detect_stack() {
  [[ -f "$target_dir/package.json" ]] && echo npm && return
  [[ -f "$target_dir/pyproject.toml" || -f "$target_dir/setup.cfg" || -f "$target_dir/setup.py" ]] && echo python && return
  [[ -f "$target_dir/Makefile" || -f "$target_dir/makefile" ]] && echo make && return
  echo generic
}

detect_test() {
  [[ -f "$target_dir/package.json" ]] && grep -Eq '"test"[[:space:]]*:' "$target_dir/package.json" && { echo "npm test"; return; }
  [[ -f "$target_dir/pyproject.toml" || -f "$target_dir/setup.cfg" || -f "$target_dir/setup.py" ]] && { echo pytest; return; }
  local mf=""
  mf="$(makefile_path || true)"
  [[ -n "$mf" ]] && grep -Eq '^[[:space:]]*test[[:space:]]*:' "$mf" && { echo "make test"; return; }
  case "$recipe" in
    node) echo "npm test" ;;
    python) echo pytest ;;
    beads) echo "bd ready" ;;
  esac
}

detect_build() {
  [[ -f "$target_dir/package.json" ]] && grep -Eq '"build"[[:space:]]*:' "$target_dir/package.json" && { echo "npm run build"; return; }
  local mf=""
  mf="$(makefile_path || true)"
  [[ -n "$mf" ]] && grep -Eq '^[[:space:]]*build[[:space:]]*:' "$mf" && { echo "make build"; return; }
  case "$recipe" in
    node) echo "npm run build" ;;
  esac
}

recipe_effects() {
  case "$recipe" in
    node) echo "- recipe node: package.json-oriented commands and npm workflow" ;;
    python) echo "- recipe python: pytest-first test notes" ;;
    docs) echo "- recipe docs: docs review and lint prompts" ;;
    beads) echo "- recipe beads: issue/board workflow notes" ;;
    solo-dev) echo "- recipe solo-dev: minimal safe local workflow" ;;
  esac
}

context_init() {
  local context_dir="$target_dir/.opencode/context"
  local arch="$context_dir/architecture.md" cmds="$context_dir/commands.md" testf="$context_dir/testing.md"
  local stack test_cmd build_cmd
  stack="$(detect_stack)"; test_cmd="$(detect_test || true)"; build_cmd="$(detect_build || true)"
  if [[ "$dry_run" == true ]]; then
    echo "DRY-RUN: write $arch"
    echo "DRY-RUN: write $cmds"
    echo "DRY-RUN: write $testf"
    return 0
  fi
  mkdir -p "$context_dir"
  for f in "$arch" "$cmds" "$testf"; do
    [[ -e "$f" && "$force" != true ]] && { echo "SKIP existing: $f"; continue; }
    case "$f" in
      "$arch") cat >"$f" <<EOF
# Architecture

Stack: $stack
Recipe: ${recipe:-none}
EOF
      ;;
      "$cmds") cat >"$f" <<EOF
# Commands

Test: ${test_cmd:-not detected}
Build: ${build_cmd:-not detected}
EOF
      ;;
      *) cat >"$f" <<EOF
# Testing

Use safe, repeatable local checks first.
EOF
      ;;
    esac
    echo "Created $f"
  done
}

write_command_file() {
  local path="$1" description="$2" command_text="$3"
  if [[ "$dry_run" == true ]]; then
    echo "DRY-RUN: write $path"
    return 0
  fi
  mkdir -p "$(dirname "$path")"
  cat >"$path" <<EOF
---
description: $description
---

# Command: /$(basename "$path" .md)

Run this project workflow:

\`\`\`bash
$command_text
\`\`\`

User input: \$ARGUMENTS
EOF
  echo "Created $path"
}

apply_recipe_commands() {
  [[ -n "$recipe" ]] || return 0
  local command_dir="$target_dir/.opencode/commands"
  local test_file="$command_dir/test.md" build_file="$command_dir/build.md" extra_file=""
  local had_test="$1" had_build="$2"
  case "$recipe" in
    node)
      [[ "$had_test" == false || "$force" == true ]] && write_command_file "$test_file" "Run npm tests for this project." "npm test"
      [[ "$had_build" == false || "$force" == true ]] && write_command_file "$build_file" "Run npm build for this project." "npm run build"
      ;;
    python)
      [[ "$had_test" == false || "$force" == true ]] && write_command_file "$test_file" "Run pytest for this project." "pytest"
      [[ "$had_build" == false || "$force" == true ]] && write_command_file "$build_file" "Document Python build command when one is added." "# No obvious Python build command detected"
      ;;
    docs)
      extra_file="$command_dir/docs-review.md"
      [[ ! -e "$extra_file" || "$force" == true ]] && write_command_file "$extra_file" "Review documentation for clarity, links, and examples." "# Review docs, README, and changelog"
      ;;
    beads)
      extra_file="$command_dir/beads-status.md"
      [[ ! -e "$extra_file" || "$force" == true ]] && write_command_file "$extra_file" "Inspect Beads issue tracker state." "bd ready && bd list --status open"
      ;;
    solo-dev)
      extra_file="$command_dir/session-check.md"
      [[ ! -e "$extra_file" || "$force" == true ]] && write_command_file "$extra_file" "Run a lightweight solo development session check." "git status && openzeus doctor --fix-plan"
      ;;
  esac
}

while [[ $# -gt 0 ]]; do
  if [[ "${1:-}" == context && "${2:-}" == init ]]; then
    shift 2
    while [[ $# -gt 0 ]]; do
      case "$1" in
        --target) require_value "$1" "${2:-}"; target_dir="$2"; shift ;;
        --recipe) require_value "$1" "${2:-}"; recipe="$2"; shift ;;
        --dry-run) dry_run=true ;;
        --force) force=true ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
      esac
      shift
    done
    validate_recipe
    context_init
    exit 0
  fi
  case "$1" in
    --plan) mode=plan ;;
    --apply) mode=apply ;;
    --recipe) require_value "$1" "${2:-}"; recipe="$2"; shift ;;
    --target) require_value "$1" "${2:-}"; target_dir="$2"; shift ;;
    --dry-run) dry_run=true ;;
    --force) force=true ;;
    recipes) recipes_help; exit 0 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
  shift
done

validate_recipe

if [[ "$mode" == plan ]]; then
  stack="$(detect_stack)"; test_cmd="$(detect_test || true)"; build_cmd="$(detect_build || true)"
  echo "Setup plan for $target_dir"
  echo "Detected stack: $stack"
  [[ -n "$test_cmd" ]] && echo "Test command: $test_cmd"
  [[ -n "$build_cmd" ]] && echo "Build command: $build_cmd"
  echo "Proposed files: .opencode/agents/project-guide.md .opencode/commands/test.md .opencode/commands/build.md .opencode/skills/project-context/SKILL.md .opencode/context/{architecture.md,commands.md,testing.md}"
  [[ -n "$recipe" ]] && recipe_effects
  echo "Apply: openzeus setup --apply --target $target_dir${recipe:+ --recipe $recipe}"
  exit 0
fi

apply_args=(--target "$target_dir")
[[ "$dry_run" == true ]] && apply_args+=(--dry-run)
[[ "$force" == true ]] && apply_args+=(--force)
had_test=false; had_build=false
[[ -e "$target_dir/.opencode/commands/test.md" ]] && had_test=true
[[ -e "$target_dir/.opencode/commands/build.md" ]] && had_build=true
"$root/scripts/init-project.sh" "${apply_args[@]}"
apply_recipe_commands "$had_test" "$had_build"
context_init
