# HttpFoundation (`symfony/http-foundation`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- Request data: the `query` (URL parameters), `request` (form fields), `cookies`, `files`, `headers`, `server` and `attributes` bags hold the request data. Typed getters convert a value or throw an exception. If a `query`, `request` or `cookies` value has the wrong type, the getter throws `BadRequestException`, and HttpKernel returns HTTP 400. For an array value, use `all('key')`. `InputBag::getInt()`, `getString()`, `getBoolean()`, `getEnum()`, `filter()`, `ParameterBag::all()`
- Request body: `getPayload()` returns the form fields. If the request has no form fields, it decodes the JSON body. `toArray()` decodes a JSON body and throws `JsonException` (HTTP 400) if the body is empty or invalid. `getContent()` returns the raw body. To map the body to a DTO, use `#[MapRequestPayload]` (HttpKernel). `Request::getPayload()`, `Request::toArray()`, `Request::getContent()`
- Uploaded files: `$request->files->get('name')` returns an `UploadedFile`. Its original name, extension and MIME type come from the client and are not safe. `guessExtension()` gets the extension from the MIME type of the file content and needs symfony/mime. `move()` moves the file and throws a `FileException` subclass for each upload error. `UploadedFile::guessExtension()`, `UploadedFile::move()`, `UploadedFile::getErrorMessage()`
- Content negotiation: `getPreferredLanguage()` selects the best locale from the `Accept-Language` header. `getPreferredFormat()` returns the request format, for example the `_format` route parameter, before it reads the `Accept` header. `getFormat()` and `getMimeType()` convert between a format name and a MIME type. To add a format, use `framework.request.formats`. `Request::getPreferredLanguage()`, `Request::getPreferredFormat()`, `Request::getAcceptableContentTypes()`, `AcceptHeader::fromString()`
- HTTP cache headers: `setCache()` sets the `Cache-Control` directives, `ETag` and `Last-Modified` in one call. It throws an exception for an unknown option. `isNotModified()` compares the `ETag` and `Last-Modified` values with the request. If they match, it sets status 304 and removes the body. If the response has no cache header, the `Cache-Control` value is `no-cache, private`. `Response::setCache()`, `setPublic()`, `setMaxAge()`, `setSharedMaxAge()`, `setEtag()`, `setLastModified()`, `setVary()`, `isNotModified()`
- JSON and redirect responses: `JsonResponse` encodes the data and escapes `<`, `>`, `'`, `&` and `"`, so that the JSON is safe in HTML. `JsonResponse::fromJsonString()` sends JSON that is already encoded. For a GET response, return a JSON object, not a top-level array, to prevent XSSI attacks. `RedirectResponse` sets the `Location` header and rejects a status that is not a redirect status. It does not check the target URL. If the URL comes from user input, check it first to prevent open redirects. `JsonResponse`, `RedirectResponse`
- File downloads: `BinaryFileResponse` sends a file and supports `Range` requests (status 206). The response is public by default. If the file is private, call `setPrivate()`. `setContentDisposition()` sets the download name and makes an ASCII fallback name. `deleteFileAfterSend()` deletes the file after the response. To send a file that exists only in memory, pass a `\SplTempFileObject`. If `framework.trust_x_sendfile_type_header` is true and the web server sends an `X-Sendfile-Type` header, the web server sends the file. If you do not set the `Content-Type` header, the response guesses it with symfony/mime. `BinaryFileResponse`, `HeaderUtils::makeDisposition()`, `AbstractController::file()`
- Streamed responses and SSE: `StreamedResponse` sends the output of a callback or the strings of an iterable. `StreamedJsonResponse` encodes generators part by part, so that a large list uses less memory. `EventStreamResponse` sets the `text/event-stream` and `X-Accel-Buffering: no` headers. Its callback yields `ServerEvent` objects, and the loop stops when the client disconnects. For many concurrent connections, the docs recommend Mercure. `StreamedResponse`, `StreamedJsonResponse`, `EventStreamResponse`, `ServerEvent`
- Cookies: `Cookie::create()` makes a cookie that is HttpOnly and `SameSite=Lax` by default. If you do not set `secure`, the cookie is secure on HTTPS requests. The `with*()` methods return a changed copy, and `withPartitioned()` makes a partitioned (CHIPS) cookie. `Cookie::create()`, `ResponseHeaderBag::setCookie()`, `ResponseHeaderBag::clearCookie()`
- Sessions and flash messages: in a service, get the session from `RequestStack::getSession()`. The session starts when the code reads, writes or checks a value in it. If a request uses the session, HttpKernel makes the response private. `migrate()` gives the session a new ID and keeps the data. `invalidate()` deletes the data and gives a new ID. The flash bag methods `get()` and `all()` remove the messages, and `peek()` and `peekAll()` keep them. `getFlashBag()` is on `FlashBagAwareSessionInterface`, not on `SessionInterface`. `RequestStack::getSession()`, `SessionInterface`, `FlashBagInterface`, `AbstractController::addFlash()`
- Session handlers: `framework.session.handler_id` takes a service ID or a DSN. If `handler_id` and `save_path` are both null, the `php.ini` session settings apply. The `redis`, `rediss`, `valkey`, `valkeys` and `memcached` DSN schemes need symfony/cache. The other schemes are `file` and the PDO schemes, for example `mysql`, `pgsql` and `sqlite`. `PdoSessionHandler` locks the session in a transaction by default, and `createTable()` creates its table. The Redis and Memcached handlers do not lock the session. `MigratingSessionHandler` reads from the current handler and writes to two handlers during a move. To encrypt the session data, decorate `session.marshaller` with `SodiumMarshaller` (Cache). `RedisSessionHandler`, `MemcachedSessionHandler`, `PdoSessionHandler`, `MongoDbSessionHandler`, `MigratingSessionHandler`
- Trusted proxies and hosts: `framework.trusted_proxies` lists the IP addresses or CIDR ranges of your proxies, or `private_ranges`. `framework.trusted_headers` lists the `X-Forwarded-*` or `Forwarded` headers that the proxies set. Then `getClientIp()`, `getHost()`, `getScheme()`, `getPort()` and `isSecure()` return the client values, not the proxy values. `framework.trusted_hosts` lists host regular expressions. For other hosts, `getHost()` throws `SuspiciousOperationException` (HTTP 400). `Request::setTrustedProxies()`, `Request::setTrustedHosts()`
- IP addresses and request matchers: `IpUtils::checkIp()` tests an IPv4 or IPv6 address against addresses and CIDR ranges. `IpUtils::isPrivateIp()` tests the ranges in `IpUtils::PRIVATE_SUBNETS`. `IpUtils::anonymize()` sets the last bytes of an address to zero before you log or store it. `ChainRequestMatcher` matches a request only if all its matchers match. The 11 matchers test the path, host, method, IP, scheme, port, header, query parameter, attribute, JSON body or an expression. `IpUtils`, `ChainRequestMatcher`, `RequestMatcherInterface`, the `RequestMatcher\*RequestMatcher` classes
- Signed URLs: `UriSigner::sign()` adds a `_hash` parameter, an HMAC-SHA256 of the URL. The `uri_signer` service uses `kernel.secret` as the key. An expiration adds an `_expiration` parameter. `check()` and `checkRequest()` return a boolean. `verify()` throws an exception: HTTP 404 for a missing or wrong hash, and HTTP 403 for an expired URL. On a controller, `#[IsSignatureValid]` (HttpKernel) checks the request. `UriSigner::sign()`, `UriSigner::verify()`
- URL helper: `UrlHelper::getAbsoluteUrl()` makes an absolute URL from a path, with the scheme and host of the main request. Without a request, for example in a console command, it uses the router request context that `framework.router.default_uri` sets. `getRelativePath()` makes a path that is relative to the main request. `UrlHelper`, the Twig functions `absolute_url()` and `relative_path()`

## Entry points

- `Symfony\Component\HttpFoundation\Request`: type-hint it in a controller argument to get the current request.
- `Symfony\Component\HttpFoundation\RequestStack`: autowire it in a service. It gives `getCurrentRequest()`, `getMainRequest()` and `getSession()`.
- `Symfony\Component\HttpFoundation\Session\SessionInterface`: type-hint it in a controller argument to get the session.
- `Symfony\Component\HttpFoundation\UriSigner`: autowire it to sign and verify URLs (service `uri_signer`).
- `Symfony\Component\HttpFoundation\UrlHelper`: autowire it to make absolute URLs and relative paths (service `url_helper`).
- `\SessionHandlerInterface`: autowire the configured session handler (alias of `session.handler`).
- `Symfony\Component\HttpFoundation\Response`, `JsonResponse`, `RedirectResponse`, `BinaryFileResponse`, `StreamedResponse`, `StreamedJsonResponse`, `EventStreamResponse` and `ServerEvent`: the response classes to create and return.
- `Symfony\Component\HttpFoundation\Cookie`, `IpUtils`, `HeaderUtils` and `AcceptHeader`: helpers for cookies, IP addresses and HTTP headers.
- `Symfony\Component\HttpFoundation\ChainRequestMatcher`, `RequestMatcherInterface` and the classes in `Symfony\Component\HttpFoundation\RequestMatcher\`: match requests against rules.
- Without FrameworkBundle: call `Request::setTrustedProxies()` and `Request::setTrustedHosts()` in place of the `framework.trusted_*` keys. Use `NativeSessionStorage` for sessions, or `MockArraySessionStorage` in unit tests.
- `Symfony\Component\HttpFoundation\Session\Storage\Handler\RedisSessionHandler`, `MemcachedSessionHandler`, `PdoSessionHandler`, `MongoDbSessionHandler`, `MigratingSessionHandler` and `SessionHandlerFactory`: session handlers to register as services.
- Attributes: this package defines no attributes. The related attributes are in `Symfony\Component\HttpKernel\Attribute`: `IsSignatureValid`, `MapQueryParameter`, `MapQueryString`, `MapRequestPayload`, `MapUploadedFile`, `MapRequestHeader` and `Cache`.
- `framework.session`: set it to `true` to enable sessions. If the key is missing, sessions are off. The framework-bundle recipe sets it to `true`. Its keys are `handler_id`, `save_path`, `storage_factory_id`, `name`, `cookie_lifetime`, `cookie_path`, `cookie_domain`, `cookie_secure`, `cookie_httponly`, `cookie_samesite`, `use_cookies`, `gc_maxlifetime`, `gc_probability`, `gc_divisor` and `metadata_update_threshold`.
- `framework.trusted_proxies`, `framework.trusted_headers` and `framework.trusted_hosts`: their defaults read the `SYMFONY_TRUSTED_PROXIES`, `SYMFONY_TRUSTED_HEADERS` and `SYMFONY_TRUSTED_HOSTS` env vars.
- `framework.http_method_override`: if it is true, the `_method` parameter of a POST request sets the HTTP method. On a POST request, the `X-HTTP-Method-Override` header sets the method also when this key is false. `framework.allowed_http_method_override` lists the methods that an override can set. To disable all overrides, set it to `[]`.
- `framework.trust_x_sendfile_type_header`: let the web server send the files of `BinaryFileResponse`. The default reads the `SYMFONY_TRUST_X_SENDFILE_TYPE_HEADER` env var.
- `framework.request.formats`: add MIME types to the request formats.
- `framework.secret`: the key of `UriSigner`, as the `kernel.secret` parameter.
- Service IDs: `session.handler.native` (the `php.ini` handler), `session.handler.native_file`, `session.storage.factory.native`, `session.storage.factory.php_bridge`, `session.storage.factory.mock_file` and `session.marshaller`.
- `Symfony\Bundle\FrameworkBundle\Controller\AbstractController`: `json()`, `file()`, `redirect()`, `redirectToRoute()`, `addFlash()` and `stream()` (a Twig template as a `StreamedResponse`).
- Twig: `app.request`, `app.session`, `app.flashes()`, `absolute_url()` and `relative_path()`.
- Console commands: none.
- `Symfony\Bundle\FrameworkBundle\Test\BrowserKitAssertionsTrait` (in `WebTestCase`): `assertResponseIsSuccessful()`, `assertResponseStatusCodeSame()`, `assertResponseRedirects()`, `assertResponseHasHeader()`, `assertResponseHeaderSame()`, `assertResponseHasCookie()`, `assertResponseCookieValueSame()`, `assertResponseFormatSame()`, `assertResponseIsUnprocessable()`, `assertRequestAttributeValueSame()`, `assertRouteSame()` and `assertSessionHasFlashMessage()`. Their PHPUnit constraints are in `Symfony\Component\HttpFoundation\Test\Constraint`.
- `Symfony\Component\HttpFoundation\Session\Storage\MockArraySessionStorage` for unit tests, and `MockFileSessionStorage` for functional tests. The framework-bundle recipe sets `session.storage.factory.mock_file` in the `test` environment.

## Symbiotic packages

- [HttpKernel](../packages/http-kernel.md): HttpKernel turns a `Request` into a `Response` with your controller, converts request exceptions to HTTP 400, and adds the `Map*`, `#[Cache]` and `#[IsSignatureValid]` attributes.
- [FrameworkBundle](../packages/framework-bundle.md): FrameworkBundle configures the session, the trusted proxies and hosts, `UriSigner` and `UrlHelper` from the `framework.*` keys, and `AbstractController` creates the responses.
- [FrameworkBundle test tools](../packages/framework-bundle-testing.md): the `WebTestCase` assertions check the status, headers, cookies, redirects and flash messages with the constraints of this package.
- [HttpClient](../packages/http-client.md): often confused with HttpFoundation; HttpClient sends requests to other services, and HttpFoundation models the request that your application receives.
- [Routing](../packages/routing.md): the Routing article documents `UriSigner`, and `UrlHelper` uses the router request context when no request exists.
- [Security](../packages/security-bundle.md): `access_control` rules and the firewall `request_matcher` option use request matchers and IP ranges, and the `login_throttling` `limiter` option takes a `RequestRateLimiterInterface` service.
- [RateLimiter](../packages/rate-limiter.md): `AbstractRequestRateLimiter` consumes tokens from several RateLimiter limiters for one `Request` and returns the strictest result.
- [Cache](../packages/cache.md): the `redis`, `valkey` and `memcached` session DSNs need Cache, and its `SodiumMarshaller` encrypts the session data.
- [Mime](../packages/mime.md): `UploadedFile::guessExtension()`, `File::getMimeType()` and the default `Content-Type` of `BinaryFileResponse` use the MIME type guesser of Mime.
- [Doctrine Bridge](../packages/doctrine-bridge.md): the bridge adds the `PdoSessionHandler` table to the Doctrine schema, so that a Doctrine migration creates the table.
- [Twig Bridge](../packages/twig-bridge.md): `app.request`, `app.session`, `app.flashes()`, `absolute_url()` and `relative_path()` give templates the data and helpers of this package.
- [Asset](../packages/asset.md): `RequestStackContext` reads the base path and the HTTPS state of the main request, so that asset URLs match the request.
- [Form](../packages/form.md): a `FileType` field gives an `UploadedFile` object for each uploaded file.
- [Validator](../packages/validator.md): the `File` and `Image` constraints validate `File` and `UploadedFile` objects and report the upload errors.
- [Serializer](../packages/serializer.md): if the `serializer` service exists, `AbstractController::json()` encodes the data with it before it creates the `JsonResponse`.
- [JsonStreamer](../packages/json-streamer.md): a `StreamedResponse` sends the JSON parts that the JsonStreamer `StreamWriterInterface` writes.
- [Mercure](../packages/mercure.md): for many concurrent SSE connections, the docs recommend a Mercure hub instead of `EventStreamResponse`.
- [UX Live Component](../packages/ux-live-component.md): the session docs suggest a Live Component that loads the flash messages in a second request, so that the page stays cacheable.
- [Security CSRF](../packages/security-csrf.md): a stateful CSRF token starts the session, and the response then becomes private.
- [PSR-7 Bridge](../packages/psr-http-message-bridge.md): the bridge converts `Request` and `Response` objects to PSR-7 messages and back.
- [Runtime](../packages/runtime.md): `SymfonyRuntime` creates the `Request` from the PHP globals, gives it to the kernel and sends the `Response`.
- [Clock](../packages/clock.md): `UriSigner` reads the time from a `Psr\Clock\ClockInterface`, so a mock clock can test the expiration of signed URLs.
- [ExpressionLanguage](../packages/expression-language.md): `ExpressionRequestMatcher` evaluates an expression against the request.
- [Webhook](../packages/webhook.md): a webhook request parser uses request matchers to accept only the expected requests.
- [String](../packages/string.md): the upload docs slug the name from `UploadedFile::getClientOriginalName()` with `SluggerInterface::slug()` to make a safe file name.

## Changed in 8.0/8.1

- 8.0: `$request->get('id')` -> `$request->attributes->get('id')`, `$request->query->get('id')` or `$request->request->get('id')`. Symfony 8.0 removes `Request::get()`.
- 8.1: `$request->query = new InputBag([...])`, `$response->headers = $bag` or another assignment to a bag property -> call `replace()` on the bag, or pass the values to the constructor. Symfony 8.1 deprecates these assignments. `Response::__construct()` now accepts a `ResponseHeaderBag`.
- 8.0: a method override to `GET`, `HEAD`, `CONNECT` or `TRACE` -> Symfony ignores it. To limit the override methods, use `framework.allowed_http_method_override`.
- 8.0: the `sid_length`, `sid_bits_per_character`, `referer_check`, `use_only_cookies`, `use_trans_sid`, `trans_sid_hosts` and `trans_sid_tags` session options -> do not set them. `NativeSessionStorage` ignores them, and FrameworkBundle no longer has the `framework.session.sid_length` and `sid_bits_per_character` keys.
- 8.0: `Response::sendHeaders()` after PHP sent the headers -> a PHP warning. To send output in parts, use a `StreamedResponse`.
- 8.1: a manual flash bag check in a functional test -> `assertSessionHasFlashMessage()`.

## Status

- The session classes need the PHP `session` extension. Without it, `NativeSessionStorage` and an enabled `framework.session` throw a `LogicException`.

## Docs

- https://symfony.com/doc/current/components/http_foundation.html
- https://symfony.com/doc/current/session.html
- https://symfony.com/doc/current/reference/configuration/framework.html
- https://symfony.com/doc/current/deployment/proxies.html
- https://symfony.com/doc/current/controller.html
- https://symfony.com/doc/current/controller/upload_file.html
- https://symfony.com/doc/current/routing.html
- https://symfony.com/doc/current/http_cache/validation.html
- https://symfony.com/doc/current/testing.html
