# Cache (`symfony/cache`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Get-or-compute call:** `get()` returns the cached value. On a cache miss, it calls your callback, stores the return value and returns it. If the callback sets its `bool &$save` argument to `false`, the pool does not store the value. Entry point: `Symfony\Contracts\Cache\CacheInterface::get()` and `::delete()`.
- **Expiration:** in the callback, set the lifetime of the item with `$item->expiresAfter(3600)` (seconds or `\DateInterval`) or `$item->expiresAt()`. A pool can also have a default lifetime. Entry point: `Symfony\Contracts\Cache\ItemInterface`, `framework.cache.pools.<name>.default_lifetime`.
- **Pools and namespaces:** a pool is a logical store of items. Keys of two pools never collide, even on the same backend, because each pool adds a namespace prefix. Symfony calculates the namespace from a hash of the pool name, the adapter class and the `prefix_seed` value. The default `prefix_seed` contains the project directory. If each deployment uses a new directory, set `prefix_seed` to a constant value, for example the application name. Entry point: `framework.cache.pools`, `framework.cache.prefix_seed`.
- **Built-in pools:** `cache.app` is the general data pool for your code. It uses the filesystem by default, and the docs recommend Redis when it is available. `cache.system` holds data that Symfony derives from the source code (for example, validator and serializer metadata). Treat `cache.system` as read-only after deployment. Entry point: `framework.cache.app`, `framework.cache.system`.
- **Adapters and providers:** an adapter is the storage backend. Symfony has adapter templates for the filesystem, APCu, Redis, Valkey, Memcached, Doctrine DBAL, PDO, memory (array) and any PSR-6 pool. A provider is the connection of the adapter. If you give a DSN such as `redis://localhost`, Symfony creates the connection service for you. Entry point: the `cache.adapter.*` services, `framework.cache.pools.<name>.provider`, `Symfony\Component\Cache\Adapter\AbstractAdapter::createConnection()`.
- **Chain (multi-level cache):** a chain reads an item from the first adapter that has it and writes items to all adapters. Put the fastest adapter first. Entry point: `framework.cache.pools.<name>.adapters` (a list), `Symfony\Component\Cache\Adapter\ChainAdapter`.
- **Tags:** attach tags with `$item->tag(['product-42'])`. Then `invalidateTags(['product-42'])` invalidates all items that have one of these tags. Set `tags: true` on a pool. To keep the tags in a different pool, set `tags: <other pool>`. For Redis and for the filesystem, use the optimized `RedisTagAwareAdapter` (`cache.adapter.redis_tag_aware`) and `FilesystemTagAwareAdapter`. `RedisTagAwareAdapter` needs the Redis `maxmemory-policy` `noeviction` or `volatile-*`, and Redis compression must be off. Entry point: `Symfony\Contracts\Cache\TagAwareCacheInterface`, `Symfony\Component\Cache\Adapter\TagAwareAdapter`.
- **Sub-namespaces:** `withSubNamespace('user-42')` returns a view of the pool that prefixes all keys, for example per user or per locale. `clear()` on that pool deletes only the items of its sub-namespace, for example with the filesystem, Redis and PDO adapters. Memcached and Couchbase pools use namespace versioning, so there `clear()` invalidates the whole pool. Entry point: `Symfony\Contracts\Cache\NamespacedPoolInterface::withSubNamespace()`.
- **Stampede protection with a lock:** on a cache miss, only one process per host computes a given key. The other processes wait, then read the value that the first process stored. The lock is a `flock()` on local files, so it does not work across hosts. The lock is off in CLI processes (`cli`, `phpdbg` and `embed` SAPIs) and on Windows. The PSR-6 methods (`getItem()`, `save()`) have no stampede protection. Entry point: automatic in `CacheInterface::get()` (`Symfony\Component\Cache\LockRegistry`).
- **Probabilistic early expiration:** before an item expires, `get()` recomputes it for one random request, while the other requests get the cached value. The third argument `$beta` controls this behavior: `1.0` is the default, a larger value recomputes earlier, `0` disables it, and `INF` recomputes now. It works only for items that have an expiration. Entry point: `CacheInterface::get($key, $callback, $beta)`.
- **Asynchronous computation:** when early expiration selects an item, the pool returns the cached value at once and sends an `EarlyExpirationMessage` to a Messenger bus. A worker then computes the new value. Use a service as the callback, for example a class that implements `CallbackInterface`. If the callback is an anonymous closure, the pool computes the value at once. Route `EarlyExpirationMessage` to an asynchronous transport. Entry point: `framework.cache.pools.<name>.early_expiration_message_bus`, `Symfony\Contracts\Cache\CallbackInterface`, `Symfony\Component\Cache\Messenger\EarlyExpirationMessage`.
- **Marshallers:** a marshaller converts values to strings before the backend stores them. `DefaultMarshaller` uses `serialize()`, or `igbinary_serialize()` if you request it. `DeflateMarshaller` compresses the result with zlib. By default, the pools use the `cache.default_marshaller` service. In debug mode, this service throws a `\ValueError` when PHP cannot serialize a value. Since 8.1, the pool option `marshaller` sets a different marshaller for one pool. Entry point: `Symfony\Component\Cache\Marshaller\MarshallerInterface`, `cache.default_marshaller`, `framework.cache.pools.<name>.marshaller`.
- **Encryption:** `SodiumMarshaller` encrypts the cached values with libsodium. Make a key with `sodium_crypto_box_keypair()`. Add the key to the secrets store. The first key encrypts and decrypts, and the other keys only decrypt, so you can rotate keys. The cache keys stay in clear text. Entry point: `Symfony\Component\Cache\Marshaller\SodiumMarshaller` (decorate `cache.default_marshaller`, or use the pool option `marshaller`).
- **PSR-6 and PSR-16 interoperability:** all adapters implement PSR-6 (`Psr\Cache\CacheItemPoolInterface`). `Psr16Cache` wraps a PSR-6 pool as a PSR-16 cache, and `Psr16Adapter` wraps a PSR-16 cache as a PSR-6 pool. `ProxyAdapter` (`cache.adapter.psr6`) wraps a third-party PSR-6 pool. `symfony/cache` does not install `psr/simple-cache`. To use `Psr16Cache`, require `psr/simple-cache`. Entry point: `Symfony\Component\Cache\Psr16Cache`, `Symfony\Component\Cache\Adapter\Psr16Adapter`.
- **Prune, clear and inspect:** `prune()` deletes expired items from adapters that implement `PruneableInterface` (for example filesystem, PHP files, PDO and Doctrine DBAL). Console commands list the pools, clear them, delete one item, prune expired items and invalidate tags. Entry point: `Symfony\Component\Cache\PruneableInterface`, `cache:pool:prune`, `cache:pool:clear`.

## Entry points

- Autowire `Symfony\Contracts\Cache\CacheInterface`: injects `cache.app` (`get()`, `delete()`).
- Autowire `Symfony\Contracts\Cache\TagAwareCacheInterface`: injects `cache.app.taggable`, a `TagAwareAdapter` around `cache.app` (adds `invalidateTags()`).
- Autowire `Symfony\Contracts\Cache\NamespacedPoolInterface`: injects `cache.app` (adds `withSubNamespace()`).
- Autowire `Psr\Cache\CacheItemPoolInterface`: injects `cache.app` (PSR-6 `getItem()`, `save()`, `deleteItem()`; no stampede protection).
- `Symfony\Contracts\Cache\ItemInterface`: the type of the callback argument (`expiresAfter()`, `expiresAt()`, `tag()`, `isHit()`, `getMetadata()`).
- `Symfony\Contracts\Cache\CallbackInterface`: a callback service for asynchronous computation.
- `#[Symfony\Component\DependencyInjection\Attribute\Target('<pool name>')]`: injects a custom pool with one of the four interfaces above.
- `framework.cache`: `app`, `system`, `directory`, `prefix_seed`, `default_redis_provider`, `default_valkey_provider`, `default_memcached_provider`, `default_doctrine_dbal_provider`, `default_pdo_provider`, `default_psr6_provider`, `pools`.
- `framework.cache.pools.<name>`: `adapter` (or `adapters` for a chain), `provider`, `default_lifetime`, `tags`, `public`, `clearer`, `early_expiration_message_bus`, `marshaller`.
- Adapter templates: `cache.adapter.filesystem`, `cache.adapter.apcu`, `cache.adapter.redis`, `cache.adapter.redis_tag_aware`, `cache.adapter.valkey`, `cache.adapter.valkey_tag_aware`, `cache.adapter.memcached`, `cache.adapter.doctrine_dbal`, `cache.adapter.pdo`, `cache.adapter.array`, `cache.adapter.psr6`, `cache.adapter.system`.
- Services: `cache.app`, `cache.system`, `cache.app.taggable`, `cache.default_marshaller`; clearers `cache.global_clearer`, `cache.system_clearer`, `cache.app_clearer`.
- Service tag `cache.pool`: makes your own adapter service a pool (attributes `clearer`, `provider`, `name`, `namespace`, `default_lifetime`, `early_expiration_message_bus`, `reset`, `pruneable`, `marshaller`).
- Console commands: `cache:pool:list`; `cache:pool:clear <pools>...` (`--all`, `--exclude`; a clearer ID such as `cache.global_clearer` also works); `cache:pool:delete <pool> <key>`; `cache:pool:prune`; `cache:pool:invalidate-tags <tags>...` (`--pool`, `-p`).
- Without FrameworkBundle: `Symfony\Component\Cache\Adapter\FilesystemAdapter`, `RedisAdapter` with `RedisAdapter::createConnection('redis://localhost')`, `ApcuAdapter`, `ChainAdapter`, `TagAwareAdapter`, `PhpArrayAdapter` (`warmUp()`), `Symfony\Component\Cache\Psr16Cache`, `Symfony\Component\Cache\Adapter\Psr16Adapter`.
- Tests: `Symfony\Component\Cache\Adapter\ArrayAdapter` (in memory; accepts a PSR-20 clock for predictable lifetimes). Since 8.1.1, its second argument is `$deepClone`. The docs name it `$storeSerialized`.
- Tests: `Symfony\Component\Cache\Adapter\NullAdapter` (stores nothing; `get()` always calls the callback).

## Symbiotic packages

- [HttpKernel](../packages/http-kernel.md): the HTTP cache of HttpKernel (`#[Cache]` attribute, `HttpCache` reverse proxy) caches full HTTP responses, and Cache stores data inside your code, for example query results.
- [FrameworkBundle](../packages/framework-bundle.md): FrameworkBundle creates the pools from `framework.cache`, registers the autowiring aliases and adds the `cache:pool:*` commands.
- [Symfony Contracts](../packages/contracts.md): `symfony/cache-contracts` defines the interfaces that you type-hint (`CacheInterface`, `TagAwareCacheInterface`, `NamespacedPoolInterface`, `ItemInterface`), and the pools and items of this package implement them.
- [Messenger](../packages/messenger.md): with the pool option `early_expiration_message_bus`, a Messenger worker computes early-expired values from `EarlyExpirationMessage`.
- [HttpClient](../packages/http-client.md): `CachingHttpClient` stores HTTP responses in a tag-aware pool that the client option `caching.cache_pool` selects (default `cache.http_client`).
- [RateLimiter](../packages/rate-limiter.md): limiters keep their state in the `cache.rate_limiter` pool by default, and the limiter option `cache_pool` selects a different pool.
- [Lock](../packages/lock.md): the stampede lock of `get()` works per host, while Lock with a remote store lets only one process on all servers run a task.
- [Security](../packages/security-bundle.md): login links with `max_uses` store the used links in a pool (`used_link_cache`), and OIDC token handlers keep the discovery data in a pool (`discovery.cache.id`).
- [HttpFoundation](../packages/http-foundation.md): to encrypt session data, decorate the `session.marshaller` service (it implements `MarshallerInterface` of this package) with `SodiumMarshaller`.
- [Scheduler](../packages/scheduler.md): a stateful schedule (`->stateful($cache)`) keeps its last run date in a cache pool, so a restarted worker handles the missed messages.
- [ExpressionLanguage](../packages/expression-language.md): `ExpressionLanguage` keeps parsed expressions in a PSR-6 pool (an `ArrayAdapter` by default), and its constructor accepts a different pool.
- [Doctrine Bridge](../packages/doctrine-bridge.md): `DoctrineDbalCacheAdapterSchemaListener` adds the table of `DoctrineDbalAdapter` to the schema that Doctrine ORM generates.
- [VarExporter](../packages/var-exporter.md): this package requires VarExporter, because `PhpFilesAdapter` and `PhpArrayAdapter` export values as PHP code and `ArrayAdapter` copies values with `DeepCloner`.
- [WebProfilerBundle](../packages/web-profiler-bundle.md): when the profiler is on, `TraceableAdapter` records each pool call, and the cache panel shows calls, hits, misses, reads, writes and deletes.
- [DependencyInjection](../packages/dependency-injection.md): `#[Target('<pool name>')]` selects a custom pool, and 8.1 deprecates the injection by argument name only.
- [Clock](../packages/clock.md): `ArrayAdapter` accepts a PSR-20 clock, for example `MockClock`, to test item lifetimes.
- [Config](../packages/config.md): `ConfigCache` keeps a generated code file fresh against its source files; use a cache pool to cache application data.

## Changed in 8.0/8.1

- 8.0 removes `CouchbaseBucketAdapter` -> use `CouchbaseCollectionAdapter`.
- 8.1 deprecates the injection of a pool by argument name (`CacheInterface $customThingCache`) -> `#[Target('custom_thing.cache')] CacheInterface $cache`.
- 8.1 adds the pool option `marshaller`. If only some pools need a different marshaller, use this option, not a decoration of `cache.default_marshaller`.

## Status

The component itself needs no PHP extension. Some adapters and marshallers need one:
- `ApcuAdapter`: ext-apcu with `apc.enabled`.
- `RedisAdapter` and `RedisTagAwareAdapter`: ext-redis 6.1 or higher, ext-relay 0.12.1 or higher, or `predis/predis`.
- `MemcachedAdapter`: ext-memcached 3.1.6 or higher.
- `CouchbaseCollectionAdapter`: ext-couchbase 3.0.5 or higher, and lower than 4.0.
- `PhpFilesAdapter` and `PhpArrayAdapter`: the docs require OPcache (`opcache.enable`).
- `SodiumMarshaller`: ext-sodium. `DeflateMarshaller`: ext-zlib. `DefaultMarshaller` with igbinary: ext-igbinary 3.1.6 or higher.

## Docs

- https://symfony.com/doc/current/cache.html
- https://symfony.com/doc/current/reference/configuration/framework.html
- https://symfony.com/doc/current/cache/adapters/redis_adapter.html
- https://symfony.com/doc/current/cache/adapters/filesystem_adapter.html
- https://symfony.com/doc/current/cache/adapters/apcu_adapter.html
- https://symfony.com/doc/current/cache/adapters/memcached_adapter.html
- https://symfony.com/doc/current/cache/adapters/doctrine_dbal_adapter.html
- https://symfony.com/doc/current/cache/adapters/pdo_adapter.html
- https://symfony.com/doc/current/cache/adapters/chain_adapter.html
- https://symfony.com/doc/current/cache/adapters/array_cache_adapter.html
- https://symfony.com/doc/current/cache/adapters/php_files_adapter.html
- https://symfony.com/doc/current/cache/adapters/php_array_cache_adapter.html
- https://symfony.com/doc/current/cache/adapters/proxy_adapter.html
- https://symfony.com/doc/current/cache/adapters/couchbasecollection_adapter.html
- https://symfony.com/doc/current/http_cache.html (use it instead for full HTTP responses)
