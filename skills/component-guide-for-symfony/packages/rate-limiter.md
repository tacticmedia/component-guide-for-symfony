# RateLimiter (`symfony/rate-limiter`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when an action may happen only N times per period, for example API requests per client, login attempts or outgoing API calls. It rejects or delays the extra events, with HTTP 429 for web requests, and it can also slow down queue workers. To limit concurrent processes, see [Semaphore](semaphore.md).

**Details:** [../details/rate-limiter.md](../details/rate-limiter.md)

## Why it exists

Applications must limit how often a client or a process can do an action, for example send API requests or try a login. A hand-written counter in Redis or in a database needs its own expiry, reset and lock logic. The package counts these actions per key with a configurable policy and keeps the state in a cache by default. It runs inside the application, so it cannot stop DoS attacks, which the web server or a proxy must block.

## When to use it

- Reject API requests with HTTP 429 after a client reaches its quota.
- Limit failed login attempts per username and IP address to stop brute-force attacks.
- Add a request limit to one controller action or to a whole controller with a PHP attribute.
- Keep outgoing HTTP requests below the request quota of a third-party API.
- Limit the number of messages that a queue worker handles in a time period.
- Give each customer a monthly quota that resets on a fixed calendar day.
- Delay an operation until the limit allows it.
- Show the remaining quota to API clients in the response headers.
- Throttle actions in a command-line tool or a plain PHP script, with the state in memory or in a cache.

## Use it instead of

- `$redis->incr('hits:'.$ip)` with `$redis->expire()` and an `if ($hits > 100)` check -> `$factory->create($ip)->consume()->isAccepted()` on a `RateLimiterFactoryInterface` with a `fixed_window` or `sliding_window` limiter. If several servers share the limit, set `cache_pool` to a Redis pool.
- A custom `#[MyRateLimit]` attribute with a `kernel.controller_arguments` listener -> `#[RateLimit('api')]`.
- A `failed_login_count` column and a `last_failed_login_at` check in the authenticator -> `login_throttling` on the firewall.
- `usleep()` or `sleep()` between calls to a third-party API -> the `rate_limiter` option of a scoped HTTP client (`ThrottlingHttpClient`).
- `sleep()` in a Messenger handler to slow down the worker -> the `rate_limiter` option of the transport.
- `while (!$allowed) { sleep(1); }` around a manual counter check -> `$limiter->reserve()->wait()`.
- `new Response('Too many requests', 429, ['Retry-After' => $seconds])` -> `throw new TooManyRequestsHttpException($seconds)`.
- A cron job that resets the monthly API usage of all customers -> a `fixed_window` limiter with `interval: '1 month'` and `anchor_at`.
