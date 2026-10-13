# MonologBundle (`symfony/monolog-bundle`): details

**Applies to:** MonologBundle 4.1, Monolog 3

## Key features and concepts

- **Default logger:** The `logger` service is the Monolog logger of the `app` channel (service `monolog.logger`). `Psr\Log\LoggerInterface` is an alias of `logger`, so autowiring injects this logger. The `monolog.timezone` option (new in 4.1) sets the time zone of the record timestamps. If you do not set it, the PHP default time zone applies. Entry point: autowire `Psr\Log\LoggerInterface`.
- **Handler stack:** Each entry under `monolog.handlers` creates the service `monolog.handler.<name>`. The `type` option selects the handler class, and `level` sets the minimum level (default `DEBUG`). A handler with a higher `priority` (default `0`) runs first; equal priorities keep the order of definition. `enabled: false` removes a handler, and `bubble: false` stops the record after this handler. The bundle reserves the handler name `debug`. Entry point: `monolog.handlers.<name>.type`.
- **Handler types:** The bundle maps 42 `type` values to Monolog and MonologBridge handler classes. Examples are `stream`, `rotating_file`, `console`, `syslog`, `error_log`, `symfony_mailer`, `slackwebhook`, `telegram`, `redis`, `mongodb`, `elastic_search`, `null`, `noop` and `test`. The type `service` adds a handler service of your own. For the full list, read `getHandlerClassByType()` in the bundle class `MonologExtension`. Entry point: `type: service` and `id: <handler service id>`.
- **Fingers crossed buffer:** `type: fingers_crossed` keeps all records of a request in memory. When one record reaches `action_level` (default `WARNING`), the handler passes all kept records to the nested `handler`. `buffer_size` limits the buffer and removes the oldest records (default `0`, no limit). `passthru_level` sends the records of that level or higher at the end, also without activation. `activation_strategy` takes the service id of your own activation strategy. A top-level handler of this type gets the `kernel.reset` tag, so the Messenger worker clears the buffer between messages. Entry point: `type: fingers_crossed` and `handler: <name>`.
- **Excluded HTTP codes:** On a `fingers_crossed` handler, HTTP exceptions with a status code in `excluded_http_codes` do not activate the handler. With URL path patterns, as in `{ 400: ['^/api'] }`, the exclusion applies only to the matching paths. You cannot use this option together with `activation_strategy`. By default, Symfony logs 4xx exceptions at the `ERROR` level. If `passthru_level` is `error` or lower, the nested handler still gets these records. Entry point: `excluded_http_codes: [404, 405]`.
- **Wrapper handlers:** `buffer` keeps the records until the handler closes, then sends them as one batch. `deduplication` also buffers, and it compares the records of `deduplication_level` (default `ERROR`) or higher with the records that it sent before. If all of them have the same level and message as a record from the last `time` seconds (default `60`), it drops the batch. `filter` passes only `accepted_levels`, or the levels from `min_level` to `max_level`. `sampling` passes about one record in `factor` records. `group` sends each record to all `members`; `whatfailuregroup` ignores the failures of members; `fallbackgroup` stops at the first member that succeeds. Entry point: `type: deduplication` and `handler: <name>`, or `type: group` and `members: [...]`.
- **Log rotation:** `type: rotating_file` writes one file per day, named `{filename}-{date}` from the `path` option. `max_files` sets the number of files to keep (default `0`, keep all files). `date_format` also accepts `Y-m-d-H`, `Y-m` and `Y`. Entry point: `type: rotating_file` and `max_files: 10`.
- **Email handlers:** `type: symfony_mailer` sends records by email through Symfony Mailer (service `mailer.mailer` by default). Set `from_email`, `to_email` and `subject`, or set an `email_prototype` service. In `subject`, `%%message%%` inserts the message of the record with the highest level. With `formatter: monolog.formatter.html`, the email has an HTML body. `type: native_mailer` uses the PHP function `mail()`. Entry point: `type: symfony_mailer`.
- **Channels:** Each channel other than `app` has its own logger service, `monolog.logger.<channel>`. `monolog.channels` declares more channels. A `monolog.logger` tag or a `#[WithMonologChannel]` attribute also creates its channel. The Flex recipe declares the `deprecation` channel, and FrameworkBundle then logs deprecations to it. The handler option `channels` takes a list (`[security]`) or an exclusion list (`['!event']`). This option works only on top-level handlers, not on nested handlers. Entry point: `monolog.channels` and `monolog.handlers.<name>.channels`.
- **Channel logger injection:** For each channel except `app`, the bundle registers a named autowiring alias. Add `#[Target('<channel>')]` to a `LoggerInterface` argument to get the logger of that channel. For the `app` channel, use `LoggerInterface` without an attribute. Symfony 8.1 deprecates a match only by the argument name (`$billingLogger`). `#[Autowire(service: 'monolog.logger.<channel>')]` also works. Entry point: `#[Target('billing')] LoggerInterface $logger`.
- **`#[WithMonologChannel]` attribute:** On a service class, `#[WithMonologChannel('billing')]` gives the `billing` logger to each autowired `LoggerInterface` argument. On one constructor argument (new in 4.1), it changes only that argument. The equivalent service tag is `monolog.logger` with `channel` and an optional `argument`. Entry point: `Monolog\Attribute\WithMonologChannel`.
- **Processors:** A processor changes each record, for example it adds data to `$record->extra`. `#[AsMonologProcessor]` on a class or a method registers a processor. The `channel` or `handler` argument limits it to one channel or one handler, but you cannot set both. On a class, `method` selects the method (default `__invoke()`). A processor with a higher `priority` runs first. A service that implements `ProcessorInterface` gets the `monolog.processor` tag through autoconfiguration. Entry point: `Monolog\Attribute\AsMonologProcessor`.
- **Formatters:** The handler option `formatter` takes a formatter service id. The bundle registers 12 formatter services: `monolog.formatter.json`, `line`, `html`, `logstash`, `syslog`, `google` (new in 4.1), `chrome_php`, `gelf_message`, `loggly`, `normalizer`, `scalar` and `wildfire`. `include_stacktraces: true` adds stack traces to line and JSON output. A `service` handler cannot have the `formatter` option. Entry point: `formatter: monolog.formatter.json`.
- **PSR-3 placeholders:** The bundle adds `PsrLogMessageProcessor` to each handler without a nested `handler` or `members`, but not to a `type: service` handler. This processor replaces placeholders such as `{userId}` with values from the context. Set `process_psr_3_messages: false` to stop this replacement. Entry point: `process_psr_3_messages`.
- **Console output:** `type: console` writes records to the error output (stderr) of the running command, according to the verbosity. By default, `-q` shows errors, the normal verbosity shows warnings, `-v` notices, `-vv` info and `-vvv` debug messages. `verbosity_levels` changes this map. With `interactive_only: true`, the handler writes only in interactive mode, and the next handlers do not get the records that it writes. In non-interactive mode, it writes nothing, and the next handlers get the records. Entry point: `type: console`.

## Entry points

- Autowire `Psr\Log\LoggerInterface` to get the `logger` service, an alias of `monolog.logger` (channel `app`).
- `#[Symfony\Component\DependencyInjection\Attribute\Target('<channel>')]` on a `LoggerInterface` argument to get the logger of a declared channel.
- `#[Symfony\Component\DependencyInjection\Attribute\Autowire(service: 'monolog.logger.<channel>')]` to get a channel logger by its service id.
- `#[Monolog\Attribute\WithMonologChannel('<channel>')]` on a service class or on a constructor argument.
- `#[Monolog\Attribute\AsMonologProcessor]` on a processor class or method, and the interface `Monolog\Processor\ProcessorInterface` (autoconfigured).
- Service tags `monolog.logger` (attributes `channel` and `argument`) and `monolog.processor` (attributes `channel`, `handler`, `method` and `priority`).
- Config key `monolog` with `monolog.handlers`, `monolog.channels`, `monolog.use_microseconds` and `monolog.timezone`. The Flex recipe creates `config/packages/monolog.yaml` with `when@dev`, `when@test` and `when@prod` handlers.
- In PHP config files, return `App::config(['monolog' => [...]])`. Symfony 8 does not support XML config or the fluent `MonologConfig` closures.
- Service ids `logger`, `monolog.logger.<channel>`, `monolog.handler.<name>` and `monolog.formatter.<name>`.
- `Monolog\Logger::reset()` to clear the handler buffers between the jobs of a long-running process.
- Console commands from FrameworkBundle: `debug:config monolog`, `config:dump-reference monolog`, `debug:autowiring logger` and `debug:container monolog`.
- Install with `composer require symfony/monolog-bundle`. The bundle has no console command, Twig function or test assertion of its own.

## Symbiotic packages

- [Monolog Bridge](../packages/monolog-bridge.md): it holds the Symfony handler and processor classes, such as `ConsoleHandler` and `MailerHandler`, that this bundle creates from the `monolog` config.
- [FrameworkBundle](../packages/framework-bundle.md): its services log to channels such as `request` and `cache`, and `framework.exceptions.<class>.log_channel` selects the channel that logs an exception class.
- [DependencyInjection](../packages/dependency-injection.md): `#[Target]` and `#[Autowire]` select a channel logger, and with autoconfiguration, `ServicesBundle` adds a `setLogger()` call to services that implement `LoggerAwareInterface`.
- [Mailer](../packages/mailer.md): the `symfony_mailer` handler type sends log records by email through the `mailer.mailer` service.
- [Console](../packages/console.md): the `console` handler type shows log records in the command output; use `ConsoleLogger` only in console apps without Monolog.
- [HttpKernel](../packages/http-kernel.md): without this bundle, HttpKernel registers its minimal `Logger` as the `logger` service; `excluded_http_codes` reads the status code of `HttpExceptionInterface` exceptions.
- [Messenger](../packages/messenger.md): the worker resets services between messages, so a `fingers_crossed` handler does not keep the records of the previous message.
- [Security](../packages/security-bundle.md): it logs to the `security` channel, and it gives `security.untracked_token_storage` to the `TokenStorageInterface` argument of processors that implement `ProcessorInterface`.
- [WebProfilerBundle](../packages/web-profiler-bundle.md): when the profiler is enabled, FrameworkBundle collects the records of all Monolog loggers, and the profiler shows them for each request.
- [DebugBundle](../packages/debug-bundle.md): it registers the `server:log` command, which shows the records that a `server_log` handler sends to it.
- [AI Mate](../packages/ai-mate.md): its package `symfony/ai-monolog-mate-extension` gives an AI agent tools that search and tail the log files in `var/log`.
- [ErrorHandler](../packages/error-handler.md): the `php` channel receives the PHP errors, and the `request` channel receives the uncaught exceptions.
- [Notifier](../packages/notifier.md): a handler with `type: service` and `id: notifier.monolog_handler` connects the log channels to the notifier.

## Changed in 4.0 to 4.1 (with Symfony 8.0 and 8.1)

- `excluded_404s: ['^/foo']` -> `excluded_http_codes: [{ 404: ['^/foo'] }]` (4.0 removed `excluded_404s`).
- `type: elasticsearch` -> `type: elastica` or `type: elastic_search`; `type: mongo` -> `type: mongodb`; `console_formater_options` -> `console_formatter_options` (removed in 4.0).
- `type: sentry` and `type: raven` -> `type: service` with a handler from `sentry/sentry-symfony` (removed in 4.0).
- `NotFoundActivationStrategy` or the abstract service `monolog.activation_strategy.not_found` -> `excluded_http_codes` (MonologBridge 8.0 removes the class; 4.0 removes this service and `monolog.handler.fingers_crossed.error_level_activation_strategy`).
- `#[WithMonologChannel]` on a constructor argument (new in 4.1, needs Monolog 3.12) -> one service gets the loggers of different channels without service config.
- New in 4.1: `monolog.timezone`, the `monolog.formatter.google` service, `expand_newlines` for `error_log`, `parameters` for `native_mailer`, `rfc` for `syslogudp`, and `OutputInterface::VERBOSITY_*` keys in `verbosity_levels`. 4.1 deprecates and ignores the `predis` option; for `type: predis`, configure the Predis client under `redis`.
- `LoggerInterface $billingLogger` without an attribute -> `#[Target('billing')] LoggerInterface $logger` (Symfony 8.1 deprecates the match by name only).
- `return static function (MonologConfig $monolog) { $monolog->handler('main')->type('stream'); };` -> YAML, or `return App::config(['monolog' => [...]]);` (Symfony 8.0 removed the fluent PHP format and XML config).

## Docs

- https://symfony.com/doc/current/logging.html
- https://symfony.com/doc/current/logging/channels_handlers.html
- https://symfony.com/doc/current/logging/monolog_exclude_http_codes.html
- https://symfony.com/doc/current/logging/monolog_email.html
- https://symfony.com/doc/current/logging/processors.html
- https://symfony.com/doc/current/logging/monolog_console.html
- https://symfony.com/doc/current/logging/formatter.html
- https://symfony.com/doc/current/logging/handlers.html
- https://symfony.com/doc/current/reference/configuration/monolog.html
- https://symfony.com/doc/current/service_container/autowiring.html
- https://github.com/symfony/monolog-bundle/blob/4.x/src/DependencyInjection/Configuration.php
