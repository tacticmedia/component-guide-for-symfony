# ErrorHandler (`symfony/error-handler`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when an application or a script must show custom error pages, or turn PHP warnings and fatal errors into exceptions and log records. It renders each uncaught exception as an HTML page, a JSON or XML response, or terminal text. To map an exception to an HTTP status code or a log level, see [HttpKernel](http-kernel.md).

**Details:** [../details/error-handler.md](../details/error-handler.md)

## Why it exists

PHP reports warnings, notices and fatal errors outside of the exception flow, so a try-catch block cannot catch them. The package turns these errors into exceptions or PSR-3 log records. It also renders each uncaught exception as an HTML page, a serialized response in JSON, XML, CSV or YAML, or terminal text.

## When to use it

- Show a custom page for the 404, 403 and 500 errors in production.
- Return API errors as JSON or XML problem details instead of an HTML page.
- Preview a custom error page in the development environment without a real error.
- Turn the PHP warnings and notices of one function call into exceptions, also when the error control operator silences them.
- Report fatal errors, for example out of memory or a time limit, through the normal exception handler.
- Write static HTML error pages for the web server, for errors that occur before the request reaches the application.
- Enable the debug error handler and the class loader checks in a front controller that does not use [Runtime](runtime.md).
- Show an uncaught exception as readable text in a command-line script.
- Detect classes that extend a class marked final in its docblock, or use internal or deprecated types of other vendors.
- Add native return types to your classes from their docblock return annotations.

## Use it instead of

- A temporary `set_error_handler()` that throws, or `@file_get_contents($path)` followed by `error_get_last()` -> `ErrorHandler::call(fn () => file_get_contents($path))`, which throws an `\ErrorException`.
- `ini_set('display_errors', '1'); error_reporting(E_ALL);` in `public/index.php` -> `Debug::enable()`, or `SymfonyRuntime` in debug mode.
- `register_shutdown_function()` with `error_get_last()` to report fatal errors -> `ErrorHandler::register()`, which turns them into `FatalError` objects.
- A `kernel.exception` listener or a `try`/`catch` block in each controller that builds an HTML error `Response` -> Twig templates in `templates/bundles/TwigBundle/Exception/` (`TwigErrorRenderer`).
- A `try`/`catch` block in each API controller that returns `new JsonResponse(['error' => $e->getMessage()], 500)` -> `SerializerErrorRenderer` with `ProblemNormalizer`, or your own `FlattenException` normalizer, which must also implement `getSupportedTypes()`.
- `if ($e instanceof ProductNotFoundException) { $response->setStatusCode(404); }` in a listener -> `#[WithHttpStatus(404)]` on the exception class (HttpKernel).
- A temporary route that throws an exception to test the error page -> the preview URL `/_error/404` (route `_preview_error`).
- A hand-written `404.html` file for the web server -> `APP_ENV=prod php bin/console error:dump var/cache/prod/error_pages/`.
