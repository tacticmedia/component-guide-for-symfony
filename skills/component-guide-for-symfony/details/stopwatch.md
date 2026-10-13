# Stopwatch (`symfony/stopwatch`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Events:** `start($name, $category)` starts a named event in the active section and returns a `StopwatchEvent`. The default category is `default`. `stop($name)` ends the last open period of the event and returns the event. If the event has no open period, `stop()` throws `\LogicException`. `getEvent($name)` returns an event of the active section, and `isStarted($name)` returns `true` if the event has an open period. Entry point: `Stopwatch::start()`, `Stopwatch::stop()`, `Stopwatch::getEvent()`, `Stopwatch::isStarted()`.
- **Laps and periods:** `lap($name)` stops the event and starts it again at once. Each pair of start and stop makes a `StopwatchPeriod` with a start time, an end time, a duration and a memory usage value. `getPeriods()` returns all periods. `getLastPeriod()` returns the last period or `null`. Entry point: `Stopwatch::lap()`, `StopwatchEvent::getPeriods()`, `StopwatchEvent::getLastPeriod()`.
- **Duration and precision:** All times are in milliseconds from the origin of the event or of its section. `getDuration()` adds the durations of all periods, and it includes the open periods up to the current time. If you call `start()` again before `stop()`, the periods overlap, and `getDuration()` counts the overlap twice. `new Stopwatch()` stores whole milliseconds as `int`. `new Stopwatch(true)` keeps `float` values with a precision of 0.1 ms, and the `debug.stopwatch` service uses this setting. Entry point: `StopwatchEvent::getDuration()`, `new Stopwatch(true)`.
- **Memory usage:** Each period stores the value of `memory_get_usage(true)` at the time when the period ends. `getMemory()` of an event returns the highest value of its periods, in bytes. This value is the total memory that PHP allocates from the system, not the memory that the code of the event uses. Entry point: `StopwatchEvent::getMemory()`, `StopwatchPeriod::getMemory()`.
- **Text summary:** `(string) $event` returns `category/name: X.XX MiB - N ms`, for example `default/export-data: 2.00 MiB - 3 ms`. `(string) $period` returns only `X.XX MiB - N ms`. Entry point: `StopwatchEvent::__toString()`, `StopwatchPeriod::__toString()`.
- **Sections:** `openSection()` opens a new child section of the active section. `stopSection($id)` closes the active section and keeps it under the ID. `getSectionEvents($id)` returns the events of a closed section, or an empty array for an unknown ID. To add events to a closed section, call `openSection($id)` in its parent section. If the active section has no child with this ID, `openSection($id)` throws `\LogicException`. Each section has a `__section__` event that measures the section, and the parent section gets a `__section__.child` event in the category `section`. Entry point: `Stopwatch::openSection()`, `Stopwatch::stopSection()`, `Stopwatch::getSectionEvents()`.
- **Root section and scope:** Events outside a section go to the root section `Stopwatch::ROOT` (`'__root__'`). `getRootSectionEvents()` returns the same events as `getSectionEvents(Stopwatch::ROOT)`. `start()`, `stop()`, `lap()`, `isStarted()` and `getEvent()` use only the active section. If you start an event in one section, stop it in the same section. In debug mode with the profiler enabled, Symfony opens a section for each request and each `--profile` command. Thus, your events are not in the root section. Entry point: `Stopwatch::ROOT`, `Stopwatch::getRootSectionEvents()`.
- **Reset:** `reset()` deletes all sections and events. FrameworkBundle tags the `debug.stopwatch` service with `kernel.reset`, so Symfony resets it before the next main request and after each message of a Messenger worker. Do not call `reset()` on this service during a request. A reset deletes the request section, so the profiler shows no events for the request. After a reset, `stop()` throws `\LogicException` for an event that started before the reset. Entry point: `Stopwatch::reset()`.
- **The `debug.stopwatch` service:** If the Stopwatch class exists, FrameworkBundle registers the `debug.stopwatch` service in all environments, with the autowiring alias `Symfony\Component\Stopwatch\Stopwatch`. In debug mode, Symfony decorates the event dispatcher, the controller resolver and the argument resolvers with traceable classes that write events to this service. If `symfony/stopwatch` is only a dev dependency (for example through `symfony/profiler-pack`), a production install without dev packages has no `debug.stopwatch` service. In this case, declare the argument as `?Stopwatch $stopwatch = null`. Then call the methods with the nullsafe operator, for example `$this->stopwatch?->start('export-data')`. Entry point: autowire `Symfony\Component\Stopwatch\Stopwatch`.
- **Built-in events:** In debug mode, Symfony packages write their own events to the same service. Their categories are `section` (kernel events and the controller), `event_listener`, `template`, `http_client`, `messenger.middleware`, `workflow`, `doctrine`, `command`, `controller.argument_value_resolver`, `command.argument_value_resolver` and `ai` (Symfony AI). Other built-in events, for example `dump`, use the category `default`. Give your events a category of your own to show or hide them as a group on the timeline. Entry point: the second argument of `Stopwatch::start()`.
- **Performance panel:** The `time` data collector reads the events of the request section when the profiler saves the profile at `kernel.terminate`. It calls `ensureStopped()` on each event, so an event without `stop()` lasts until that time. The Performance panel shows the total execution time, the Symfony initialization time, the peak memory usage and an execution timeline. On the timeline, a threshold field (default 1 ms) hides shorter events. A click on a category in the legend hides or shows its events. Sub-requests have a striped background. The toolbar item turns yellow when the request takes more than 1000 ms. Entry point: the Performance panel of the profiler (collector ID `time`).
- **Twig tag:** `{% stopwatch 'name' %}...{% endstopwatch %}` records the body as an event in the category `template`. The tag records only when the `debug.stopwatch` service exists and `kernel.debug` is true; otherwise it renders only the body. If the Stopwatch class does not exist, TwigBundle does not register the tag, and Twig throws `Twig\Error\SyntaxError` when it compiles a template with the tag. If `symfony/stopwatch` is only a dev dependency, do not use the tag in templates that production renders. In debug mode, Symfony also records each rendered template as an event in the category `template`. Entry point: Twig tag `stopwatch` (`Symfony\Bridge\Twig\Extension\StopwatchExtension`).
- **Console profiling:** With FrameworkBundle, the global option `--profile` saves a profile of a console command. It needs debug mode, the Stopwatch component and the profiler; otherwise the command shows a warning and runs without a profile. With `-v`, the command prints a link to the profile. With `-vvv`, it also prints the text summary of the command event. To profile `messenger:consume`, add the `--no-reset` option. Add `--limit` to process only a few messages. Entry point: `php bin/console --profile -v app:my-command`.
- **Time in tests:** The PHPUnit Bridge `ClockMock` replaces `microtime()`, `sleep()`, `usleep()` and other time functions in the namespaces that you register. Stopwatch calls `microtime()` in its own namespace. Thus, register `Stopwatch::class` and also the namespace of the code that calls `sleep()`. `#[TimeSensitive]` without an argument registers the namespace of the test class. Then `sleep(10)` returns at once, and `getDuration()` returns `10000`. The attributes work only if the PHPUnit configuration registers `Symfony\Bridge\PhpUnit\SymfonyExtension` (PHPUnit 10 and later). Entry point: `#[TimeSensitive]` plus `#[TimeSensitive(Stopwatch::class)]` on a test class with a namespace.

## Entry points

- Autowire `Symfony\Component\Stopwatch\Stopwatch` to get the `debug.stopwatch` service.
- Without FrameworkBundle: `new Symfony\Component\Stopwatch\Stopwatch(true)`, for example in a script.
- The classes `Symfony\Component\Stopwatch\StopwatchEvent` and `Symfony\Component\Stopwatch\StopwatchPeriod`, and the constant `Stopwatch::ROOT`.
- The Twig tag `{% stopwatch 'name' %}...{% endstopwatch %}` (service `twig.extension.debug.stopwatch`).
- The Performance panel of the profiler: collector ID `time`, class `Symfony\Component\HttpKernel\DataCollector\TimeDataCollector`. In a `WebTestCase`, use `$client->getProfile()->getCollector('time')`.
- The console option `--profile` of `Symfony\Bundle\FrameworkBundle\Console\Application`, with `-v` or `-vvv`.
- The test attribute `Symfony\Bridge\PhpUnit\Attribute\TimeSensitive`, for example `#[TimeSensitive(Stopwatch::class)]`.
- Install with `composer require --dev symfony/profiler-pack` (Stopwatch and WebProfilerBundle), or with `composer require symfony/stopwatch` for all environments.
- Stopwatch has no configuration key, console command or PHP attribute of its own. The `framework.profiler` key enables the profiler that shows the events.

## Symbiotic packages

- [WebProfilerBundle](../packages/web-profiler-bundle.md): its Performance panel shows the Stopwatch events, and its toolbar shows the total time; it does not require Stopwatch, and `symfony/profiler-pack` installs both packages.
- [FrameworkBundle](../packages/framework-bundle.md): it registers the `debug.stopwatch` service with the `Stopwatch` autowiring alias, and it adds the console option `--profile`.
- [HttpKernel](../packages/http-kernel.md): its traceable event dispatcher opens a Stopwatch section for each request, and `TimeDataCollector` reads that section for the profiler.
- [EventDispatcher](../packages/event-dispatcher.md): `TraceableEventDispatcher` records each dispatched event in the category `section` and each listener in the category `event_listener`.
- [Twig Bridge](../packages/twig-bridge.md): it supplies the `{% stopwatch %}` tag and `ProfilerExtension`, which record template events in the category `template`.
- [TwigBundle](../packages/twig-bundle.md): it registers the `stopwatch` tag only when the Stopwatch class exists, and it enables the tag only in debug mode.
- [Console](../packages/console.md): in a `--profile` run, `TraceableCommand` records the command and its `initialize()`, `interact()` and `execute()` steps in the category `command`.
- [HttpClient](../packages/http-client.md): `TraceableHttpClient` records each request as an event named `"METHOD URL"` in the category `http_client`.
- [Messenger](../packages/messenger.md): in debug mode, the `traceable` middleware records each middleware in the category `messenger.middleware`; profile `messenger:consume` with `--no-reset`.
- [Workflow](../packages/workflow.md): in debug mode, `TraceableWorkflow` records each call to a workflow method in the category `workflow`.
- [Doctrine Bridge](../packages/doctrine-bridge.md): its debug middleware records each database call as the event `doctrine`; the `profiling` option of a DoctrineBundle connection (default: `%kernel.debug%`) enables it.
- [Security](../packages/security-bundle.md): in debug mode, SecurityBundle makes the event dispatcher of each firewall traceable with the `debug.stopwatch` service.
- [DebugBundle](../packages/debug-bundle.md): its dump data collector records each `dump()` call as the event `dump`.
- [AI Bundle](../packages/ai-bundle.md): in debug mode, it decorates each platform, agent and toolbox with `TraceablePlatform`, `TraceableAgent` and `TraceableToolbox`, which record events in the category `ai`.
- [Mercure](../packages/mercure.md): in debug mode with Stopwatch installed, MercureBundle decorates each hub with `TraceableHub`, which records each `publish()` call as a Stopwatch event.
- [PHPUnit Bridge](../packages/phpunit-bridge.md): `ClockMock` with `#[TimeSensitive]` and `#[TimeSensitive(Stopwatch::class)]` makes Stopwatch durations exact in tests without a real wait.
- [Clock](../packages/clock.md): `MonotonicClock` measures a monotonic elapsed time with `hrtime()`, and Stopwatch profiles code with `microtime()` for the profiler timeline.
- [FrameworkBundle test tools](../packages/framework-bundle-testing.md): in a `WebTestCase`, `getCollector('time')->getDuration()` returns the total execution time of the request, in milliseconds.
- [DependencyInjection](../packages/dependency-injection.md): if no service matches a typed argument with a default value, autowiring uses the default, so `?Stopwatch $stopwatch = null` works without the package.
- [Symfony Contracts](../packages/contracts.md): `Stopwatch` implements `ResetInterface` from `symfony/service-contracts`, which Stopwatch requires.

## Changed in 8.0/8.1

- **8.1, Console and WebProfilerBundle:** the Performance panel of a `--profile` run shows the duration of each console argument value resolver (category `command.argument_value_resolver`). Thus, you do not need your own Stopwatch events to find a slow resolver.

## Docs

- https://symfony.com/doc/current/performance.html
- https://symfony.com/doc/current/profiler.html
- https://symfony.com/doc/current/reference/twig_reference.html
- https://symfony.com/doc/current/console.html
- https://symfony.com/doc/current/testing/profiling.html
- https://symfony.com/doc/current/components/phpunit_bridge.html
- https://symfony.com/doc/current/event_dispatcher.html
- https://symfony.com/doc/current/components/clock.html
- https://symfony.com/doc/current/reference/configuration/framework.html
- https://symfony.com/components/Stopwatch
- https://github.com/symfony/stopwatch
