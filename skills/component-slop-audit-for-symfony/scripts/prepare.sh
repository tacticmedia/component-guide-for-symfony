#!/usr/bin/env bash
# Usage: prepare.sh <run-directory> <catalogue-directory> <skill-directory>
# Creates the run directory and copies the catalogue (SKILL.md, packages/, details/) and the
# templates and references of this skill into it, so that the audit and its subagents read
# only files inside the project.
set -euo pipefail

usage='usage: prepare.sh <run-directory> <catalogue-directory> <skill-directory>'
run_directory=${1:?$usage}
catalogue=${2:?$usage}
skill=${3:?$usage}

[ -f "$catalogue/SKILL.md" ] || { echo "No SKILL.md in $catalogue" >&2; exit 2; }
[ -d "$skill/templates" ] && [ -d "$skill/references" ] || { echo "No templates/ and references/ in $skill" >&2; exit 2; }

mkdir -p "$run_directory/catalogue" "$run_directory/templates" "$run_directory/references" "$run_directory/plans"
cp "$catalogue/SKILL.md" "$run_directory/catalogue/SKILL.md"
cp -R "$catalogue/packages" "$catalogue/details" "$run_directory/catalogue/"
cp "$skill/templates"/*.md "$run_directory/templates/"
cp "$skill/references"/*.md "$run_directory/references/"

printf 'run_directory=%s packages=%d templates=%d references=%d\n' \
    "$run_directory" \
    "$(find "$run_directory/catalogue/packages" -name '*.md' | wc -l | tr -d ' ')" \
    "$(find "$run_directory/templates" -name '*.md' | wc -l | tr -d ' ')" \
    "$(find "$run_directory/references" -name '*.md' | wc -l | tr -d ' ')"
