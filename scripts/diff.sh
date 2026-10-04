#!/bin/bash
set -euo pipefail

summary=false
ci=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --summary) summary=true ;;
    --ci) ci=true ;;
    -h|--help) echo "Usage: diff.sh [--summary] [--ci]"; exit 0 ;;
  esac
  shift
done

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config="${OPENCODE_CONFIG_DIR:-${OPENZEUS_CONFIG_DIR:-${HOME}/.config/opencode}}"
install_profile="all"
[[ -f "$config/.openzeus-install-profile" ]] && IFS= read -r install_profile < "$config/.openzeus-install-profile"

should_include_skill() {
  return 0
}

out="$($root/scripts/sync-utils.sh --repo "$root" --config "$config" status || true)"
issues=()
while IFS= read -r line; do
  case "$line" in
    MISSING\ config:skills/zeus-*) skill_name="${line#MISSING config:skills/}"; should_include_skill "$skill_name" && issues+=("$line") ;;
    DIFF*|MISSING*) issues+=("$line") ;;
  esac
done <<< "$out"

extra=()
if [[ -d "$config/skills" ]]; then
  for d in "$config/skills"/zeus-*; do [[ -d "$d" ]] || continue; [[ -d "$root/skills/$(basename "$d")" ]] || extra+=("EXTRA $(basename "$d")") ; done
fi

for helper in sync-utils.sh create-utils.sh setup-hooks.sh doctor.sh init-project.sh setup.sh validate.sh capture-command.sh diff.sh upgrade.sh; do
  pkg="$root/scripts/$helper"
  cfg="$config/$helper"
  if [[ ! -e "$cfg" ]]; then
    issues+=("MISSING config:$helper")
  elif [[ -f "$pkg" && -f "$cfg" ]]; then
    cmp -s "$pkg" "$cfg" || issues+=("DIFF $helper")
    [[ -x "$cfg" ]] || issues+=("DIFF $helper executable-bit")
  else
    issues+=("DIFF $helper type")
  fi
done

all=("${issues[@]}" "${extra[@]}")
if [[ "$summary" == true ]]; then
  echo "${#all[@]} issue(s)"
else
  printf '%s\n' "${all[@]}"
fi

if [[ "$ci" == true ]]; then
  [[ ${#all[@]} -eq 0 ]]
else
  exit 0
fi
