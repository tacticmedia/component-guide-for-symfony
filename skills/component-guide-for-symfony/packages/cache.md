# Cache (`symfony/cache`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when code repeats slow work, such as database queries, API calls or computations, and must reuse the result. It stores values in Redis, APCu, Memcached, a database or files, with expiration, invalidation by tag and stampede protection. It also implements PSR-6 and PSR-16. To cache full HTTP responses, see [HttpKernel](http-kernel.md).

**Details:** [../details/cache.md](../details/cache.md)

## Why it exists

An application that repeats slow work on each request or job responds slowly, for example a database query or a call to a remote API. The package stores the result and returns it until the result expires or until you invalidate it. It also prevents a cache stampede, when many processes compute the same expired value at the same time.

## When to use it

- Store the result of a slow database query, API call or computation, and reuse it until it expires.
- Share cached data between several servers with Redis, Valkey or Memcached.
- When a record changes, delete all cached values that depend on that record.
- Stop many processes from computing the same expired value at the same time.
- Compute the new value of a cache item in a background worker before the item expires.
- Compress or encrypt cached values before the backend stores them.
- Give a PSR-6 or PSR-16 cache object to a third-party library.
- Keep values in memory for the duration of one PHP process, for example in tests.
- Limit the number of items in memory in a long-running worker.
- Cache data in a command-line tool or a plain PHP script, without the framework.

## Use it instead of

- `file_put_contents($file, serialize($data))` plus a `filemtime($file) > time() - 3600` check -> `CacheInterface::get()` with `$item->expiresAfter(3600)`.
- `$redis->get($key)`, then `$redis->setex($key, 3600, serialize($value))` on a miss -> a pool with `adapter: cache.adapter.redis` and `CacheInterface::get()`.
- `apcu_fetch($key, $success)` and `apcu_store($key, $value, 3600)` -> `ApcuAdapter` (`cache.adapter.apcu`).
- `$redis->del('product_42', 'product_list', 'home_page')` with a hand-written list of keys for each change -> `$item->tag('product-42')` and `TagAwareCacheInterface::invalidateTags(['product-42'])`.
- `$redis->set($key.':lock', 1, ['nx', 'ex' => 30])` or `flock()` around a recomputation -> the stampede protection of `CacheInterface::get()` (lock per host and `$beta`).
- A custom Messenger message and handler that recompute a cache entry -> the pool option `early_expiration_message_bus` with `EarlyExpirationMessage`.
- `openssl_encrypt(serialize($value), ...)` before a write to the cache backend -> `SodiumMarshaller`.
- `gzcompress(serialize($value))` before a write to the cache backend -> `DeflateMarshaller`.
- A hand-written class that implements `Psr\SimpleCache\CacheInterface` on top of a PSR-6 pool -> `Psr16Cache`.
- `static $memo = [];` in a long-running worker, where the array grows without a limit -> `ArrayAdapter` with `$maxItems` (it deletes the least recently used items first) and `$maxLifetime`.
