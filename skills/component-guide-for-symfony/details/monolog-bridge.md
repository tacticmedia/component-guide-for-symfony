# Monolog Bridge (`symfony/monolog-bridge`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Console output by verbosity:** The `console` handler type writes the log records of a command to its error output (stderr). At normal verbosity, it shows `WARNING` and higher. It adds `NOTICE` with `-v`, `INFO` with `-vv` and `DEBUG` with `-vvv`. With `-q` it shows only `ERROR` and higher, and with `--silent` it shows nothing. The `verbosity_levels` option changes this map. Entry point: `Symfony\Bridge\Monolog\Handler\ConsoleHandler`.
- **Interactive mode only:** If `interactive_only` is `true`, the handler writes only when the input is interactive. When it writes a record, the next handlers do not get that record. With `-n` (`--no-interaction`), `-q` or `--silent`, it writes nothing, and the next handlers get the records. Entry point: the `interactive_only` option of the `console` handler type.
- **Console format:** `ConsoleFormatter` shows the time, the level in color, the channel, the message, the context and the extra data. It replaces `{name}` placeholders in the message with the context values in color. The `console_formatter_options` option sets `format`, `date_format`, `colors`, `multiline`, `level_name_format` and `ignore_empty_context_and_extra`. With `-vvv`, the handler shows the context and the extra data on more than one line. The docs and the Flex recipe set `process_psr_3_messages: false` on this handler. Without `symfony/var-dumper`, the handler uses a plain `LineFormatter`. Entry point: `Symfony\Bridge\Monolog\Formatter\ConsoleFormatter`.
- **Error emails:** The `symfony_mailer` handler type sends log records as an email through Symfony Mailer. Put it behind a `fingers_crossed` handler and a `deduplication` handler. Then a failed request sends one email, and the same error does not send a new email for 60 seconds. The `subject` is a `LineFormatter` format for the record with the highest level. In the config files, write the placeholder as `%%message%%`. With `formatter: monolog.formatter.html`, the email body is HTML. MonologBundle accepts the `content_type` option but does not use it. The handler cuts a subject longer than 200 characters and ends it with `[...]`. Entry point: `Symfony\Bridge\Monolog\Handler\MailerHandler`.
- **Notifier alerts:** `NotifierHandler` sends a log record as a Notifier `Notification` to the admin recipients (`framework.notifier.admin_recipients`). For a batch, it uses the record with the highest level. It handles only `ERROR` and higher records, also when you set a lower level. If the record context has an `exception`, it calls `Notification::fromThrowable()`. `CRITICAL` and higher records get the `urgent` importance, and `ERROR` records get `high`. The `framework.notifier.channel_policy` option then selects the channels, for example `chat/slack`. FrameworkBundle registers the handler as `notifier.monolog_handler`. In MonologBundle, reference it with `type: service` and `id: notifier.monolog_handler`. Entry point: `Symfony\Bridge\Monolog\Handler\NotifierHandler`.
- **HTTP code exclusions:** On a `fingers_crossed` handler, `excluded_http_codes` wraps the activation strategy in `HttpCodeActivationStrategy`. A record whose `exception` context is an `HttpExceptionInterface` with a listed status code then does not activate the handler. An entry such as `{ 400: ['^/foo'] }` excludes the code only for matching URL paths. By default, Symfony logs 4xx HTTP exceptions at the `ERROR` level. If `passthru_level` is `error` or lower, these records still reach the nested handler. Entry point: `Symfony\Bridge\Monolog\Handler\FingersCrossed\HttpCodeActivationStrategy`.
- **Request data:** `WebProcessor` adds `url`, `ip`, `http_method`, `server` and `referrer` from the main `Request` to the `extra` data. Its `ip` comes from `Request::getClientIp()`, so it uses the trusted proxies. `RouteProcessor` adds `requests` with the `controller`, the `route` and the `route_params` of each active request. Entry points: `Symfony\Bridge\Monolog\Processor\WebProcessor`, `Symfony\Bridge\Monolog\Processor\RouteProcessor`.
- **User data:** `TokenProcessor` adds `token` with `authenticated`, `roles` and `user_identifier` of the current user. During impersonation, `SwitchUserTokenProcessor` adds the same data for the original user as `impersonator_token`. These two processors do not implement `ProcessorInterface`, so Symfony does not inject `security.untracked_token_storage` automatically. Bind `$tokenStorage` to `@security.untracked_token_storage`. Then a log call does not mark the session as used. Entry points: `Symfony\Bridge\Monolog\Processor\TokenProcessor`, `Symfony\Bridge\Monolog\Processor\SwitchUserTokenProcessor`.
- **Command data:** `ConsoleCommandProcessor` adds `command` with the `name` and the `arguments` of the running command. To also add the options, set its `$includeOptions` argument to `true`. For nested commands, it adds the data of the inner command until that command ends. Entry point: `Symfony\Bridge\Monolog\Processor\ConsoleCommandProcessor`.
- **Processor registration:** Register a bridge processor as a service with autoconfiguration. Autoconfiguration adds the `monolog.processor` tag to `WebProcessor` and `TokenProcessor`. Add this tag yourself to `RouteProcessor`, `SwitchUserTokenProcessor` and `ConsoleCommandProcessor`. Keep autoconfiguration on, because `WebProcessor`, `RouteProcessor` and `ConsoleCommandProcessor` also need the `kernel.event_subscriber` tag. Entry point: the service tag `monolog.processor` (attributes `channel`, `handler`, `method`, `priority`).
- **Profiler logs:** In debug mode, FrameworkBundle registers `DebugProcessor` as `debug.log_processor`. If the profiler is on, `DebugLoggerConfigurator` pushes it to each channel logger in the web runtime mode. It keeps the records of each request for the "Logs" panel of the profiler and does not change the records. Entry point: `Symfony\Bridge\Monolog\Processor\DebugProcessor`.
- **Live log server:** `bin/console server:log` listens on `127.0.0.1:9911` by default and shows the records that a `server_log` handler sends (`type: server_log`, `host: 127.0.0.1:9911`). The `server_log` handler formats the records with `VarDumperFormatter` and sends them to the `host` address. The `--filter` option takes an ExpressionLanguage expression, for example `"level > 200 or channel in ['app', 'doctrine']"`. DebugBundle registers the command as `monolog.command.server_log`. It is not `symfony server:log` of the Symfony CLI, which shows the web server, PHP and application logs. Entry point: `Symfony\Bridge\Monolog\Command\ServerLogCommand`.
- **Elasticsearch:** `ElasticsearchLogstashHandler` sends records in the Logstash format to the `_bulk` API of Elasticsearch. The defaults are `http://127.0.0.1:9200` and the index `monolog`. Declare it as a service. Reference it in MonologBundle with `type: service`. In production, wrap it in a `fingers_crossed` or `buffer` handler to send one bulk request. If Elasticsearch is version 7 or later, set `$elasticsearchVersion`. The handler then omits the `_type` field. It needs `symfony/http-client`. Without a `$client` argument, it uses its own client with a 1-second timeout. But MonologBundle autoconfiguration injects `monolog.http_client`, which has no timeout option. In that case, set `$client` to a client with a `timeout` option. It writes transport errors, for example a failed connection, to `error_log()`. If Elasticsearch returns a 4xx or 5xx status code, a log call or the destructor of the handler throws a `ClientException` or a `ServerException`. Entry point: `Symfony\Bridge\Monolog\Handler\ElasticsearchLogstashHandler`.
- **Browser extensions:** The `chromephp` and `firephp` handler types add the log records to the headers of the main response for the ChromePHP and FirePHP browser extensions. They add the headers only for a matching `User-Agent` or, for FirePHP, an `X-FirePHP-Version` request header. Entry points: `Symfony\Bridge\Monolog\Handler\ChromePhpHandler`, `Symfony\Bridge\Monolog\Handler\FirePHPHandler`.
- **Channel attributes (from `monolog/monolog`):** `#[WithMonologChannel('name')]` on a service class gives its `LoggerInterface` arguments the logger of that channel. MonologBundle reads the attribute and also creates the channel logger. With MonologBundle 4.1 and Monolog 3.12, the attribute also works on one constructor argument. This bridge does not use the attribute. Entry point: `Monolog\Attribute\WithMonologChannel`.

## Entry points

- Handler types for `monolog.handlers.<name>.type` (MonologBundle config): `console` (`Symfony\Bridge\Monolog\Handler\ConsoleHandler`), `symfony_mailer` (`Symfony\Bridge\Monolog\Handler\MailerHandler`), `server_log` (`Symfony\Bridge\Monolog\Handler\ServerLogHandler`, an internal class), `chromephp` (`Symfony\Bridge\Monolog\Handler\ChromePhpHandler`) and `firephp` (`Symfony\Bridge\Monolog\Handler\FirePHPHandler`).
- Config keys of the `console` type: `verbosity_levels`, `console_formatter_options` and `interactive_only`.
- Config keys of the `symfony_mailer` type: `from_email`, `to_email`, `subject`, `mailer` (default service `mailer.mailer`) and `email_prototype`. The `email_prototype` key takes the `id` of an `Email` service, or the `id` and the `method` of a service that returns an `Email`.
- Config key `host` of the `server_log` type (required).
- Config key `excluded_http_codes` of the `fingers_crossed` type -> `Symfony\Bridge\Monolog\Handler\FingersCrossed\HttpCodeActivationStrategy`.
- Service `notifier.monolog_handler` (`Symfony\Bridge\Monolog\Handler\NotifierHandler`, registered by FrameworkBundle when `framework.notifier` is on) and the config key `framework.notifier.admin_recipients`.
- Classes to declare as services: `Symfony\Bridge\Monolog\Handler\ElasticsearchLogstashHandler`, and `Symfony\Bridge\Monolog\Handler\MailerHandler` to set `$subjectMaxLength`.
- Processors `Symfony\Bridge\Monolog\Processor\WebProcessor`, `RouteProcessor`, `TokenProcessor`, `SwitchUserTokenProcessor` and `ConsoleCommandProcessor`, with the service tag `monolog.processor`.
- Service `debug.log_processor` (`Symfony\Bridge\Monolog\Processor\DebugProcessor`, registered by FrameworkBundle in debug mode).
- Formatters `Symfony\Bridge\Monolog\Formatter\ConsoleFormatter` (constants `SIMPLE_FORMAT` and `SIMPLE_DATE`) and `Symfony\Bridge\Monolog\Formatter\VarDumperFormatter`.
- Console command `server:log` (options `--host`, `--format`, `--date-format` and `--filter`): class `Symfony\Bridge\Monolog\Command\ServerLogCommand`, service `monolog.command.server_log` (DebugBundle).
- Attributes `Monolog\Attribute\WithMonologChannel` and `Monolog\Attribute\AsMonologProcessor` (package `monolog/monolog`; MonologBundle autoconfigures them).
- Channel logger for an autowired argument: `Psr\Log\LoggerInterface` with `#[Symfony\Component\DependencyInjection\Attribute\Target('<channel>')]` (the alias comes from MonologBundle).
- Twig functions and test helpers: none in this package.

## Symbiotic packages

- [MonologBundle](../packages/monolog-bundle.md): requires this bridge, builds bridge handlers from the `monolog.handlers` config and reads the `#[WithMonologChannel]` and `#[AsMonologProcessor]` attributes.
- [Console](../packages/console.md): `ConsoleHandler` and `ConsoleCommandProcessor` listen to console events; the Console `ConsoleLogger` is for applications without Monolog.
- [HttpKernel](../packages/http-kernel.md): `WebProcessor`, `RouteProcessor` and the browser handlers listen to kernel events, and `DebugProcessor` implements its `DebugLoggerInterface` for the logger data collector.
- [FrameworkBundle](../packages/framework-bundle.md): registers `DebugProcessor` as `debug.log_processor` in debug mode and `NotifierHandler` as `notifier.monolog_handler` when the Notifier is on.
- [DebugBundle](../packages/debug-bundle.md): registers the `server:log` command as the `monolog.command.server_log` service.
- [WebProfilerBundle](../packages/web-profiler-bundle.md): its "Logs" panel shows the records that `DebugProcessor` keeps for each request.
- [Mailer](../packages/mailer.md): `MailerHandler` sends the log email through `MailerInterface`, by default through the `mailer.mailer` service.
- [Mime](../packages/mime.md): `MailerHandler` clones an `Email` template or calls a callable that returns an `Email`.
- [Notifier](../packages/notifier.md): `NotifierHandler` turns error records into a `Notification` for the admin recipients, and `channel_policy` selects the channels by importance.
- [HttpClient](../packages/http-client.md): `ElasticsearchLogstashHandler` needs an HTTP client to post the records to Elasticsearch.
- [Security](../packages/security-bundle.md): `TokenProcessor` and `SwitchUserTokenProcessor` read the token storage, and its `security.untracked_token_storage` service does not mark the session as used.
- [VarDumper](../packages/var-dumper.md): `ConsoleFormatter` and `VarDumperFormatter` dump the context with it; without it, `ConsoleHandler` uses a plain `LineFormatter`.
- [ExpressionLanguage](../packages/expression-language.md): the `--filter` option of the `server:log` command needs it.
- [Messenger](../packages/messenger.md): the worker resets services between messages, and `ConsoleCommandProcessor` keeps the `messenger:consume` command data across these resets.
- [DependencyInjection](../packages/dependency-injection.md): `#[Target('<channel>')]` selects a channel logger, and 8.1 deprecates a match of a named alias by the argument name only.
- [AI Mate](../packages/ai-mate.md): its separate `symfony/ai-monolog-mate-extension` package (also called "Monolog Bridge") gives AI agents log search tools and does not require this bridge.

## Changed in 8.0/8.1

- 8.0 removes `NotFoundActivationStrategy`, and MonologBundle 4.0 removes `excluded_404s` -> `excluded_http_codes: [404]` (`HttpCodeActivationStrategy`).
- MonologBundle 4.0 removes the misspelled `console_formater_options` option -> `console_formatter_options`.
- 7.4 and 8.0 add the `interactive_only` option of the `console` handler type (MonologBundle 3.11 or later). Since 8.0.12 and 8.1.0, it also stops the propagation to the next handlers.
- 8.1 cuts `MailerHandler` subjects longer than 200 characters (`$subjectMaxLength`, `0` disables it). MonologBundle has no option for it, so define the handler as a service to change it.
- 8.1 deprecates `LoggerInterface $securityLogger` without an attribute -> `#[Target('security')]` or `#[WithMonologChannel('security')]`.
- MonologBundle 4.1 with Monolog 3.12 accepts `#[WithMonologChannel]` on a constructor argument -> one service can get loggers of different channels.
- Since 8.0.12 and 8.1.0, `server:log` listens on `127.0.0.1:9911` by default instead of `0.0.0.0:9911` (security fix CVE-2026-45077). Use `--host` for another address.

## Docs

- https://symfony.com/doc/current/logging.html
- https://symfony.com/doc/current/logging/monolog_console.html
- https://symfony.com/doc/current/logging/monolog_email.html
- https://symfony.com/doc/current/logging/monolog_exclude_http_codes.html
- https://symfony.com/doc/current/logging/processors.html
- https://symfony.com/doc/current/logging/handlers.html
- https://symfony.com/doc/current/logging/channels_handlers.html
- https://symfony.com/doc/current/console/verbosity.html
- https://symfony.com/doc/current/console.html
- https://symfony.com/doc/current/reference/dic_tags.html
- https://symfony.com/doc/current/reference/configuration/monolog.html
- https://symfony.com/doc/current/service_container/autowiring.html
- https://symfony.com/doc/current/notifier.html
- https://symfony.com/doc/current/messenger.html
- https://github.com/symfony/monolog-bridge
