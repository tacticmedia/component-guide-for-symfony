# Batch <n>

## Intents

One block per file, in the order of the batch. Write each intent as a goal in general software terms, the same way as the pitches of the catalogue: what the code achieves, not how.

- `<path>`: <intent of the file>
  - `<Class or function>`: <intent>
  - `<Class>::<method>()`: <intent>, only for methods with their own purpose

## Candidates

One block per candidate. Leave this section empty when the batch has none.

### C-<n>-<two-digit number>: <short title>

- Category: Reinvented feature | Outdated API use
- Package: `<triage file name, for example lock>`
- Where: `<path>:<first line>-<last line>`, one line per location
- The code: <what the code does, in two sentences at most>
- Catalogue match: <the "Use it instead of" entry, or the "Changed in" entry, or the core rule of SKILL.md>
- Excerpt: at most three lines of code, without secrets
- Confidence: high | medium | low, and why
