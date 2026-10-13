#!/usr/bin/env bash
# Usage: coverage.sh <run-directory>
# Compares inventory.tsv with the read logs read-<batch>.tsv (path, last line read).
# Writes gaps.tsv (path, status, lines read, lines) and exits 1 when a file is missing or partly read.
set -euo pipefail

run_directory=${1:?usage: coverage.sh <run-directory>}
inventory="$run_directory/inventory.tsv"
gaps="$run_directory/gaps.tsv"
[ -f "$inventory" ] || { echo "No inventory.tsv in $run_directory" >&2; exit 2; }

shopt -s nullglob
read_logs=("$run_directory"/read-*.tsv)

awk -F '\t' '
    FNR == NR { lines[$1] = $3; order[++count] = $1; next }
    { if (!($1 in best) || $2 + 0 > best[$1]) { best[$1] = $2 + 0 } }
    END {
        for (i = 1; i <= count; i++) {
            path = order[i]
            if (!(path in best)) { printf "%s\tmissing\t0\t%d\n", path, lines[path] }
            else if (best[path] < lines[path]) { printf "%s\tpartial\t%d\t%d\n", path, best[path], lines[path] }
        }
    }
' "$inventory" ${read_logs[@]+"${read_logs[@]}"} > "$gaps"

files=$(grep -c . "$inventory" || true)
missing=$(grep -c $'\tmissing\t' "$gaps" || true)
partial=$(grep -c $'\tpartial\t' "$gaps" || true)
printf 'files=%d read=%d missing=%d partial=%d\n' "$files" "$((files - missing - partial))" "$missing" "$partial"
[ "$missing" -eq 0 ] && [ "$partial" -eq 0 ]
