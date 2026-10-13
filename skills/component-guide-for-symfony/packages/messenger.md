# Messenger (`symfony/messenger`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when slow or unreliable jobs must run in a background worker process, with automatic retries and a store for the jobs that fail. It queues each job in RabbitMQ, Redis, a database, Amazon SQS or Beanstalkd, and a long-running worker handles it. For jobs that recur on a schedule, see [Scheduler](scheduler.md).

**Details:** [../details/messenger.md](../details/messenger.md)

## Why it exists

Some work is too slow or too unreliable for an HTTP request, for example an email, a report or a call to a remote API. A home-made job table or queue script needs its own worker loop, retry logic and failure handling. The package puts each job into a message object. It handles the message at once, or sends it to a queue, and a worker process handles it later with retries.

## When to use it

- Send emails, SMS messages or API calls from a background worker, not in the HTTP request.
- Queue jobs in RabbitMQ, Redis, a database table, Amazon SQS or Beanstalkd.
- Retry a failed job with an exponential delay, and keep the jobs that still fail.
- Delay a job, for example send a reminder one hour after an order.
- Separate commands, queries and events with one message bus for each, as in CQRS.
- Run a command-line command or an external process in a background worker.
- Skip a duplicate job that has the same business key, for example the same order ID.
- Limit how fast a worker processes jobs, for example to respect the quota of an API.
- Handle jobs in groups, not one at a time.
- Exchange JSON messages with other applications through a message broker.

## Use it instead of

- `exec('php bin/console app:report > /dev/null 2>&1 &')` or `fastcgi_finish_request()` to run slow work after the response -> a message on an async transport: `#[AsMessage('async')]`, `MessageBusInterface::dispatch()` and a `messenger:consume async` worker.
- A `jobs` table and a cron script with `SELECT * FROM jobs WHERE status = 'pending'` -> the Doctrine transport: `MESSENGER_TRANSPORT_DSN=doctrine://default` and `messenger:consume`.
- `$redis->lPush('jobs', serialize($job))` and a `while (true) { $redis->brPop(...); }` consumer script -> the Redis transport (`symfony/redis-messenger`) and `messenger:consume`.
- `for ($i = 0; $i < 3; $i++) { try { ...; break; } catch (\Throwable $e) { sleep(2 ** $i); } }` -> the `retry_strategy` of the transport (`max_retries`, `delay`, `multiplier`) and `failure_transport`.
- `$this->handlers[$command::class]->handle($command)` in a home-made command bus -> `MessageBusInterface::dispatch()` with `#[AsMessageHandler]`, and `HandleTrait` for query results.
- `$em->getConnection()->beginTransaction()`, `commit()` and `rollBack()` in each handler -> the `doctrine_transaction` middleware.
- `shell_exec('php bin/console app:import')` or `(new Process([...]))->start()` in a controller -> `RunCommandMessage` or `RunProcessMessage` on an async transport.
- `if ($cache->hasItem('job_'.$orderId)) { return; }` to skip a duplicate job -> `DeduplicateStamp`.
- `usleep(200000)` in a consumer loop to respect an API quota -> the `rate_limiter` option of the transport.
- `json_encode(['type' => 'order.placed', ...])` for another application -> `messenger.transport.symfony_serializer` with `#[AsMessage(serializedTypeName: 'order.placed')]`.
