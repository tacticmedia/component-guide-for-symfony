# Clock (`symfony/clock`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when code reads the current time or waits, and tests must freeze, set or move that time without a real wait. It gives a PSR-20 clock, a mock clock for tests, a monotonic clock and an immutable date class that follows the mock. To mock the PHP time functions directly, see [PHPUnit Bridge](phpunit-bridge.md).

**Details:** [../details/clock.md](../details/clock.md)

## Why it exists

Code that reads the system clock directly, or that sleeps, is hard to test. Tests of such code cannot control the time, and they wait in real time. The package puts the clock behind a PSR-20 interface. Tests replace it with a mock clock that they can freeze or move, and a sleep on the mock clock returns at once.

## When to use it

- Get the current date and time in application code in a way that tests can control.
- Freeze, set or move the time in a PHPUnit test.
- Pause the code for a number of seconds without a real wait in the tests, for example in a poll or retry loop.
- Measure elapsed time that changes to the system clock do not affect.
- Calculate a relative date, for example 3 hours from now, that follows the mocked time.
- Store dates of the immutable date class in database columns, with the column types of the [Doctrine Bridge](doctrine-bridge.md).
- Parse a date string and get an exception for invalid input, not a false return value.
- Validate a date against today or another relative date, with a clock that tests control.
- Control the time of delayed queue messages and scheduled tasks in tests.

## Use it instead of

- `new \DateTimeImmutable()`, `time()` or `date('Y-m-d')` inside a service -> inject `ClockInterface` and call `$this->clock->now()`, or use `ClockAwareTrait::now()`.
- `sleep(5)` or `usleep(500000)` in a poll or retry loop -> `$clock->sleep(5)`; in tests, `MockClock::sleep()` returns at once.
- A hand-written `FrozenClock` or `FakeClock` test double -> `new MockClock('2024-01-31 10:00')` or `ClockSensitiveTrait::mockTime()`.
- `$start = microtime(true)` and a subtraction for elapsed time -> `MonotonicClock::now()` at the start and at the end.
- `\DateTimeImmutable::createFromFormat('Y-m-d', $input)` and a check for `false` -> `DatePoint::createFromFormat('Y-m-d', $input)` with `catch (\DateMalformedStringException)`.
- `new \DateTimeImmutable('now', new \DateTimeZone('UTC'))` -> `$clock->withTimeZone('UTC')->now()`.
- `new \DateTimeImmutable()` or `new \DateTimeImmutable('+3 hours')` in an entity, a message or other code that is not a service -> `new DatePoint()`, `new DatePoint('+3 hours')` or `now('+3 hours')`.
- `#[ORM\Column(type: 'datetime_immutable')]` and a conversion to `DatePoint` in the getter -> `#[ORM\Column(type: DatePointType::NAME)]`.
