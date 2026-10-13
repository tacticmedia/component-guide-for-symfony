# Lock (`symfony/lock`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Lock factory and resource name:** `LockFactory::createLock($resource, $ttl = 300.0, $autoRelease = true)` returns a new `SharedLockInterface` object for the resource name. Each object is a separate owner, also inside one process. A second `acquire()` call on the same object returns `true` and does not wait. If several services need exclusive access to one resource, give each service its own object from `createLock()`.
- **Blocking mode:** `acquire()` returns `false` immediately when another owner holds the lock. `acquire(true)` waits until the lock is free. If the store does not implement `BlockingStoreInterface`, the lock object tries again about every 100 milliseconds. If the wait fails, `acquire(true)` throws `LockConflictedException`. If the store fails, `acquire()` throws `LockAcquiringException`.
- **TTL and refresh:** the second argument of `createLock()` is the TTL in seconds (default `300.0`). An expiring store frees the lock after the TTL, so a crashed process cannot keep the lock forever. For a long task, call `refresh()` before the TTL ends. Call `release()` in a `finally` block, so that the code also releases the lock after an exception. `refresh(600)` sets a TTL of 600 seconds for this call only. `getRemainingLifetime()` and `isExpired()` use the local expiry time, and `isAcquired()` asks the store. With a `null` TTL, `RedisStore`, `MemcachedStore`, `PdoStore`, `DoctrineDbalStore`, `MongoDbStore` and `DynamoDbStore` still free the lock after their initial TTL of 300 seconds. In that case, `refresh()` without an argument throws `InvalidArgumentException`.
- **Automatic release:** a lock object releases its lock when PHP destroys the object, for example at the end of the process. Keep the lock object in a variable. A chained call such as `$factory->createLock('a')->acquire()` releases the lock immediately, because PHP destroys the lock object after the call. To keep the lock after the object ends, pass `false` as the third argument (`$autoRelease`). Then an expiring store keeps the lock until a `release()` call or the end of the TTL. A store without expiry frees the lock at the latest when the process or the store connection ends.
- **Owner:** `isAcquired()` returns `true` only if this object holds the lock. To check if another process holds the lock, call `acquire()`. A `release()` call on an object that does not own the lock does nothing.
- **Read locks:** `acquireRead()` gets a read lock, and several owners can hold read locks at the same time. `acquire()` changes a read lock into a write lock, and `acquireRead()` changes a write lock into a read lock. If the store does not implement `SharedLockStoreInterface`, `acquireRead()` gets a write lock. The store sets the priority between readers and writers; `RedisStore` prefers readers.
- **Stores:** a DSN selects the store. The store properties are the scope (local or remote), the wait in `acquire(true)` (native or retry), expiry, read locks and key serialization.
  - `FlockStore` (`flock`, `flock://<directory>`): lock files in a local directory, by default `sys_get_temp_dir()`. Local, native wait, no expiry, read locks, no key serialization.
  - `SemaphoreStore` (`semaphore`, `semaphore://<project-id>`): System V semaphores (`sysvsem` extension). Local, native wait, no expiry, no read locks, no key serialization.
  - `RedisStore` (`redis://`, `rediss://`, `valkey://`, `valkeys://`): Redis or Valkey. The service ID of a `\Redis`, Relay or Predis client also works. Remote, retry, expiry, read locks, key serialization.
  - `MemcachedStore` (`memcached://`): remote, retry, expiry (TTL of 1 second or more), no read locks, key serialization.
  - `PdoStore` (PDO DSN, for example `mysql:host=…` or `sqlite:…`) and `DoctrineDbalStore` (Doctrine URL, for example `mysql://…` or `sqlite:///…`): an SQL table, by default `lock_keys`. Remote, retry, expiry (TTL of 1 second or more), no read locks, key serialization. The first `save()` creates the table, and `createTable()` creates it in advance.
  - `PostgreSqlStore` (`pgsql+advisory:host=…`) and `DoctrineDbalPostgreSqlStore` (`postgresql+advisory://…`): PostgreSQL advisory locks, which end with the database session. Remote, native wait (also for read locks), no expiry, read locks, no key serialization.
  - `MongoDbStore` (`mongodb://<host>/<database>?collection=<name>`): remote, retry, expiry, no read locks, key serialization. A TTL index deletes the old lock documents, and `createTtlIndex()` creates the index.
  - `ZookeeperStore` (`zookeeper://host1,host2:2181`): ephemeral nodes. Remote, retry, no expiry, no read locks, no key serialization.
  - `DynamoDbStore` (`dynamodb://default/<table>`, package `symfony/amazon-dynamo-db-lock`): a DynamoDB table, by default `lock_keys`. Remote, retry, expiry (TTL of 1 second or more), no read locks, key serialization. The first `save()` creates the table, and `createTable()` creates it in advance.
  - `CombinedStore`: several stores with `ConsensusStrategy` (a majority) or `UnanimousStrategy` (all stores). A list of DSNs in `framework.lock` creates it with the majority strategy.
  - `InMemoryStore` (`in-memory`) keeps the locks in the PHP process, and `NullStore` (`null`) keeps nothing. Use them in tests.
- **Lock or Semaphore:** a lock has one owner, or several owners of a read lock. If up to N processes can use a resource at the same time, use `SemaphoreFactory::createSemaphore($resource, $limit)` from `symfony/semaphore`. Since 8.1, `framework.semaphore: 'lock://'` uses a Lock store as the semaphore backend.
- **Transfer to another process:** to continue a locked job in another process, create the lock from a `Key`: `$key = new Key('article.'.$id); $lock = $factory->createLockFromKey($key, 300, false); $lock->acquire(true);`. The `false` argument stops the automatic release. Send the `Key` with the job, for example in a Messenger message. PHP `serialize()` and the Serializer (`LockKeyNormalizer`) can serialize a `Key`. In the other process, call `$factory->createLockFromKey($key)->release()`. `FlockStore`, `SemaphoreStore`, `PostgreSqlStore`, `DoctrineDbalPostgreSqlStore` and `ZookeeperStore` mark the key as not serializable, so `serialize()` throws `UnserializableKeyException`. Do not serialize the `Lock` object, because it throws `BadMethodCallException`.
- **Framework configuration:** `framework.lock` takes one DSN, a list of DSNs or a map of named resources. A value without `:` and without `%env()%` is a service ID, except `flock`, `semaphore`, `in-memory` and `null`. The service can be any client that `StoreFactory::createStore()` accepts, for example a `\Redis`, `\PDO` or Doctrine DBAL `Connection` object. A list of DSNs for one resource creates a `CombinedStore`. A string with commas stays one DSN and does not create several stores. Write several stores as a YAML or PHP list. Without a value, the default store is `semaphore` if the `sysvsem` extension is loaded, else `flock`.
- **Named locks:** each resource `<name>` gets the service `lock.<name>.factory`. Inject it with `#[Target('<name>')] LockFactory $lockFactory`. The `LockFactory` autowiring alias and the `lock.factory` service exist only for the resource `default`. Without a `default` resource, Messenger adds no deduplicate middleware, and a rate limiter with `lock_factory: auto` uses no lock. If you add named resources, also keep a `default` resource.
- **Project scope (8.1):** the literal values `flock` and `semaphore` create stores that are specific to the project directory. This also applies to the default store. The flock directory is a `symfony-lock/<hash>` subdirectory of `sys_get_temp_dir()`, and the semaphore keys include `%kernel.project_dir%`. There is no automatic scope for `flock://…`, for a `%env()%` value and for the default store of `LockableTrait`. The Flex recipe writes `framework.lock: '%env(LOCK_DSN)%'` with `LOCK_DSN=flock`, so it creates a `FlockStore` without scope. If several applications share one server, write `framework.lock: flock` (or `semaphore`), or set `LOCK_DSN=semaphore://<project-id>`.
- **Console commands:** `use LockableTrait;` adds `lock(?string $name = null, bool $blocking = false): bool` and `release()` to a command. If `lock()` returns `false`, another process runs the command. In that case, return from the command. The lock name is `Command::getName()` or the name of a class-level `#[AsCommand]`. For a method command, pass a name to `lock()`. By default, the trait uses a local `SemaphoreStore` or `FlockStore` without project scope. To use the application store, set `$this->lockFactory = $lockFactory;` in the constructor, without constructor property promotion. The trait uses the default TTL of 300 seconds and never calls `refresh()`. If the command runs longer than 300 seconds, an expiring store can give the lock to another process.
- **Reliability rules:**
  - Remote stores identify the owner with a unique token in the `Key`. All processes must use the same server. Do not put Memcached behind a load balancer, a cluster or round-robin DNS.
  - Choose a TTL that is longer than one step of the task plus the network delay. Before each step, check `getRemainingLifetime()`. If the remaining time is short, call `refresh()`.
  - A change of the server date or time can end a lock too early. The docs recommend that you disable NTP and change the date only while the service is stopped. `PdoStore`, `DoctrineDbalStore` and `MongoDbStore` also need synchronized clocks on all nodes. `DynamoDbStore` also uses the clock of the PHP server for the expiry.
  - Redis, Memcached, ZooKeeper and PostgreSQL lose all locks when they restart, and they do not tell the processes. If Redis or Memcached restarts, delay the service start for the longest lock TTL.
  - Do not call `FLUSHDB` on Redis or `flush()` on Memcached. Keep the locks on a dedicated server, not on the cache server.
  - Remote stores make the storage key from the resource name only, without an application prefix. If applications share a Redis database, an SQL table or another remote store, use unique resource names.
  - `FlockStore` and `SemaphoreStore` are reliable only when all processes run on one machine. `FlockStore` also needs the same absolute directory path in all processes. During a Kubernetes or Swarm update, two containers can run at the same time. Some NFS types do not support file locks. A `/tmp` cleanup or a `tmpfs` reboot deletes the lock files.
  - With systemd and `RemoveIPC=yes`, systemd deletes the semaphores of a non-system user at logout. Run the process as a system user, or set `RemoveIPC=off`.
  - A `CombinedStore` is at best as reliable as its least reliable store. With `ConsensusStrategy`, use at least 3 servers.
  - During a deployment, do not start processes with a new store configuration while old processes still run.

## Entry points

- `Symfony\Component\Lock\LockFactory`: autowire it for the `default` resource (service `lock.factory`). Methods: `createLock()`, `createLockFromKey()`. There is no `LockInterface` service.
- Without FrameworkBundle: create the factory with `new LockFactory($store)`. `StoreFactory::createStore()` creates the store from a DSN or a client object.
- `#[Symfony\Component\DependencyInjection\Attribute\Target('<name>')] LockFactory $lockFactory`: the factory of a named resource (service `lock.<name>.factory`).
- `Symfony\Component\Lock\SharedLockInterface` (extends `Symfony\Component\Lock\LockInterface`): `acquire()`, `acquireRead()`, `refresh()`, `isAcquired()`, `release()`, `isExpired()`, `getRemainingLifetime()`.
- `Symfony\Component\Lock\Key`: the state of a lock. Serialize it to transfer the lock to another process.
- Config: `framework.lock` (string, list or map), `framework.lock.enabled`, `framework.lock.resources.<name>`. The Flex recipe adds the env var `LOCK_DSN`.
- Console: `Symfony\Component\Console\Command\LockableTrait`, with `lock()` and `release()`.
- Stores (namespace `Symfony\Component\Lock\Store`): `FlockStore`, `SemaphoreStore`, `RedisStore`, `MemcachedStore`, `PdoStore`, `DoctrineDbalStore`, `PostgreSqlStore`, `DoctrineDbalPostgreSqlStore`, `MongoDbStore`, `ZookeeperStore`, `CombinedStore`, `InMemoryStore`, `NullStore`. `StoreFactory::createStore()` creates a store from a DSN or a client object.
- DynamoDB store: `Symfony\Component\Lock\Bridge\DynamoDb\Store\DynamoDbStore` (package `symfony/amazon-dynamo-db-lock`).
- Strategies for `CombinedStore`: `Symfony\Component\Lock\Strategy\ConsensusStrategy`, `Symfony\Component\Lock\Strategy\UnanimousStrategy`.
- Serializer: `Symfony\Component\Lock\Serializer\LockKeyNormalizer` (service `serializer.normalizer.lock_key`).
- Custom store: implement `Symfony\Component\Lock\PersistingStoreInterface`, and optionally `BlockingStoreInterface`, `SharedLockStoreInterface` or `BlockingSharedLockStoreInterface`.
- Exceptions (namespace `Symfony\Component\Lock\Exception`): `LockConflictedException`, `LockAcquiringException`, `LockReleasingException`, `LockExpiredException`, `UnserializableKeyException`, `InvalidTtlException`.
- Tests: `InMemoryStore` (`LOCK_DSN=in-memory`), `NullStore` (`LOCK_DSN=null`), `Symfony\Component\Lock\NoLock` (a lock that always succeeds) and `Symfony\Component\Lock\Test\AbstractStoreTestCase` (a PHPUnit base test for a custom store).
- Logs: the Monolog channel `lock`.
- The package has no console commands, no Twig functions and no PHP attributes.

## Symbiotic packages

- [Console](../packages/console.md): `LockableTrait` adds `lock()` and `release()` to a command. Without a `$lockFactory`, it uses a local `SemaphoreStore` or `FlockStore`.
- [Semaphore](../packages/semaphore.md): if up to N processes can use a resource at the same time, use Semaphore; Lock allows one owner. Semaphore `LockStore` and `framework.semaphore: 'lock://'` use a Lock factory as the semaphore backend.
- [Messenger](../packages/messenger.md): `DeduplicateStamp` and the deduplicate middleware use `lock.factory` to skip duplicate messages. The middleware exists only when `framework.lock` has a `default` resource.
- [Scheduler](../packages/scheduler.md): `Schedule::lock()` takes a lock, so only one of several workers generates the messages of a schedule.
- [RateLimiter](../packages/rate-limiter.md): a limiter locks its state with `lock.factory` (option `lock_factory`, default `auto`). RateLimiter counts events in a time interval; Lock gives exclusive access to one task.
- [Security](../packages/security-bundle.md): since 8.1.6, `login_throttling` gives `lock.factory` to its limiters by default (`lock_factory: auto`).
- [Cache](../packages/cache.md): the `redis:`, `rediss:`, `valkey:`, `valkeys:` and `memcached:` DSNs need `symfony/cache`. To compute a cache value only once per host, use `CacheInterface::get()`, which has its own stampede lock (off in CLI processes and on Windows).
- [Doctrine Bridge](../packages/doctrine-bridge.md): `LockStoreSchemaListener` adds the table of a `DoctrineDbalStore` to the Doctrine schema, so `make:migration` creates it.
- [Serializer](../packages/serializer.md): `LockKeyNormalizer` normalizes a `Key` for the transfer to another process.
- [FrameworkBundle](../packages/framework-bundle.md): `framework.lock` creates the stores, the factories, the autowiring aliases and the `Key` normalizer service.
- [DependencyInjection](../packages/dependency-injection.md): `#[Target('<name>')]` selects the factory of a named lock resource.

## Changed in 8.0/8.1

- 8.1: the literal values `framework.lock: flock` and `semaphore` create stores specific to the project directory, so applications on one server do not share locks.
- 8.1: `SemaphoreStore` takes a `$projectId` argument, and the DSN `semaphore://<project-id>` sets it.
- 8.1: Symfony deprecates the injection of a named factory by the argument name only. Write `#[Target('invoice')] LockFactory $lockFactory` instead of `LockFactory $invoiceLockFactory` without an attribute.
- 8.1: Semaphore `LockStore` and `framework.semaphore: 'lock://'` use a Lock store for N parallel processes.
- 8.1: Messenger releases the deduplication lock when a message fails and Messenger does not retry it.
- 8.1.6: `login_throttling` uses `lock.factory` by default (`lock_factory: auto`).
- 8.0 (also 7.4): `LockKeyNormalizer` lets the Serializer transfer a `Key` to another process.
- 8.0 (also 7.4): `DynamoDbStore` in the new package `symfony/amazon-dynamo-db-lock`.

## Status

Some stores need a PHP extension: `SemaphoreStore` needs `sysvsem`, `MemcachedStore` needs `memcached`, `ZookeeperStore` needs `zookeeper` and `MongoDbStore` needs `mongodb`. `RedisStore` needs the `redis` or `relay` extension, or the Predis library. `FlockStore` needs no extension. The Doctrine stores need `doctrine/dbal` 4.3 or later. `DynamoDbStore` needs `async-aws/dynamo-db`.

## Docs

- https://symfony.com/doc/current/lock.html
- https://symfony.com/doc/current/components/lock.html
- https://symfony.com/doc/current/console/lockable_trait.html
- https://symfony.com/doc/current/reference/configuration/framework.html
- https://symfony.com/doc/current/components/semaphore.html
- https://github.com/symfony/dynamo-db-lock
- https://packagist.org/packages/symfony/amazon-dynamo-db-lock
