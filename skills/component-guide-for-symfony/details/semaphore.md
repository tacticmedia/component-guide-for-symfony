# Semaphore (`symfony/semaphore`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Factory and holder:** `SemaphoreFactory::createSemaphore($resource, $limit, $weight = 1, $ttlInSecond = 300.0, $autoRelease = true)` returns a new `SemaphoreInterface` object. Each object is one holder. Two objects for the same resource are two holders, also in one process. If several services must use one holder, share the object, or call `createSemaphoreFromKey()` with the same `Key`.
- **Limit:** `$limit` is the maximum sum of weights that all holders of a resource can have at the same time. Use the same limit for a resource in all processes, because each store checks the limit of the caller.
- **Weight:** `$weight` is the number of slots that one holder takes (default 1). `Key` throws `InvalidArgumentException` if the limit or the weight is below 1, or if the weight is above the limit.
- **Acquisition without wait:** `acquire()` returns `true` or `false` at once. It has no blocking mode, unlike `Lock::acquire(true)`. If the code must wait for a free slot, call `acquire()` again later. If the store fails, `acquire()` throws `Symfony\Component\Semaphore\Exception\RuntimeException`. A second `acquire()` call on an acquired semaphore returns `true`, but it does not extend the TTL in the store.
- **TTL and refresh:** each holder has a TTL (default 300 seconds). In an expiring store, such as Redis, a crashed process loses its slot after the TTL. `refresh()` extends the TTL; without an argument, it uses the TTL from creation. It throws `SemaphoreExpiredException` if the holder lost its slot. `isAcquired()` asks the store; `isExpired()` and `getRemainingLifetime()` use the local expiry time. Do not pass `null` as the TTL: `Semaphore` requires a float and throws a `TypeError`.
- **Automatic release:** the object releases its slot when PHP destroys it. To keep the slot after the object ends, pass `false` as `$autoRelease`. It is the fifth argument of `createSemaphore()` and the third argument of `createSemaphoreFromKey()`.
- **Redis store:** `Symfony\Component\Semaphore\Store\RedisStore` keeps the holders in Redis or Valkey with Lua scripts, so processes on several servers share one limit. It accepts `\Redis`, `\RedisArray`, `\RedisCluster`, `Relay\Relay`, `Relay\Cluster` and `Predis\ClientInterface`. Its Redis keys are `{<resource>}:weight` and `{<resource>}:time`, without an application prefix. If applications share a Redis server, use unique resource names.
- **Lock store (8.1):** `Symfony\Component\Semaphore\Store\LockStore` uses a Lock `LockFactory` as the backend and needs `symfony/lock`. For a limit N, it uses the lock names `<resource>_0` to `<resource>_<N-1>`, and a holder acquires `$weight` of them. The TTL applies only if the Lock store expires. The `flock` and `semaphore` Lock stores never expire and work on one machine only. They release the locks of a process when the process ends.
- **Store factory:** `StoreFactory::createStore()` creates a store from a `redis://`, `rediss://`, `valkey://` or `valkeys://` DSN, from a Redis client object or from a `LockFactory`. A DSN needs `symfony/cache`.
- **Release in another process (8.1):** create the `Key` with `new Key($resource, $limit)`. In both processes, create the semaphore with `createSemaphoreFromKey($key, $ttl, false)`. With `true`, the first process releases the slot when it ends. Serialize the `Key` with PHP `serialize()` or with the Serializer and `SemaphoreKeyNormalizer`. Do not serialize the `Semaphore` object: it throws `BadMethodCallException`. In the other process, call `release()` when the work ends. This does not work with `LockStore`: it marks the key as not serializable, and serialization throws `UnserializableKeyException`.
- **FrameworkBundle configuration:** `framework.semaphore` takes a DSN or a service ID for the `default` resource, or a map of named resources. A value can also be `lock://` (the `default` lock resource) or `lock://<name>` (the lock resource `<name>`). Autowire `SemaphoreFactory` for the `default` resource. For another resource, add `#[Target('<name>')]` to the argument.
- **No Flex recipe:** `composer require symfony/semaphore` adds no configuration. Without a `framework.semaphore` resource, the container has no `SemaphoreFactory` service.
- **Env var problem:** if a `framework.semaphore` value is only `%env(...)%`, Symfony wraps it in a service reference. When a service uses the factory, the container compilation fails with `EnvParameterException`, because the service `"%env(...)%"` does not exist. The reference docs show this form. Do not use it. Use a literal DSN, a Redis service ID (for example a `\Redis` service built with `RedisAdapter::createConnection('%env(SEMAPHORE_DSN)%')`), or `lock://` with `framework.lock: '%env(LOCK_DSN)%'`. A DSN with a variable inside, such as `redis://%env(REDIS_HOST)%`, also compiles.
- **Logging:** FrameworkBundle gives the `logger` service to each factory, on the `semaphore` Monolog channel. A semaphore logs a debug message when `acquire()` or `refresh()` succeeds, and a notice when `acquire()` fails.

## Entry points

- `Symfony\Component\Semaphore\SemaphoreFactory`: autowire it for the `default` resource. Methods: `createSemaphore()`, `createSemaphoreFromKey()`.
- `#[Symfony\Component\DependencyInjection\Attribute\Target('<name>')] SemaphoreFactory $factory`: the factory of a named resource. Since 8.1, a match on the argument name alone (`SemaphoreFactory $pdfSemaphoreFactory`) is deprecated.
- `Symfony\Component\Semaphore\SemaphoreInterface`: `acquire()`, `release()`, `refresh()`, `isAcquired()`, `isExpired()`, `getRemainingLifetime()`.
- `Symfony\Component\Semaphore\Key`: the state of one holder (`new Key($resource, $limit, $weight = 1)`). Serialize it to release the slot in another process.
- Config: `framework.semaphore` (string or map), `framework.semaphore.resources.<name>` (DSN, service ID, `lock://` or `lock://<name>`), `framework.semaphore.enabled`.
- Service IDs: `semaphore.factory` (private alias of `semaphore.default.factory`), `semaphore.<name>.factory`, `serializer.normalizer.semaphore_key`.
- Stores: `Symfony\Component\Semaphore\Store\RedisStore`, `Symfony\Component\Semaphore\Store\LockStore`, `Symfony\Component\Semaphore\Store\StoreFactory::createStore()`. A custom store implements `Symfony\Component\Semaphore\PersistingStoreInterface`. `framework.semaphore` cannot use a custom store object, so give it to your own `SemaphoreFactory` service.
- Without FrameworkBundle: give a store from `StoreFactory::createStore()`, or a custom store, to your own `SemaphoreFactory`.
- Serializer: `Symfony\Component\Semaphore\Serializer\SemaphoreKeyNormalizer`.
- Exceptions (namespace `Symfony\Component\Semaphore\Exception`): `SemaphoreExpiredException`, `RuntimeException`, `UnserializableKeyException`, `InvalidArgumentException`, `SemaphoreReleasingException`. All of them implement `ExceptionInterface`.
- The package has no console commands, no Twig functions, no PHP attributes and no test helpers.

## Symbiotic packages

- [Lock](../packages/lock.md): Lock gives one holder, a blocking `acquire(true)` and shared read locks; Semaphore gives N holders without a wait. `LockStore` and the `lock://` DSN use a Lock factory as the semaphore backend.
- [RateLimiter](../packages/rate-limiter.md): RateLimiter counts events in a time interval and has no release step when the work ends. Use RateLimiter for "N requests per minute" and Semaphore for "N at the same time".
- [FrameworkBundle](../packages/framework-bundle.md): `framework.semaphore` creates the stores, the factories, the autowiring aliases and the `Key` normalizer service.
- [Cache](../packages/cache.md): `StoreFactory` uses `AbstractAdapter::createConnection()` from symfony/cache to open the Redis or Valkey connection of a DSN.
- [Messenger](../packages/messenger.md): the docs acquire a slot, dispatch a message that carries the `Key`, and release the slot in the worker.
- [Serializer](../packages/serializer.md): `SemaphoreKeyNormalizer` normalizes and denormalizes a `Key` for the transfer between processes.
- [DependencyInjection](../packages/dependency-injection.md): `#[Target('<name>')]` selects the factory of a named semaphore resource.

## Changed in 8.0/8.1

- 8.1 adds `LockStore` and the `lock://` DSN: a semaphore can use any Lock backend (flock, PDO, Redis and more).
- 8.1 adds `Key` serialization and `SemaphoreKeyNormalizer`: acquire a slot in one process and release it in another.
- 8.1 deprecates named autowiring by the argument name only: write `#[Target('pdf')] SemaphoreFactory $factory`, not only `SemaphoreFactory $pdfSemaphoreFactory`.
- 8.0 removes the XML format and the fluent PHP format (`static function (FrameworkConfig $framework)` with `$framework->semaphore()->resource(...)`). Write YAML, or PHP with `App::config(['framework' => ['semaphore' => ...]])`.

## Docs

- https://symfony.com/doc/current/components/semaphore.html
- https://symfony.com/doc/current/reference/configuration/framework.html
- https://symfony.com/doc/current/lock.html
- https://symfony.com/doc/current/rate_limiter.html
