# FrameworkBundle test tools (`symfony/framework-bundle`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when PHPUnit functional or integration tests must boot the application, send HTTP requests without a web server, mock dependencies or log in a user. It adds assertions for responses, HTML, emails, notifications, outgoing HTTP calls and console commands. To run JavaScript in a real browser, see [Panther](panther.md).

**Details:** [../details/framework-bundle-testing.md](../details/framework-bundle-testing.md)

## Why it exists

Tests of a full application need its objects with their real dependencies, and HTTP requests without a web server. Without these tools, tests start a real web server, parse HTML with regular expressions, or make private objects public. The package gives PHPUnit base classes, an in-process HTTP client, a dependency injection container for tests and many assertions.

## When to use it

- Test a class with its real dependencies from the dependency injection container.
- Replace a private object of the dependency injection container with a mock for one test.
- Check the status code, headers, redirect or HTML of a controller response.
- Test a page that requires a logged-in user, without a login form submission.
- Check the emails and notifications that a request or a class sends.
- Test a console command: its exit code, its output and its error output.
- Check the outgoing HTTP requests that the application sends during a request.
- Check a flash message, the matched route or a cookie after a request.

## Use it instead of

- `new Kernel('test', true)`, `$kernel->boot()` and `$kernel->getContainer()->get(Foo::class)`, which fails for private services -> `self::bootKernel()` and `static::getContainer()->get(Foo::class)` in a `KernelTestCase`.
- `public: true` on services only so that tests can get or replace them -> the test container: `static::getContainer()->set(Foo::class, $mock)`.
- A started web server plus `file_get_contents('http://127.0.0.1:8000/blog')`, `curl_init()` or Guzzle in a test -> `static::createClient()` and `$client->request('GET', '/blog')` in a `WebTestCase`.
- `$this->assertSame(200, $client->getResponse()->getStatusCode())` -> `self::assertResponseIsSuccessful()` or `self::assertResponseStatusCodeSame(201)`.
- `str_contains($client->getResponse()->getContent(), 'Hello')` or `preg_match('#<h1>(.*?)</h1>#', ...)` -> `self::assertSelectorTextContains('h1', 'Hello')`.
- `$client->submitForm('Sign in', ['_username' => ..., '_password' => ...])` at the start of each test -> `$client->loginUser($user)`.
- A spy mailer transport, or a file transport that the test parses -> `self::assertEmailCount(1)`, `self::getMailerMessage()` and `self::assertEmailHtmlBodyContains($email, 'Welcome')`.
- `exec('php bin/console app:create-user')`, a `Process`, or `new Application(self::$kernel)` plus `CommandTester::execute()` -> `$result = static::runCommand('app:create-user', ['username' => 'Wouter'])` and `$this->assertCommandIsSuccessful($result)`.
- `$client->getRequest()->getSession()->getFlashBag()->peek('success')` -> `self::assertSessionHasFlashMessage('success', 'Saved.')`.
- A decorator that records the calls of `HttpClientInterface` -> `$client->enableProfiler()` and `self::assertHttpClientRequest('https://api.example.com/orders', 'POST')`.
