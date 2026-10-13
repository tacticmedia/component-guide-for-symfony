# WebProfilerBundle (`symfony/web-profiler-bundle`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Installation and environments**: `composer require --dev symfony/profiler-pack` installs WebProfilerBundle and Stopwatch. The Flex recipe enables the bundle in the `dev` and `test` environments. For `dev`, it sets `web_profiler.toolbar: true` and `framework.profiler: true`, and it imports the `/_wdt` and `/_profiler` routes. For `test`, it sets only `framework.profiler.collect: false`, so the profiler exists but does not collect data. Entry point: `config/packages/web_profiler.yaml`.
- **Web debug toolbar**: `WebDebugToolbarListener` inserts the toolbar before the last `</body>` tag of the main response. The response must have a profile (`X-Debug-Token`), an HTML content type and the `html` request format. The listener does not inject the toolbar into redirects, `BinaryFileResponse` objects, attachments or AJAX responses. If the toolbar does not show, make sure that the page has a `</body>` tag, for example from `base.html.twig`. Since 8.1, the listener also injects the toolbar into a `StreamedResponse`. If the response has a `Content-Security-Policy` header, the listener adds the nonces of the toolbar scripts and styles to it. Entry point: `web_profiler.toolbar`.
- **Profiler pages**: `/_profiler` lists the last 10 request profiles. The search form filters the profiles by token, IP, URL, method, status code, date range and type (`request` or `command`). `/_profiler/{token}` opens one profile, and `/_profiler/latest` opens the newest profile. The query parameter `panel` opens one panel, for example `?panel=logger`. The query parameter `type=command` makes `latest` select the newest console profile. Entry point: route `_profiler`.
- **Panels and data collectors**: Each panel shows the data of one data collector. FrameworkBundle adds the Request / Response, Performance, Exception, Logs, Events, Routing, Cache, Configuration and Console Command panels. Enabled components add Forms, Validator, Translation, Messages, Emails, HTTP Client, Notifications, Serializer and Workflow. SecurityBundle adds Security, TwigBundle adds Twig, DebugBundle adds Debug, and DoctrineBundle adds the `db` panel. A command profile has no Request / Response and Routing panels. Entry point: `php bin/console debug:container --tag=data_collector`.
- **API and AJAX requests**: The profiler adds the `X-Debug-Token` header to each response that it profiles. If the toolbar or `intercept_redirects` is enabled, the bundle also adds `X-Debug-Token-Link`, the absolute URL of the profile. The toolbar lists the `fetch()`, XHR and `EventSource` requests of the page, except the URLs that match `excluded_ajax_paths`. With `ajax_replace: true`, the toolbar shows the data of each new AJAX request instead of the first page. The bundle sets the `Symfony-Debug-Toolbar-Replace: 1` header only on requests with `X-Requested-With: XMLHttpRequest`. For other requests, set this header in a `kernel.response` listener with `#[When(env: 'dev')]`. Entry point: `web_profiler.toolbar.ajax_replace`.
- **Redirect interception**: If `web_profiler.intercept_redirects` is `true`, the listener replaces the redirect of an HTML request with a page. This page shows the target URL and the toolbar of the redirect response. Click the link on that page to follow the redirect. Entry point: `web_profiler.intercept_redirects`.
- **Programmatic access**: The `profiler` service loads a profile with `loadProfileFromResponse($response)` or `loadProfile($token)`. `find($ip, $url, $limit, $method, $start, $end, $statusCode, $filter)` returns the newest matching profiles as arrays with a `token` key. A URL filter that starts with `!` excludes the matching URLs. The container has no autowiring alias for `Profiler`. Add `Symfony\Component\HttpKernel\Profiler\Profiler: '@profiler'` under `when@dev: services:`, and type the argument `?Profiler`. Entry point: `Symfony\Component\HttpKernel\Profiler\Profiler`.
- **Conditional collection**: `$profiler->disable()` and `$profiler->enable()` change the collection for the current request. `framework.profiler.collect: false` turns off the collection by default. With `collect_parameter: 'profile'`, a request collects data if its attribute, query parameter or body parameter `profile` is `true`, `yes`, `on` or `1`. If `collect` is `true`, another value of that parameter stops the collection. `only_exceptions` and `only_main_requests` limit the collection to requests with an exception or to main requests. Entry point: `framework.profiler.collect_parameter`.
- **Console command profiles**: `php bin/console --profile app:my-command` saves a profile of the command. The option needs debug mode, `symfony/stopwatch` and `framework.profiler`. If one of them is missing, the command shows a warning and runs without a profile. If `framework.profiler.collect` is `false`, the command saves no profile. With `-v`, the command prints a link to the profile, and with `-vvv`, it also prints the time and the memory. For `messenger:consume`, add `--no-reset`, or you get no profile. Add `--limit` to process only a few messages. Entry point: `--profile`.
- **Profiles in functional tests**: The `test` environment keeps the profiler with `collect: false`. `$client->enableProfiler()` collects data for the next request only, and only if the `profiler` service exists. `$client->getProfile()` returns the `Profile`. It returns `false` if the container has no profiler, and `null` if the response has no profile. Read a collector by its ID, for example `$profile->getCollector('db')->getQueryCount()` or `$profile->getCollector('time')->getDuration()`. If the request has no profile, the HttpClient assertions of `WebTestCase` fail. Call `enableProfiler()` before the request. Entry point: `Symfony\Bundle\FrameworkBundle\KernelBrowser::enableProfiler()`.
- **Custom data collector**: Extend `AbstractDataCollector`. In `collect()`, store the data in `$this->data`. `collect()` runs on `kernel.response`. For data that is ready later, implement `LateDataCollectorInterface::lateCollect()`, which runs before the profiler saves the profile on `kernel.terminate`. Autoconfiguration adds the `data_collector` tag without attributes to each `DataCollectorInterface` service. Without an `id` attribute, the profiler shows the toolbar item and the panel only if `getName()` returns the class name (the default). If `getName()` returns a short ID, tag the service `data_collector` with an `id` attribute equal to that ID. The `template` attribute has priority over `getTemplate()`. A higher `priority` attribute (default `0`) shows the item earlier in the toolbar and in the panel menu. Entry point: `Symfony\Bundle\FrameworkBundle\DataCollector\AbstractDataCollector`.
- **Collector data**: The profiler serializes each collector into the profile file. Do not store objects that cannot be serialized, such as a PDO connection. Use `$this->cloneVar($value)` for a value that the panel shows with `profiler_dump()`. `reset()` empties `$this->data` between requests. If a traceable service records data for a collector, inject `profiler.is_disabled_state_checker`. Do not record data when this `Closure` returns `true`. Entry point: `Symfony\Component\HttpKernel\DataCollector\DataCollector::cloneVar()`.
- **Collector templates**: The static method `getTemplate()` returns the Twig template of the collector. The template extends `@WebProfiler/Profiler/layout.html.twig`. The `toolbar` block sets the `icon` and `text` variables and includes `@WebProfiler/Profiler/toolbar_item.html.twig`. For a toolbar item without a panel, pass `link: false`. To color the item, pass `status: 'red'` or `status: 'yellow'`. The `menu` and `panel` blocks define the profiler panel. The `head` block adds CSS or JavaScript; call `parent()` in it. All blocks get the `collector` variable. Entry point: `@WebProfiler/Profiler/layout.html.twig`.
- **Profile storage**: The profiler stores the profiles as files in `%kernel.cache_dir%/profiler`. Only the `file:` DSN works, and another driver causes a `LogicException`. When the storage saves a new profile, it deletes the profiles that are older than 2 days, with a probability of 1 in 10. Entry point: `framework.profiler.dsn`.
- **Production warning**: The docs say: never enable the profiler in production, because it causes major security vulnerabilities. In the `prod` environment, `WebProfilerBundle::boot()` triggers an `E_USER_WARNING`. The pages show `phpinfo()` (`/_profiler/phpinfo`), project files (`/_profiler/open`) and the server parameters with the values of environment variables. The recommended `dev` firewall (`^/(_profiler|_wdt|assets|build)/`, `security: false`) turns off security for these URLs; it does not protect them. Symfony handles vulnerabilities in the web profiler as regular bugs, not as security issues. Entry point: `config/bundles.php` (`['dev' => true, 'test' => true]`).

## Entry points

- `Symfony\Bundle\WebProfilerBundle\WebProfilerBundle`: register it for `dev` and `test` only. Install it with `composer require --dev symfony/profiler-pack` (Flex alias `profiler`). It requires PHP 8.4.1 or later, Config, FrameworkBundle, TwigBundle, Routing and `symfony/http-kernel` ^8.1.
- Config root `web_profiler`: `toolbar.enabled` (default `false`), `toolbar.ajax_replace` (`false`), `intercept_redirects` (`false`), `excluded_ajax_paths` (`^/((index|app(_[\w]+)?)\.php/)?_wdt`). Show the values with `php bin/console config:dump-reference web_profiler` or `debug:config web_profiler`.
- Config key `framework.profiler`: `enabled` (default `false`), `collect` (`true`), `collect_parameter` (`null`), `only_exceptions` (`false`), `only_main_requests` (`false`), `dsn` (`file:%kernel.cache_dir%/profiler`).
- Route files: `@WebProfilerBundle/Resources/config/routing/wdt.php` (prefix `/_wdt`) and `@WebProfilerBundle/Resources/config/routing/profiler.php` (prefix `/_profiler`). In a `MicroKernelTrait` kernel, import both files in `configureRoutes()`.
- Route names: `_wdt`, `_profiler_home`, `_profiler`, `_profiler_search`, `_profiler_search_results`, `_profiler_phpinfo`, `_profiler_xdebug`, `_profiler_open_file`, `_profiler_router`, `_profiler_exception`.
- Service `profiler`: `Symfony\Component\HttpKernel\Profiler\Profiler` (`loadProfileFromResponse()`, `loadProfile()`, `find()`, `enable()`, `disable()`, `isEnabled()`). It has no autowiring alias.
- `Symfony\Component\HttpKernel\Profiler\Profile`: `getToken()`, `getCollector()`, `hasCollector()`, `getCollectors()`, `getChildren()`, `hasErrors()`.
- Service `profiler.is_disabled_state_checker`: a `Closure` that returns `true` when the profiler is disabled.
- Data collector types: `Symfony\Component\HttpKernel\DataCollector\DataCollectorInterface`, `Symfony\Component\HttpKernel\DataCollector\DataCollector`, `Symfony\Component\HttpKernel\DataCollector\LateDataCollectorInterface`, `Symfony\Bundle\FrameworkBundle\DataCollector\AbstractDataCollector`, `Symfony\Bundle\FrameworkBundle\DataCollector\TemplateAwareDataCollectorInterface`.
- Service tag `data_collector`: attributes `id`, `template`, `priority`.
- Collector IDs for `getCollector()`: `request`, `time`, `memory`, `ajax`, `exception`, `logger`, `events`, `router`, `cache`, `config`, `command`, `form`, `validator`, `translation`, `messenger`, `mailer`, `http_client`, `notifier`, `serializer`, `workflow`, `security`, `twig`, `dump`, `db` (DoctrineBundle).
- Twig: the templates `@WebProfiler/Profiler/layout.html.twig` and `@WebProfiler/Profiler/toolbar_item.html.twig`, and the function `profiler_dump()`.
- Twig filters of the `twig.extension.code` service, only where the bundle is enabled: `abbr_class`, `abbr_method`, `file_excerpt`, `file_link`, `file_relative`, `format_args`, `format_args_as_text`, `format_file`, `format_file_from_text`.
- Console: the global option `--profile` of the FrameworkBundle console application, and `php bin/console debug:container --tag=data_collector`.
- Test helpers: `Symfony\Bundle\FrameworkBundle\KernelBrowser::enableProfiler()` and `getProfile()`. In a `WebTestCase`: `assertHttpClientRequest()`, `assertNotHttpClientRequest()`, `assertHttpClientRequestCount()` (`Symfony\Bundle\FrameworkBundle\Test\HttpClientAssertionsTrait`).
- HTTP headers: `X-Debug-Token`, `X-Debug-Token-Link`, `Symfony-Debug-Toolbar-Replace`.
- All classes of the bundle are internal, and `WebDebugToolbarListener` is `@final`. Do not extend them or call them from application code.

## Symbiotic packages

- [FrameworkBundle](../packages/framework-bundle.md): `framework.profiler` creates the `profiler` service and the core data collectors; WebProfilerBundle requires FrameworkBundle and shows the collected data.
- [HttpKernel](../packages/http-kernel.md): HttpKernel provides `Profiler`, `Profile`, the file storage, `ProfilerListener` and `DataCollectorInterface`; WebProfilerBundle 8.1 requires `symfony/http-kernel` ^8.1.
- [TwigBundle](../packages/twig-bundle.md): The bundle renders the toolbar and the panels with Twig, and TwigBundle adds the `twig` collector for the Twig panel.
- [Routing](../packages/routing.md): The bundle requires Routing for the `/_wdt` and `/_profiler` routes, and the Routing panel shows the match trace of each route for the request.
- [Stopwatch](../packages/stopwatch.md): Stopwatch events show on the timeline of the Performance panel, and `--profile` needs `symfony/stopwatch`; `symfony/profiler-pack` installs both packages.
- [DebugBundle](../packages/debug-bundle.md): DebugBundle adds the `dump` collector, so `dump()` output shows in the toolbar and in the Debug panel; `symfony/debug-pack` installs DebugBundle, MonologBundle and `symfony/profiler-pack`.
- [VarDumper](../packages/var-dumper.md): `cloneVar()` stores values as VarDumper `Data` objects, and `profiler_dump()` renders them in a panel.
- [FrameworkBundle test tools](../packages/framework-bundle-testing.md): `KernelBrowser::enableProfiler()`, `getProfile()` and the HttpClient assertions read the profile of a request in a functional test.
- [Console](../packages/console.md): The `--profile` option of the FrameworkBundle console application profiles a command, and 8.1 adds the argument value resolvers to the Performance panel.
- [Messenger](../packages/messenger.md): The Messages panel shows the dispatched messages; to profile `messenger:consume`, add `--no-reset` and `--limit`.
- [MonologBundle](../packages/monolog-bundle.md): The Logs panel shows the log records of the request, and MonologBundle reserves the handler name `debug` for the profiler.
- [Monolog Bridge](../packages/monolog-bridge.md): When the profiler is enabled, FrameworkBundle adds the bridge `DebugProcessor` to the Monolog loggers, and the Logs panel reads its records.
- [Doctrine Bridge](../packages/doctrine-bridge.md): DoctrineBundle registers the `db` collector on the bridge `DoctrineDataCollector`, which provides `getQueryCount()` for tests.
- [Security](../packages/security-bundle.md): SecurityBundle adds the Security panel; its recommended `dev` firewall turns off security for `/_profiler` and `/_wdt`, so firewalls do not block them.
- [HttpClient](../packages/http-client.md): The HTTP Client panel lists the requests of each traceable client, and the HttpClient test assertions read the `http_client` collector.
- [Mailer](../packages/mailer.md): The Emails panel shows the emails of a request from the `mailer` collector.
- [Notifier](../packages/notifier.md): If Notifier is enabled, the profiler adds the Notifications panel (`notifier` collector).
- [Form](../packages/form.md): If Form is enabled, the profiler adds the Forms panel (`form` collector).
- [Validator](../packages/validator.md): If validation is enabled, the profiler adds the Validator panel (`validator` collector).
- [Translation](../packages/translation.md): If the translator is enabled, a data collector decorates the `translator` service for the Translation panel.
- [Serializer](../packages/serializer.md): If Serializer is enabled, the profiler adds the Serializer panel (`serializer` collector).
- [Workflow](../packages/workflow.md): If workflows are configured, the profiler adds the Workflow panel (`workflow` collector).
- [Cache](../packages/cache.md): The Cache panel shows the calls to the traceable cache pools (`cache` collector).
- [EventDispatcher](../packages/event-dispatcher.md): The Events panel shows the called listeners, the not called listeners and the orphaned events of the request (`events` collector).
- [ErrorHandler](../packages/error-handler.md): The Exception panel renders the exception with the `HtmlErrorRenderer` of ErrorHandler, which FrameworkBundle registers as the `error_handler.error_renderer.html` service.
- [Symfony Flex](../packages/flex.md): The alias `profiler` installs `symfony/profiler-pack`, and the recipe writes `config/packages/web_profiler.yaml` and `config/routes/web_profiler.yaml`.
- [Mercure](../packages/mercure.md): In debug mode, if `symfony/stopwatch` is installed, MercureBundle registers the `mercure` collector and its panel.
- [UX Twig Component](../packages/ux-twig-component.md): `twig_component.profiler.enabled` (default `%kernel.debug%`) adds the `twig_component` collector and its panel.
- [AI Bundle](../packages/ai-bundle.md): The AI Bundle registers the `ai` collector for its traceable platforms, agents, tools and stores, and `AiAssertionsTrait` reads it from `$client->getProfile()`.
- [MCP Bundle](../packages/mcp-bundle.md): The MCP Bundle registers the `mcp` collector, which shows the capabilities of the MCP servers.
- [AI Mate](../packages/ai-mate.md): A coding agent runs the Mate tools `symfony-profiler-list` and `symfony-profiler-get` of `symfony/ai-symfony-mate-extension` with `vendor/bin/mate tools:call` to read the profiles in `var/cache/dev/profiler`.

## Changed in 8.0/8.1

- 8.0: The XML routing files `wdt.xml` and `profiler.xml` are removed. Import `@WebProfilerBundle/Resources/config/routing/wdt.php` and `profiler.php` instead.
- 8.0: XML configuration and the fluent PHP config builders are removed, for example `<web-profiler:toolbar ajax-replace="true"/>` and `$profiler->toolbar()->ajaxReplace(true)`. Use YAML or `App::config(['web_profiler' => [...]])`.
- 8.0: Data collectors use `__serialize()` and `__unserialize()` instead of `__sleep()` and `__wakeup()`. `DataCollector` provides both methods.
- 8.1: `framework.profiler.collect_serializer_data` is deprecated and has no effect. Remove it, also from `when@test` (the 7.3 recipe added it).
- 8.1: The toolbar works on `StreamedResponse` pages. Do not buffer a streamed HTML page only to see the toolbar.
- 8.1: `Profile::hasErrors()` is new. The profile list marks the profiles with exceptions or error-level log records.
- 8.1: With `--profile`, the Performance panel shows the duration of each console argument value resolver.
- 8.1: The toolbar forwards its CSP nonces to the `dump()` output (`DumpDataCollector::setNonce()`) instead of disabling CSP.

## Docs

- https://symfony.com/doc/current/profiler.html
- https://symfony.com/doc/current/reference/configuration/web_profiler.html
- https://symfony.com/doc/current/testing/profiling.html
- https://symfony.com/doc/current/reference/configuration/framework.html
- https://symfony.com/doc/current/console.html
- https://symfony.com/doc/current/testing.html
- https://symfony.com/doc/current/performance.html
- https://symfony.com/doc/current/security.html
- https://symfony.com/doc/current/reference/twig_reference.html
