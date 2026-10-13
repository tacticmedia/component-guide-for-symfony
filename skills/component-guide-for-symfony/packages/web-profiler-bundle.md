# WebProfilerBundle (`symfony/web-profiler-bundle`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when you must see what one web request or console command did during development, for example its database queries, logs, timing, emails and exceptions. It adds a debug toolbar to HTML pages and serves pages that show the stored data of each request. Functional tests can read the same data. To see variable dumps in the toolbar, see [DebugBundle](debug-bundle.md).

**Details:** [../details/web-profiler-bundle.md](../details/web-profiler-bundle.md)

## Why it exists

Printed debug data, such as SQL queries or timings, changes the page and is easy to forget in the code. The framework can store a debug profile for each request, and for each console command that runs with profiling. The package shows these profiles: it injects a debug toolbar into HTML pages and serves pages to browse and search them. Use it only in development, because these pages show source files, PHP information and environment variables without access control.

## When to use it

- See the SQL queries, log messages, timing and exceptions of a page in the development environment.
- Find the debug profile of a JSON API response or an AJAX request.
- Examine a request that ends with a redirect before the browser follows the redirect.
- Profile a console command or a queue worker run.
- Check the number of database queries or outgoing HTTP calls of a request in a functional test.
- Show your own debug data in the debug toolbar and in a panel of its own.
- Collect profiles only for some requests, for example the requests with a query parameter that asks for a profile.
- Find the deprecated calls of a request before an upgrade.
- Load or search stored profiles in PHP code.

## Use it instead of

- `dump($queries)`, `var_dump()` or a debug footer in `base.html.twig` that prints queries, timings or the current user -> the web debug toolbar and the profiler panels (`web_profiler.toolbar: true`).
- `dd($request->request->all())` before `return $this->redirectToRoute(...)` to see the data of a POST request -> `web_profiler.intercept_redirects: true`.
- A Doctrine middleware or SQL logger that counts the queries for a performance test -> `$client->enableProfiler()` and `$client->getProfile()->getCollector('db')->getQueryCount()`.
- A decorated HTTP client that records the sent requests for test assertions -> `$client->enableProfiler()` and `assertHttpClientRequest()` or `assertHttpClientRequestCount()`.
- `if ($request->query->has('debug')) { /* log details */ }` in a controller -> `framework.profiler.collect: false` with `collect_parameter: 'profile'`.
- `$start = microtime(true);` and `$output->writeln()` of the duration and the memory in a console command -> `php bin/console --profile -vvv app:my-command`.
- `file_put_contents('var/debug.log', print_r($data, true))` to examine the data of your own service for each request -> a collector that extends `AbstractDataCollector`, with a `getTemplate()` panel.
- A log of each API request and response to find a failed call in development -> the `X-Debug-Token-Link` response header and the search form of `/_profiler`.
- `grep -i deprecat var/log/dev.log` to find the deprecated calls before an upgrade -> the Deprecations count of the toolbar and the Deprecations tab of the Logs panel (`/_profiler/latest?panel=logger`).
