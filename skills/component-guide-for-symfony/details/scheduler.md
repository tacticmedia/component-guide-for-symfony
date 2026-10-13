# Scheduler (`symfony/scheduler`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Schedule provider and transport:** A class with `#[AsSchedule]` implements `ScheduleProviderInterface` and returns a `Schedule`, a named group of recurring messages. The default name is `default`. Symfony registers one Messenger transport for each schedule, named `scheduler_<name>` (DSN `schedule://<name>`). Two providers for the same name cause a container error. Entry point: `#[AsSchedule('name')]`, `ScheduleProviderInterface::getSchedule()`.
- **Recurring message:** `RecurringMessage` pairs a trigger with a message. The message is any object that has a Messenger handler. Build the schedule with `Schedule::add()`. `Schedule::with()` returns a new `Schedule` that keeps only the event dispatcher, so it drops the lock, the state and the earlier messages. Entry point: `RecurringMessage`, `Schedule::add()`.
- **Cron triggers:** `RecurringMessage::cron()` takes a 5-field cron expression or an alias such as `@daily`, plus an optional timezone. It needs the `dragonmantank/cron-expression` package. A `#` in the expression (for example `#midnight` or `# #(0-7) * * *`) gives each message a stable random time. For a `#` expression, the message must implement `\Stringable`; the messages that the attributes create do. Entry point: `RecurringMessage::cron()`, `CronExpressionTrigger::fromSpec()`.
- **Periodic triggers:** `RecurringMessage::every()` takes seconds (`int`), a PHP relative format (`'10 seconds'`, `'first Monday of next month'`), an ISO 8601 duration or a `\DateInterval`, plus optional `from` and `until` dates. Without `from`, the first period starts when the worker starts. If the schedule is not stateful, each worker restart thus starts a new period. For a list of weekdays, use a cron expression. Entry point: `RecurringMessage::every()`, `PeriodicalTrigger`.
- **Jitter, time exclusion and custom triggers:** `withJitter()` adds a random delay of 0 to N seconds (default 60). `ExcludeTimeTrigger` skips the runs inside a time window. A custom trigger implements `TriggerInterface`: `getNextRunDate()` must return a date strictly after the given date, or `null` to stop. Because `TriggerInterface` extends `\Stringable`, also add `__toString()`. Entry point: `RecurringMessage::withJitter()`, `JitterTrigger`, `ExcludeTimeTrigger`, `CallbackTrigger`, `TriggerInterface`, `RecurringMessage::trigger()`.
- **Task attributes:** `#[AsCronTask]` and `#[AsPeriodicTask]` on a service class or method add a task to a schedule (option `schedule`, default `default`). For a method attribute, the worker calls that method. For a class attribute, it calls `__invoke()` or the method that the `method` option names. The `arguments` option gives the method arguments. On a console command, the task runs the command through `RunCommandMessage`, and `arguments` gives the command arguments and options. Both attributes accept `jitter` and `transports`. `AsCronTask` also accepts `timezone`, and `AsPeriodicTask` accepts `from` and `until`. Entry point: `#[AsCronTask('0 3 * * *')]`, `#[AsPeriodicTask(frequency: '10 minutes')]`.
- **Dynamic messages:** `CallbackMessageProvider` calls a callback each time the trigger is due, and the callback yields zero or more messages. Entry point: `CallbackMessageProvider`, `MessageProviderInterface`, `MessageContext`.
- **Runtime changes:** `add()`, `remove()`, `removeById()` and `clear()` change a running schedule, and the worker then recalculates its trigger heap. The worker calls `getSchedule()` only once. Thus, store the `Schedule` in a provider property (`$this->schedule ??= ...`). Then change that object. Entry point: `Schedule::add()`, `Schedule::remove()`, `Schedule::removeById()`, `Schedule::clear()`.
- **Stateful schedules:** `stateful($cache)` stores the last run time in a cache pool. After a restart, the worker then runs the messages that it missed. With `processOnlyLastMissedRun(true)`, the worker runs a missed message only once, not once for each missed run. The Flex recipe creates `src/Schedule.php` with both settings. Entry point: `Schedule::stateful()`, `Schedule::processOnlyLastMissedRun()`.
- **Locked schedules:** `lock($lock)` lets only one worker generate the messages of the schedule. The other workers wait, and one of them takes over if the active worker stops. This gives high availability, not more throughput. The default lock store (`semaphore` or `flock`) is local. If the workers run on several servers, use a remote store, for example Redis. Entry point: `Schedule::lock()`, `LockFactory::createLock()`.
- **Parallel processing:** The scheduler worker runs the tasks one after the other, so a long task delays the next tasks. `transports: 'async'` on an attribute, or a `RedispatchMessage` around the message, sends the task to another Messenger transport. Regular `messenger:consume` workers then run the tasks in parallel. A `ScheduledStamp` marks these messages. Entry point: `#[AsCronTask(..., transports: 'async')]`, `new RedispatchMessage($message, 'async')`, `ScheduledStamp`.
- **Events:** Symfony dispatches `PreRunEvent` before the handler runs, and `shouldCancel(true)` skips the message. `PostRunEvent::getResult()` gives the handler result. `FailureEvent::getError()` gives the exception. Listen to them with `#[AsEventListener]`, or with `before()`, `after()` and `onFailure()` on a `new Schedule($dispatcher)`. The `before()`, `after()` and `onFailure()` listeners also receive the events of the other schedules. To limit a listener to one schedule, check `$event->getMessageContext()->name`. `FailureEvent::shouldIgnore(true)` has an effect only in the standalone `Scheduler` worker. Entry point: `PreRunEvent`, `PostRunEvent`, `FailureEvent`, `Schedule::before()`.
- **Failures:** If a task fails in the scheduler worker, Messenger does not retry it and does not send it to the failure transport. The task runs again at its next run date. For retries and the failure transport, send the task to a configured transport with `transports`. Entry point: `#[AsCronTask(..., transports: 'async')]`, `RedispatchMessage`, `FailureEvent`.
- **Worker:** `messenger:consume scheduler_<name>` generates the due messages and handles them. Keep it running with Supervisor or systemd. Outside a Symfony application, the `Scheduler` class runs schedules with a map of handlers. Entry point: `php bin/console messenger:consume scheduler_default`, `Scheduler::run()`.
- **Debug command:** `debug:scheduler` shows each schedule with the trigger, the provider and the next run date of each message. `--date` sets the base date, `--all` also shows ended messages, and `--sort` orders by next run date. Without `--date`, the command computes the next run dates of a stateful schedule from the stored checkpoint. Entry point: `php bin/console debug:scheduler`.

## Entry points

- Attributes: `Symfony\Component\Scheduler\Attribute\AsSchedule`, `Symfony\Component\Scheduler\Attribute\AsCronTask`, `Symfony\Component\Scheduler\Attribute\AsPeriodicTask`.
- Interfaces to implement: `Symfony\Component\Scheduler\ScheduleProviderInterface`, `Symfony\Component\Scheduler\Trigger\TriggerInterface` (custom trigger), `Symfony\Component\Scheduler\Trigger\MessageProviderInterface` (custom message provider).
- Classes to build a schedule: `Symfony\Component\Scheduler\Schedule`, `Symfony\Component\Scheduler\RecurringMessage`, `Symfony\Component\Scheduler\Trigger\CronExpressionTrigger`, `PeriodicalTrigger`, `CallbackTrigger`, `JitterTrigger`, `ExcludeTimeTrigger`, `CallbackMessageProvider` (namespace `Symfony\Component\Scheduler\Trigger\`).
- Types to autowire into a provider: `Symfony\Contracts\Cache\CacheInterface` (for `stateful()`, alias of `cache.app`), `Symfony\Component\Lock\LockFactory` (for `lock()`), `Symfony\Component\EventDispatcher\EventDispatcherInterface` (for `new Schedule($dispatcher)`).
- Events: `Symfony\Component\Scheduler\Event\PreRunEvent`, `Symfony\Component\Scheduler\Event\PostRunEvent`, `Symfony\Component\Scheduler\Event\FailureEvent`.
- Messenger types: `Symfony\Component\Scheduler\Messenger\ScheduledStamp`, `Symfony\Component\Scheduler\Generator\MessageContext`, `Symfony\Component\Messenger\Message\RedispatchMessage`, `Symfony\Component\Scheduler\Messenger\ServiceCallMessage` (the message that a task attribute creates for a service).
- Messages with built-in handlers, to schedule work without a custom handler: `Symfony\Component\Console\Messenger\RunCommandMessage`, `Symfony\Component\Process\Messenger\RunProcessMessage`, `Symfony\Component\HttpClient\Messenger\PingWebhookMessage`.
- Config key: `framework.scheduler` (only `enabled`). It is on by default when the package is installed, and it needs `framework.messenger`.
- Transports: `scheduler_<name>`, one for each schedule, with the DSN `schedule://<name>`.
- Console commands: `debug:scheduler [schedule...] [--date=DATE] [--all] [--sort]`, `messenger:consume scheduler_<name>`, `messenger:consume 'scheduler_.*'` (all schedules).
- Service tags that the attributes add: `scheduler.schedule_provider` (attribute `name`), `scheduler.task`.
- Without FrameworkBundle: the worker `Symfony\Component\Scheduler\Scheduler` (`run()`, `stop()`).
- Flex recipe file: `src/Schedule.php`, an `#[AsSchedule]` provider with `stateful($this->cache)` and `processOnlyLastMissedRun(true)`.

## Symbiotic packages

- [Messenger](../packages/messenger.md): Each schedule is a Messenger transport, so `messenger:consume` runs it and Messenger handlers process its messages. The framework integration stops with an error if Messenger is not enabled. For a one-time delayed message, use the Messenger `DelayStamp`, not Scheduler.
- [Console](../packages/console.md): `#[AsCronTask]` or `#[AsPeriodicTask]` on a command runs the command through `RunCommandMessage`, and `debug:scheduler` lists the schedules.
- [Cache](../packages/cache.md): `Schedule::stateful()` stores the run checkpoint in a cache pool, so a restarted worker continues from the last run.
- [Lock](../packages/lock.md): `Schedule::lock()` takes a lock from `LockFactory`, so only one of several workers generates the messages of a schedule.
- [Clock](../packages/clock.md): Scheduler requires `symfony/clock`. The scheduler transport reads the time from the `clock` service, and the standalone `Scheduler` takes a `ClockInterface`.
- [EventDispatcher](../packages/event-dispatcher.md): The event dispatcher sends `PreRunEvent`, `PostRunEvent` and `FailureEvent` to your listeners.
- [Process](../packages/process.md): A recurring `RunProcessMessage` runs an external program on a schedule, in place of a crontab line.
- [HttpClient](../packages/http-client.md): A recurring `PingWebhookMessage` sends an HTTP request on a schedule, for example a health check of another service.
- [FrameworkBundle](../packages/framework-bundle.md): FrameworkBundle enables `framework.scheduler`, autoconfigures the three attributes and registers `debug:scheduler`.
- [Serializer](../packages/serializer.md): If a scheduled message goes through a transport that uses the Symfony Serializer, `SchedulerTriggerNormalizer` serializes the trigger in `ScheduledStamp` as its text description.
- [MakerBundle](../packages/maker-bundle.md): `make:schedule` is deprecated since MakerBundle 1.63; install Scheduler with Flex to get an initial schedule.

## Changed in 8.0/8.1

- 8.1: `debug:scheduler --sort` orders the recurring messages by next run date. With `--all`, the messages without a next run date come first.
- 8.1: `messenger:consume` accepts regular expressions as receiver names. `php bin/console messenger:consume 'scheduler_.*'` consumes all schedules in one worker.
- 8.0: `Command::getDefaultName()` is removed. Name a scheduled command with `#[AsCommand]`, because Scheduler reads the command name from this attribute or from the `console.command` tag.

## Docs

- https://symfony.com/doc/current/scheduler.html
- https://symfony.com/doc/current/messenger.html
- https://symfony.com/doc/current/reference/configuration/framework.html
- https://symfony.com/doc/current/reference/attributes.html
