# Panther (`symfony/panther`)

**Applies to:** Panther 2.4

**Elevator pitch:** Use when tests or scrapers must run JavaScript in a real browser such as Chrome or Firefox, for example for end-to-end tests. It controls the browser through WebDriver, waits for elements and takes screenshots. If a page needs no JavaScript, see the faster [BrowserKit](browser-kit.md) or [FrameworkBundle test tools](framework-bundle-testing.md).

**Details:** [../details/panther.md](../details/panther.md)

## Why it exists

Clients that parse HTML in PHP do not run JavaScript, so they cannot test or scrape pages that JavaScript builds or changes. The package controls a real Chrome or Firefox browser through the W3C WebDriver protocol, with the API of [BrowserKit](browser-kit.md) and [DomCrawler](dom-crawler.md). In tests, it also starts your application on the PHP built-in web server, so that the browser can load it.

## When to use it

- Test a page that JavaScript changes, for example a page with [UX Turbo](ux-turbo.md), [UX Live Component](ux-live-component.md) or [StimulusBundle](stimulus-bundle.md).
- Wait in a test until JavaScript adds, removes, shows, hides or changes an element.
- Take a screenshot of a page, or keep a screenshot of each failed browser test.
- Read the browser console logs of a page in a test.
- Test a real-time feature, for example a chat over Mercure or WebSocket, with two isolated browsers.
- Scrape a website that renders its content with JavaScript.
- Run browser tests in CI or in a Docker container with a headless browser.
- Examine a failed browser test in a visible browser window before the test run continues.

## Use it instead of

- `sleep(3)` or a `usleep()` loop before you read an element that JavaScript adds -> `$client->waitFor('.result')` or `$this->assertSelectorWillExist('.result')`.
- A custom `$driver->wait()->until(...)` closure that checks if an element is visible or enabled -> `$client->waitForVisibility('.modal')`, `$client->waitForEnabled('[type="submit"]')` or `$this->assertSelectorWillBeVisible('.modal')`.
- `proc_open('php -S 127.0.0.1:8000 -t public')` plus `exec('chromedriver --port=9515 &')`, a `sleep()` until both answer, and a manual stop in `tearDown()` -> `PantherTestCase::createPantherClient()` with the `ServerExtension` PHPUnit extension.
- `RemoteWebDriver::create('http://localhost:4444', DesiredCapabilities::chrome())` with `findElement(WebDriverBy::cssSelector('…'))` calls -> `Client::createChromeClient()` with `request()`, `clickLink()`, `submitForm()` and `$crawler->filter()`.
- `file_get_contents('https://…')` or `HttpBrowser` on a page that builds its content with JavaScript -> `Client::createChromeClient()`, then `waitFor()` and `filter()`.
- A Puppeteer or Playwright script in Node.js that PHP starts with `exec()` -> `Symfony\Component\Panther\Client` in PHP.
- An `onNotSuccessfulTest()` override that saves a screenshot of a failed test -> the `ServerExtension` PHPUnit extension with `PANTHER_ERROR_SCREENSHOT_DIR`.
