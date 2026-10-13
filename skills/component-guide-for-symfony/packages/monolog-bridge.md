# Monolog Bridge (`symfony/monolog-bridge`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when application logs must appear in the terminal by verbosity, go to email, notifications or Elasticsearch, or ignore 404 errors. It gives the Monolog handlers and formatters for these targets, and processors that add the route, the user or the console command to each record. To configure them, see [MonologBundle](monolog-bundle.md).

**Details:** [../details/monolog-bridge.md](../details/monolog-bridge.md)

## Why it exists

Monolog does not know the console commands, HTTP requests, users, email sending or notifications of the framework. The package gives the Monolog handlers, formatters and processors for them. The framework also uses its classes for the log panel of each request and for a live log server in the terminal. To build the loggers from these classes, see [MonologBundle](monolog-bundle.md).

## When to use it

- Show log messages in the output of a console command, filtered by the verbosity level of the command.
- Email the logs of a failed request or command.
- Send error log records as notifications to the admin users, for example in a chat channel, through [Notifier](notifier.md).
- Stop 404 and 405 errors from releasing the buffered log records of a request.
- Add the route, the controller, the user, the impersonator or the console command to each log record.
- Watch the logs of the application live in a second terminal, filtered by level or channel.
- Push log records to Elasticsearch in the Logstash format.
- Give one class, or one constructor argument, its own logger channel with a PHP attribute.

## Use it instead of

- `if ($output->isVerbose()) { $output->writeln('...'); }` around each message in a command -> `$logger->notice('...')` with the `console` handler type (`Symfony\Bridge\Monolog\Handler\ConsoleHandler`).
- `$logger = new ConsoleLogger($output);` in a command of a full-stack application -> an injected `Psr\Log\LoggerInterface` and the `console` handler type. Keep `ConsoleLogger` for applications without Monolog.
- `try { ... } catch (\Throwable $e) { $mailer->send((new Email())->subject('Error')->text($e->getMessage())); }` -> the `fingers_crossed`, `deduplication` and `symfony_mailer` handler types (`Symfony\Bridge\Monolog\Handler\MailerHandler`).
- `$notifier->send(new Notification($e->getMessage(), ['chat/slack']));` in an exception listener -> a handler with `type: service` and `id: notifier.monolog_handler` (`Symfony\Bridge\Monolog\Handler\NotifierHandler`).
- A custom `ActivationStrategyInterface` that returns `false` for a `NotFoundHttpException` -> `excluded_http_codes: [404]` (`Symfony\Bridge\Monolog\Handler\FingersCrossed\HttpCodeActivationStrategy`).
- `$logger->error('...', ['ip' => $_SERVER['REMOTE_ADDR'], 'route' => $request->attributes->get('_route')]);` -> `WebProcessor` and `RouteProcessor` with the `monolog.processor` tag.
- `['user' => $security->getUser()?->getUserIdentifier()]` in the context of each log call -> `Symfony\Bridge\Monolog\Processor\TokenProcessor` (and `SwitchUserTokenProcessor` for impersonation).
- `$httpClient->request('POST', 'http://127.0.0.1:9200/_bulk', ['body' => $ndjson]);` in a custom handler -> `Symfony\Bridge\Monolog\Handler\ElasticsearchLogstashHandler`.
- `LoggerInterface $securityLogger` without an attribute (deprecated in 8.1), or a `monolog.logger` tag on each service -> `#[WithMonologChannel('security')]` or `#[Target('security')]` (MonologBundle makes both work).
