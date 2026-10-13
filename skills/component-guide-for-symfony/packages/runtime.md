# Runtime (`symfony/runtime`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when you write the web or command-line entry script of a PHP application, or run it in FrankenPHP worker mode. The entry script returns a closure. The package loads the .env files, resolves the closure arguments and runs the returned application.

**Details:** [../details/runtime.md](../details/runtime.md)

## Why it exists

Without the package, each front controller loads the .env files, registers the error handler, creates the request object from superglobals and sends the response. The package moves this code into a runtime class. The application then runs with PHP-FPM, in FrankenPHP worker mode or on another server, and the front controller does not change.

## When to use it

- Write the web front controller of the application.
- Write the command-line entry script of a console application, or a script that runs a single command.
- Run the application in FrankenPHP worker mode, where one PHP process serves many requests.
- Prevent state leaks between requests in FrankenPHP worker mode.
- Load the .env files from another directory or file.
- Get environment variables, the HTTP request or the command-line input in an entry script without superglobals.
- Return a maintenance page from the front controller instead of the full application.
- Send the response to the client before slow cleanup work runs, with PHP-FPM.
- Run the application on another server, for example Swoole or AWS Lambda, with a custom runtime class.

## Use it instead of

- `require dirname(__DIR__).'/vendor/autoload.php'; (new Dotenv())->bootEnv(dirname(__DIR__).'/.env'); $kernel = new Kernel($_SERVER['APP_ENV'], (bool) $_SERVER['APP_DEBUG']); $request = Request::createFromGlobals(); $response = $kernel->handle($request); $response->send(); $kernel->terminate($request, $response);` in `public/index.php` -> `require_once dirname(__DIR__).'/vendor/autoload_runtime.php';` and `return static function (array $context) { return new Kernel($context['APP_ENV'], (bool) $context['APP_DEBUG']); };`.
- `$input = new ArgvInput();` with manual `--env` and `--no-debug` parsing, `putenv('APP_ENV='.$env)`, `set_time_limit(0)` and `$application->run($input)` in `bin/console` -> `return function (array $context) { return new Application(new Kernel($context['APP_ENV'], (bool) $context['APP_DEBUG'])); };` with the FrameworkBundle `Application`.
- `if ($_SERVER['APP_DEBUG']) { umask(0000); Debug::enable(); }` in the front controller -> `SymfonyRuntime`, which calls `umask(0o000)` and enables the `DebugClassLoader` in debug mode, and registers the `ErrorHandler`.
- `$_SERVER['APP_ENV']`, `$_GET`, `$_POST`, `$_FILES` or `$_SERVER['argv']` in the front controller -> the closure arguments `array $context`, `array $request`, `array $argv`, `Request $request` or `InputInterface $input`.
- A hand-written worker loop around `frankenphp_handle_request($handler)` with a request counter and `gc_collect_cycles()` -> the normal `public/index.php`, which `FrankenPhpWorkerRunner` runs in worker mode (`worker_loop_max`, `FRANKENPHP_RESET_KERNEL`).
- `(new Dotenv())->bootEnv(dirname(__DIR__).'/config/.env')` with a custom path in each front controller -> `"extra": {"runtime": {"dotenv_path": "config/.env"}}` in `composer.json`, or `$_SERVER['APP_RUNTIME_OPTIONS']['dotenv_path']` above the `require_once` line.
- `$app = new Application(); $app->addCommand($command); $app->setDefaultCommand('hello', true); $app->run();` for a one-command script -> `return static function (Command $command): Command { return $command->setCode(static function (OutputInterface $output): int { $output->writeln('Hello'); return Command::SUCCESS; }); };`.
- Server-specific bootstrap code, for example a ReactPHP event loop, in `public/index.php` -> a `RunnerInterface` class and a `GenericRuntime` subclass, selected with `APP_RUNTIME`.
