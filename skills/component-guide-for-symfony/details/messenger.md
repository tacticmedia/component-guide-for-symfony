# Messenger (`symfony/messenger`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Messages and handlers.** A message is a plain PHP object that PHP can serialize. A handler is a service with the `#[AsMessageHandler]` attribute and an `__invoke()` method that type-hints the message class. If a message refers to a Doctrine entity, put the entity ID into the message, not the entity. `MessageHandlerInterface` and `MessageSubscriberInterface` do not exist. Use `#[AsMessageHandler]`. Entry point: `Symfony\Component\Messenger\Attribute\AsMessageHandler`.
- **Message bus.** `MessageBusInterface::dispatch()` wraps the message in an `Envelope` and passes it through the middleware of the bus. If you do not route the message class to a transport, the handler runs at once, in the same process. Entry point: `Symfony\Component\Messenger\MessageBusInterface`.
- **Transports.** A transport sends messages to a queue system and gives them back to a worker. Define each transport with a DSN under `framework.messenger.transports`. The built-in `sync://` transport handles the message at once. The built-in `in-memory://` transport keeps the messages in memory for tests. Entry point: `framework.messenger.transports`.
- **Transport packages.** Install one package for each queue system:
  - `symfony/amqp-messenger`: AMQP brokers, for example RabbitMQ. DSN `amqp://` or `amqps://`. It needs the `amqp` PHP extension. `Symfony\Component\Messenger\Bridge\Amqp\Transport\AmqpPriorityStamp` sets a priority for one message.
  - `symfony/redis-messenger`: Redis streams. DSN `redis://`, `rediss://`, `valkey://` or `valkeys://`. It needs the `redis` PHP extension, version 6.1 or higher.
  - `symfony/doctrine-messenger`: a database table through Doctrine DBAL (`messenger_messages` by default). DSN `doctrine://<connection_name>`. The Flex recipe adds `auto_setup=0` to the DSN. If `auto_setup` is `0`, create the table with a Doctrine migration.
  - `symfony/amazon-sqs-messenger`: Amazon SQS. DSN `sqs://` or the queue URL `https://sqs.<region>.amazonaws.com/...`. `Symfony\Component\Messenger\Bridge\AmazonSqs\Transport\AmazonSqsFifoStamp` sets the group ID and the deduplication ID for FIFO queues.
  - `symfony/beanstalkd-messenger`: Beanstalkd. DSN `beanstalkd://<host>:<port>`. `Symfony\Component\Messenger\Bridge\Beanstalkd\Transport\BeanstalkdPriorityStamp` sets a priority for one message. For Beanstalkd, `0` is the highest priority.
- **Routes to transports.** Add `#[AsMessage('async')]` to the message class, or map the class under `framework.messenger.routing`. The configuration overrides the attribute. Messages without a route run synchronously. A namespace wildcard such as `App\Message\*` or the `*` key routes many classes at once. The `*` key also routes the `SendEmailMessage` of Mailer. Entry points: `Symfony\Component\Messenger\Attribute\AsMessage`, `framework.messenger.routing`.
- **Workers.** `messenger:consume <transport>` starts a worker that handles messages until it stops. If you name more than one transport, for example `messenger:consume async_high async_low`, the worker reads the next transport only when the previous one is empty. Make the worker stop after a limit with `--limit`, `--memory-limit`, `--time-limit` or `--failure-limit`. Use Supervisor or systemd to start it again. After each deploy, run `messenger:stop-workers` so that the workers load the new code. Between two messages, the worker resets the services that implement `Symfony\Contracts\Service\ResetInterface`. Entry points: `messenger:consume`, `messenger:stop-workers`.
- **Retries.** Each transport under `framework.messenger.transports` has a `retry_strategy`. The default is 3 retries, a first delay of 1000 ms and a multiplier of 2. To stop the retries for a message, throw `UnrecoverableMessageHandlingException`. To force a retry, throw `RecoverableMessageHandlingException`. Entry point: `framework.messenger.transports.<name>.retry_strategy`.
- **Failure transport.** The `failure_transport` keeps the messages that fail after the last retry or that the worker does not retry. It covers only the transports under `framework.messenger.transports`. Use `messenger:failed:show`, `messenger:failed:retry` and `messenger:failed:remove` to manage these messages. Entry point: `framework.messenger.failure_transport`.
- **Envelopes and stamps.** A stamp adds metadata to the envelope of a message. `DelayStamp` delays the message by a number of milliseconds. If a handler dispatches a new message with `DispatchAfterCurrentBusStamp`, the bus sends or handles it only after the current handler finishes without an exception. `TransportNamesStamp` overrides the configured transports for one message. Entry points: `Symfony\Component\Messenger\Envelope`, `Symfony\Component\Messenger\Stamp\DelayStamp`.
- **Middleware.** Middleware run around the handlers of a bus. Add the built-in `validation` or `router_context` middleware, the `doctrine_transaction` middleware from DoctrineBundle, or your own service that implements `MiddlewareInterface`. Entry points: `framework.messenger.buses.<bus>.middleware`, `Symfony\Component\Messenger\Middleware\MiddlewareInterface`.
- **Multiple buses.** Define a command bus, a query bus and an event bus under `framework.messenger.buses`. If you define more than one bus, set `default_bus`. To inject another bus, add `#[Target('query.bus')]` to the `MessageBusInterface` argument. Since 8.1, an argument name such as `MessageBusInterface $queryBus` without `#[Target]` triggers a deprecation notice. To get the return value of a query handler, use `HandleTrait`. Entry points: `framework.messenger.buses`, `Symfony\Component\DependencyInjection\Attribute\Target`, `Symfony\Component\Messenger\HandleTrait`.
- **Serializers and signatures.** The default serializer uses the PHP `serialize()` function. To send JSON to other applications, use the `messenger.transport.symfony_serializer` serializer. With this serializer, `#[AsMessage(serializedTypeName: 'order.placed')]` sets the `type` header. `#[AsMessageHandler(sign: true)]` signs the messages of the handler with an HMAC that uses `kernel.secret`. If the signature is missing or not valid, the handler does not run. Entry point: `framework.messenger.serializer.default_serializer`.
- **Deduplication and rate limits.** `DeduplicateStamp` skips a message while another message with the same key is in the queue or in progress. It needs `symfony/lock`. The `rate_limiter` option of a transport limits how fast a worker consumes the transport. It needs `symfony/rate-limiter`. Entry points: `Symfony\Component\Messenger\Stamp\DeduplicateStamp`, `framework.messenger.transports.<name>.rate_limiter`.
- **Batch handlers.** A handler that implements `BatchHandlerInterface` and uses `BatchHandlerTrait` handles messages in groups. By default, the handler processes a group when it has 10 messages, or after 1 second without a new message. Entry point: `Symfony\Component\Messenger\Handler\BatchHandlerInterface`.
- **Built-in messages.** Dispatch `RunCommandMessage` to run a console command, `RunProcessMessage` to run an external process, or `PingWebhookMessage` to send an HTTP request. FrameworkBundle registers the handlers of these messages. Entry points: `Symfony\Component\Console\Messenger\RunCommandMessage`, `Symfony\Component\Process\Messenger\RunProcessMessage`, `Symfony\Component\HttpClient\Messenger\PingWebhookMessage`.

## Entry points

- Autowire `Symfony\Component\Messenger\MessageBusInterface` to get the default bus (service `messenger.default_bus`). For another bus, add `#[Target('query.bus')]` (`Symfony\Component\DependencyInjection\Attribute\Target`) to the argument.
- Attribute `Symfony\Component\Messenger\Attribute\AsMessageHandler` (options `bus`, `fromTransport`, `handles`, `method`, `priority`, `sign`).
- Attribute `Symfony\Component\Messenger\Attribute\AsMessage` (options `transport`, `serializedTypeName`).
- Trait `Symfony\Component\Messenger\HandleTrait` (it needs a `$messageBus` property).
- Exceptions `Symfony\Component\Messenger\Exception\UnrecoverableMessageHandlingException` and `Symfony\Component\Messenger\Exception\RecoverableMessageHandlingException`.
- Config key `framework.messenger` (`transports`, `routing`, `failure_transport`, `buses`, `default_bus`, `serializer`, `stop_worker_on_signals`).
- Environment variable `MESSENGER_TRANSPORT_DSN` (from the Flex recipe).
- Services: `messenger.default_bus`, and `messenger.transport.<name>` for each transport. Some docs pages name `messenger.sender.<name>` and `messenger.receiver.<name>`. These service IDs do not exist.
- Console commands: `messenger:consume`, `messenger:stop-workers`, `messenger:failed:show`, `messenger:failed:retry`, `messenger:failed:remove`, `messenger:stats` (`--format=txt` or `--format=json`), `messenger:setup-transports`, `debug:messenger`. The `messenger:failed:*` commands exist only when you configure a failure transport.
- Generators in `symfony/maker-bundle`: `make:message` (a message and its handler), `make:messenger-middleware`.
- Test helpers: the `in-memory://` DSN and `Symfony\Component\Messenger\Transport\InMemory\InMemoryTransport` (`getSent()`, `getAcknowledged()`, `getRejected()`). For middleware unit tests, extend `Symfony\Component\Messenger\Test\Middleware\MiddlewareTestCase`. FrameworkBundle has no Messenger assertions. In a test, call `getSent()` on the `messenger.transport.<name>` service.

## Symbiotic packages

- [Scheduler](../packages/scheduler.md): Scheduler needs Messenger, and a `messenger:consume scheduler_<name>` worker runs its recurring messages. By default, a message that fails in this worker gets no retry and does not go to the failure transport. To get retries, use the `transports` option of `#[AsCronTask]` or `#[AsPeriodicTask]`, which sends the message to a transport under `framework.messenger.transports`. For recurring cron-like tasks, use Scheduler instead of delayed Messenger messages.
- [Mailer](../packages/mailer.md): When Messenger is installed, `MailerInterface::send()` dispatches a `SendEmailMessage` on the bus. To send emails from a worker, route `SendEmailMessage` to an async transport.
- [Notifier](../packages/notifier.md): When Messenger is enabled, each Notifier channel (chat, SMS, email and others) dispatches its message on the bus. If Messenger is enabled, do not set `framework.notifier.message_bus` to `false`, because the channels then throw a `LogicException`.
- [Doctrine Bridge](../packages/doctrine-bridge.md): It contains the `doctrine_transaction`, `doctrine_ping_connection` and `doctrine_close_connection` middleware and a listener that clears the entity managers after each message. DoctrineBundle registers them. Do not confuse it with `symfony/doctrine-messenger`, which is the database transport.
- [Serializer](../packages/serializer.md): The `messenger.transport.symfony_serializer` serializer uses the Serializer to encode messages as JSON or XML instead of PHP `serialize()`.
- [Validator](../packages/validator.md): The `validation` middleware validates each message before the handlers run. If the message is not valid, it throws `Symfony\Component\Messenger\Exception\ValidationFailedException`.
- [Lock](../packages/lock.md): `DeduplicateStamp` and the `deduplicate_middleware` middleware use Lock to skip duplicate messages. Messenger adds this middleware only when `framework.lock` has a `default` resource.
- [RateLimiter](../packages/rate-limiter.md): The `rate_limiter` option of a transport uses a configured rate limiter to slow down the worker that consumes this transport.
- [Console](../packages/console.md): `RunCommandMessage` runs a console command in a worker, and its handler returns a `RunCommandContext` with the exit code and the output.
- [Process](../packages/process.md): `RunProcessMessage` runs an external process in a worker, and FrameworkBundle signs these messages by default.
- [HttpClient](../packages/http-client.md): `PingWebhookMessage` sends an HTTP request from a worker, for example to check the status of a web service.
- [Webhook](../packages/webhook.md): To send an outgoing webhook, dispatch a `SendWebhookMessage` on the bus. `SendWebhookHandler` signs and sends the HTTP request.
- [RemoteEvent](../packages/remote-event.md): The webhook controller dispatches each incoming event as a `ConsumeRemoteEventMessage`. To process the event in a worker, route `ConsumeRemoteEventMessage` to an async transport.
- [Cache](../packages/cache.md): With `early_expiration_message_bus`, a cache pool dispatches an `EarlyExpirationMessage` so that a worker computes the new value.
- [Mercure](../packages/mercure.md): A handler that MercureBundle registers publishes each Mercure `Update` that you dispatch on the bus. The docs discourage async dispatch because most Mercure hubs already publish asynchronously.
- [EventDispatcher](../packages/event-dispatcher.md): The worker dispatches events such as `WorkerMessageFailedEvent` and `WorkerMessageHandledEvent` through the EventDispatcher. EventDispatcher listeners run in the current process; to move work to a queue, dispatch a Messenger message.
- [DependencyInjection](../packages/dependency-injection.md): Autoconfiguration turns `#[AsMessageHandler]` into a `messenger.message_handler` tag, and the worker resets services between messages with the services resetter. The `#[Target]` attribute selects a named bus for a `MessageBusInterface` argument.
- [Routing](../packages/routing.md): The `router_context` middleware keeps the scheme, the host and the port of the original request, so that a worker can generate absolute URLs.
- [Clock](../packages/clock.md): Messenger requires Clock, and `HandleMessageMiddleware` and the in-memory transport read the time from the `clock` service.
- [FrameworkBundle](../packages/framework-bundle.md): The `framework.messenger` configuration creates the buses, the transports and the console commands, and FrameworkBundle autoconfigures the handlers.
- [FrameworkBundle test tools](../packages/framework-bundle-testing.md): `KernelTestCase` and `WebTestCase` reset all `in-memory://` transports after each test.
- [MakerBundle](../packages/maker-bundle.md): `make:message` creates a message class and its handler, and `make:messenger-middleware` creates a middleware.
- [WebProfilerBundle](../packages/web-profiler-bundle.md): the Messages panel shows the dispatched messages; to profile `messenger:consume`, add `--no-reset` and `--limit`.

## Changed in 8.0/8.1

- 8.1: `RecoverableMessageHandlingException` has a new `forceRetry` argument. Old: the exception always forced a retry, without a limit. New: to set `retryDelay` and keep the `max_retries` limit, pass `forceRetry: false`.
- 8.0: `RecoverableExceptionInterface` declares `getRetryDelay(): ?int`. Implement it in your own recoverable exceptions. Return `null` to use the delay of the retry strategy.
- 8.1: A message that the serializer cannot decode no longer disappears from the queue. It goes through the retries and the failure transport. In a custom serializer, return `MessageDecodingFailedException::wrap($encodedEnvelope, $reason)` instead of throwing an exception.
- 8.1: The `senders` level under `framework.messenger.routing` is deprecated. Old: `App\Message\Foo: { senders: [async] }`. New: `App\Message\Foo: [async]`.
- 8.1: `messenger:consume` accepts regular expressions as transport names (for example `scheduler_.*`), `--fetch-size=<n>` and `--no-reset=<n>`.
- 8.1: `AmqpPriorityStamp` sets the priority of one AMQP message. The queue must declare the `x-max-priority` argument. For Beanstalkd, use `BeanstalkdPriorityStamp`. The docs show a generic `PriorityStamp` in the `Stamp` namespace. This class does not exist.
- 8.1: To select a named bus, add `#[Target]`. The argument name alone is deprecated. Old: `MessageBusInterface $queryBus`. New: `#[Target('query.bus')] MessageBusInterface $queryBus`.
- 8.1: `StopWorkerOnTimeLimitListener` is deprecated. If you create a `Worker` yourself, pass the `time_limit` option to `Worker::run()`.

## Status

- The core package needs no PHP extension.
- `symfony/amqp-messenger` needs the `amqp` PHP extension. `symfony/redis-messenger` needs the `redis` PHP extension, version 6.1 or higher.
- If you install the `pcntl` PHP extension, a worker finishes the current message and then stops on `SIGTERM`, `SIGINT` or `SIGQUIT`.

## Docs

- https://symfony.com/doc/current/messenger.html
- https://symfony.com/doc/current/messenger/custom-transport.html
- https://symfony.com/doc/current/reference/configuration/framework.html
