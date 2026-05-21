#!/bin/bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config_dir="${OPENCODE_CONFIG_DIR:-${OPENZEUS_CONFIG_DIR:-${HOME}/.config/opencode}}"
status=0

fail() {
    echo "FAIL $1"
    status=1
}

warn() {
    echo "WARN $1"
}

contains() {
    local file="$1"
    local pattern="$2"
    grep -q "$pattern" "$file"
}

first_line_is_frontmatter() {
    local file="$1"
    local first=""
    [[ -f "$file" ]] || return 1
    IFS= read -r first < "$file" || true
    [[ "$first" == "---" ]]
}

for file in \
    "$root_dir/bin/openzeus" \
    "$root_dir/scripts/install.sh" \
    "$root_dir/scripts/sync-utils.sh" \
    "$root_dir/scripts/create-utils.sh" \
    "$root_dir/scripts/setup-hooks.sh" \
    "$root_dir/scripts/doctor.sh"; do
    [[ -x "$file" ]] || fail "missing executable: $file"
done

[[ -f "$root_dir/agents/OpenZeus.md" ]] || fail "missing agents/OpenZeus.md"
first_line_is_frontmatter "$root_dir/agents/OpenZeus.md" || fail "agents/OpenZeus.md missing frontmatter"
contains "$root_dir/agents/OpenZeus.md" '^description:' || fail "agents/OpenZeus.md missing description"
contains "$root_dir/agents/OpenZeus.md" '^mode:' || fail "agents/OpenZeus.md missing mode"

for skill in "$root_dir"/skills/zeus-*/SKILL.md; do
    [[ -f "$skill" ]] || continue
    first_line_is_frontmatter "$skill" || fail "$skill missing frontmatter"
    contains "$skill" '^name:' || fail "$skill missing name frontmatter"
    contains "$skill" '^description:' || fail "$skill missing description frontmatter"
done

for command in "$root_dir"/commands/zeus-*.md; do
    [[ -f "$command" ]] || continue
    first_line_is_frontmatter "$command" || fail "$command missing frontmatter"
    contains "$command" '^description:' || fail "$command missing description frontmatter"
done

contains "$root_dir/package.json" '"openzeus"[[:space:]]*:[[:space:]]*"bin/openzeus"' || fail "package.json missing openzeus bin"
contains "$root_dir/package.json" '"postinstall"' && fail "package.json should not run mutating postinstall"

if [[ ! -d "$config_dir" ]]; then
    warn "OpenCode config dir absent: $config_dir (install will create it)"
fi

if [[ "$status" -eq 0 ]]; then
    echo "OpenZeus doctor: ok"
fi

exit "$status"
