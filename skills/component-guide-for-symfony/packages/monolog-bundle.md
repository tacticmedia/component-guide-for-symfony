# MonologBundle (`symfony/monolog-bundle`)

**Applies to:** MonologBundle 4.1, Monolog 3

**Elevator pitch:** Use when an application or a worker must write logs to files, stderr, syslog, email or a chat webhook, by level and channel. It configures Monolog behind the standard PSR-3 logger: handlers, a buffer that writes only when an error occurs, log rotation and processors. For the Monolog classes of the framework, see [Monolog Bridge](monolog-bridge.md).

**Details:** [../details/monolog-bundle.md](../details/monolog-bundle.md)

## Why it exists

Without this package, the default logger of the framework is a minimal PSR-3 logger. By default, it passes only error messages and higher levels to the PHP error log. The package replaces it with a Monolog logger. It creates the handlers, channels, formatters and processors from one configuration key.

## When to use it

- Write the log messages of an application to a file, to stderr or to syslog.
- Write JSON log lines to stderr in a container.
- Log all messages of a request only when an error occurs, except for 404 errors.
- Email production errors to the developers without duplicate emails.
- Send error records to a chat service through a webhook.
- Send the messages of one channel, for example the security messages, to a separate log file.
- Inject the logger of a specific channel into a class.
- Add the same extra data, for example a request token, to each log record.
- Rotate the log files every day with a limit on the number of old files.
- Show log messages in the output of a console command according to its verbosity level.
- Clear the buffered log records between the jobs of a long-running worker.

## Use it instead of

- `file_put_contents('var/log/app.log', $line, FILE_APPEND)` or `error_log($message)` -> inject `Psr\Log\LoggerInterface` and call `$logger->error('Payment {orderId} failed', ['orderId' => $orderId])`. A `stream` handler writes the file.
- `'app-'.date('Y-m-d').'.log'` file names and a cron job that deletes old files -> `type: rotating_file` with `max_files`.
- `mail('dev@example.com', 'Error', $e->getMessage())` in a `catch` block -> the handler chain `fingers_crossed`, then `deduplication`, then `symfony_mailer`.
- `if ($output->isVerbose()) { $output->writeln('...'); }` in a command -> `$this->logger->notice('...')` and a `type: console` handler.
- `new Logger('billing', [new StreamHandler('var/log/billing.log')])` in a service -> `monolog.channels: [billing]`, a handler with `channels: [billing]`, and `#[Target('billing')] LoggerInterface $logger`.
- The same `'requestId' => ...` context entry in each log call -> a processor class with `#[AsMonologProcessor]` that sets `$record->extra['requestId']`.
- A custom exception listener that skips `NotFoundHttpException` before it writes the log -> `excluded_http_codes: [404]` on the `fingers_crossed` handler.
- `fwrite(STDERR, json_encode($data).PHP_EOL)` in a container -> a `stream` handler with `path: php://stderr` and `formatter: monolog.formatter.json`.
- `curl_init()` with a POST to a Slack webhook in a `catch` block -> `type: slackwebhook` with `webhook_url`, behind a `fingers_crossed` handler.
- `$logger->error($e->getMessage().' '.$e->getTraceAsString())` -> `$logger->error('Import failed', ['exception' => $e])` and `include_stacktraces: true` on the handler, which adds the stack trace to the line or JSON output.
