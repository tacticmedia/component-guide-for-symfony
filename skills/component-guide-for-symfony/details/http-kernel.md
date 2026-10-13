# HttpKernel (`symfony/http-kernel`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Kernel events:** `HttpKernel::handle()` dispatches `kernel.request`, `kernel.controller` and `kernel.controller_arguments`, calls the controller, and then dispatches `kernel.response` and `kernel.finish_request`. If the controller does not return a `Response`, a `kernel.view` listener must create the response. If a `kernel.request` listener sets a response, the kernel does not call the controller. A `kernel.exception` listener can set the error response. If this response has no error or redirect status, the kernel sets the exception status or 500. To keep the status, call `$event->allowCustomResponseCode()` in the listener. `kernel.terminate` runs after `$response->send()`. Entry point: `Symfony\Component\HttpKernel\KernelEvents`.
- **Controller attribute events (8.1):** For each attribute of the controller class or method, `ControllerAttributesListener` dispatches an event named `<kernel event>.<attribute FQCN>`, for example `kernel.controller_arguments.App\Attribute\Audit`. It does this for `kernel.controller`, `kernel.controller_arguments`, `kernel.view`, `kernel.response`, `kernel.exception` and `kernel.finish_request`. A listener for this event gets `$event->attribute` and the original event in `$event->kernelEvent`. To evaluate an `Expression` or a closure that the attribute contains, call `$event->evaluate()`. `ControllerAttributesListener` also dispatches events for the parent classes and the interfaces of the attribute. On `kernel.view`, `kernel.response`, `kernel.exception` and `kernel.finish_request` events, use `$event->controllerMetadata?->getAttributes()`. The docs show `ResponseEvent::getControllerAttributes()`. This method does not exist. Entry point: `Symfony\Component\HttpKernel\Event\ControllerAttributeEvent`.
- **Controllers as services:** `#[AsController]` adds the `controller.service_arguments` tag to a class, so that each action can receive services as arguments. FrameworkBundle adds the same tag to `AbstractController` subclasses and to classes that use `#[Route]`. `AbstractController::forward()` sends a sub-request to another controller. Entry point: `Symfony\Component\HttpKernel\Attribute\AsController`.
- **Built-in value resolvers:** The kernel gives the `Request`, the session and the route parameters to the controller arguments, by type or by name. Backed enum, `Uid` and `DateTimeInterface` arguments receive the converted route parameter, and `#[MapDateTime(format: 'Y-m-d')]` sets the date format. If a typed route parameter is not valid, the response is 404. Since 8.1, this rule also applies to `int`, `float`, `bool` and `string` arguments. Entry point: `Symfony\Component\HttpKernel\Attribute\MapDateTime`.
- **Custom value resolvers:** `ValueResolverInterface::resolve()` returns the values for one argument, or an empty array when the next resolver must try. FrameworkBundle adds the `controller.argument_value_resolver` tag to each implementation. On an argument, `#[ValueResolver(MyResolver::class)]` limits the resolvers to this one, the request attributes and the default value. `disabled: true` disables one resolver for the argument. `#[AsTargetedValueResolver]` removes a resolver from the general list, so it runs only for arguments that name it. Entry point: `Symfony\Component\HttpKernel\Controller\ValueResolverInterface`.
- **Query string attributes:** `#[MapQueryParameter]` maps one query parameter to an `int`, `float`, `bool`, `string`, `array`, backed enum or `Uid` argument. Its `filter`, `flags` and `options` arguments go to `filter_var()`. `#[MapQueryString]` maps all query parameters to a DTO and validates the DTO. If a value is not valid, both attributes give a 404 response, and `validationFailedStatusCode` changes this status. If a `Uid` value is not valid, `#[MapQueryParameter]` does not give 404. It throws `Symfony\Component\Uid\Exception\InvalidArgumentException`, which gives a 500 response. Entry point: `Symfony\Component\HttpKernel\Attribute\MapQueryParameter`.
- **Request payload attributes:** `#[MapRequestPayload]` maps a JSON, XML or form body to a DTO and validates the DTO. To map a list of DTOs, type the argument as `array` and set `type:`. An unsupported format gives 415, a body that is not valid gives 400, and a validation failure gives 422. `#[MapUploadedFile]` gives an `UploadedFile` argument and validates the file with `constraints:`. Entry point: `Symfony\Component\HttpKernel\Attribute\MapRequestPayload`.
- **Request header attribute (8.1):** `#[MapRequestHeader]` maps one header to a `string`, `array` or `AcceptHeader` argument. The argument name gives the header name, so `$acceptLanguage` reads `Accept-Language`. For `Accept`, `Accept-Charset`, `Accept-Encoding` and `Accept-Language`, an `array` argument receives the parsed values. If the header is missing, the argument receives its default value. If the default value is missing or `null`, an `array` or `?array` argument receives `[]`, and any other nullable argument receives `null`. Otherwise, the response is 400. Entry point: `Symfony\Component\HttpKernel\Attribute\MapRequestHeader`.
- **HTTP exceptions and status codes:** Throw an `HttpException` subclass, such as `NotFoundHttpException`, or call `HttpException::fromStatusCode()`. The kernel uses the status code and the headers of this exception for the error response. Other exceptions give 500, and `RequestExceptionInterface` exceptions from HttpFoundation give 400. `#[WithHttpStatus]` and `#[WithLogLevel]` on an exception class, a parent class or an interface set the status code and the log level. `#[WithHttpStatus]` has no effect on an `HttpExceptionInterface` exception. The `framework.exceptions` option sets `status_code`, `log_level` and `log_channel` for each class and has priority over the attributes. By default, 5xx and non-HTTP exceptions log as `critical`, and 4xx exceptions log as `error`. Entry point: `Symfony\Component\HttpKernel\Attribute\WithHttpStatus`.
- **`#[Cache]` attribute:** `#[Cache]` sets `Cache-Control` directives, `Expires`, `Vary`, `ETag` and `Last-Modified` on the controller response. `etag`, `lastModified` and the 8.1 option `if` accept an expression or, since 8.1, a closure. Expressions can use `request`, `args`, `this`, the request attributes and the argument names. A closure receives the arguments array, the `Request` and the controller object, in this order. Closures in attributes need PHP 8.5 and must be `static function` closures, not arrow functions. If the request has a matching `If-None-Match` or `If-Modified-Since` header, the kernel returns 304 and does not call the controller. The attribute does not replace a header value that the controller sets. To select a cache policy by condition, repeat the attribute with `if` conditions that exclude each other. Entry point: `Symfony\Component\HttpKernel\Attribute\Cache`.
- **Reverse proxy:** If `framework.http_cache` is enabled, `Kernel::handle()` sends each main request through `HttpCache`, a PHP reverse proxy with a file store. In debug mode, the `X-Symfony-Cache` header shows what the cache did. On a cache hit, `kernel.terminate` does not run. To purge entries, override `invalidate()` in a subclass of the FrameworkBundle `HttpCache`. In this method, call `$this->getStore()->purge($request->getUri())`. Register the subclass as a decorator of the `http_cache` service. If code uses the session during the request, the kernel makes the response private, unless the response has the `AbstractSessionListener::NO_AUTO_CACHE_CONTROL_HEADER` header. Entry point: `Symfony\Bundle\FrameworkBundle\HttpCache\HttpCache`.
- **ESI, SSI and fragments:** In Twig, `render_esi(controller('App\\Controller\\NewsController::latest'))` embeds a controller response that the reverse proxy caches separately. `render_ssi()` does the same with SSI, and `render()` renders the sub-request inline. If the proxy does not support ESI or SSI, the renderer renders the fragment inline. For ESI and SSI, pass only scalar values or arrays of scalar values to `controller()`. For a `controller()` reference, the proxy gets the fragment from a signed URL under `/_fragment`. Enable `framework.fragments` to handle these URLs. With this option, `FragmentListener` rejects an unsigned main request to this path with 403. The fragment controller must use `#[AsController]` or `#[Route]`, extend `AbstractController`, or have the `controller.service_arguments` tag. Entry point: `framework.esi`, `framework.ssi` and `framework.fragments`.
- **`#[RateLimit]` (8.1):** `#[RateLimit('api')]` consumes a token from the `api` limiter of `framework.rate_limiter` before the controller runs. The default key is the client IP, the HTTP method and the path. `key` accepts a literal string, an `Expression` object or a closure, and `tokens` sets the cost of one request. `methods` limits the attribute to some HTTP methods, and `GET` also covers `HEAD`. Stack several attributes to combine limits; each limit must pass. If a limit is reached, the response is 429 with a `Retry-After` header. Entry point: `Symfony\Component\HttpKernel\Attribute\RateLimit`.
- **`#[Serialize]` (8.1):** On a controller method, `#[Serialize]` serializes the return value with the Serializer. The format is the request format, or `json` when the request has no format. The attribute sets the `Content-Type` header. `code` and `headers` set the response status and headers, and `context` goes to the Serializer. An unsupported format gives 415. Entry point: `Symfony\Component\HttpKernel\Attribute\Serialize`.
- **`#[IsSignatureValid]`:** `#[IsSignatureValid]` checks the URL signature with `UriSigner::verify()` before the controller runs. A missing or wrong signature gives 404, and an expired signature gives 403. `methods` limits the check to some HTTP methods, and `GET` also covers `HEAD`. Entry point: `Symfony\Component\HttpKernel\Attribute\IsSignatureValid`.

## Entry points

- `Symfony\Component\HttpKernel\HttpKernelInterface` (service `http_kernel`): `handle()` with `HttpKernelInterface::MAIN_REQUEST` or `HttpKernelInterface::SUB_REQUEST`
- `Symfony\Component\HttpKernel\KernelInterface` (service `kernel`) and `Symfony\Component\HttpKernel\Kernel` (base class of the application kernel)
- `Symfony\Component\HttpKernel\KernelEvents` and the events in `Symfony\Component\HttpKernel\Event\`: `RequestEvent`, `ControllerEvent`, `ControllerArgumentsEvent`, `ViewEvent`, `ResponseEvent`, `FinishRequestEvent`, `ExceptionEvent`, `TerminateEvent`, `ControllerAttributeEvent`
- Attributes in `Symfony\Component\HttpKernel\Attribute\`: `AsController`, `ValueResolver`, `AsTargetedValueResolver`, `MapQueryParameter`, `MapQueryString`, `MapRequestPayload`, `MapUploadedFile`, `MapRequestHeader`, `MapDateTime`, `WithHttpStatus`, `WithLogLevel`, `Cache`, `RateLimit`, `Serialize`, `IsSignatureValid`
- `Symfony\Component\HttpKernel\Controller\ValueResolverInterface` (tags `controller.argument_value_resolver` and `controller.targeted_value_resolver`)
- `Symfony\Component\HttpKernel\Exception\HttpException`, its subclasses (for example `NotFoundHttpException`, `AccessDeniedHttpException`, `BadRequestHttpException`) and `HttpExceptionInterface`
- `Symfony\Bundle\FrameworkBundle\HttpCache\HttpCache` (extend it to purge entries) and `Symfony\Component\HttpKernel\HttpCache\StoreInterface` (service `http_cache.store`)
- `Symfony\Component\HttpKernel\CacheWarmer\CacheWarmerInterface` and `Symfony\Component\HttpKernel\CacheClearer\CacheClearerInterface` (tags `kernel.cache_warmer` and `kernel.cache_clearer`, added by autoconfiguration)
- `Symfony\Component\HttpKernel\Bundle\AbstractBundle` (`configure()`, `loadExtension()`, `prependExtension()`)
- Config: `framework.http_cache`, `framework.esi`, `framework.ssi`, `framework.fragments` (`path`, `hinclude_default_template`), `framework.exceptions`, `framework.error_controller`, `framework.handle_all_throwables`
- Service tag: `controller.service_arguments`
- Constant: `Symfony\Component\HttpKernel\EventListener\AbstractSessionListener::NO_AUTO_CACHE_CONTROL_HEADER`
- Twig functions: `render()`, `render_esi()`, `render_ssi()`, `render_hinclude()`, `controller()`, `fragment_uri()`
- Console: `php bin/console debug:event-dispatcher kernel.request` (listeners and priorities); in debug mode, `php bin/console debug:container debug.argument_resolver.inner` (value resolvers)
- Tests: `Symfony\Component\HttpKernel\HttpKernelBrowser` (FrameworkBundle `KernelBrowser` extends it)

## Symbiotic packages

- [HttpFoundation](../packages/http-foundation.md): HttpKernel converts a `Request` into a `Response`, and `UriSigner`, `AcceptHeader` and `UploadedFile` also come from HttpFoundation.
- [EventDispatcher](../packages/event-dispatcher.md): The kernel dispatches its events through the event dispatcher, and `#[AsEventListener]` registers a listener for a kernel event.
- [Routing](../packages/routing.md): `RouterListener` stores the matched route parameters as request attributes, and value resolvers convert them into typed controller arguments.
- [FrameworkBundle](../packages/framework-bundle.md): FrameworkBundle registers the kernel services, the `framework.*` options, `AbstractController` and the `HttpCache` base class.
- [Serializer](../packages/serializer.md): `#[MapRequestPayload]`, `#[MapQueryString]` and `#[Serialize]` need the Serializer to convert request data and return values.
- [Validator](../packages/validator.md): The Validator validates the DTOs of `#[MapRequestPayload]` and `#[MapQueryString]` and the files of `#[MapUploadedFile]`.
- [ExpressionLanguage](../packages/expression-language.md): Expressions in `#[Cache]`, `#[RateLimit]` and the `validationGroups` option need ExpressionLanguage.
- [RateLimiter](../packages/rate-limiter.md): `#[RateLimit]` consumes tokens from a limiter that `framework.rate_limiter` defines.
- [ErrorHandler](../packages/error-handler.md): The error controller renders a `FlattenException`, and the `error:dump` command writes the error pages to static HTML files.
- [Twig Bridge](../packages/twig-bridge.md): `render()`, `render_esi()`, `render_ssi()` and `controller()` embed fragments in Twig, and `#[Template]` renders a template on the `kernel.view` event.
- [TwigBundle](../packages/twig-bundle.md): With the Twig Bridge, TwigBundle renders the error page of a status code from a template such as `templates/bundles/TwigBundle/Exception/error404.html.twig`.
- [Security](../packages/security-bundle.md): `#[IsGranted]` runs on `kernel.controller_arguments` before `#[MapRequestPayload]` maps the payload, and `#[CurrentUser]` is a value resolver attribute.
- [Doctrine Bridge](../packages/doctrine-bridge.md): `#[MapEntity]` extends the `ValueResolver` attribute, and `EntityValueResolver` loads an entity for a controller argument.
- [Uid](../packages/uid.md): `UidValueResolver` and `#[MapQueryParameter]` convert route and query values into `Uuid` or `Ulid` arguments.
- [Cache](../packages/cache.md): The Cache component stores application data, such as query results, and `#[Cache]` and `HttpCache` cache HTTP responses.
- [Console](../packages/console.md): Console 8.1 has its own `MapDateTime`, `ValueResolver`, `AsTargetedValueResolver` and `ValueResolverInterface` for command arguments. In a controller, import the HttpKernel classes.
- [DependencyInjection](../packages/dependency-injection.md): `Kernel` extends `Symfony\Component\DependencyInjection\Kernel\AbstractKernel`, and an application without HTTP can use the DependencyInjection kernel alone.
- [WebProfilerBundle](../packages/web-profiler-bundle.md): The HttpKernel `Profiler` and its data collectors supply the data that the web debug toolbar and the profiler show.
- [FrameworkBundle test tools](../packages/framework-bundle-testing.md): `KernelBrowser` extends `HttpKernelBrowser` and sends test requests through the kernel without a web server.
- [BrowserKit](../packages/browser-kit.md): `HttpKernelBrowser` extends the BrowserKit `AbstractBrowser`.
- [Runtime](../packages/runtime.md): `HttpKernelRunner` runs an `HttpKernelInterface` application from the front controller.
- [MonologBundle](../packages/monolog-bundle.md): The `log_channel` option of `framework.exceptions` sends the exception log to the `monolog.logger.<channel>` logger.
- [PSR-7 Bridge](../packages/psr-http-message-bridge.md): `PsrServerRequestResolver` gives a PSR-7 `ServerRequestInterface` object to a controller argument.
- [UX Twig Component](../packages/ux-twig-component.md): For reusable parts of a page, the docs prefer Twig components to `render(controller())`. If the fragment must be a sub-request, for example for ESI, use an embedded controller.
- [UX Live Component](../packages/ux-live-component.md): For content that loads or updates asynchronously, the docs prefer Live components to `render_hinclude()`.
- [Clock](../packages/clock.md): `DateTimeValueResolver` creates controller date arguments with the clock, and an empty value for a non-nullable argument gives the clock time.
- [Config](../packages/config.md): the `configure()` hook of `AbstractBundle` receives a Config `DefinitionConfigurator`, and `loadExtension()` receives the processed configuration array.
- [Form](../packages/form.md): for an HTML form, use Form; `#[MapRequestPayload]` is for a JSON API payload without an HTML form.
- [HttpClient](../packages/http-client.md): often confused: `HttpCache` is a reverse proxy for the responses of your own application, and `CachingHttpClient` of HttpClient caches the responses of other services.
- [ObjectMapper](../packages/object-mapper.md): after `#[MapRequestPayload]` creates and validates the input DTO, `map()` copies the DTO into the entity.
- [PropertyInfo](../packages/property-info.md): `#[MapRequestPayload]` denormalizes a nested array of DTOs (`@param UserDto[]`) when `phpstan/phpdoc-parser` and `phpdocumentor/type-resolver` are installed.

## Changed in 8.0/8.1

- `$request->headers->get('Accept-Language')` in a controller -> `#[MapRequestHeader] string $acceptLanguage` (8.1).
- `$serializer->serialize()` plus `new Response()` in a controller -> `#[Serialize]` on the controller method (8.1).
- `$limiter->consume()` plus a manual 429 response -> `#[RateLimit('<limiter name>')]` (8.1).
- A `kernel.controller_arguments` listener that filters `$event->getAttributes()` -> a listener for `kernel.controller_arguments.<attribute FQCN>` with `ControllerAttributeEvent` (8.1).
- Manual header code for a conditional cache policy -> `#[Cache(if: ...)]` with an expression or a closure (8.1).
- `extends Symfony\Component\HttpKernel\DependencyInjection\Extension` -> `extends Symfony\Component\DependencyInjection\Extension\Extension` (deprecated in 8.1).
- `addAnnotatedClassesToCompile()` in an extension, or `getAnnotatedClassesToCompile()` in a kernel -> remove the call or the method (removed in 8.0).
- `framework.http_cache.terminate_on_cache_hit` -> remove the option (deprecated in 8.1; 7.0 removed the matching `HttpCache` option).

## Docs

- https://symfony.com/doc/current/components/http_kernel.html
- https://symfony.com/doc/current/controller.html
- https://symfony.com/doc/current/controller/value_resolver.html
- https://symfony.com/doc/current/controller/service.html
- https://symfony.com/doc/current/controller/error_pages.html
- https://symfony.com/doc/current/reference/events.html
- https://symfony.com/doc/current/reference/attributes.html
- https://symfony.com/doc/current/http_cache.html
- https://symfony.com/doc/current/http_cache/expiration.html
- https://symfony.com/doc/current/http_cache/validation.html
- https://symfony.com/doc/current/http_cache/cache_invalidation.html
- https://symfony.com/doc/current/http_cache/esi.html
- https://symfony.com/doc/current/http_cache/ssi.html
- https://symfony.com/doc/current/rate_limiter.html
- https://symfony.com/doc/current/routing.html
- https://symfony.com/doc/current/templates.html
- https://symfony.com/doc/current/reference/configuration/framework.html
- https://symfony.com/doc/current/bundles/configuration.html
- https://symfony.com/doc/current/configuration/front_controllers_and_kernel.html
