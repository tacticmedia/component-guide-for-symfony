# FrameworkBundle test tools (`symfony/framework-bundle`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Kernel test case**: `KernelTestCase` boots your kernel in the `APP_ENV` environment (`test` by default) and shuts it down after each test. It finds the kernel class in the `KERNEL_CLASS` environment variable. For a custom kernel, override `createKernel()` or `getKernelClass()`. Entry point: `KernelTestCase::bootKernel(['environment' => ..., 'debug' => ...])`.
- **Test container**: `static::getContainer()` returns a special container that gives public services and the private services that the compiler did not remove. It boots the kernel when necessary. It needs `framework.test: true`. If no service uses a private service, the compiler removes it. If a test needs that service, make it public in `config/services_test.yaml`. Entry point: `KernelTestCase::getContainer()`.
- **Service mocks**: `static::getContainer()->set($id, $mock)` replaces a public or a private service. Replace the service before the container creates it, because a replacement after that throws an exception. For a non-shared service, give a closure that returns the mock (new in 8.1). Entry point: `static::getContainer()->set()`.
- **Test client**: `createClient()` boots the kernel and returns the `KernelBrowser`. The client sends each request through the kernel in the same PHP process, without a web server, and returns a `Crawler`. The client does not follow redirects. To follow a redirect, call `followRedirect()` after the request, or call `followRedirects()` before it. It needs `symfony/browser-kit`. If the kernel is already booted, `createClient()` throws a `LogicException`, so call it before `getContainer()` or `bootKernel()`. Before you create a second client, call `self::ensureKernelShutdown()`. Entry point: `WebTestCase::createClient($options, $server)`.
- **Kernel reboot between requests**: Before each request after the first one, the client reboots the kernel and gets a new container. The new container does not keep the services that you replaced with `set()`. The reboot also clears the security token and detaches Doctrine entities. To keep the same kernel, call `disableReboot()`; Symfony then resets the services with the `kernel.reset` tag. This reset also clears the security token and detaches Doctrine entities. To keep the state of a service, remove its `kernel.reset` tag in a compiler pass in the `test` environment. Entry point: `KernelBrowser::disableReboot()`.
- **Simulated login**: `loginUser($user, $firewallContext, $tokenAttributes)` logs in a `UserInterface` object without the login form. It stores a `TestBrowserToken` in the session for the firewall context (`main` by default). It does not work with stateless firewalls. The user object must be serializable. Entry point: `KernelBrowser::loginUser()`.
- **Session setup**: `getSession()` gives the session of the test client before a request, for example to store a CSRF token. Call `save()` after you change it. It returns `null` when the application has no session. Entry point: `KernelBrowser::getSession()`.
- **Profiler data**: `enableProfiler()` collects profiler data for the next request only. `getProfile()` returns that profile and its data collectors. The configuration must enable the profiler. The WebProfilerBundle recipe enables it in the `test` environment with `collect: false`. Entry point: `KernelBrowser::enableProfiler()`.
- **Response assertions**: `assertResponseIsSuccessful()`, `assertResponseStatusCodeSame()`, `assertResponseRedirects()`, `assertResponseHasHeader()`, `assertResponseHeaderSame()`, `assertResponseHasCookie()`, `assertResponseCookieValueSame()`, `assertResponseFormatSame()` and `assertResponseIsUnprocessable()` check the last response. The failure messages of `assertResponseIsSuccessful()`, `assertResponseStatusCodeSame()`, `assertResponseRedirects()`, `assertResponseFormatSame()` and `assertResponseIsUnprocessable()` show the full response. In debug mode, if the application threw an exception, a failed response assertion also shows that exception. To make `request()` throw the exception, call `$client->catchExceptions(false)` before the request. To remove the response body from these messages, call `setBrowserKitAssertionsAsVerbose(false)`. For one assertion, set its `$verbose` argument to `false`. Entry point: `BrowserKitAssertionsTrait`.
- **Request and browser assertions**: `assertRouteSame()`, `assertRequestAttributeValueSame()` and `assertSessionHasFlashMessage()` (new in 8.1) check the last request. `assertBrowserHasCookie()`, `assertBrowserCookieValueSame()`, `assertBrowserHistoryIsOnFirstPage()` and `assertBrowserHistoryIsOnLastPage()` check the client. The third argument of `assertBrowserCookieValueSame()` is `bool $raw`, before `$path`. To apply your own PHPUnit constraint, use `assertThatForResponse()` or `assertThatForClient()`. Entry point: `BrowserKitAssertionsTrait`.
- **Crawler assertions**: `assertSelectorExists()`, `assertSelectorCount()`, `assertSelectorTextContains()`, `assertSelectorTextSame()`, `assertPageTitleSame()`, `assertInputValueSame()`, `assertCheckboxChecked()` and `assertFormValue()` apply CSS selectors to the last HTML response. `assertSelectorTextContains()` and `assertSelectorTextSame()` check only the first matching node. To accept any matching node, use `assertAnySelectorTextContains()` or `assertAnySelectorTextSame()`. The text checks normalize white space. Entry point: `DomCrawlerAssertionsTrait`.
- **Mailer assertions**: `assertEmailCount()`, `assertQueuedEmailCount()`, `getMailerMessage()`, `assertEmailSubjectContains()`, `assertEmailHtmlBodyContains()`, `assertEmailTextBodyContains()`, `assertEmailAddressContains()`, `assertEmailHeaderSame()` and `assertEmailAttachmentCount()` check the emails of the current kernel. `assertQueuedEmailCount()` counts the emails that the mailer sent to the Messenger bus. When the client follows a redirect, the kernel reboots and the logged emails are lost. Entry point: `MailerAssertionsTrait` (in `KernelTestCase`).
- **Notifier assertions**: `assertNotificationCount()`, `assertQueuedNotificationCount()`, `getNotifierMessage()`, `assertNotificationSubjectContains()` and `assertNotificationTransportIsEqual()` check the notifications of the current kernel. Entry point: `NotificationAssertionsTrait` (in `KernelTestCase`).
- **HttpClient assertions**: `assertHttpClientRequest()`, `assertNotHttpClientRequest()` and `assertHttpClientRequestCount()` check the requests that an HTTP client service sent (`http_client` by default). They read the profiler data, so call `$client->enableProfiler()` before the request. Entry point: `HttpClientAssertionsTrait` (in `WebTestCase`).
- **Console assertions** (new in 8.1): `static::runCommand($name, $input, $interactiveInputs)` runs a command through `CommandTester` and returns an `ExecutionResult` with `getOutput()`, `getErrorOutput()`, `getDisplay()` and `statusCode`. `assertCommandIsSuccessful()`, `assertCommandFailed()`, `assertCommandIsInvalid()` and `assertCommandResultEquals()` check that result. This path does not dispatch console events; to test them, use `ApplicationTester`. Entry point: `ConsoleCommandAssertionsTrait` (in `KernelTestCase`).

## Entry points

- `Symfony\Bundle\FrameworkBundle\Test\KernelTestCase`: `bootKernel()`, `getContainer()`, `createKernel()`, `getKernelClass()`, `ensureKernelShutdown()`, `runCommand()`, and the mailer, notifier and console assertions.
- `Symfony\Bundle\FrameworkBundle\Test\WebTestCase`: `createClient(array $options = [], array $server = [])`, and the response, request, browser, crawler and HttpClient assertions.
- `Symfony\Bundle\FrameworkBundle\KernelBrowser` (the test client, service `test.client`): `loginUser()`, `getSession()`, `enableProfiler()`, `getProfile()`, `disableReboot()`, `enableReboot()`, `getContainer()`, `getKernel()`, `catchExceptions()`. BrowserKit methods: `request()`, `jsonRequest()`, `xmlHttpRequest()`, `submitForm()`, `clickLink()`, `followRedirect()`, `followRedirects()`, `insulate()`.
- `Symfony\Bundle\FrameworkBundle\Test\TestBrowserToken`: the security token that `loginUser()` creates.
- Assertion traits in `Symfony\Bundle\FrameworkBundle\Test`: `BrowserKitAssertionsTrait`, `DomCrawlerAssertionsTrait`, `HttpClientAssertionsTrait`, `WebTestAssertionsTrait` (the three previous traits), `MailerAssertionsTrait`, `NotificationAssertionsTrait`, `ConsoleCommandAssertionsTrait`. Negative variants exist for many assertions, for example `assertSelectorNotExists()`, `assertResponseNotHasHeader()` and `assertEmailHtmlBodyNotContains()`.
- Config key `framework.test` (boolean): loads the `test.client` and `test.service_container` services and the test session listener. The Flex recipe sets it under `when@test`.
- Config keys `framework.profiler.enabled` and `framework.profiler.collect`: `enableProfiler()` and the HttpClient assertions need the profiler.
- Environment variable `KERNEL_CLASS` (in `.env.test` or `phpunit.dist.xml`): the kernel class that `KernelTestCase` boots.
- Service IDs `test.client` and `test.service_container`. To set server parameters for all requests of a client, such as `HTTP_HOST`, use the `$server` argument of `createClient()`. Give each HTTP header as a server parameter in capital letters with the `HTTP_` prefix, for example `HTTP_X_SESSION_TOKEN` for `X-Session-Token`. `createClient()` always replaces the server parameters from the `test.client.parameters` parameter.
- PHPUnit constraints for your own assertions: `Symfony\Component\HttpFoundation\Test\Constraint\*`, `Symfony\Component\BrowserKit\Test\Constraint\*`, `Symfony\Component\DomCrawler\Test\Constraint\*`, `Symfony\Component\Mailer\Test\Constraint\*`, `Symfony\Component\Mime\Test\Constraint\*`, `Symfony\Component\Notifier\Test\Constraint\*`, `Symfony\Component\Console\Tester\Constraint\*`. Apply a `Response*` constraint with `assertThatForResponse()` and a `Browser*` constraint with `assertThatForClient()`. Apply the other constraints with `self::assertThat()`, for example to a request, a `Crawler`, an email or a command status code.
- Installation: `composer require --dev symfony/test-pack` (it installs `phpunit/phpunit`, `symfony/browser-kit` and `symfony/css-selector`).
- Generator: `php bin/console make:test` (MakerBundle) creates a `KernelTestCase`, a `WebTestCase` or another test class.

## Symbiotic packages

- [BrowserKit](../packages/browser-kit.md): `KernelBrowser` extends the BrowserKit browser, which gives the request, form, link, redirect, history and cookie API; `createClient()` needs it.
- [DomCrawler](../packages/dom-crawler.md): each client request returns a `Crawler`, and the crawler assertions filter that crawler.
- [CssSelector](../packages/css-selector.md): the crawler assertions use CSS selectors, and `Crawler::filter()` needs this component to convert them to XPath.
- [JsonPath](../packages/json-path.md): to check a JSON response, use `JsonPathAssertionsTrait` on `$client->getResponse()->getContent()`, because FrameworkBundle has no JSON response assertions.
- [HttpKernel](../packages/http-kernel.md): `KernelBrowser` extends `HttpKernelBrowser`, which handles each request through the kernel in the same PHP process.
- [HttpFoundation](../packages/http-foundation.md): the response, request and flash message assertions use the constraints in `Symfony\Component\HttpFoundation\Test\Constraint`.
- [Console](../packages/console.md): `runCommand()` uses `CommandTester::run()` and returns its `ExecutionResult`; use `ApplicationTester` from Console when you must test console events.
- [Mailer](../packages/mailer.md): the mailer assertions read the emails that the `mailer.message_logger_listener` service logged in the current kernel.
- [Mime](../packages/mime.md): the email content assertions (subject, body, headers, addresses, attachments) use the constraints in `Symfony\Component\Mime\Test\Constraint`.
- [Notifier](../packages/notifier.md): the notifier assertions read the `notifier.notification_logger_listener` service.
- [HttpClient](../packages/http-client.md): the HttpClient assertions check the requests of HTTP client services; to prevent real calls, use `MockHttpClient` or `framework.http_client.mock_response_factory`.
- [Messenger](../packages/messenger.md): use the `in-memory://` transport in tests; `KernelTestCase` and `WebTestCase` reset it after each test.
- [Security](../packages/security-bundle.md): `loginUser()` puts a `TestBrowserToken` in the session of a firewall, so protected pages see a logged-in user.
- [WebProfilerBundle](../packages/web-profiler-bundle.md): its Flex recipe enables the profiler in the `test` environment with `collect: false`, which `enableProfiler()` and `getProfile()` need.
- [Panther](../packages/panther.md): use Panther for end-to-end tests with JavaScript in a real browser. If FrameworkBundle is installed, `PantherTestCase` extends `WebTestCase`; with the Panther client, the crawler assertions work, but the response and request assertions do not work.
- [PHPUnit Bridge](../packages/phpunit-bridge.md): use it for deprecation reports and clock or DNS mocks; `KernelTestCase` and `WebTestCase` do not need it.
- [Clock](../packages/clock.md): in a `KernelTestCase` or a `WebTestCase`, `ClockSensitiveTrait::mockTime()` also changes the time of the `clock` service, because that service reads the global clock.
- [Dotenv](../packages/dotenv.md): the test bootstrap loads `.env`, `.env.test` and `.env.test.local`, but not `.env.local`.
- [FrameworkBundle](../packages/framework-bundle.md): the `framework.test` key of the bundle loads the test client and the test container.
- [MakerBundle](../packages/maker-bundle.md): `make:test` generates `KernelTestCase` and `WebTestCase` classes.
- [Form](../packages/form.md): use `TypeTestCase` to unit test a form type; if you cannot mock its dependencies, use `KernelTestCase` and the `form.factory` service.
- [UX Live Component](../packages/ux-live-component.md): `InteractsWithLiveComponents` works only in a test class that extends `KernelTestCase`, and by default it sends the component requests through the `test.client` service.
- [UX Twig Component](../packages/ux-twig-component.md): `InteractsWithTwigComponents` mounts or renders a component with the services of the test container, so it works only in a test class that extends `KernelTestCase`.
- [AI Bundle](../packages/ai-bundle.md): `AiAssertionsTrait` reads the `ai` profiler data of a `KernelBrowser` request in a `WebTestCase`.
- [Filesystem](../packages/filesystem.md): if the tests run with debug mode off, clear `var/cache/test` with `remove()` in `tests/bootstrap.php`.

## Changed in 8.0/8.1

- New in 8.1: `static::runCommand()` in `KernelTestCase` returns an `ExecutionResult`; check it with `$this->assertCommandIsSuccessful($result)`. Old: `new Application(self::$kernel)`, `new CommandTester($command)`, `execute()` and `getDisplay()`.
- New in 8.1: `self::assertSessionHasFlashMessage('success', 'Saved.')` checks the flash bag of the last request.
- New in 8.1: `static::getContainer()->set()` can replace a non-shared service, but only with a closure that acts as a factory, for example `fn () => $mock`.
- New in 7.4/8.0: `$client->getSession()` prepares the session, for example a CSRF token, before the request.
- New in 7.4/8.0: `assertBrowserHistoryIsOnFirstPage()`, `assertBrowserHistoryIsOnLastPage()` and the two `assertBrowserHistoryIsNot...()` methods.
- New in 7.4/8.0: `BrowserKitAssertionsTrait::setBrowserKitAssertionsAsVerbose(false)` removes the response body from the failure messages of the response assertions.
- New in 7.4/8.0: `assertEmailAddressNotContains()`.
- Removed in 8.0: `Request::get()`. Old: `$client->getRequest()->get('_route')`. New: `self::assertRouteSame('app_home')` or `$client->getRequest()->attributes->get('_route')`.

## Docs

- https://symfony.com/doc/current/testing.html (main page: KernelTestCase, WebTestCase, the test client and all assertion groups)
- https://symfony.com/doc/current/testing/profiling.html (profiler data in tests)
- https://symfony.com/doc/current/testing/insulating_clients.html (several clients, `ensureKernelShutdown()`, `insulate()`)
- https://symfony.com/doc/current/testing/bootstrap.html (custom `tests/bootstrap.php`)
- https://symfony.com/doc/current/testing/database.html (repository tests with `KernelTestCase`)
- https://symfony.com/doc/current/testing/dom_crawler.html (crawler in tests)
- https://symfony.com/doc/current/testing/end_to_end.html (Panther)
- https://symfony.com/doc/current/console.html (section "Testing Commands": `runCommand()`)
- https://symfony.com/doc/current/mailer.html (section "Write a Functional Test")
- https://symfony.com/doc/current/notifier.html (section "Testing Notifier")
- https://symfony.com/doc/current/http_client.html (section "Testing": `MockHttpClient`, `mock_response_factory`)
- https://symfony.com/doc/current/messenger.html (section "In Memory Transport")
- https://symfony.com/doc/current/best_practices.html (section "Smoke Test your URLs")
- https://symfony.com/doc/current/reference/configuration/framework.html (option `test`, profiler options)
