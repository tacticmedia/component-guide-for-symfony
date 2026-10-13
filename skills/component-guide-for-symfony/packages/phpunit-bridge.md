# PHPUnit Bridge (`symfony/phpunit-bridge`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when PHPUnit tests must control time, DNS lookups or class existence checks in code that calls the native PHP functions directly. It replaces these functions with mocks. With PHPUnit 9 and older, it also reports deprecation notices and fails the run above a limit. For code that receives a clock object, see [Clock](clock.md).

**Details:** [../details/phpunit-bridge.md](../details/phpunit-bridge.md)

## Why it exists

Tests that call native time, DNS or class-existence functions are slow or unreliable, or they cannot reach the other code path. The package replaces these functions in the namespace of the tested class with mocks that the test controls. With PHPUnit 9 and older, it also collects the deprecation notices of a test run and makes the run fail above a threshold.

## When to use it

- Test code that sleeps or reads the current time, with the same result each time and without a real wait.
- Test code that makes DNS lookups, for example of MX records or host addresses, without a network connection.
- Test the other branch of code that checks if a class, an interface, a trait or an enum exists.
- Register the clock and DNS mocks for PHPUnit 10 or later in the PHPUnit configuration file.
- Make PHPUnit 9 tests fail on new deprecations, with thresholds, an ignore list or a baseline.
- Make sure that deprecated code triggers the expected deprecation message.
- Run the tests of a library with a PHPUnit version that its Composer dependencies do not include.

## Use it instead of

- `sleep(10)` in a test, then `assertEqualsWithDelta(10000, $duration, 100)` on a Stopwatch event -> `#[TimeSensitive]` and `#[TimeSensitive(Stopwatch::class)]` on the test class, with `SymfonyExtension`. The first attribute mocks `sleep()` in the test namespace, and the second attribute mocks `microtime()` in the Stopwatch namespace. `ClockMock` then moves the clock without a wait, so `assertEquals(10000, $duration)` passes.
- A global variable or a test-only wrapper around `time()` in code that you cannot change -> `ClockMock::register(LegacyService::class)` and `ClockMock::withClockMock(1700000000)`. For code that you can change, inject `ClockInterface` from Clock.
- A real DNS lookup in a test, or a resolver interface that exists only for tests -> `DnsMock::withMockedHosts(['example.com' => [['type' => 'A', 'ip' => '1.2.3.4']]])` with `#[DnsSensitive(DomainValidator::class)]`.
- A second CI job without a dev dependency, only to test the code path for a missing class -> `ClassExistsMock::withMockedClasses([DependencyClass::class => false])`.
- A custom `set_error_handler()` that collects `E_USER_DEPRECATED` notices and fails the run -> `SYMFONY_DEPRECATIONS_HELPER=max[direct]=0` with PHPUnit 9 and older. With PHPUnit 10.1 and later, use the PHPUnit option `failOnDeprecation="true"` instead. With PHPUnit 11.1 and later, also list `trigger_deprecation` in `<deprecationTrigger>`. With PHPUnit 10.2 and later, `<source>` also needs `ignoreSuppressionOfDeprecations="true"`.
- A `grep -v` list of known deprecation messages in a CI script -> `ignoreFile=./tests/deprecation-ignore` or `generateBaseline=true&baselineFile=./tests/allowed.json`.
- `set_error_handler()` in a test method to catch a deprecation message -> `ExpectDeprecationTrait::expectDeprecation('Since vendor/package 1.3: %s')` in a `legacy` test (PHPUnit 9 and older).
- A `phpunit/phpunit` constraint in `require-dev` that conflicts with the dependencies of a library -> `vendor/bin/simple-phpunit` with `SYMFONY_PHPUNIT_VERSION`.
