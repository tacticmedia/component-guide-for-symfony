# Scheduler (`symfony/scheduler`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when jobs must run on a recurring schedule, for example each night at 03:00 or every 10 minutes, without crontab entries. A long-running worker process runs them, with random delays, locks and catch-up of missed runs. For a one-time delay of a job, see [Messenger](messenger.md).

**Details:** [../details/scheduler.md](../details/scheduler.md)

## Why it exists

Cron jobs live outside the application. The deployment process must add or edit them, and they cannot change when application data changes. The package keeps the schedule in PHP code. A long-running worker process creates each recurring job when it is due and runs it.

## When to use it

- Run a task at fixed times, for example a database cleanup each night at 03:00.
- Run a command-line command on a cron expression without a crontab entry.
- Repeat a task at a fixed interval, for example every 10 minutes.
- Run an external program or send an HTTP health check on a schedule.
- Spread the start times of many scheduled tasks to prevent load spikes.
- Run the tasks that a stopped worker missed, after a restart or a deployment.
- Run scheduler workers on several servers, but generate each run only once.
- Run long scheduled tasks in parallel, with retries for the tasks that fail.
- Add, remove or skip scheduled tasks at runtime, based on application data.
- List the scheduled tasks and their next run dates.
- Run schedules in a plain PHP program without the full framework.

## Use it instead of

- A crontab line such as `0 3 * * * php /path/to/bin/console app:purge-logs` -> `#[AsCronTask('0 3 * * *')]` on the command class, plus one `messenger:consume scheduler_default` worker.
- A crontab line that starts a shell script -> `RecurringMessage::cron('0 2 * * *', new RunProcessMessage(['/usr/local/bin/backup.sh'], timeout: 3600))`. The default timeout of `RunProcessMessage` is 60 seconds.
- A crontab line such as `*/5 * * * * curl -fsS https://example.com/status` -> `RecurringMessage::every('5 minutes', new PingWebhookMessage('GET', 'https://example.com/status'))`. The handler throws on a 3xx, 4xx or 5xx response.
- A long-running command with `while (true) { $this->sync(); sleep(600); }` -> `#[AsPeriodicTask(frequency: '10 minutes')]` on the service, or `RecurringMessage::every('10 minutes', $message)`.
- `sleep(random_int(0, 60));` at the start of a cron task -> `jitter: 60` on the attribute, `RecurringMessage::withJitter(60)`, or a hashed expression such as `'#midnight'`.
- A `flock -n /tmp/job.lock` wrapper, or a rule that cron runs on one server only -> `Schedule::lock($lockFactory->createLock('schedule-default'))` with a remote lock store.
- A `last_run_at` database row that a cron script reads to repeat missed jobs -> `Schedule::stateful($cache)` plus `processOnlyLastMissedRun(true)`.
- `if ($this->isHoliday(new \DateTimeImmutable())) { return; }` at the start of a task -> a custom `TriggerInterface` decorator, `ExcludeTimeTrigger`, or `PreRunEvent::shouldCancel(true)` in a listener.
- `crontab -l` to see what runs and when -> `php bin/console debug:scheduler`.
- An "add or edit cron jobs" step in the deployment script -> the schedule in code. After the deployment, run `messenger:stop-workers`; the process manager then restarts the worker.
