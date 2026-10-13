#!/usr/bin/env bash
# Usage: inventory.sh <run-directory> [path ...]
# Run from the project root. Writes <run-directory>/inventory.tsv (path, bytes, lines)
# and <run-directory>/batches.tsv (batch, path), then prints a summary.
set -euo pipefail

run_directory=${1:?usage: inventory.sh <run-directory> [path ...]}
shift
[ "$#" -gt 0 ] || set -- .

batch_bytes=${AUDIT_BATCH_BYTES:-160000}
extensions='php|twig|yaml|yml|xml|js|mjs|cjs|ts|jsx|tsx|vue'
excluded='^(vendor|var|node_modules|public/build|public/bundles|assets/vendor|\.git|\.claude|\.component-slop-audit-for-symfony)/|(^|/)\.env|\.min\.(js|css)$'

mkdir -p "$run_directory"
inventory="$run_directory/inventory.tsv"
batches="$run_directory/batches.tsv"

list_files() {
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        git ls-files --cached --others --exclude-standard -- "$@"
    else
        find "$@" -type f | sed 's#^\./##'
    fi
}

list_files "$@" \
    | { grep -E "\.($extensions)\$" || true; } \
    | { grep -v -E "$excluded" || true; } \
    | LC_ALL=C sort -u \
    | while IFS= read -r path; do
        [ -f "$path" ] || continue
        bytes=$(wc -c < "$path" | tr -d ' ')
        lines=$(awk 'END { print NR }' "$path")
        printf '%s\t%s\t%s\n' "$path" "$bytes" "$lines"
    done > "$inventory"

awk -F '\t' -v limit="$batch_bytes" '
    {
        if (batch == 0 || (size > 0 && size + $2 > limit)) { batch++; size = 0 }
        size += $2
        printf "%d\t%s\n", batch, $1
    }
' "$inventory" > "$batches"

awk -F '\t' '
    { files++; bytes += $2; lines += $3 }
    END { printf "files=%d lines=%d bytes=%d approx_tokens=%d\n", files, lines, bytes, bytes / 4 }
' "$inventory"
printf 'batches=%d\n' "$(cut -f1 "$batches" | sort -u | grep -c . || true)"
