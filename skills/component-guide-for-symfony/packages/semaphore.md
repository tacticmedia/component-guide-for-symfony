# Semaphore (`symfony/semaphore`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when at most N processes may use a resource at the same time, for example an external API or a CPU-heavy job. It sets a concurrency limit on one or more servers, and a large job can take several slots. For one holder, see [Lock](lock.md). For N events per time interval, see [RateLimiter](rate-limiter.md).

**Details:** [../details/semaphore.md](../details/semaphore.md)

## Why it exists

Some resources accept only a limited number of users at the same time, for example a remote API or a CPU-heavy job. A hand-written counter in a database or in Redis does not free the slot of a crashed process. The package allows at most N holders of a resource at the same time. A holder frees its slot at release, or after a time limit in an expiring store such as Redis.

## When to use it

- Allow at most N parallel calls to an external API or web service.
- Run at most N heavy jobs at the same time, on one or more servers, for example PDF generation, video conversion or imports.
- Give a large job more slots than a small job, for example 3 of 10 slots for a full import.
- Keep a slot that a web request acquires until a background worker releases it.
- Share a pool of N licenses or connections between processes.
- Limit concurrency with the [Lock](lock.md) storage that the application already uses, for example lock files, PDO or Redis.

## Use it instead of

- `$redis->incr('pdf_jobs')` with a `> 2` check, plus `$redis->decr('pdf_jobs')` in `finally` -> `$factory->createSemaphore('pdf-jobs', 2)` with `acquire()` and `release()`. The TTL frees the slot of a crashed process.
- A slot counter in a database table (`UPDATE job_slots SET used = used + 1 WHERE used < 3`) -> `SemaphoreFactory` with a Redis store, or `framework.semaphore: 'lock://'` with a PDO Lock store.
- A loop over numbered locks (`$lock = $lockFactory->createLock('pdf_'.$i); if ($lock->acquire()) { break; }`) -> `LockStore` through `framework.semaphore: 'lock://'`, which does the same with weights and release.
- PHP System V semaphores (`sem_get($key, 3)` and `sem_acquire()`), which work on one machine only -> `SemaphoreFactory` with `RedisStore` for several servers.
- A count of running workers (`exec('pgrep -c pdf-worker')`) or of `running` rows before a job starts -> `acquire()`, which returns `false` when all slots are in use.
- A `LockFactory::createLock()` lock when 2 or more processes may run the code at the same time -> `SemaphoreFactory::createSemaphore($resource, $limit)`.
- A slot token in a cache item or a file that a worker must delete -> a serialized `Key`, with `createSemaphoreFromKey($key, $ttl, false)` and `release()` in the worker.
