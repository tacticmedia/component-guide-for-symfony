# HttpClient (`symfony/http-client`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when PHP code must call HTTP APIs or download from other servers, with timeouts, parallel requests and retries. It adds response caching, rate limits, Server-Sent Events, PSR-18 adapters and fake responses for tests. For the incoming request, see [HttpFoundation](http-foundation.md). To cache the responses of your own application, see [HttpKernel](http-kernel.md).

**Details:** [../details/http-client.md](../details/http-client.md)

## Why it exists

Applications call other services over HTTP, and these calls need timeouts, parallel requests, exceptions for failed responses and fake responses in tests. Raw cURL code repeats this work in each call. The package gives one interface for the cURL, Amp and PHP stream transports, and it sends requests asynchronously by default. Decorators add retry, response caching, rate limits, options per base URL and SSRF protection without changes to the calling code.

## When to use it

- Call a REST or JSON API from a web page, a command-line tool or a background worker.
- Process the responses of many parallel HTTP requests as they arrive.
- Upload files to an API as a multipart form.
- Retry failed requests to an unstable API with a delay that increases after each attempt.
- Cache the responses of an external API as its HTTP cache headers allow.
- Keep the outgoing requests below the rate limit of an API.
- Read a Server-Sent Events stream that reconnects after a network error.
- Block requests to private networks when a user supplies the URL.
- Send requests without blocking an event loop, for example in a terminal UI.
- Replace real HTTP responses with fake responses or a HAR file in tests.
- Give a PSR-18, HTTPlug or Guzzle-based library the configured client.

## Use it instead of

- `curl_init()` with `curl_setopt()` and `curl_exec()`, or `file_get_contents('https://…')` with a stream context -> `HttpClientInterface::request()` and `$response->toArray()`
- A `curl_multi_exec()` loop for parallel downloads -> several `request()` calls, then `$client->stream($responses)`
- A `for` loop with `try`/`catch` and `sleep()` that repeats a failed request -> `framework.http_client.default_options.retry_failed` or `RetryableHttpClient`
- `json_encode()` for the request body, a manual `Content-Type: application/json` header and `json_decode($body, true)` -> the `json` request option and `$response->toArray()`
- A cache of API responses with `$cache->get()` and a fixed TTL, for an API that sends `Cache-Control` headers -> the `caching` option (`CachingHttpClient`)
- `usleep()` calls between API requests to stay below a rate limit -> the `rate_limiter` option (`ThrottlingHttpClient`)
- An `fgets()` loop that parses the `data:` lines of an event stream -> `EventSourceHttpClient::connect()` and `ServerSentEvent`
- A PHPUnit mock of `HttpClientInterface` with `willReturn()` calls, or a hand-written fake client -> `MockHttpClient` with `MockResponse`, `JsonMockResponse` or `HarFileResponseFactory`
- `gethostbyname()` and manual IP range checks against SSRF -> `NoPrivateNetworkHttpClient`
- A second Guzzle client with its own transport for a Guzzle-only SDK -> `new GuzzleHttp\Client(['handler' => new GuzzleHttpHandler($client)])`
