# Lock (`symfony/lock`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when two processes must not run the same code at the same time, for example overlapping cron jobs or a race condition. It gives a mutex on one server, or across servers through Redis, SQL or DynamoDB. To allow N processes at the same time, see [Semaphore](semaphore.md).

**Details:** [../details/lock.md](../details/lock.md)

## Why it exists

Code that changes a file, a row or another resource can break when two processes run it at the same time. The package gives a named lock to one process at a time, on one server or across servers. A lock can expire after a time limit, so a crashed process does not keep it forever. The package also supports a wait until the lock is free, read locks and the release of a lock by another process.

## When to use it

- Make sure that only one process runs a command-line script or a cron job at a time.
- Let only one request or worker generate a file or report that many requests need.
- Lock one record by its ID, for example one order, so that other records stay available.
- Share one lock between servers through Redis, an SQL database, MongoDB, ZooKeeper or DynamoDB.
- Give readers parallel access and a writer exclusive access to the same data, with a read-write lock.
- Free the lock of a crashed process automatically after a time limit.
- Transfer an acquired lock to another process, for example to a queue worker that continues the job.
- Let only one of several workers create the tasks of a recurring schedule, with [Scheduler](scheduler.md).

## Use it instead of

- `flock(fopen('/tmp/import.lock', 'c'), LOCK_EX | LOCK_NB)` in a script -> `$lock = $lockFactory->createLock('import'); $lock->acquire();`, or `LockableTrait::lock()` in a command.
- A PID file (`file_put_contents('var/import.pid', getmypid())` plus a `posix_kill($pid, 0)` check) -> `LockableTrait` in the command. With the default local store, the lock ends when the process ends.
- `$redis->set('lock:report', $token, ['nx', 'ex' => 60])` plus a Lua script that deletes only your token -> `RedisStore` through `framework.lock: '%env(LOCK_DSN)%'` and `LOCK_DSN=redis://…`. `release()` deletes only the lock of the owner.
- A database flag (`UPDATE jobs SET running = 1 WHERE id = ? AND running = 0`) or a `locked_until` column -> `PdoStore` or `DoctrineDbalStore`, with a TTL and `refresh()`.
- `SELECT pg_try_advisory_lock(42)` -> `PostgreSqlStore` or `DoctrineDbalPostgreSqlStore` (`pgsql+advisory:` or `postgresql+advisory://` DSN), with `acquire(true)` for a native wait.
- `while (!$lock->acquire()) { usleep(100000); }` -> `$lock->acquire(true)`.
- `touch()` on a lock file, or an `expires_at` update in a loop -> `$lock->refresh()` with `getRemainingLifetime()`.
- A lock token in a message or in the cache, so that a worker can delete the lock -> a serialized `Key`. Before the dispatch, acquire the lock with `createLockFromKey($key, $ttl, false)`. In the worker, call `createLockFromKey($key)->release()`.
