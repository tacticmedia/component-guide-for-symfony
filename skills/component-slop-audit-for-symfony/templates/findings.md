# Audit findings

- Project: <project name>
- Run: <run directory>
- Scope: <paths>, <file count> files, <line count> lines
- Coverage: <result line of coverage.sh>
- Symfony packages installed: <families and versions>

To select a finding, tick its box, for example `- [x] **F-001: ...**`, or reply with the IDs.

## Reinvented feature

| ID | Package | What the code does | Where | Gain | Effort | Risk | Verdict |
|---|---|---|---|---|---|---|---|
| F-001 | lock | Prevents two import runs with a lock file | `src/Service/ImportLock.php:12` | ... | S | low | CONFIRMED |

- [ ] **F-001: <short title>**
  - Package: `<name>`. Installed: yes | no, then `composer require <package>`.
  - Where: `<path>:<line>-<line>`, one line per location
  - The code now: <what it does>
  - Replace with: <the package feature and its entry point>
  - Gain: <code removed, bugs avoided, maintenance moved to the package>
  - Differences to handle: <behavior that the package does not give, or gives differently>
  - Effort: S | M | L. Risk: low | medium | high, and why.
  - Verdict: CONFIRMED | PLAUSIBLE, and what a PLAUSIBLE finding needs before work starts
  - Catalogue: `packages/<name>.md`, `details/<name>.md`

## Outdated API use

The same table and blocks as above. "Replace with" gives the current API.

## Rejected candidates

| Candidate | Package | Where | Reason |
|---|---|---|---|
