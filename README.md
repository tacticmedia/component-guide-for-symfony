# An unofficial guide through Symfony Components

> [!WARNING]  
> This is an experimental package. If you also feel [The Problem](https://github.com/tacticmedia/component-guide-for-symfony#the-problem) and think [The Solution](https://github.com/tacticmedia/component-guide-for-symfony#the-solution) sounds reasonable, please make this part of your workflow, use it, and tell me what you think via [discussion](https://github.com/tacticmedia/component-guide-for-symfony-dev/discussions), [issue](https://github.com/tacticmedia/component-guide-for-symfony-dev/issues) or even a [non-sloppy pull request](https://github.com/tacticmedia/component-guide-for-symfony-dev/pulls).s

## The Problem

The Symfony ecosystem, and also PHP itself, moves faster than what the LLM training data can keep up with. Unknown unknowns bite:

1. It's hard to stop your agent from reinventing the wheel. Symfony Components solve many common problems and tasks.
2. Your agent might not even know there is a Symfony Component that ahs been solving a particular problem for years
3. Your agent might not be aware that there is a new way of doing things introduced by a recent update

> [!NOTE]
> The problem is wider than just "Symfony Components". I actually think we need a context7-style site doing exactly what this package is trying to do, but better, wider: LLM-centric library discovery platform of some sort. Let's leave that out of scope for now, though. 

## The Solution

This guide is trying to teach your agent about why, when and how to use an existing Symfony component instead of re-inventing the wheel.

Symfony has over a hundred of components. How do we tell the agent what to look for without exhausting the entire context? 

My proposal is to try to give the agent enough information in bite-sized pieces, through three layers of detail:

1. The [index SKILL file](https://github.com/tacticmedia/component-guide-for-symfony-dev/blob/main/skills/component-guide-for-symfony/SKILL.md)  file your agent loads every time new code should be added, and existing code should be refactored. It uses this index to get a hint of which components might be able to help with the problem
2. The [triage file, for example mailer.md](https://github.com/tacticmedia/component-guide-for-symfony-dev/blob/main/skills/component-guide-for-symfony/packages/mailer.md). Gives your agent just enough context for it to decide whether this package could solve the problem
3. The [guidance file, for example mailer.md](https://github.com/tacticmedia/component-guide-for-symfony-dev/blob/main/skills/component-guide-for-symfony/details/mailer.md) then includes the entire knowledge base, but not the docs. It's meant to teach your agent, at a reasonably high level, what the component does. Now that your agent know the component exists and it looks like it could actually be applied onto the task the agent is trying to solve, it can jump to the specific resources needed to do the real work: Symfony Docs, Context7, related resources, and so on. 

---

## What's included

Two [Agent Skills](https://agentskills.io) for any coding agent, and a Claude Code plugin that adds a hook and two subagents:

- **component-guide-for-symfony** (skill your agent should use when writing new code): before the agent writes PHP code for a common need, it finds the Symfony package that already does the job. It also gives the Symfony 8.1, UX 3.5 and AI 0.14 rules that replace older examples, and the corrections where symfony.com and the source code disagree. It covers 106 packages, checked against their source code.
- **component-slop-audit-for-symfony** (skill you can use to review an existing codebase ): reads every file of an existing project, reports hand-written code that a Symfony package covers and removed or deprecated Symfony APIs, and plans each finding that you select.
- **Claude Code plugin**: both skills, a SessionStart hook and the two subagents of the audit. In a project whose `composer.json` requires any `symfony/*` package, the hook adds one line with the installed Symfony versions. It also works without FrameworkBundle, for example in a console tool or a library. The subagents can only read, search and write files.

> [!NOTE]
> This project is not affiliated with, sponsored by or endorsed by Symfony SAS or the Symfony project. See [NOTICE.md](NOTICE.md).

## Install

### Any agent

The [skills](https://github.com/vercel-labs/skills) CLI installs Agent Skills for Codex, Cursor, Gemini CLI, GitHub Copilot, OpenCode, Claude Code and many other agents. It needs Node.js.

1. In the root of your project, run:

   ```bash
   npx skills add tacticmedia/component-guide-for-symfony
   ```

2. Select the skills and the agents. The audit needs both skills.
3. The CLI puts each skill folder where each agent reads skills, for example `.agents/skills/` for Codex, Cursor, Gemini CLI, GitHub Copilot and OpenCode, and `.claude/skills/` for Claude Code.

Options:

- `-g`: install for your user, not only for this project.
- `--agent <agent>`: install for one agent, for example `--agent codex`. Repeat it to add agents.
- `--skill <name>`: install one skill, for example `--skill component-guide-for-symfony`.
- `-y`: skip the questions.

To update the skills, run `npx skills update`.

Without the CLI, copy the folders in `skills/` into the skills folder of your agent.

### Claude Code

```
/plugin marketplace add tacticmedia/component-guide-for-symfony
/plugin install component-guide-for-symfony@component-guide-for-symfony
```

For a whole team, use the project scope. Both commands write to the project settings in `.claude/`. Commit `.claude/settings.json`. A teammate who does not have the plugin yet runs the second command.

```bash
claude plugin marketplace add tacticmedia/component-guide-for-symfony --scope project
claude plugin install component-guide-for-symfony@component-guide-for-symfony --scope project
```

To stay on one Symfony line, add the marketplace at its branch, for example `tacticmedia/component-guide-for-symfony#8.1`.

Claude Code does not update this marketplace automatically. To get new versions, run `claude plugin update component-guide-for-symfony@component-guide-for-symfony`, or turn on auto-update in `/plugin` > Marketplaces.

## Context cost

The agent loads only the part that the current task needs.

| When | What loads | Approximate tokens |
|---|---|---|
| Each session | The descriptions of both skills | 230 |
| Each session in a project that requires `symfony/*`, Claude Code plugin only | Hook line | 50 |
| A task where a package can apply | `SKILL.md`: reading procedure, version rules, core rules, router | 7,100 |
| Each candidate package | `packages/<name>.md`: why, when, and the hand-written code it replaces | 790 on average |
| Each package that the agent uses | `details/<name>.md`: features, entry points, related packages, changes | 3,700 on average |
| You start the audit | The `SKILL.md` of the audit | 2,100 |

The whole catalogue is about 470,000 tokens. A typical task reads `SKILL.md`, two or three triage files and one details file.

## Versions

Each package file has an "Applies to" line, for example "Symfony 8.1". The agent reads the installed versions from `composer.lock`:

- Same minor version or a later patch: the files apply as written.
- Symfony 8.0: the agent skips the items marked 8.1.
- Symfony 7.4: the agent treats the 8.0 removals as deprecations to avoid.
- A later version: the installed source in `vendor/` wins when it disagrees.
- The agent does not ask you to upgrade because of these files.

The default branch follows the latest checked Symfony minor version. Each older line keeps its own branch. [verification.md](https://github.com/tacticmedia/component-guide-for-symfony-dev/blob/main/docs/verification.md) gives the exact version that each file was checked against.

## Audit

In Claude Code:

```
/component-guide-for-symfony:component-slop-audit-for-symfony [path ...]
```

In other agents, ask for it by name, for example "Run the component-slop-audit-for-symfony skill on src/".

1. A script copies the catalogue into a run directory, lists the source files and splits them into batches. The agent shows the file count, the token estimate and the number of subagents, and waits for your confirmation. The subagents run on a faster model, Sonnet in Claude Code, unless you name another model at this step.
2. One subagent per batch reads every file to its last line. A second script checks that each file was read completely.
3. Other subagents group the candidates by package, and try to prove that the package does not cover the code.
4. `findings.md` lists the findings in two sections, "Reinvented feature" and "Outdated API use", each with a checkbox, the location, the replacement, the gain, the effort and the risk.
5. You tick the findings to address, or reply with their IDs. The agent writes one plan for each, then stops.

The run writes its files to `.component-slop-audit-for-symfony/<timestamp>/` in your project, with a copy of the catalogue that it used. It changes no project file. The audit reads all files at least once, so its token use is a multiple of the size of the project. Use paths to limit it.

An agent without subagents reads each batch itself, so all batches stay in its context. Then audit one folder at a time.

The subagents write their results to the run directory, so Claude Code asks you to approve these writes, unless you allow edits for the session.

## Development

Development happens in [tacticmedia/component-guide-for-symfony-dev](https://github.com/tacticmedia/component-guide-for-symfony-dev). It also holds the maintainer tools, the tests, the evals and the docs. Send issues, pull requests and discussions there. See [maintaining.md](https://github.com/tacticmedia/component-guide-for-symfony-dev/blob/main/docs/maintaining.md) for the layout, the checks, the writing rules and the release steps.

## Contributions

Non-LLM-slop contributions and issues are most definitely welcome over at [tacticmedia/component-guide-for-symfony-dev](https://github.com/tacticmedia/component-guide-for-symfony-dev).

## License

The catalogue is licensed under [CC BY-SA 4.0](LICENSE). It adapts the Symfony documentation, which is licensed under CC BY-SA 3.0. The code is licensed under the [MIT License](LICENSE-CODE). See [NOTICE.md](NOTICE.md).

## One more thing

This package is brought to you by [Tactic Media, a South Australian software development business](https://tacticmedia.com.au). 

We love to help businesses become more efficient by automating tasks that shouldn't have been done by a human in the first place.

Head over to our website to check out what we do, and if you think we can help you give your employees more time to spend on something more creative, [let's talk](https://tacticmedia.com.au/contact.html)

