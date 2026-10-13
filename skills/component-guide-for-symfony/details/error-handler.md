# ErrorHandler (`symfony/error-handler`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Error handler:** The handler throws PHP warnings, notices and errors as `\ErrorException` objects, and it logs them with a PSR-3 logger. Deprecations never throw. The handler logs deprecations at the `info` level, also when the `@` operator silences them. In a Symfony application, the handler throws warnings and notices only if `framework.php_errors.throw` is true, which is the default in debug mode. `framework.php_errors.log` (default `true`) sends PHP errors to the application logger on the `php` channel. The value can also be an integer bit field of `E_*` constants, or an array that maps `E_*` constants to log levels. Do not use `E_STRICT` in this array, because the handler throws an `\InvalidArgumentException` for it. Entry point: `Symfony\Component\ErrorHandler\ErrorHandler::register()`.
- **Fatal errors and error hints:** At shutdown, the handler turns a fatal error into a `FatalError`, `OutOfMemoryError` or `MaxExecutionTimeError` object and gives it to the exception handler. In a web request of a Symfony application, the kernel then dispatches `kernel.exception` and renders the error page. The handler also replaces "undefined function", "undefined method" and "class not found" errors with `UndefinedFunctionError`, `UndefinedMethodError` and `ClassNotFoundError`. Their messages add hints, such as `Did you forget a "use" statement`. Entry point: `Symfony\Component\ErrorHandler\Error\FatalError`.
- **`Debug::enable()`:** In a development front controller without the Runtime component, this call registers all debug tools. It sets `error_reporting`, turns on assertions, enables `DebugClassLoader` and registers an `ErrorHandler` in debug mode. `SymfonyRuntime` registers the `ErrorHandler` in all modes, and it enables `DebugClassLoader` only in debug mode. Entry point: `Symfony\Component\ErrorHandler\Debug::enable()`.
- **Safe function calls:** `ErrorHandler::call()` calls a function and turns each PHP error of that function into an `\ErrorException`, also when the code uses the `@` operator. Entry point: `Symfony\Component\ErrorHandler\ErrorHandler::call()`.
- **DebugClassLoader:** It wraps the registered autoloaders. It throws a `\RuntimeException` if a file does not define the expected class, or if the class name and the file name differ in case. It triggers a deprecation when a class extends a `@final` class or uses an `@internal` or `@deprecated` type of another vendor. It also triggers a deprecation when a class does not implement a `@method` or a return type that a parent announces. Entry point: `Symfony\Component\ErrorHandler\DebugClassLoader::enable()`.
- **Return type patches:** `vendor/bin/patch-type-declarations` adds native return types from the `@return` annotations to the classes of the Composer class map, except the classes in `vendor/`. The `SYMFONY_PATCH_TYPE_DECLARATIONS` environment variable sets the mode, for example `force=2` (all methods) or `force=phpdoc` (only docblock annotations). Entry point: `vendor/bin/patch-type-declarations`.
- **Error renderers:** `ErrorRendererInterface::render()` turns a `\Throwable` into a `FlattenException` that holds the status code, the headers and the rendered body. `HtmlErrorRenderer` renders the debug exception page, or the generic "Oops! An Error Occurred" page when debug is off. `SerializerErrorRenderer` serializes the exception in the request format, and `CliErrorRenderer` renders it as terminal text. In a Symfony application, the `error_renderer` service is the `SerializerErrorRenderer` if the Serializer is enabled. This renderer uses the default renderer when the serializer cannot encode the request format. The default renderer is the `error_renderer.html` service (`HtmlErrorRenderer`, or `TwigErrorRenderer` with TwigBundle) when `kernel.runtime_mode.web` is true, and `error_renderer.cli` when it is false. Entry point: `Symfony\Component\ErrorHandler\ErrorRenderer\ErrorRendererInterface`.
- **`FlattenException`:** This class wraps an exception and its previous exceptions without objects in the trace, so code can serialize it. `createFromThrowable()` takes the status code and the headers from an `HttpExceptionInterface`, uses 400 for a `RequestExceptionInterface`, and uses 500 for all other exceptions. Entry point: `Symfony\Component\ErrorHandler\Exception\FlattenException::createFromThrowable()`.
- **Twig error templates:** With TwigBundle, `TwigErrorRenderer` renders `templates/bundles/TwigBundle/Exception/error<code>.html.twig`, or else `error.html.twig`, when debug is off. The templates get the variables `exception` (a `FlattenException`), `status_code` and `status_text`. If no template exists, the `HtmlErrorRenderer` page shows. Entry point: `Symfony\Bridge\Twig\ErrorRenderer\TwigErrorRenderer`.
- **Error page preview:** In `dev`, the routes of `@FrameworkBundle/Resources/config/routing/errors.php` with the prefix `/_error` show the production error page of a status code. Examples are `/_error/404` and `/_error/404.json`. The preview also works with a custom error controller. Entry point: route `_preview_error` (`ErrorController::preview()`).
- **Custom error controller:** `framework.error_controller` names the controller that `ErrorListener` calls in a sub-request for an uncaught exception. The controller gets the `exception` and `logger` arguments. If the `exception` argument has the type `FlattenException` or no type, `ErrorListener` converts the exception to a `FlattenException`. The default controller (`ErrorController`) renders the exception with the `error_renderer` service. Entry point: `framework.error_controller`.
- **IDE file links:** `framework.ide` or the `SYMFONY_IDE` environment variable sets the format of the file links on the exception page, for example `phpstorm` or `vscode`. Without a value, `FileLinkFormatter` uses the `xdebug.file_link_format` PHP setting, and then `file://%f#L%l`. Entry point: `framework.ide`.
- **Static error pages:** `error:dump <path> [status-codes]` writes the HTML error page of each given status code to `<path>/<code>.html`. Without status codes, it writes the pages of all 4xx and 5xx codes. Run the command with `APP_ENV=prod`. Configure the web server to serve these files. Entry point: `error:dump`.
- **Exception-to-status mapping (HttpKernel):** HttpKernel maps the exception to a status code before the renderer runs. A `status_code` in `framework.exceptions` has the highest priority. Next come the status code of an `HttpExceptionInterface` exception and `#[WithHttpStatus]` on the exception class, a parent class or an interface. Other exceptions get the status code 500. `#[WithLogLevel]` and the `log_level` option set the log level of the exception. Entry point: `Symfony\Component\HttpKernel\Attribute\WithHttpStatus`.

## Entry points

- `Symfony\Component\ErrorHandler\Debug::enable()`
- Without FrameworkBundle: call `Debug::enable()` in a development front controller without the Runtime component, or `ErrorHandler::register()` and `ErrorHandler::call()` in any PHP script.
- `Symfony\Component\ErrorHandler\ErrorHandler` (`register()`, `call()`, `throwAt()`, `setDefaultLogger()`)
- `Symfony\Component\ErrorHandler\DebugClassLoader` (`enable()`, `checkClasses()`; since 8.1, pass the namespace mapping to `enable()` as a positional argument, not as a named argument)
- `Symfony\Component\ErrorHandler\BufferingLogger`
- `Symfony\Component\ErrorHandler\Error\FatalError`, `OutOfMemoryError`, `MaxExecutionTimeError`, `ClassNotFoundError`, `UndefinedFunctionError`, `UndefinedMethodError`
- `Symfony\Component\ErrorHandler\ErrorRenderer\ErrorRendererInterface`, `HtmlErrorRenderer` (`setTemplate()`), `SerializerErrorRenderer`, `CliErrorRenderer`
- `Symfony\Component\ErrorHandler\ErrorRenderer\FileLinkFormatter` (autowiring alias of the `debug.file_link_formatter` service)
- `Symfony\Component\ErrorHandler\Exception\FlattenException`
- `Symfony\Bridge\Twig\ErrorRenderer\TwigErrorRenderer` (`symfony/twig-bridge`); templates `templates/bundles/TwigBundle/Exception/error<code>.html.twig` and `error.html.twig`; Twig variables `exception`, `status_code`, `status_text`
- `Symfony\Component\HttpKernel\Controller\ErrorController` (`__invoke()`, `preview()`) and `Symfony\Component\HttpKernel\EventListener\ErrorListener` (`symfony/http-kernel`)
- `Symfony\Component\HttpKernel\Attribute\WithHttpStatus`, `Symfony\Component\HttpKernel\Attribute\WithLogLevel`, `Symfony\Component\HttpKernel\Exception\HttpExceptionInterface` (`symfony/http-kernel`)
- `Symfony\Component\Serializer\Normalizer\ProblemNormalizer` (`symfony/serializer`)
- Service IDs: `error_renderer`, `error_renderer.html`, `error_renderer.serializer`, `error_renderer.cli`, `error_controller`
- Config keys: `framework.error_controller`, `framework.php_errors` (`log`, `throw`), `framework.ide`, `framework.exceptions` (`status_code`, `log_level`, `log_channel`), `framework.handle_all_throwables` (default `true`: the kernel also turns `\Error` objects into error responses)
- Parameters: `kernel.error_controller`, `debug.error_handler.throw_at`, `debug.file_link_format`
- Routes: `@FrameworkBundle/Resources/config/routing/errors.php` (`type: php`; route `_preview_error`, path `/{code}.{_format}`)
- Console command: `error:dump <path> [status-codes...] [--force]`
- Composer binary: `vendor/bin/patch-type-declarations` (environment variables `SYMFONY_PATCH_TYPE_DECLARATIONS` and `SYMFONY_PATCH_TYPE_EXCLUDE`)
- Environment variable: `SYMFONY_IDE`
- Request attribute: `showException` (`false` renders the production page in debug mode)
- Debug response headers: `X-Debug-Exception`, `X-Debug-Exception-File`
- Runtime option: `error_handler` (`symfony/runtime`)

## Symbiotic packages

- [HttpKernel](../packages/http-kernel.md): Its `ErrorListener` maps an exception to a status code and a log level, and its `ErrorController` renders the error page with an ErrorHandler renderer.
- [FrameworkBundle](../packages/framework-bundle.md): It configures the error handler at boot, defines the `error_renderer` services and the `error:dump` command, and gives the `framework.php_errors`, `framework.ide` and `framework.error_controller` options.
- [TwigBundle](../packages/twig-bundle.md): With the Twig Bridge, it renders the production error pages from Twig templates, and ErrorHandler renders the debug page.
- [Twig Bridge](../packages/twig-bridge.md): `TwigErrorRenderer` decorates `error_renderer.html` and uses `HtmlErrorRenderer` in debug mode or when no error template exists.
- [Serializer](../packages/serializer.md): If the Serializer is enabled, `SerializerErrorRenderer` renders errors in the request format, and `ProblemNormalizer` creates RFC 7807 problem details from the `FlattenException`.
- [Runtime](../packages/runtime.md): `SymfonyRuntime` registers the `ErrorHandler`, and `DebugClassLoader` in debug mode, so the front controller needs no `Debug::enable()` call.
- [VarDumper](../packages/var-dumper.md): ErrorHandler requires VarDumper, and the HTML and CLI renderers dump the exception with `HtmlDumper` and `CliDumper`.
- [PHPUnit Bridge](../packages/phpunit-bridge.md): The bridge enables `DebugClassLoader` in tests, so the test run reports the `@final`, `@internal`, `@deprecated` and `@method` deprecations; since 8.1, its `deprecations-namespaces-mapping` parameter sets the namespace mapping.
- [MonologBundle](../packages/monolog-bundle.md): The `php` channel receives the PHP errors, a `deprecation` channel (if you add one to `monolog.channels`) receives the deprecations, and the `request` channel receives the uncaught exceptions.
- [WebProfilerBundle](../packages/web-profiler-bundle.md): Its exception panel renders the exception with `HtmlErrorRenderer`, and it redefines the `debug.file_link_formatter` service.
- [DebugBundle](../packages/debug-bundle.md): DebugBundle configures the `dump()` output of VarDumper; use ErrorHandler, not DebugBundle, for PHP errors and error pages.
- [Console](../packages/console.md): `error:dump` is a Console command, and `DebugHandlersListener` renders an uncaught exception of a command with the Console application.
- [Messenger](../packages/messenger.md): `ErrorDetailsStamp` keeps the failure of a message as a `FlattenException`.
- [Notifier](../packages/notifier.md): `Notification::exception()` stores the exception as a `FlattenException`.
- [HttpFoundation](../packages/http-foundation.md): `FlattenException` takes the status text from `Response::$statusTexts`, and `SerializerErrorRenderer` uses `Request::getPreferredFormat()` as the output format.
- [WebpackEncoreBundle](../packages/webpack-encore-bundle.md): `error:dump` resets the Encore entrypoints before each page, so each static error page includes the assets.
- [Security](../packages/security-bundle.md): Because of the load order of routing and security, a 404 error page has no security data and shows the user as logged out.

## Changed in 8.0/8.1

- `resource: '@FrameworkBundle/Resources/config/routing/errors.xml'` (removed in 8.0) -> `resource: '@FrameworkBundle/Resources/config/routing/errors.php'` with `type: php`.
- `twig: { exception_controller: null }` (deprecated in 7.4; the option does not exist in 8.1) -> no option; `framework.error_controller` sets a custom controller.
- `DebugClassLoader::enable()` hides deprecations between `Acme\Library` and `Acme\Bundle`, because they share the first namespace segment -> `DebugClassLoader::enable(['Acme\Bundle' => 'Acme\Bundle', 'Acme\Library' => 'Acme\Library'])` (8.1).
- `@method` announcements only on interfaces -> `@method` also on abstract classes; a subclass without the method triggers a deprecation (8.1).
- A check of the `FatalError` message for "Maximum execution time" -> `$e instanceof MaxExecutionTimeError` (8.1).

## Docs

- https://symfony.com/doc/current/controller/error_pages.html
- https://symfony.com/doc/current/reference/configuration/framework.html
- https://symfony.com/doc/current/components/phpunit_bridge.html
- https://symfony.com/doc/current/components/runtime.html
- https://symfony.com/doc/current/components/http_kernel.html
- https://symfony.com/doc/current/reference/events.html
- https://symfony.com/doc/current/serializer.html
- https://github.com/symfony/error-handler
