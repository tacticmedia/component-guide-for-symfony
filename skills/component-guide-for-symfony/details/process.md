# Process (`symfony/process`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Array command line.** Each array item is one argument, and the class escapes each argument for the operating system. Shell syntax in a value, for example `;` or `$(...)`, has no effect. The constructor accepts only an array. Entry point: `new Process(['git', 'log', '--oneline', $branch])`.
- **Shell command line.** `Process::fromShellCommandline()` sends a string to the shell of the OS (`/bin/sh` or `cmd.exe`), so pipes, redirections and `&&` work. Put each variable value in a `"${:NAME}"` placeholder. Give the value as an env var to `run()`, `mustRun()` or `start()`. The class replaces the placeholder with the escaped value, or throws `InvalidArgumentException` if the value is missing. Signals go to the shell wrapper, not to your command. Entry point: `Process::fromShellCommandline('ls "${:DIR}" | wc -l')`, then `$process->run(null, ['DIR' => $directory])`.
- **Run and check the result.** `run()` waits for the end of the command and returns the exit code. `mustRun()` throws `ProcessFailedException` if the exit code is not 0. The message of this exception contains the command line, the exit code and the working directory. If the output is enabled, the message also contains the output and the error output. Entry points: `run()`, `mustRun()`, `isSuccessful()`, `getExitCode()`, `getOutput()`, `getErrorOutput()`.
- **Live output.** Give a callback `function (string $type, string $buffer)` to `run()`, `mustRun()`, `start()` or `wait()`. `$type` is `Process::OUT` or `Process::ERR`. After `start()`, `foreach ($process as $type => $data)` waits for each new chunk of output. The loop removes each chunk from the output buffer, unless you give `Process::ITER_KEEP_OUTPUT` to `getIterator()`. `getIncrementalOutput()` returns only the output since the last call. `waitUntil()` returns `true` when its callback returns `true`, for example when a server prints that it is ready. It returns `false` if the command ends first. Entry points: the callback argument, `Process::getIterator()` with the `Process::ITER_*` flags, `waitUntil()`.
- **Timeouts.** The default timeout is 60 seconds. `setTimeout(null)` or `setTimeout(0)` removes the limit. `setIdleTimeout()` limits the time without new output. At a timeout, the class stops the command and throws `ProcessTimedOutException`. Its `isGeneralTimeout()` and `isIdleTimeout()` methods tell which limit the command reached. After `start()`, call `checkTimeout()` regularly in your own loop. `wait()`, `waitUntil()` and the iterator do this check for you.
- **Standard input.** Give the input to `setInput()` or to the fourth constructor argument. The input can be a string, a stream resource, a `Traversable` or another started `Process`, whose STDOUT the class forwards. The class closes STDIN after it writes all the input. To write while the command runs, set an `InputStream` as the input before `start()`. Then call `InputStream::write()`. When you have no more input, call `InputStream::close()`.
- **Environment and working directory.** The child gets the env vars of the parent. Add more vars with the third constructor argument, `setEnv()` or the second argument of `run()`, `mustRun()` or `start()`. To remove a var from the child, set it to `false`. Under a non-CLI SAPI, for example PHP-FPM, the child does not inherit request vars such as `HTTP_*` and `QUERY_STRING`. The second constructor argument or `setWorkingDirectory()` sets the directory in which the command runs. By default, the command runs in the current directory of the PHP process. If the directory does not exist, `start()` throws `RuntimeException`, also when `run()` or `mustRun()` calls it. Entry point: `new Process(['bin/console', 'cache:clear'], $projectDir, ['APP_ENV' => 'prod'])`.
- **Background processes.** `start()` returns while the command continues in the background. Use `isRunning()`, `getPid()`, `wait()` and `stop()` to control it. `stop($timeout, $signal)` sends `SIGTERM`, waits up to `$timeout` seconds (default 10), and then sends `$signal` (default `SIGKILL`) if the command still runs. The destructor of `Process` stops a running command, at the latest when the parent script ends. To keep the command alive after the parent exits, call `setOptions(['create_new_console' => true])` before `start()`. `setOptions()` accepts only `create_new_console`, `create_process_group` and `blocking_pipes`.
- **Signals.** `signal(SIGUSR1)` sends a POSIX signal to the running command. `setIgnoredSignals([SIGINT])` blocks the given signals in the child before it starts, so the child does not get them. This method needs the `pcntl` extension. `wait()` throws `ProcessSignaledException` if a signal that the `Process` object did not send ends the command. On Windows, every signal runs `taskkill /F /T` on the process ID.
- **TTY and PTY.** `setTty(true)` connects the command to the real terminal, for example to open `vim`. The command writes to the terminal, so `getOutput()` returns an empty string. `setPty(true)` gives the command a pseudo-terminal: the command prints colors and prompts, and `getOutput()` still captures them. If the OS has no PTY support, the class uses normal pipes and shows no error. Neither mode works on Windows. Entry points: `Process::isTtySupported()`, `Process::isPtySupported()`.
- **Output memory.** `disableOutput()` stops the collection of the output. A callback that you give to `run()`, `mustRun()` or `start()` still gets each chunk. You cannot use `disableOutput()` together with an idle timeout. With the output enabled, the class keeps the output in `php://temp` streams, which move to a temporary file above 1 MiB.
- **PHP child processes.** `PhpProcess` runs a string of PHP code in a new PHP process. `PhpSubprocess` runs a PHP script, for example `['bin/console', 'app:import']`, with a temporary `php.ini` that copies the current settings, `-d` values included. Both classes find the PHP binary with `PhpExecutableFinder`. Both classes throw `LogicException` from `fromShellCommandline()`.
- **Executable lookup.** `(new ExecutableFinder())->find('ffprobe')` returns the path of the binary from the `PATH` directories, or the `$default` argument (`null` by default). The third argument adds more directories. `(new PhpExecutableFinder())->find()` returns the path of the PHP binary, or `false`.
- **Exceptions.** All exceptions implement `Symfony\Component\Process\Exception\ExceptionInterface`. `ProcessStartFailedException` (the command did not start) extends `ProcessFailedException`, so one `catch` handles both. `ProcessTimedOutException` and `ProcessSignaledException` extend the `RuntimeException` of the component. A `LogicException` shows a wrong call order, for example `getOutput()` before `start()`.
- **Messenger integration.** Dispatch a `RunProcessMessage` to run a command in a Messenger handler. The handler calls `mustRun()` and returns a `RunProcessContext` with `exitCode`, `output` and `errorOutput`. If the command fails or does not start, the handler throws `RunProcessFailedException`, which keeps the context in `$context`. At a timeout, the handler throws `ProcessTimedOutException`. Entry points: `new RunProcessMessage(['bin/convert-video', $file])`, `RunProcessMessage::fromShellCommandline()`.

## Entry points

- `Symfony\Component\Process\Process`: create it with `new Process([...])` or `Process::fromShellCommandline()`. It is not a container service.
- Without FrameworkBundle: `Process`, `PhpProcess`, `PhpSubprocess`, `InputStream`, `ExecutableFinder` and `PhpExecutableFinder` need no container and no configuration. Only `RunProcessMessage` needs Messenger and the handler service.
- `Symfony\Component\Process\PhpProcess` and `Symfony\Component\Process\PhpSubprocess`: PHP child processes.
- `Symfony\Component\Process\InputStream`: the standard input that you write to while the command runs.
- `Symfony\Component\Process\ExecutableFinder` and `Symfony\Component\Process\PhpExecutableFinder`: find binaries.
- `Symfony\Component\Process\Exception\ProcessFailedException`, `ProcessStartFailedException`, `ProcessTimedOutException`, `ProcessSignaledException`, `RunProcessFailedException` and the marker interface `ExceptionInterface` (all in `Symfony\Component\Process\Exception`).
- `Symfony\Component\Process\Messenger\RunProcessMessage`: dispatch it with `Symfony\Component\Messenger\MessageBusInterface`. The handler `Symfony\Component\Process\Messenger\RunProcessMessageHandler` (service `process.messenger.process_message_handler`) returns a `Symfony\Component\Process\Messenger\RunProcessContext`.
- `Symfony\Component\Console\Helper\ProcessHelper`: the Console helper `process`, which runs a `Process` and prints debug lines by verbosity. See [Console](../packages/console.md).
- The package has no config key, no attribute, no console command and no Twig function.

## Symbiotic packages

- [Console](../packages/console.md): `ProcessHelper`, the `process` helper of the default helper set, runs a `Process` and prints its command line, output and result by verbosity. Since 8.1, `RawInputInterface::unparse()` returns the options of the current command as tokens for a child `Process` array. Do not give these tokens to `fromShellCommandline()`, because `unparse()` does not escape them. To run a console command in a worker, use `RunCommandMessage`. To run an external program, use `RunProcessMessage`.
- [Messenger](../packages/messenger.md): a `RunProcessMessage` runs a command in a worker, and the handler returns a `RunProcessContext`. Messenger signs this message type when it goes through a transport, and a worker refuses a message with a missing or wrong signature.
- [FrameworkBundle](../packages/framework-bundle.md): if `symfony/process` is installed, FrameworkBundle registers `RunProcessMessageHandler` as the service `process.messenger.process_message_handler`, with the handler tag option `sign: true`.
- [HttpKernel](../packages/http-kernel.md): the Process docs describe a synchronous run in a `kernel.terminate` listener, after the response. Outside debug mode, under PHP-FPM, FrankenPHP or LiteSpeed, the client gets the response before the command ends. Prefer Messenger, because the PHP worker stays busy until the command ends.
- [Tui](../packages/tui.md): `Process::run()` and `Process::wait()` block the Revolt event loop of a Tui application. In a Tui application, the docs recommend `amphp/process` instead. Tui is experimental.
- [BrowserKit](../packages/browser-kit.md): `insulate()` runs each request of a test client in a new PHP process with `PhpProcess`, so it requires `symfony/process`.
- [Dotenv](../packages/dotenv.md): a `$(command)` in a `.env` value runs through `Process::fromShellCommandline()`. This feature requires `symfony/process` and does not work on Windows.
- [Validator](../packages/validator.md): the `Video` constraint finds `ffprobe` with `ExecutableFinder` and runs it with `Process`. The constraint requires `symfony/process` and the `ffprobe` binary.
- [AssetMapper](../packages/asset-mapper.md): if the matching PHP extension is missing, `framework.asset_mapper.precompress` runs the `brotli`, `zstd` or `gzip` command through `Process`. For gzip, it prefers the `zopfli` command, if it is installed.

## Changed in 8.0/8.1

- 8.0.13 and 8.1.0 (bug fix): under a non-CLI SAPI, for example PHP-FPM or CGI, the child no longer inherits request vars. Examples are `HTTP_*`, `REDIRECT_*`, `QUERY_STRING` and `REQUEST_URI`. If the child needs one of these values, give it in `$env`.
- 8.1 (Console): `RawInputInterface::unparse()` replaces hand-built `--option=value` strings for a child `Process`. Spread its result into the command array.

## Status

The component needs no PHP extension. The constructor throws `LogicException` if the `proc_open()` function is not available. `setIgnoredSignals()` has an effect only with the `pcntl` extension, which also defines the `SIG*` constants such as `SIGINT`. TTY and PTY modes do not work on Windows.

## Docs

- https://symfony.com/doc/current/components/process.html
- https://symfony.com/doc/current/messenger.html
- https://symfony.com/doc/current/console/helpers/processhelper.html
- https://symfony.com/doc/current/console/input.html
- https://symfony.com/doc/current/tui/integrations/revolt.html
