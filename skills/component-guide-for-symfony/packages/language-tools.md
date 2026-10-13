# Symfony Language Tools (`symfony/lsp`)

**Applies to:** symfony/lsp 0.23, Symfony CLI 5.22

**Elevator pitch:** Use when an editor must complete, or a CI job must check, the route names, template names, translation keys and configuration keys of an application. It is an LSP server and a command-line checker in one executable, for Symfony applications. It is an experimental 0.x tool from GitHub, not a Composer dependency.

**Details:** [../details/language-tools.md](../details/language-tools.md)

## Why it exists

A general PHP language server does not know the routes, templates and configuration that a Symfony application builds when it starts. The tool starts the application in debug mode and reads this metadata through the debug commands of the application. The editor then gets completion and navigation, and the editor and CI get the same diagnostics.

## When to use it

- Find unknown route names, missing route parameters, unknown templates and unknown configuration parameters in CI.
- Find missing translation keys and translation placeholders that do not match the passed parameters.
- Find unknown or deprecated configuration keys and values of the wrong type in the configuration files.
- Report framework problems as GitHub annotations, a GitLab Code Quality report, SARIF or JSON.
- Accept the existing findings of an old application with a baseline, and block only new findings.
- Get completion, hover, go to definition, references and rename in VS Code, Neovim, Zed or another LSP client.
- Give a coding agent, such as OpenCode, framework diagnostics and navigation.
- Analyze an application that runs in Docker when PHP is not installed on the host.
- Check code that you do not trust from its source files only, without running the application.

## Use it instead of

- `bin/console debug:router --format=json` in a CI script, compared with a `grep` for `path('…')` in `templates/` -> `symfony-lsp check --fail-on=route.not_found,route.missing_parameters`.
- A PHPUnit test that calls `$router->generate($name)` for each route name that a regex finds -> `route.not_found` and `route.missing_parameters` from `symfony-lsp check`.
- `test -f "templates/$name"` for each `render()` argument -> `template.not_found`, which resolves the name through each Twig loader path of the application.
- A test that parses `translations/messages.en.yaml` and compares its keys with the `|trans` calls -> `symfony-lsp check --translation-diagnostics` (`translation.not_found`, `translation.domain_not_found`), plus `translation.placeholders`.
- A manual comparison of `bin/console config:dump-reference framework` with `config/packages/*.yaml` -> `config.unknown_key`, `config.invalid_type` and `config.deprecated_key` in the editor and in `symfony-lsp check`.
- `grep -v -f known-issues.txt` on the CI output -> `symfony-lsp check --generate-baseline` once, then `--baseline=.symfony-lsp-baseline.json` in each run.
- A script that prints `echo "::error file=$f,line=$l::$msg"` or writes a SARIF file -> `symfony-lsp check --format=github`, `--format=gitlab` or `--format=sarif`.
- A search and replace of a route name or translation key in PHP, Twig and YAML files -> the rename feature of the `symfony-lsp` server.
