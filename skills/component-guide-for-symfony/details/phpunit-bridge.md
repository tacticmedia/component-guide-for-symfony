# PHPUnit Bridge (`symfony/phpunit-bridge`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **PHPUnit extension (PHPUnit 10 and later):** `SymfonyExtension` reads the `time-sensitive` and `dns-sensitive` groups and the bridge attributes, and it resets the mocks after each of these tests. Its `clock-mock-namespaces` and `dns-mock-namespaces` parameters register comma-separated namespaces before the tests run. A namespace value covers only the code directly in that namespace, not its sub-namespaces. The extension also enables `DebugClassLoader` and stops the deduplication of Doctrine deprecations. Entry point: `<bootstrap class="Symfony\Bridge\PhpUnit\SymfonyExtension">` in the `<extensions>` element of `phpunit.dist.xml`.
- **Clock mock:** `ClockMock` replaces `time()`, `microtime()`, `sleep()`, `usleep()`, `date()`, `gmdate()`, `hrtime()` and `strtotime()` in the namespace of a registered class. Call `register()` before the tested code calls one of these functions for the first time. `sleep()` and `usleep()` move the mocked clock forward and return at once. `withClockMock(true)` starts the mock at the current time, a number sets the mocked time to that Unix timestamp, and `false` stops the mock. The mock does not change a fully qualified call such as `\time()`. `new \DateTime()` still uses the real time. For the mocked time, use `\DateTime::createFromFormat('U', (string) time())`. Entry point: `Symfony\Bridge\PhpUnit\ClockMock::register()` and `ClockMock::withClockMock()`.
- **Time-sensitive tests:** The `time-sensitive` group or `#[TimeSensitive]` registers the clock mock for the namespace of the test class and for that namespace without `\Tests\`. Each test with the group or the attribute starts with the mock enabled. `#[TimeSensitive(Stopwatch::class)]` registers only the namespace of the given class. If the test calls `sleep()` or another time function itself, also add `#[TimeSensitive]` or the group. The attribute is repeatable on a class or a method. Only `SymfonyExtension` reads the attribute, so the attribute needs PHPUnit 10 or later. Entry point: `#[Group('time-sensitive')]` or `Symfony\Bridge\PhpUnit\Attribute\TimeSensitive`.
- **DNS mock:** `DnsMock` replaces `checkdnsrr()`, `dns_check_record()`, `getmxrr()`, `dns_get_mx()`, `gethostbyaddr()`, `gethostbyname()`, `gethostbynamel()` and `dns_get_record()`. `withMockedHosts()` takes host names as keys and records in the `dns_get_record()` format as values. With an empty array, the real functions run. The `dns-sensitive` group and `#[DnsSensitive]` register namespaces in the same way as for the clock mock. Entry point: `Symfony\Bridge\PhpUnit\DnsMock::withMockedHosts()`, `#[Group('dns-sensitive')]` or `Symfony\Bridge\PhpUnit\Attribute\DnsSensitive`.
- **Class existence mock:** `ClassExistsMock` replaces `class_exists()`, `interface_exists()`, `trait_exists()` and `enum_exists()`. `withMockedClasses([Foo::class => false])` makes a class absent or present for the tested code, and `withMockedEnums()` does the same for enums. No group or attribute exists for this mock. Call `ClassExistsMock::register(MyClass::class)` before the tested code calls one of these functions for the first time, for example in `setUpBeforeClass()`. Entry point: `Symfony\Bridge\PhpUnit\ClassExistsMock`.
- **Deprecation helper (PHPUnit 9 and older):** The Composer autoload file `bootstrap.php` registers `DeprecationErrorHandler` when PHPUnit runs. It puts each deprecation in the unsilenced, legacy, self, direct, indirect or other group and prints a summary at the end. By default, any unsilenced deprecation, and any deprecation outside a legacy test, makes the run fail. Entry point: `Symfony\Bridge\PhpUnit\DeprecationErrorHandler`.
- **Helper modes:** `SYMFONY_DEPRECATIONS_HELPER` takes a URL-encoded string with the keys `max[total]`, `max[self]`, `max[direct]`, `max[indirect]`, `verbose`, `quiet[]`, `disabled`, `ignoreFile`, `generateBaseline`, `baselineFile` and `logFile`. A `/regex/` value prints the stack trace of the first matching deprecation and stops the run. A number sets `max[total]`, `strict` equals `max[total]=0`, `weak` allows all deprecations without details, and `disabled` turns the helper off. Entry point: the `SYMFONY_DEPRECATIONS_HELPER` env var in `<php><env>` or in the shell.
- **Deprecation types:** A `self` deprecation comes from your own code. A `direct` deprecation comes from a vendor package that your code calls. An `indirect` deprecation comes from a vendor package that another vendor package calls. The docs recommend `max[total]=0` for projects with stable dependencies, `max[direct]=0` when dependencies fix deprecations late, and `max[self]=0` for libraries. Entry point: `max[self]`, `max[direct]` and `max[indirect]`.
- **Ignore list and baseline:** `ignoreFile` points to a file with one regular expression per line, and lines that start with `#` are comments. `generateBaseline=true&baselineFile=./tests/allowed.json` writes the current deprecations to a JSON file. Later runs with `baselineFile` alone ignore these deprecations. Entry point: the `ignoreFile`, `generateBaseline` and `baselineFile` keys.
- **Legacy tests (PHPUnit 9 and older):** The `@group legacy` annotation (recommended), a `Legacy` prefix in the class name or a `testLegacy*` method name marks a test as legacy. PHPUnit 9 reads groups only from annotations, so `#[Group('legacy')]` has no effect there. Silenced deprecations from legacy tests do not count toward the thresholds. Deprecations from data providers named `provideLegacy*` or `getLegacy*` are legacy too. Entry point: `@group legacy` in the docblock of the test class or method.
- **Deprecation assertions:** With PHPUnit 9 and older, `ExpectDeprecationTrait::expectDeprecation()` asserts a message in the `assertStringMatchesFormat()` format, and the test must be in the `legacy` group. `ExpectUserDeprecationMessageTrait` maps `expectUserDeprecationMessage()` to `expectDeprecation()` below PHPUnit 11, and it is empty on PHPUnit 11 and later. Symfony's own tests on PHPUnit 13 use `#[Group('legacy')]`, `#[IgnoreDeprecations]` (`PHPUnit\Framework\Attributes\IgnoreDeprecations`, PHPUnit 10.5 and later) and the PHPUnit method `expectUserDeprecationMessage()` (PHPUnit 11 and later). Entry point: `Symfony\Bridge\PhpUnit\ExpectDeprecationTrait` and `Symfony\Bridge\PhpUnit\ExpectUserDeprecationMessageTrait`.
- **Autoload-time deprecations:** If symfony/error-handler is available, the bridge enables `DebugClassLoader`. It triggers deprecations at autoload time, for example when a class extends a `@final` class or misses a method that a parent announces with `@method`. With the PHPUnit 9 listener, the `debug-class-loader` option set to `0` turns it off. Entry point: `Symfony\Component\ErrorHandler\DebugClassLoader`.
- **`simple-phpunit`:** The script installs PHPUnit in a separate directory and runs it, so PHPUnit does not change the dependencies of the project. `SYMFONY_PHPUNIT_VERSION` selects the version (default `9.6`), and the script refuses PHPUnit 10. Below PHPUnit 11, it adds assertion polyfills and `SymfonyTestsListener`; from PHPUnit 11, it turns the deprecation helper off. With a directory argument, it runs each subdirectory that has a `phpunit.xml.dist` file in parallel, 3 levels deep by default. Entry point: `vendor/bin/simple-phpunit`.
- **Other listener features (PHPUnit 9 and older):** `SymfonyTestsListener` sets the locale to `C` unless `SYMFONY_PHPUNIT_LOCALE` gives another value. It also records the skipped tests in the file that `SYMFONY_PHPUNIT_SKIPPED_TESTS` names, and the next run runs only these tests. `CoverageListener` adds the tested class as `@covers` when a test has no `@covers` annotation. Entry point: `Symfony\Bridge\PhpUnit\SymfonyTestsListener` and `Symfony\Bridge\PhpUnit\CoverageListener` in `<listeners>`.

## Entry points

- `Symfony\Bridge\PhpUnit\SymfonyExtension`: `<bootstrap class="Symfony\Bridge\PhpUnit\SymfonyExtension"/>` inside `<extensions>` of `phpunit.dist.xml` (PHPUnit 10 and later). The Flex recipe of the bridge adds it with `App` as the mocked namespace. This value does not cover sub-namespaces such as `App\Service`.
- Without FrameworkBundle: register `SymfonyExtension` in `phpunit.dist.xml`, or call `ClockMock::register()`, `DnsMock::register()` or `ClassExistsMock::register()` in the test. A library can run its tests with `vendor/bin/simple-phpunit`.
- `SymfonyExtension` parameters: `clock-mock-namespaces` and `dns-mock-namespaces` (comma-separated namespaces), `deprecations-namespaces-mapping` (comma-separated `Prefix=>Vendor` pairs, since 8.1).
- `Symfony\Bridge\PhpUnit\ClockMock`: `register()`, `withClockMock()`.
- `Symfony\Bridge\PhpUnit\DnsMock`: `register()`, `withMockedHosts()`.
- `Symfony\Bridge\PhpUnit\ClassExistsMock`: `register()`, `withMockedClasses()`, `withMockedEnums()`.
- `Symfony\Bridge\PhpUnit\Attribute\TimeSensitive` and `Symfony\Bridge\PhpUnit\Attribute\DnsSensitive` (optional class argument).
- Test groups `time-sensitive`, `dns-sensitive` and `legacy`: the `@group` annotation with PHPUnit 9 and older, the `#[Group('...')]` attribute (`PHPUnit\Framework\Attributes\Group`) with PHPUnit 10 and later.
- `SYMFONY_DEPRECATIONS_HELPER` env var and `Symfony\Bridge\PhpUnit\DeprecationErrorHandler` (PHPUnit 9 and older).
- `Symfony\Bridge\PhpUnit\ExpectDeprecationTrait` and `Symfony\Bridge\PhpUnit\ExpectUserDeprecationMessageTrait`.
- `Symfony\Bridge\PhpUnit\SymfonyTestsListener` and `Symfony\Bridge\PhpUnit\CoverageListener` in `<listeners>` (PHPUnit 9 and older).
- `vendor/bin/simple-phpunit`; `simple-phpunit install` installs PHPUnit without a test run. Env vars: `SYMFONY_PHPUNIT_VERSION`, `SYMFONY_MAX_PHPUNIT_VERSION`, `SYMFONY_PHPUNIT_DIR`, `SYMFONY_PHPUNIT_REMOVE`, `SYMFONY_PHPUNIT_REQUIRE`, `SYMFONY_PHPUNIT_REMOVE_RETURN_TYPEHINT`, `SYMFONY_PHPUNIT_MAX_DEPTH`, `SYMFONY_PHPUNIT_SKIPPED_TESTS`.
- `SYMFONY_PHPUNIT_LOCALE` env var (PHPUnit 9 and older).

## Symbiotic packages

- [Clock](../packages/clock.md): Clock (`MockClock`, `ClockSensitiveTrait::mockTime()`) mocks the time of code that uses a `ClockInterface`, and `ClockMock` mocks code that calls `time()` or `sleep()` directly.
- [ErrorHandler](../packages/error-handler.md): The bridge enables `DebugClassLoader` from ErrorHandler, which triggers deprecations at autoload time and, since 8.1, can map namespaces to different vendors.
- [Symfony Contracts](../packages/contracts.md): `trigger_deprecation()` from symfony/deprecation-contracts triggers the deprecations that the helper reports, and the PHPUnit recipe lists it as a `<deprecationTrigger>`.
- [Stopwatch](../packages/stopwatch.md): Stopwatch calls `microtime()` without a leading backslash, so `#[TimeSensitive(Stopwatch::class)]` and `#[TimeSensitive]` on the test make its durations exact without a real wait.
- [HttpClient](../packages/http-client.md): `DnsMock` fakes the host lookups of `NoPrivateNetworkHttpClient`, and `MockHttpClient` fakes the HTTP responses; the HttpClient tests use both.
- [BrowserKit](../packages/browser-kit.md): With PHPUnit 9 and older, the bridge collects the deprecations of an insulated `AbstractBrowser` request through `SYMFONY_DEPRECATIONS_SERIALIZE`.
- [FrameworkBundle test tools](../packages/framework-bundle-testing.md): `KernelTestCase` and `WebTestCase` boot the kernel and send requests, and the bridge adds only mocks and deprecation checks to the same PHPUnit run.
- [Dotenv](../packages/dotenv.md): `simple-phpunit` reads `SYMFONY_PHPUNIT_VERSION` from `phpunit.dist.xml` or from a real environment variable, not from a `.env` file.
- [Symfony Flex](../packages/flex.md): symfony/test-pack 1.2 does not install the bridge; require `symfony/phpunit-bridge` (alias `phpunit-bridge`).

## Changed in 8.0/8.1

- 8.0: `SymfonyTestsListener` registers `class_exists` as the Doctrine annotation loader -> the listener does not register a loader, and no replacement exists. 8.0 does not rename or remove anything else in the bridge.
- 8.1: Deprecations between `Acme\Bundle` and `Acme\Library` stay hidden (same top namespace) -> the `deprecations-namespaces-mapping` parameter or `DebugClassLoader::enable([...])` maps them to different vendors.
- 8.1: `DebugClassLoader` reads `@method` only on interfaces -> it also reads `@method` on abstract classes, and a subclass without the method triggers a deprecation.
- 8.1: `simple-phpunit` reads its settings (for example `SYMFONY_PHPUNIT_VERSION`) from `phpunit.xml` or `phpunit.xml.dist` -> it also reads `phpunit.dist.xml`.

## Status

The deprecation helper, `SymfonyTestsListener`, `ExpectDeprecationTrait`, `CoverageListener` and the locale setting work only with PHPUnit 9 and older. With PHPUnit 10 and later, register `SymfonyExtension` for the mocks. For deprecations, use the PHPUnit option `failOnDeprecation` (PHPUnit 10.1 and later) and the `<deprecationTrigger>` element (PHPUnit 11.1 and later). PHPUnit 10.2 and later report the silenced `trigger_deprecation()` notices only if `<source>` has `ignoreSuppressionOfDeprecations="true"`, which the phpunit/phpunit 11.1 recipe sets. `simple-phpunit` ships in 8.1, and the Symfony repository runs its tests with it on PHPUnit 13. A Flex application runs PHPUnit with `bin/phpunit` from the phpunit/phpunit recipe. `symfony/test-pack` 1.2 does not install the bridge.

## Docs

- https://symfony.com/doc/current/components/phpunit_bridge.html
- https://symfony.com/doc/current/setup/upgrade_major.html
- https://symfony.com/doc/current/setup/bundles.html
- https://symfony.com/doc/current/bundles/best_practices.html
- https://symfony.com/doc/current/reference/attributes.html
- https://symfony.com/doc/current/testing.html
- https://symfony.com/doc/current/components/clock.html
