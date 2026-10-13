# DebugBundle (`symfony/debug-bundle`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Web debug toolbar and profiler panel:** In debug mode, `DebugBundle::boot()` sets the VarDumper handler, so `dump()` sends each dump to the `data_collector.dump` service. The web debug toolbar shows the number of dumps, and each dump with its label, file and line. In the profiler panel "Debug", a click on a line number shows the source lines around that call. If a request has dumps and no exception, the profiler opens the "Debug" panel first. In 8.1, the toolbar gives the CSP nonces of the response to the collector. Entry point: `Symfony\Component\HttpKernel\DataCollector\DumpDataCollector`.
- **Dump destination:** `debug.dump_destination` sets a second destination for the dumps, and the profiler keeps the dumps of a web request in all cases. The bundle default `null` adds no second destination. A stream such as `php://stderr` gets each dump as text at once. A `tcp://` URL sends each dump to the dump server. If the value is a file path, the dumper opens the file in `w` mode, which removes the old content. Entry point: `debug.dump_destination`.
- **Output fallback:** If `dump_destination` is `null` and the web debug toolbar cannot show the dumps, the collector writes them to the PHP output, before the response content. This occurs for a redirect, a non-HTML response, a page without `</body>`, or when the toolbar is off. HTML responses get HTML dumps, and other responses get text dumps. The dumps of AJAX requests, requests with an `Origin` header and sub-requests stay only in the profiler. Entry point: `DumpDataCollector::collect()`.
- **`dd()`:** `dd()` dumps its arguments and stops the script with exit code 1. In a web request, it first sends the HTTP status 500 if PHP has not sent the headers. If `dump_destination` is `null` or the dump server does not answer, the collector writes the dumps to the output before the exit. HttpKernel 7.4.17 and 8.1.5 added this behavior. Entry point: `dd()`.
- **Console commands:** On the `console.command` event, `DumpListener` sets a new dump handler. If `dump_destination` is a `tcp://` URL and the dump server runs, the dumps go only to the server. In the other cases, the dumps go to the standard output, or to the stream in `dump_destination`. With the `--profile` option, the profile of the command also keeps these dumps. With a `null` destination, the collector then writes the dumps to the standard output only at the end of the command. With a `tcp://` destination and no running dump server, only the profile keeps them. The `--profile` option needs debug mode, the Stopwatch component and `framework.profiler`. Entry point: `Symfony\Component\HttpKernel\EventListener\DumpListener`.
- **Dump server:** `php bin/console server:dump` shows the dumps of all web requests and commands in one terminal, with their source, request and command context. `server:dump --format=html > dump.html` saves the dumps as an HTML page. The server and its client connection use the address in `dump_destination`, and `VAR_DUMPER_SERVER` defaults to `127.0.0.1:9912`. If `dump_destination` is not a `tcp://` URL, `server:dump` only shows a warning and exits with code 8. Entry point: `server:dump`.
- **Flex recipe and packs:** The Flex recipe enables the bundle in the `dev` environment only. It creates `config/packages/debug.yaml`, which sets `dump_destination` to `tcp://%env(VAR_DUMPER_SERVER)%` under `when@dev`. With this file, PHP `dump()` calls do not change a web response that ends normally. The dumps go to the dump server if it runs, and the profiler keeps them in both cases. `composer require --dev debug` installs `symfony/debug-pack`, which adds DebugBundle, MonologBundle and `symfony/profiler-pack`. The `dump` alias installs only VarDumper. Entry point: `config/packages/debug.yaml`.
- **Twig dumps:** `{% dump articles %}` sends the value through the VarDumper handler, like PHP `dump()`, so the web debug toolbar shows it. `{{ dump(article) }}` prints the value in the page with the HTML dumper. Without arguments, both dump all template variables. If DebugBundle is enabled and `twig.debug` is false, both output nothing; the `twig.debug` default is `%kernel.debug%`. The Flex recipe enables DebugBundle only in `dev`, so in `prod` both cause a Twig `SyntaxError`. Do not use `{{ dump() }}` in an HTML attribute or in a `<script>` tag. Entry point: `Symfony\Bridge\Twig\Extension\DumpExtension` (service `twig.extension.dump`).
- **Labels:** In PHP, `dump(order: $order)` uses the argument name as the label of the dump. The Symfony docs show the same form in Twig. The `dump()` function of `DumpExtension` is not variadic, so `{{ dump(user: app.user) }}` causes a `SyntaxError` ("Unknown argument"). To show names in Twig, use `{% dump articles, user %}`. This tag dumps one array with the variable names as keys. Entry point: `dump(name: $value)` and `{% dump %}`.
- **Cloner limits:** `max_items` (default `2500`) limits the number of items that the cloner keeps past the `min_depth` level; `-1` removes the limit. `min_depth` (default `1`) sets the depth to which the cloner keeps all items. `max_string_length` (default `-1`, no limit) cuts longer strings. Entry point: `debug.max_items`, `debug.min_depth`, `debug.max_string_length`.
- **Theme:** `theme` (`dark` or `light`, default `dark`) sets the colors of the `var_dumper.html_dumper` service. This service renders the Twig `dump()` function and `server:dump --format=html`. The web debug toolbar and the profiler do not use this theme. Entry point: `debug.theme`.
- **IDE links:** The dumpers and the profiler link each file and line to an editor through the `debug.file_link_formatter` service. To select the editor, set `framework.ide` or the `SYMFONY_IDE` environment variable, for example to `phpstorm` or `vscode`. Entry point: `framework.ide`.
- **Log server:** If `symfony/monolog-bridge`, `monolog/monolog` and the Console component are installed, the bundle registers the `server:log` command. The command listens on `--host` (default `127.0.0.1:9911`) and shows the log records of a MonologBundle handler with `type: server_log`. The `--filter` option takes an ExpressionLanguage expression, for example `level > 200 or channel in ['app', 'doctrine']`. This command is not `symfony server:log` of the Symfony CLI, which shows the web server, PHP and application logs. Entry point: `server:log` (`Symfony\Bridge\Monolog\Command\ServerLogCommand`).
- **`VAR_DUMPER_FORMAT`:** If `$_SERVER['VAR_DUMPER_FORMAT']` is set, `VarDumper::setHandler()` ignores all new handlers. Then VarDumper uses its own handler for that format, and the web debug toolbar shows no dumps. Entry point: `VAR_DUMPER_FORMAT`.

## Entry points

- `Symfony\Bundle\DebugBundle\DebugBundle` in `config/bundles.php` with `['dev' => true]` (the Flex recipe adds it)
- Config root `debug`: `config/packages/debug.yaml`, or `return App::config(['debug' => [...]]);` in `config/packages/debug.php` with `namespace Symfony\Component\DependencyInjection\Loader\Configurator;`
- Config keys: `debug.dump_destination`, `debug.max_items`, `debug.min_depth`, `debug.max_string_length`, `debug.theme`
- Environment variables: `VAR_DUMPER_SERVER` (default `127.0.0.1:9912`), `SYMFONY_IDE`; `VAR_DUMPER_FORMAT` bypasses the bundle
- PHP functions (VarDumper): `dump()`, `dd()`
- Twig: the `dump()` function and the `{% dump %}` tag (`Symfony\Bridge\Twig\Extension\DumpExtension`, `Symfony\Bridge\Twig\TokenParser\DumpTokenParser`)
- Console commands: `server:dump [--format=cli|html]`, `server:log [--host=] [--format=] [--date-format=] [--filter=]`, and the global `--profile` option (FrameworkBundle)
- Config inspection (FrameworkBundle): `php bin/console config:dump-reference debug`, `php bin/console debug:config debug`, `php bin/console debug:config --resolve-env debug`
- MonologBundle handler for `server:log`: `type: server_log` with `host: 127.0.0.1:9911`
- Service IDs (the bundle defines no autowiring aliases): `data_collector.dump` (public), `var_dumper.cloner` (public), `debug.dump_listener`, `twig.extension.dump`, `var_dumper.cli_dumper`, `var_dumper.html_dumper`, `var_dumper.server_connection`, `var_dumper.dump_server`, `var_dumper.command.server_dump`, `monolog.command.server_log`
- Data collector: ID `dump`, template `@Debug/Profiler/dump.html.twig`, priority 240
- Runtime classes: `Symfony\Component\HttpKernel\DataCollector\DumpDataCollector` (`getDumpsCount()`, `setNonce()`), `Symfony\Component\HttpKernel\EventListener\DumpListener`, `Symfony\Component\VarDumper\Server\Connection`

## Symbiotic packages

- [VarDumper](../packages/var-dumper.md): VarDumper provides `dump()`, `dd()`, the cloner, the dumpers and the dump server, and DebugBundle connects them to the kernel, the profiler and Twig.
- [WebProfilerBundle](../packages/web-profiler-bundle.md): It shows the dumps in the web debug toolbar and in the "Debug" profiler panel, and it gives the CSP nonces to `DumpDataCollector`.
- [HttpKernel](../packages/http-kernel.md): HttpKernel contains `DumpDataCollector` and `DumpListener`, which collect the dumps of web requests and set the dump handler of console commands.
- [Twig Bridge](../packages/twig-bridge.md): The bridge defines `DumpExtension` with the `dump()` function and the `{% dump %}` tag, and DebugBundle registers it as the `twig.extension.dump` service.
- [TwigBundle](../packages/twig-bundle.md): Twig dumps need `twig.debug`. Without DebugBundle, for example in `test`, TwigBundle adds the Twig `DebugExtension` in debug mode. Its `dump()` prints `var_dump()` output, and the `{% dump %}` tag causes an error. In `prod`, both cause an error.
- [FrameworkBundle](../packages/framework-bundle.md): FrameworkBundle gives the `--profile` option, `framework.ide` and commands such as `debug:container` and `debug:config`; DebugBundle adds no `debug:*` command.
- [Console](../packages/console.md): `DumpListener` sets the dump handler on the `console.command` event, and `server:dump` and `server:log` are Console commands.
- [Stopwatch](../packages/stopwatch.md): `DumpDataCollector` measures the time of each dump with `debug.stopwatch`, and the console `--profile` option needs Stopwatch.
- [Monolog Bridge](../packages/monolog-bridge.md): The bridge contains the `server:log` command and `ServerLogHandler`, and DebugBundle registers the command as `monolog.command.server_log`.
- [MonologBundle](../packages/monolog-bundle.md): A MonologBundle handler with `type: server_log` sends log records to `server:log`, and `symfony/debug-pack` installs MonologBundle with DebugBundle.
- [ExpressionLanguage](../packages/expression-language.md): The `--filter` option of `server:log` needs ExpressionLanguage to select log records.
- [Symfony Flex](../packages/flex.md): The recipe enables DebugBundle in `dev` with the dump server destination; the `debug` alias installs `symfony/debug-pack`, but the `dump` alias installs only VarDumper.
- [ErrorHandler](../packages/error-handler.md): ErrorHandler, not DebugBundle, handles PHP errors and error pages, and Packagist names it as the replacement of the abandoned `symfony/debug`.

## Changed in 8.0/8.1

- `config/packages/debug.xml` with `<debug:config dump-destination="php://stderr"/>` (8.0 removed the XML configuration format) -> `config/packages/debug.yaml` with `debug: { dump_destination: php://stderr }`, or `return App::config(['debug' => ['dump_destination' => 'php://stderr']]);` in `config/packages/debug.php` (namespace `Symfony\Component\DependencyInjection\Loader\Configurator`).
- A temporary `$output->writeln(print_r($data, true));` to inspect a profiled command -> `dump($data)` and `php bin/console --profile app:my-command`; the command profile keeps the dump if no running dump server gets it (new in 7.4 and 8.0).
- `php bin/console server:log` listened on `0.0.0.0:9911` by default -> since 7.4.12, 8.0.12 and 8.1.0, it listens on `127.0.0.1:9911` (CVE-2026-45077); pass `--host` for another address.

## Status

The package requires the PHP `xml` extension (`ext-xml` in its `composer.json`), although Symfony 8.0 removed the XML configuration format.

## Docs

- https://symfony.com/doc/current/reference/configuration/debug.html
- https://symfony.com/doc/current/components/var_dumper.html
- https://symfony.com/doc/current/templates.html
- https://symfony.com/doc/current/reference/twig_reference.html
- https://symfony.com/doc/current/profiler.html
- https://symfony.com/doc/current/console.html
- https://symfony.com/doc/current/reference/configuration/framework.html
- https://symfony.com/doc/current/reference/configuration/twig.html
- https://symfony.com/doc/current/setup.html
