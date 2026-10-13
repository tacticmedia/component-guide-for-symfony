# Clock (`symfony/clock`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Clock contract:** `ClockInterface` extends the PSR-20 `Psr\Clock\ClockInterface` with `sleep()` and `withTimeZone()`. `withTimeZone()` returns a new clock and does not change the original clock. Entry point: `Symfony\Component\Clock\ClockInterface`.
- **The `clock` service:** in a Symfony application, the `clock` service is a `Clock` object with the aliases `Symfony\Component\Clock\ClockInterface` and `Psr\Clock\ClockInterface`. The service reads the global clock at each call. Thus, `mockTime()` in a `KernelTestCase` or a `WebTestCase` also changes the time of the service. Entry point: autowire `ClockInterface`.
- **System clock:** `NativeClock` returns the system time. Its default time zone is the value of `date_default_timezone_get()`. Its `sleep()` method calls the PHP functions `sleep()` and `usleep()`. Entry point: `new NativeClock('UTC')`.
- **Mock clock:** `MockClock` holds a fixed time. Only `sleep()` and `modify()` change this time. `sleep()` adds the seconds at once and does not wait, and it ignores a zero or negative value. If the date string has no time zone and you give no time zone argument, `MockClock` uses UTC. Entry point: `new MockClock('2024-01-31 10:00')`, `MockClock::modify('+1 day')`.
- **Monotonic clock:** `MonotonicClock` uses `hrtime()`, so changes to the system clock do not affect it. Use it to measure elapsed time. It returns `DatePoint` objects with microsecond precision. If `hrtime()` returns `false`, the constructor throws `\RuntimeException`. Entry point: `new MonotonicClock()`.
- **Global clock:** `Clock::get()` returns the global clock, by default a `NativeClock`. `Clock::set()` replaces the global clock, and it wraps a PSR-20 clock that is not a Symfony clock in a `Clock` object. A `new Clock()` without arguments reads the global clock at each call. Entry point: `Clock::get()`, `Clock::set()`.
- **`now()` function:** `now()` returns the time of the global clock as a `DatePoint`. A modifier, as in `now('+3 hours')`, is relative to that time. Composer loads the function with the package. Entry point: `use function Symfony\Component\Clock\now;`.
- **DatePoint:** `DatePoint` is a final, immutable date class that extends `\DateTimeImmutable`. Its constructor takes the current time from the global clock, so `new DatePoint('+1 day')` follows a mocked clock. The third constructor argument sets a different reference time. The methods `modify()`, `setTime()` and the other setters return a `DatePoint`. Entry point: `Symfony\Component\Clock\DatePoint`.
- **Errors as exceptions:** for invalid input, `DatePoint::createFromFormat()` throws `\DateMalformedStringException`, and `\DateTimeImmutable::createFromFormat()` returns `false`. When the date has no time zone, `DatePoint::getTimezone()` throws `\DateInvalidTimeZoneException` and does not return `false`. `setMicrosecond()` throws `\DateRangeError` for a value outside 0 to 999999. Entry point: `DatePoint::createFromFormat()`.
- **Clock in a service:** `ClockAwareTrait` adds a `setClock()` method with `#[Required]` and a protected `now()` method that returns a `DatePoint`. When the service is autowired, the container calls `setClock()` with the `clock` service. Without a clock, `now()` reads the global clock. The clock property is `readonly`, so call `setClock()` only once and before the first `now()` call. Entry point: `Symfony\Component\Clock\ClockAwareTrait`.
- **Time in tests:** add `ClockSensitiveTrait` to a test case. `mockTime()` replaces the global clock with a `MockClock` and returns it. It accepts a date or a modifier string, a `\DateTimeImmutable`, `true` to freeze the current time, or `false` to restore the original clock. The trait restores the original clock after each test. Entry point: `Symfony\Component\Clock\Test\ClockSensitiveTrait::mockTime()`.
- **Doctrine column types:** DoctrineBundle registers the Doctrine Bridge types `date_point`, `day_point` and `time_point` when `DatePoint` exists. They store a `DatePoint` as a date and time, as a date, or as a time. Set the column type, for example `#[ORM\Column(type: DatePointType::NAME)]`. The ORM does not detect these types from a `DatePoint` property type. Entry point: `Symfony\Bridge\Doctrine\Types\DatePointType`, `DayPointType`, `TimePointType`.
- **Form input:** the `input` option value `date_point` makes `DateType`, `DateTimeType` and `TimeType` read and write `DatePoint` objects. Entry point: `'input' => 'date_point'`.
- **Relative dates in constraints:** the comparison validators (for example `GreaterThanValidator`) and `RangeValidator` convert a relative date string such as `today` for a date value. If the value is a `DatePoint`, the global clock controls `today`, so `mockTime()` changes the result. Since 8.1, the validators accept an optional `ClockInterface` argument, but FrameworkBundle does not inject the `clock` service. If a test must control `today`, type the property as `DatePoint`. Entry point: `#[Assert\GreaterThan('today')]` on a `DatePoint` property.
- **Clock in other components:** FrameworkBundle gives the `clock` service to the controller `DateTimeValueResolver`, `UriSigner`, the Messenger in-memory transport and the Scheduler. ConsoleBundle gives it to the console `DateTimeValueResolver`, and the Messenger stamps read the global clock. Thus, `mockTime()` controls their time in tests. `ArrayAdapter` uses a clock only when you give one to its constructor. Entry point: the `clock` service, `new ArrayAdapter(clock: $clock)`.

## Entry points

- Autowire `Symfony\Component\Clock\ClockInterface` or `Psr\Clock\ClockInterface` to get the `clock` service (class `Symfony\Component\Clock\Clock`).
- Trait `Symfony\Component\Clock\ClockAwareTrait` for a service that needs `now()`.
- Static methods `Symfony\Component\Clock\Clock::get()` and `Clock::set()` for the global clock.
- Function `Symfony\Component\Clock\now()`.
- Classes `Symfony\Component\Clock\DatePoint`, `Symfony\Component\Clock\NativeClock`, `Symfony\Component\Clock\MockClock` and `Symfony\Component\Clock\MonotonicClock`.
- Without FrameworkBundle: create a `NativeClock`, `MockClock` or `MonotonicClock`, or use the global clock with `Clock::get()`, `Clock::set()` and `now()`.
- Test helper `Symfony\Component\Clock\Test\ClockSensitiveTrait` with `mockTime()`.
- Doctrine column types `date_point`, `day_point` and `time_point` (`Symfony\Bridge\Doctrine\Types\DatePointType::NAME`, `DayPointType::NAME`, `TimePointType::NAME`).
- Form option `'input' => 'date_point'` on `DateType`, `DateTimeType` and `TimeType`.
- Install the package with `composer require symfony/clock`. If Composer installs `symfony/clock` only as a dev dependency, `ServicesBundle` removes the two `ClockInterface` aliases.
- The Clock component has no `framework` configuration key, console command, Twig function or attribute.

## Symbiotic packages

- [DependencyInjection](../packages/dependency-injection.md): since 8.1, its `ServicesBundle` registers the `clock` service and the two `ClockInterface` aliases.
- [FrameworkBundle](../packages/framework-bundle.md): it gives the `clock` service to `UriSigner`, the controller `DateTimeValueResolver`, the Messenger in-memory transport and the Scheduler transport.
- [FrameworkBundle test tools](../packages/framework-bundle-testing.md): in a `KernelTestCase` or a `WebTestCase`, `mockTime()` also changes the time of the `clock` service, because the service reads the global clock.
- [Doctrine Bridge](../packages/doctrine-bridge.md): it supplies the `date_point`, `day_point` and `time_point` column types for `DatePoint` properties.
- [Validator](../packages/validator.md): for a `DatePoint` value, the comparison constraints and `Range` resolve `today` or `+5 hours` against the global clock. The validators accept a `ClockInterface` argument, but FrameworkBundle does not inject the `clock` service.
- [Form](../packages/form.md): the option `'input' => 'date_point'` on the date and time types maps a field to a `DatePoint` property.
- [HttpKernel](../packages/http-kernel.md): `DateTimeValueResolver` creates controller date arguments with the clock, and an empty value for a non-nullable argument gives the clock time.
- [Console](../packages/console.md): since 8.1, `DateTimeValueResolver` creates the date arguments of invokable commands with the clock.
- [HttpFoundation](../packages/http-foundation.md): `UriSigner` uses the clock to set and check the expiration of signed URIs.
- [Messenger](../packages/messenger.md): Messenger requires Clock. The `DelayStamp` factory methods and `RedeliveryStamp` read the global clock, and the in-memory transport uses the `clock` service for delayed messages.
- [Scheduler](../packages/scheduler.md): the Scheduler component requires the Clock component and reads the clock to find the due messages.
- [Cache](../packages/cache.md): `ArrayAdapter` accepts a PSR-20 clock as a constructor argument to calculate the lifetime of cache items in tests.
- [Security](../packages/security-bundle.md): the OIDC token handler checks the `iat`, `nbf` and `exp` claims against the `clock` service.
- [PHPUnit Bridge](../packages/phpunit-bridge.md): `ClockMock` mocks only native functions such as `time()` and `sleep()`; for code with `ClockInterface` or `DatePoint`, use `MockClock`.
- [Stopwatch](../packages/stopwatch.md): Stopwatch profiles code sections with `microtime()` and does not read the clock, so tests mock its time with `ClockMock`.
- [AI Agent](../packages/ai-agent.md): the `symfony/ai-clock-tool` package gives an agent a `clock` tool that returns the current date and time from a Symfony clock.

## Changed in 8.0/8.1

- **8.1, Validator:** the comparison validators and `RangeValidator` accept an optional `ClockInterface` argument for relative date strings such as `today`. The docs say that the framework injects the `clock` service. FrameworkBundle does not inject it.
- **8.1, Messenger:** `DelayStamp::delayFor()`, `DelayStamp::delayUntil()` and `RedeliveryStamp` read the global clock instead of `new \DateTimeImmutable()` and `time()`. Thus, `mockTime()` controls the time that these stamps read in tests.
- **8.1, Console:** an invokable command can take a `\DateTimeImmutable` parameter with `#[Argument]` or `#[Option]`. The console `DateTimeValueResolver` creates the value with the clock.
- **8.1, DependencyInjection:** the `clock` service moved from FrameworkBundle to the new `ServicesBundle`. If a test builds a `ContainerBuilder` by hand, load the `ServicesBundle` extension before `FrameworkExtension::load()`.
- **8.0, MockClock:** `MockClock::sleep()` ignores a zero or negative value, the same as `NativeClock`. Versions 6.4.30, 7.3.8 and 7.4.0 have the same fix. To move a `MockClock` back, call `modify('-1 hour')`.

## Docs

- https://symfony.com/doc/current/components/clock.html
- https://symfony.com/doc/current/doctrine.html
- https://symfony.com/doc/current/reference/constraints/GreaterThan.html
- https://symfony.com/doc/current/reference/constraints/Range.html
- https://symfony.com/doc/current/reference/forms/types/datetime.html
- https://symfony.com/doc/current/controller/value_resolver.html
- https://symfony.com/doc/current/console/value_resolver.html
- https://symfony.com/doc/current/routing.html
- https://symfony.com/doc/current/configuration/front_controllers_and_kernel.html
- https://symfony.com/doc/current/components/phpunit_bridge.html
