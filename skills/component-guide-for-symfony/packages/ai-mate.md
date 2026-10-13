# AI Mate (`symfony/ai-mate`)

**Applies to:** Symfony AI 0.14

**Elevator pitch:** Use when a coding agent such as Claude Code or Codex must read the logs, request records or environment files of a PHP project. It also shows the dependency injection setup. It is a development-only command-line tool with agent skills and your own tools, not an MCP server. To serve tools to MCP clients, see [MCP Bundle](mcp-bundle.md).

**Details:** [../details/ai-mate.md](../details/ai-mate.md)

## Why it exists

A coding agent cannot see the runtime state of a PHP application. Examples are the compiled dependency injection container, the debug records of each request and the log files. The package and its extensions give the agent command-line tools that read this state from disk and do not start the application. It also writes agent instructions and installs skills, because an agent does not use a tool that it does not know.

## When to use it

- Give a coding agent tools that read the state of a PHP or Symfony project during development.
- Find the class that the dependency injection container gives for an interface, or the listeners with a given tag.
- Find the cause of a failed or slow HTTP request in the debug data that the application recorded for that request.
- Search the Monolog log files by text, regular expression, level, channel, date or context field.
- Find the environment file that declares an environment variable, and show the value only in masked form.
- Add a project-specific tool for the coding agent as a PHP method with an attribute.
- Install Agent Skills from Composer packages for Claude Code, Codex and other agents.
- Make the coding agent run the tool under the PHP of a ddev or Docker container.

## Use it instead of

- `bin/console debug:container | grep Mailer` or `bin/console debug:container <id>`, read as text -> `tools:call symfony-services --query=MailerInterface`, then `symfony-service-detail --id=<id>` with flags, tags and constructor arguments (`symfony-services`)
- `bin/console debug:dotenv`, which prints the secret values in clear text -> `tools:call symfony-dotenv-check --key=<NAME>`, which shows the value only as a length and a masked preview (`symfony-dotenv-check`)
- `tail -n 50 var/log/dev.log` -> `tools:call monolog-tail --limit=50 --level=error` (`monolog-tail`)
- `grep -E "Timeout" var/log/*.log` -> `tools:call monolog-search --term=Timeout --level=error --from="-1 hour"` (`monolog-search`)
- `grep 4711 var/log/*.log` to follow one order -> `tools:call monolog-context-search --key=order_id --value=4711` (`monolog-context-search`)
- `curl http://localhost/_profiler/<token>` or a read of the files in `var/cache/dev/profiler/` -> `tools:call symfony-profiler-list --statusCode=500 --limit=5`, then `resources:read symfony-profiler://profile/<token>/exception` (`symfony-profiler-list`)
- `php -v`, `php -m` and `uname -s` -> `tools:call server-info` (`server-info`)
- A hand-written MCP server, `mcp.json` or `.mcp.json` for the coding agent -> a `#[MateTool]` method in `mate/src/`, called with `vendor/bin/mate tools:call` (`Symfony\AI\Mate\Attribute\MateTool`)
- A `SKILL.md` that you copy by hand into `.claude/skills/` of each project -> an `extra.ai-mate.skills` folder in an extension, installed by `mate discover` (`skills:install`)
- A hand-written list of debug commands in `AGENTS.md` -> the instructions that `mate discover` writes to `mate/AGENT_INSTRUCTIONS.md` and to the managed block of `AGENTS.md` (`discover`)
