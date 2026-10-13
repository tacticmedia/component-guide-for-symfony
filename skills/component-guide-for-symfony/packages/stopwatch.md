# Stopwatch (`symfony/stopwatch`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when you must find which part of slow PHP code, a template or a console command takes the time or the memory. It measures the duration and memory usage of named events, laps and sections, and shows them on the request timeline of the debug pages. For a monotonic elapsed time, see [Clock](clock.md).

**Details:** [../details/stopwatch.md](../details/stopwatch.md)

## Why it exists

A subtraction of two microtime values gives one number for one block of code, and you must print or log the number yourself. The package records named events with periods and memory usage. In debug mode, the debug pages show these events on the timeline of each request, next to the events that the framework records.

## When to use it

- Measure the duration and memory usage of a block of code in a controller, a class or a console command.
- Add your own events to the performance timeline of a request.
- Time each iteration of a loop with laps.
- Group related events into named sections.
- Time a part of a template.
- Profile a console command and see its events on the timeline.
- Measure the steps of a plain PHP script without the framework.
- Assert a maximum request duration in a functional test.
- Test code that measures time without a real wait.

## Use it instead of

- `$start = microtime(true);` and `dump(microtime(true) - $start)` or a log message -> `$this->stopwatch->start('export-data')` and `$this->stopwatch->stop('export-data')->getDuration()`; the profiler timeline also shows the event.
- An array of `microtime(true)` values, one for each loop iteration -> `$this->stopwatch->start('process-records')` before the loop, `$this->stopwatch->lap('process-records')` in the loop, and `$event->getPeriods()` after `stop()`.
- A custom data collector that only shows the time of a task -> a Stopwatch event with a category: `$this->stopwatch->start('export-data', 'export')`.
- A `microtime(true)` timer around `$this->render()` to find a slow part of a template -> `{% stopwatch 'render-blog-posts' %}...{% endstopwatch %}` around that part.
- `$output->writeln()` of the elapsed time at the end of a command -> `php bin/console --profile -vvv app:my-command`.
- `sleep(10)` and `assertEqualsWithDelta(10000, $duration, 100)` in a test -> `#[TimeSensitive]` plus `#[TimeSensitive(Stopwatch::class)]`, then `assertEquals(10000, $duration)`.
- A manual timer around `$client->request()` in a functional test -> `$client->enableProfiler()` and `$client->getProfile()->getCollector('time')->getDuration()`.
