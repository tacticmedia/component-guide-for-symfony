#!/usr/bin/env bash
# SessionStart hook: prints one line of context when a composer.json of the project
# requires or require-devs a symfony/* package. Prints nothing otherwise.
set -u

root="${CLAUDE_PROJECT_DIR:-$PWD}"

# Prints the symfony/* names in the "require" and "require-dev" objects of a composer.json.
required_symfony_packages() {
    awk '
        { text = text $0 "\n" }
        END {
            while (match(text, /"require(-dev)?"[[:space:]]*:[[:space:]]*\{/)) {
                text = substr(text, RSTART + RLENGTH)
                closing = index(text, "}")
                block = closing ? substr(text, 1, closing - 1) : text
                while (match(block, /"symfony\/[a-z0-9.-]+"[[:space:]]*:/)) {
                    name = substr(block, RSTART + 1, RLENGTH)
                    sub(/".*/, "", name)
                    print name
                    block = substr(block, RSTART + RLENGTH)
                }
                text = closing ? substr(text, closing + 1) : ""
            }
        }
    ' "$1"
}

# Prints "<family> <major.minor>" for each symfony/* package in a composer.lock.
locked_families() {
    awk '
        /"name"[[:space:]]*:[[:space:]]*"symfony\// {
            name = $0
            sub(/.*"symfony\//, "", name)
            sub(/".*/, "", name)
            next
        }
        name != "" && /"version"[[:space:]]*:/ {
            version = $0
            sub(/.*"version"[[:space:]]*:[[:space:]]*"v?/, "", version)
            sub(/".*/, "", version)
            split(version, part, ".")
            minor = part[1] "." part[2]
            if (name ~ /^polyfill-/ || name ~ /-contracts$/) { family = "" }
            else if (name ~ /^ux-/ || name == "stimulus-bundle") { family = "Symfony-UX" }
            else if (name ~ /^ai-/ || name == "mcp-bundle") { family = "Symfony-AI" }
            else if (name ~ /^(flex|maker-bundle|monolog-bundle|panther|webpack-encore-bundle|mercure|mercure-bundle|reprise|requirements-checker|lsp)$/) { family = "symfony/" name }
            else { family = "Symfony" }
            if (family != "" && minor ~ /^[0-9]+\.[0-9]+$/) { print family " " minor }
            name = ""
        }
    ' "$1"
}

summary=""
while IFS= read -r manifest; do
    [ -n "$(required_symfony_packages "$manifest")" ] || continue

    directory=$(dirname "$manifest")
    label=${directory#"$root"}
    label=${label#/}

    lock="$directory/composer.lock"
    if [ -f "$lock" ]; then
        families=$(locked_families "$lock" | sort | uniq -c | sort -k2,2 -k1,1nr | awk '
            !seen[$2]++ { printf "%s%s %s (%d %s)", (n++ ? ", " : ""), $2, $3, $1, ($1 == 1 ? "package" : "packages") }
        ' | sed 's/Symfony-UX/Symfony UX/; s/Symfony-AI/Symfony AI/')
    else
        families="versions unknown, no composer.lock"
    fi
    summary="${summary:+$summary; }${label:+$label: }$families"
done < <(find "$root" -maxdepth 3 -name composer.json -not -path '*/vendor/*' -not -path '*/node_modules/*' 2>/dev/null | sort)

[ -n "$summary" ] || exit 0

printf 'This project uses Symfony packages (%s). Before you write PHP code for a common need, use the component-guide-for-symfony skill: a Symfony package may already cover it.\n' "$summary"
