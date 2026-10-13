# HttpClient (`symfony/http-client`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- Asynchronous responses: `request()` returns immediately and does not wait for the response. The code waits only when it reads the status code, the headers or the content. If the code does not keep the response in a variable, the request is synchronous, because the destructor waits for the headers. `HttpClientInterface::request()`, `ResponseInterface`
- Concurrent requests: `stream()` yields the chunks of many responses in the order that they arrive. Each chunk tells if it is the first chunk, the last chunk or a timeout. The default limit is 6 connections per host. `HttpClientInterface::stream()`, `ChunkInterface`, `max_host_connections`
- Fail-safe status checks: `getStatusCode()` throws only on a network error. For a 4xx or 5xx status, or a 3xx status that the client does not follow, `getHeaders()`, `getContent()` and `toArray()` throw an `HttpExceptionInterface`. The client follows up to 20 redirects (`max_redirects`). To read an error response, pass `false` to these methods. If the code calls none of these methods, the response destructor throws for these status codes. A call to `getStatusCode()` disables this destructor check. Network errors throw a `TransportExceptionInterface`, and invalid JSON throws a `DecodingExceptionInterface`. `ResponseInterface`, `HttpExceptionInterface`, `TransportExceptionInterface`
- Request options: the `json`, `body`, `query`, `headers`, `auth_basic`, `auth_bearer`, `base_uri`, `timeout`, `max_duration` and `max_connect_duration` options configure a request. `timeout` limits the idle time, `max_duration` limits the total time, and `max_connect_duration` limits the time to open the connection. The framework config has no `max_connect_duration` key. The client sends an array `body` as a URL-encoded form. If the array contains a file handle, the client sends `multipart/form-data`. An unknown option causes an exception. `HttpClientInterface::OPTIONS_DEFAULTS`, `HttpOptions`, `withOptions()`
- Scoped clients: a scoped client adds its options only to URLs that match its `base_uri` or its `scope` regular expression. The framework creates one service and one named autowiring alias for each scoped client. `framework.http_client.scoped_clients`, `ScopingHttpClient::forBaseUri()`, `HttpClient::createForBaseUri()`
- Retry: by default, the client retries a failed request 3 times. It retries the status codes 423, 425, 429, 502 and 503 for all methods. For idempotent methods, for example `GET` and `PUT`, it also retries network errors and the status codes 500, 504, 507 and 510. The first delay is 1 second, and the delay doubles each time, with a random variation of 10 %. The client obeys the `Retry-After` header. An array of base URIs gives a failover to the next URI. `retry_failed`, `RetryableHttpClient`, `GenericRetryStrategy`, `RetryStrategyInterface`, the `max_retries` request option
- Response cache: the client caches `GET` and `HEAD` responses as RFC 9111 specifies, in a tag-aware cache pool. It stores a response only after the code reads the complete content. The default shared cache does not store a response to a request with an `Authorization` header, unless the response has `public`, `s-maxage` or `must-revalidate`. For a private cache, set `shared` to `false`. If the server fails and the cached response has a `stale-if-error` window, the client returns the stale response. `caching`, `caching.shared`, `CachingHttpClient`
- Rate limits: the client reserves a token from a rate limiter for each request. If no token is free, the client pauses the request until the wait time ends. `rate_limiter`, `ThrottlingHttpClient`
- Server-Sent Events: `connect()` opens a `text/event-stream` connection, and `stream()` yields `ServerSentEvent` chunks. After a network error, the client reconnects and sends the `Last-Event-ID` header. `EventSourceHttpClient`, `ServerSentEvent::getArrayData()`
- Interoperability: `Psr18Client` implements PSR-18 and the PSR-17 request, stream and URI factories. `HttplugClient` implements the HTTPlug asynchronous client. `GuzzleHttpHandler` sends the requests of a Guzzle client through HttpClient. `StreamWrapper::createResource()` turns a response into a PHP stream. `Psr18Client`, `HttplugClient`, `GuzzleHttpHandler`, `StreamWrapper`
- Test doubles: `MockHttpClient` returns responses from a list, a callback or a list of callbacks. After the request, `MockResponse::getRequestMethod()`, `getRequestUrl()` and `getRequestOptions()` return the request data for assertions. `JsonMockResponse` encodes a JSON body. `HarFileResponseFactory` replays the responses of a HAR file. In the framework, `mock_response_factory` replaces the transport of all clients or of one scoped client. `MockHttpClient`, `MockResponse`, `JsonMockResponse`, `HarFileResponseFactory`, `framework.http_client.mock_response_factory`
- SSRF protection: the client blocks requests to private networks, also after each redirect. The `$allowList` argument keeps specific IP addresses or CIDR subnets reachable, for example a local proxy. `NoPrivateNetworkHttpClient`
- URI templates: the client expands RFC 6570 templates in the URL with the `vars` option. It needs `guzzlehttp/uri-template`, `rize/uri-template` or `league/uri`. In YAML, write `default_options.vars` as a map, not as a list. `UriTemplateHttpClient`, `framework.http_client.default_options.vars`
- Custom decorators: a decorator can change requests and responses chunk by chunk, and the responses stay asynchronous. `AsyncDecoratorTrait`, `AsyncResponse`, `AsyncContext`
- Transports and DNS: `HttpClient::create()` selects `CurlHttpClient`, `AmpHttpClient` or `NativeHttpClient` from the installed extensions and packages. `DnsResolvingHttpClient` sends each host name to your resolver callable, also on redirects. If the callable returns `null`, the transport uses its default DNS lookup. On PHP 8.5 or later, `extra.use_persistent_connections` lets cURL reuse connections, TLS sessions and DNS data. `HttpClient::create()`, `DnsResolvingHttpClient`, `CurlHttpClient`

## Entry points

- `Symfony\Contracts\HttpClient\HttpClientInterface`: autowire it to get the `http_client` service.
- `#[Symfony\Component\DependencyInjection\Attribute\Target('<client name>')]` on an `HttpClientInterface` argument: inject a scoped client.
- `Psr\Http\Client\ClientInterface`: autowire the PSR-18 adapter `psr18.http_client`. It needs `psr/http-client` and a PSR-17 implementation, for example `nyholm/psr7`. With `#[Target('<client name>')]`, you get the adapter of that scoped client.
- `Http\Client\HttpAsyncClient`: autowire the HTTPlug adapter `httplug.http_client`. It needs `php-http/httplug`, a PSR-17 implementation and, for `sendAsyncRequest()`, `guzzlehttp/promises`.
- `framework.http_client`: the root config key, with `max_host_connections`, `default_options`, `scoped_clients` and `mock_response_factory`.
- `framework.http_client.default_options.retry_failed`, `.caching` and `.rate_limiter`: enable the retry, cache and rate limit decorators of the `http_client` service. The same keys exist under `framework.http_client.scoped_clients.<name>`. A scoped client inherits `rate_limiter` and a `retry_failed` array, for example `{max_retries: 2}`, but not `caching` or `retry_failed: true`.
- `bin/console config:dump-reference framework http_client.default_options`: print the reference of the `default_options` config.
- Without FrameworkBundle: `Symfony\Component\HttpClient\HttpClient::create()` and `HttpClient::createForBaseUri()`.
- `Symfony\Component\HttpClient\RetryableHttpClient`, `CachingHttpClient`, `ThrottlingHttpClient`, `EventSourceHttpClient`, `NoPrivateNetworkHttpClient`, `DnsResolvingHttpClient`, `UriTemplateHttpClient` and `ScopingHttpClient`: decorators that wrap any `HttpClientInterface`.
- `Symfony\Component\HttpClient\Psr18Client`, `HttplugClient`, `GuzzleHttpHandler` and `Response\StreamWrapper`: adapters for other HTTP abstractions.
- `Symfony\Component\HttpClient\MockHttpClient`, `Response\MockResponse`, `Response\JsonMockResponse` and `Test\HarFileResponseFactory`: test helpers.
- `Symfony\Bundle\FrameworkBundle\Test\HttpClientAssertionsTrait` (also in `WebTestAssertionsTrait`): `assertHttpClientRequest()`, `assertNotHttpClientRequest()` and `assertHttpClientRequestCount()`. Call `$client->enableProfiler()` before the code that sends the requests.
- `Symfony\Component\HttpClient\Messenger\PingWebhookMessage`: a Messenger message. Its handler sends one HTTP request and returns the response.

## Symbiotic packages

- [FrameworkBundle](../packages/framework-bundle.md): FrameworkBundle registers the `http_client` service, the scoped clients, the PSR-18 and HTTPlug adapters and the decorators from the `framework.http_client` config.
- [FrameworkBundle test tools](../packages/framework-bundle-testing.md): `HttpClientAssertionsTrait` checks the requests that the code sent during a functional test, with data from the profiler.
- [Symfony Contracts](../packages/contracts.md): `symfony/http-client-contracts` 3.7 holds `HttpClientInterface`, `ResponseInterface` and the exception interfaces, and a library that type-hints them stays independent of the client implementation.
- [Cache](../packages/cache.md): `CachingHttpClient` needs the Cache component and stores the responses in a `TagAwareCacheInterface` pool, by default `cache.http_client`.
- [RateLimiter](../packages/rate-limiter.md): the `rate_limiter` option takes the name of a limiter that you define under `framework.rate_limiter`.
- [DependencyInjection](../packages/dependency-injection.md): `#[Target('<client name>')]` selects a scoped client, and DependencyInjection 8.1 deprecates a match on the argument name alone.
- [Messenger](../packages/messenger.md): the handler of `PingWebhookMessage` sends one HTTP request, for example to check the status of a service.
- [Webhook](../packages/webhook.md): to send webhooks, Webhook needs HttpClient, and the `webhook.transport` service sends each webhook as a signed `POST` request through `http_client`.
- [Mailer](../packages/mailer.md): the `+api` and `+https` transports of the third-party providers send the emails through HttpClient.
- [Notifier](../packages/notifier.md): the transports of the provider bridges, except Mercure, call the provider APIs through HttpClient.
- [Security](../packages/security-bundle.md): the `oidc_user_info` and `cas` token handlers send requests through HttpClient or through the client service in their `client` or `http_client` option.
- [BrowserKit](../packages/browser-kit.md): if you need cookies, links or forms on external websites, use `HttpBrowser` with HttpClient, because HttpClient does not keep cookies.
- [Mime](../packages/mime.md): Mime guesses the content type of a local file handle in a `body` array, and HttpClient accepts `FormDataPart::bodyToIterable()` as `body` with `getPreparedHeaders()->toArray()` as `headers`.
- [WebProfilerBundle](../packages/web-profiler-bundle.md): the profiler panel shows each request that a client sent, from the `data_collector.http_client` collector.
- [HttpFoundation](../packages/http-foundation.md): often confused with HttpClient: HttpFoundation models the incoming request and your response, and `NoPrivateNetworkHttpClient` needs its `IpUtils` class.
- [HttpKernel](../packages/http-kernel.md): often confused with HttpClient: `HttpCache` is a reverse proxy for the responses of your own application, and `CachingHttpClient` caches the responses of other services.
- [AssetMapper](../packages/asset-mapper.md): AssetMapper requires HttpClient to download packages from the jsDelivr CDN, for example with `importmap:require`.
- [Asset](../packages/asset.md): `JsonManifestVersionStrategy` downloads a remote manifest file with HttpClient.
- [Tui](../packages/tui.md): in a Tui application (experimental), use `AmpHttpClient` so that HTTP requests do not block the Revolt event loop.
- [Symfony Polyfill](../packages/polyfill.md): HttpClient does not require `symfony/polyfill-intl-idn`; for a non-ASCII URL host without the intl extension, require it to prevent an `InvalidArgumentException`.
- [WebLink](../packages/web-link.md): to read API pagination links, give `$response->getHeaders()['link']` to `HttpHeaderParser::parse()` of WebLink.

## Changed in 8.0/8.1

- 8.0: a `StoreInterface` object as the `$cache` argument of `CachingHttpClient` -> a `TagAwareCacheInterface` pool, for example `cache.http_client`.
- 8.0: `setLogger()` on `ScopingHttpClient`, `TraceableHttpClient` or `NoPrivateNetworkHttpClient` -> configure the logger on the wrapped client.
- 8.0: `amphp/http-client` < 5 for `AmpHttpClient` -> `amphp/http-client` 5.3.2 or later.
- 8.1: a scoped client injected by the argument name only (`HttpClientInterface $githubClient`) -> `#[Target('github.client')] HttpClientInterface $githubClient`.
- 8.1: `max_ttl: null` (or `$maxTtl = null`) for `CachingHttpClient` -> a positive integer. The default is now 86400 seconds.
- 8.1: a second Guzzle transport for Guzzle-based SDKs -> `GuzzleHttpHandler` as the Guzzle `handler`.
- 8.1: a `resolve` map that you fill for each host -> `DnsResolvingHttpClient` with a resolver callable that also runs on redirects.
- 8.1: one global `mock_response_factory` -> `mock_response_factory` per scoped client, with `true`, `false` or a service ID.

## Docs

- https://symfony.com/doc/current/http_client.html
- https://symfony.com/doc/current/reference/configuration/framework.html
- https://symfony.com/doc/current/testing.html
- https://symfony.com/doc/current/messenger.html
- https://symfony.com/doc/current/components/browser_kit.html
