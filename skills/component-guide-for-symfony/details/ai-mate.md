# AI Mate (`symfony/ai-mate`): details

**Applies to:** Symfony AI 0.14

## Key features and concepts

- **Setup:** Install the package with `composer require --dev symfony/ai-mate`. Then run `vendor/bin/mate init`. It creates the `mate/` folder and adds `extra.ai-mate` and the `Mate\` dev autoload entry to `composer.json`. Next, run `composer dump-autoload`. Then run `vendor/bin/mate discover`. Flex has no recipe for Mate. Entry point: `init`.
- **CLI for coding agents:** The agent runs `vendor/bin/mate` commands in its shell, as it runs any other command. Mate starts no server and needs no MCP client configuration. `tools:list` shows the tools, `tools:inspect <tool>` shows the JSON input schema, and `tools:call <tool>` runs a tool. `resources:read <uri>` reads a resource, so that a large payload stays out of the agent context until the agent needs it. Entry point: `vendor/bin/mate`.
- **Tool parameters:** Each tool parameter is a long option, for example `--limit=1`. Mate casts the value to the declared type and rejects a value that it cannot cast. A bare flag sets a boolean, and a repeated option fills a variadic parameter. If a value is nested, or a parameter has the name of a console option such as `format`, pass `--json='{...}'`. Entry point: `tools:call`.
- **Output formats:** `tools:*`, `resources:read`, `debug:*`, `skills:install`, `skills:list` and `skills:validate` accept `--format`. `json` gives output for scripts, and `toon` gives the smallest output but needs `helgesverre/toon`. If a `tools:call` result in the default format is larger than 8 KB, Mate prints it as JSON. Entry point: `--format`.
- **Custom tools and resources:** In `mate/src/`, a public method with `#[MateTool(name: ...)]` becomes a tool. The `name` argument is required. Mate finds the method by reflection and builds the input schema from the signature and the `@param` PHPDoc. Mate registers the class as an autowired service, so the constructor gets its dependencies. The method must return a scalar value or an array. `#[MateResource]` marks a static resource, and `#[MateResourceTemplate]` marks a resource with URI variables. Entry point: `Symfony\AI\Mate\Attribute\MateTool`.
- **Extensions:** A Composer package with an `extra.ai-mate` section is an extension. Its keys `scan-dirs`, `includes`, `instructions` and `skills` declare the tool folders, service files, agent instructions and skill folders. `mate discover` adds each new extension as enabled to `mate/extensions.php`. To disable an extension, set `'enabled' => false` in that file. To remove single tools, call `MateHelper::disableFeatures()` once in `mate/config.php`. If a package sets `extension: false`, other projects do not discover it; `mate init` writes this value for the application. Entry point: `extra.ai-mate`, `debug:extensions`.
- **Composer plugin:** `symfony/ai-mate` requires `symfony/ai-mate-composer-plugin`. When `mate/extensions.php` exists, the plugin runs `mate discover --composer` after `composer install` and `composer update`. Before `mate init`, it only prints a hint. Composer runs the plugin only when `config.allow-plugins` allows it: an interactive Composer asks, and a non-interactive Composer skips the plugin. To allow it, run `composer config --no-plugins allow-plugins.symfony/ai-mate-composer-plugin true`. Entry point: `Symfony\AI\Mate\ComposerPlugin\MatePlugin`.
- **Agent instructions:** `mate discover` writes `mate/AGENT_INSTRUCTIONS.md` from the instruction files of all enabled extensions. It also keeps a managed block in `AGENTS.md` and an `@AGENTS.md` import in `CLAUDE.md`. Mate changes only the text between its `<!-- BEGIN AI_MATE_... -->` and `<!-- END AI_MATE_... -->` markers. Entry point: `mate/AGENT_INSTRUCTIONS.md`.
- **Agent Skills:** `skills:install` copies the skill folders (`SKILL.md`) of the enabled extensions to `.agents/skills/mate-<name>/`. It mirrors them in `.claude/skills/` with relative symlinks, or with copies where symlinks do not work. `mate discover` runs this install too. A `SKILL.md` needs `name` and `description` in its front matter, and `name` must be equal to the folder name. Mate skips a skill that breaks these rules. In `mate/extensions.php`, edit only the `enabled` and `mode` keys of a skill. To change the text of a skill, run `skills:override <name>`. Then edit the copy in `mate/skills/<name>/`. Entry point: `skills:install`, `skills:list`, `skills:validate`.
- **PHP interpreter check:** `mate init` writes `mate.invocation`, the command that the agent must use, for example `ddev exec vendor/bin/mate`. It also writes `mate.php_version` as `major.minor`. Under a different PHP version, Mate stops with an error that shows the `mate.invocation` command. `init`, `discover`, `list`, `help` and `completion` only show a warning. To disable the check, set `mate.php_version` to `null`. With `--no-interaction`, `mate init` does not ask and writes the default command. If the application runs in Docker Compose or Lando, edit both parameters by hand. Then run `vendor/bin/mate discover`. Entry point: `mate/config.php`.
- **Symfony extension:** `symfony/ai-symfony-mate-extension` reads the application from disk and does not boot it. `symfony-services` and `symfony-service-detail` read the `*DebugContainer.xml` file below `ai_mate_symfony.cache_dir`. If this file is missing, run `php bin/console cache:warmup`. Symfony writes the file only in debug mode. `symfony-profiler-list`, `symfony-profiler-get` and two `symfony-profiler://` resource templates read the profiles in `ai_mate_symfony.profiler_dir`. `symfony-dotenv-check` shows where each `.env*` variable comes from and masks the value. Entry point: `symfony-services`, `symfony-profiler-list`, `symfony-dotenv-check`.
- **Profiler formatters:** Formatters reduce the `request`, `exception`, `logger`, `time`, `memory`, `db`, `mailer` and `translation` collectors to the data for a diagnosis. Other collectors give their raw data, with redaction by key name. For your own data collector, implement `CollectorFormatterInterface`. Tag the service with `ai_mate.profiler_collector_formatter`. Entry point: `Symfony\AI\Mate\Bridge\Symfony\Profiler\Service\CollectorFormatterInterface`.
- **Monolog extension:** `symfony/ai-monolog-mate-extension` gives `monolog-search`, `monolog-context-search`, `monolog-tail`, `monolog-list-files` and `monolog-list-channels`. These tools read the `*.log` files in `ai_mate_monolog.log_dir`, in the Monolog line format or as JSON lines. The output redacts context keys that look sensitive, for example `password` or `token`. `monolog-tail` reads only the newest log file of each log folder. Entry point: `monolog-search`.
- **Multi-kernel applications:** The `ai_mate_symfony.cache_dir`, `ai_mate_symfony.profiler_dir` and `ai_mate_monolog.log_dir` parameters also accept a map of context name to path, for example one entry for each `APP_ID`. Then `symfony-services`, `symfony-service-detail` and `symfony-profiler-list` accept `context`, and the Monolog tools accept `kernelContext`. Entry point: `ai_mate_symfony.cache_dir`, `ai_mate_symfony.profiler_dir`, `ai_mate_monolog.log_dir`.
- **Security and untrusted data:** Mate discovers and enables every installed package with an `extra.ai-mate` section. After a package install, review `mate/extensions.php`. Commit it with the generated skill folders, so that changes show in code review. The container, profiler and log tools put the captured data under `untrusted_data`, next to a `_security_notice`. If a script parses the output, read the payload from `untrusted_data`. Redaction can miss a secret under a harmless name. Treat profiler and log output as sensitive. Entry point: `Symfony\AI\Mate\Encoding\ResponseEncoder::encodeUntrusted()`.

## Entry points

- Binary: `vendor/bin/mate` (the console application that `Symfony\AI\Mate\App::build()` creates)
- Without FrameworkBundle: `vendor/bin/mate` is a separate console application with its own container, built from `mate/config.php`. Mate registers the `#[MateTool]` classes of `mate/src/` in this container. `symfony-services` and `symfony-service-detail` read the container XML that FrameworkBundle dumps in debug mode.
- Setup and discovery commands: `init`, `discover` (`--composer`, `--ignore-missing-file`), `clear-cache`
- Tool commands: `tools:list` (`--filter`, `--extension`, `--format`), `tools:inspect <tool>`, `tools:call <tool>` (`--<param>=<value>`, `--json`, `--format`), `resources:read <uri>`
- Debug commands: `debug:capabilities` (`--extension`, `--type`, `--format`), `debug:extensions` (`--show-all`, `--format`)
- Skill commands: `skills:install` (`--dry-run`, `--format`), `skills:list`, `skills:validate [<name>]` (`--strict`), `skills:prune` (`--dry-run`), `skills:override <name>` (`--force`), `skills:reset <name>` (`--delete-copy`), `skills:enable <name>`, `skills:disable <name>`
- Attributes: `Symfony\AI\Mate\Attribute\MateTool`, `Symfony\AI\Mate\Attribute\MateResource`, `Symfony\AI\Mate\Attribute\MateResourceTemplate`
- Helpers for tool and config code: `Symfony\AI\Mate\Encoding\ResponseEncoder::encodeUntrusted()`, `Symfony\AI\Mate\Container\MateHelper::disableFeatures()`
- Profiler extension point: `Symfony\AI\Mate\Bridge\Symfony\Profiler\Service\CollectorFormatterInterface` with the tag `ai_mate.profiler_collector_formatter`
- Composer keys: `extra.ai-mate.scan-dirs`, `extra.ai-mate.includes`, `extra.ai-mate.instructions`, `extra.ai-mate.skills`, `extra.ai-mate.extension`
- Parameters in `mate/config.php`: `mate.invocation`, `mate.php_version`, `mate.env_file`, `mate.cache_dir`, `mate.root_dir` (read-only), `ai_mate_symfony.cache_dir`, `ai_mate_symfony.profiler_dir`, `ai_mate_monolog.log_dir`
- Project files: `mate/config.php`, `mate/extensions.php`, `mate/.env`, `mate/src/` (namespace `Mate\`), `mate/skills/<name>/`, `mate/AGENT_INSTRUCTIONS.md`, `.agents/skills/`, `.claude/skills/`
- Core tool: `server-info`
- Symfony extension tools: `symfony-services`, `symfony-service-detail`, `symfony-profiler-list`, `symfony-profiler-get`, `symfony-dotenv-check`; resource templates `symfony-profiler://profile/{token}` and `symfony-profiler://profile/{token}/{collector}`
- Monolog extension tools: `monolog-search`, `monolog-context-search`, `monolog-tail`, `monolog-list-files`, `monolog-list-channels`
- Shipped skills: `php-environment-check`, `system-information` (core); `symfony-request-triage`, `symfony-profiler-debugging`, `symfony-service-inspection`, `symfony-dotenv-diagnostics` (Symfony extension); `symfony-log-investigation` (Monolog extension)
- Debug environment variables: `MATE_DEBUG`, `MATE_DEBUG_FILE`, `MATE_DEBUG_LOG_FILE`
- Composer plugin class: `Symfony\AI\Mate\ComposerPlugin\MatePlugin`

## Symbiotic packages

- [MCP Bundle](../packages/mcp-bundle.md): often confused with Mate. MCP Bundle makes a Symfony application an MCP server or client with `mcp/sdk`, but Mate has no MCP server since 0.13. Use MCP Bundle to expose application tools to MCP clients, and Mate to give a coding agent development tools.
- [AI Agent](../packages/ai-agent.md): often confused through the attributes. `#[AsTool]` gives a tool to an LLM agent in your application. `#[MateTool]` gives a tool to a coding agent, and the docs say that the two are not related.
- [AI Bundle](../packages/ai-bundle.md): Mate does not integrate with the AI Bundle. Use the AI Bundle for AI features of the application, and Mate for development tools.
- [FrameworkBundle](../packages/framework-bundle.md): in debug mode, FrameworkBundle dumps the container XML that `symfony-services` and `symfony-service-detail` read. These tools replace `bin/console debug:container` for the agent.
- [DependencyInjection](../packages/dependency-injection.md): `mate/config.php` and the `includes` files of extensions are PHP service files with `ContainerConfigurator`, and Mate builds its own container from them.
- [WebProfilerBundle](../packages/web-profiler-bundle.md): the profiler tools of the Symfony extension read the stored profiles. The docs say that these tools need this bundle to have profiles to read.
- [HttpKernel](../packages/http-kernel.md): the profiler tools of the Symfony extension need HttpKernel, and the formatters read the HttpKernel data collectors.
- [Dotenv](../packages/dotenv.md): `symfony-dotenv-check` replaces `bin/console debug:dotenv` and masks the values. Mate also uses Dotenv to load the file in `mate.env_file`.
- [MonologBundle](../packages/monolog-bundle.md): the Monolog extension searches the `*.log` files that Monolog writes, in the default line format or as JSON lines.
- [Mailer](../packages/mailer.md): the `mailer` formatter lists the messages of one request, with masked addresses and without the message bodies.
- [Translation](../packages/translation.md): the `translation` formatter lists the locale and the defined, missing and fallback messages of one request.
- [Monolog Bridge](../packages/monolog-bridge.md): the README of the Mate Monolog extension has the title "Monolog Bridge", but the extension does not require `symfony/monolog-bridge`.

## Changed in 0.9 to 0.14

- `mate serve`, `mate stop`, `mcp.json`, `.mcp.json` and the `bin/codex` wrappers -> removed in 0.13. The agent runs `vendor/bin/mate` commands, which `AGENTS.md` and `CLAUDE.md` describe.
- `mcp:tools:list`, `mcp:tools:inspect`, `mcp:tools:call <tool> '{"limit": 1}'`, `mcp:resources:read` -> `tools:list`, `tools:inspect`, `tools:call <tool> --limit=1` (or `--json='{...}'`), `resources:read` (0.13).
- `Mcp\Capability\Attribute\McpTool`, `McpResource`, `McpResourceTemplate` -> `Symfony\AI\Mate\Attribute\MateTool`, `MateResource`, `MateResourceTemplate` (0.13). `name` is now required, and the attributes apply to methods only. `#[McpPrompt]` has no replacement. Put the prompt text into a skill or into `AGENTS.md`.
- Skills as symlinks into `vendor/` -> copies in `.agents/skills/mate-<name>/` (0.13). Do not edit these copies. To change a skill, use `skills:override <name>`.
- A project from before 0.13 -> add `mate.invocation` and `mate.php_version` to `mate/config.php` by hand, because `discover` does not add them.
- `monolog-tail --lines=50` -> `monolog-tail --limit=50` (0.13).
- `bin/console debug:dotenv` -> `symfony-dotenv-check`, which never returns a raw value (0.14).
- `namespace App\Mate;` and the `App\Mate\` autoload entry -> `namespace Mate;` and `"Mate\\": "mate/src/"` in `autoload-dev` (0.9).

## Status

- 0.x: symfony/ai-mate v0.14.0 is the latest version on Packagist. Minor versions break the API; for example, 0.13 removed the MCP server. Before an update, read `UPGRADE.md` of symfony/ai.
- Development only: install the package with `--dev`. Do not deploy it to production.
- The packages need PHP 8.2 or higher. The Symfony extension needs `symfony/dependency-injection` 7.3, 7.4 or 8.x. Its container tools need the `simplexml` PHP extension, which the extension does not require in `composer.json`.
- The Mate packages have no v0.14.1 release. All four Mate packages (`symfony/ai-mate`, `symfony/ai-mate-composer-plugin`, `symfony/ai-symfony-mate-extension`, `symfony/ai-monolog-mate-extension`) are at v0.14.0.
- The Mate docs are in the symfony/ai repository, not in symfony-docs.

## Docs

- https://symfony.com/doc/current/ai/components/mate.html
- https://symfony.com/doc/current/ai/components/mate/integration.html
- https://symfony.com/doc/current/ai/components/mate/extensions.html
- https://symfony.com/doc/current/ai/components/mate/skills.html
- https://symfony.com/doc/current/ai/components/mate/commands.html
- https://symfony.com/doc/current/ai/components/mate/creating-extensions.html
- https://symfony.com/doc/current/ai/components/mate/troubleshooting.html
- https://github.com/MatesOfMate/awesome-mate (the list of community extensions that the Mate docs link)
