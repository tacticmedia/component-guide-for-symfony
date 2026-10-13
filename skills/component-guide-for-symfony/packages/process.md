# Process (`symfony/process`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when PHP must run a shell command, an external program or a PHP script as a child process. It escapes the arguments, streams the output, writes to the input and stops the command at a timeout. To run the command in a queue worker, see [Messenger](messenger.md).

**Details:** [../details/process.md](../details/process.md)

## Why it exists

With the built-in PHP functions such as exec and proc_open, you must escape the arguments, read the pipes and check the timeouts yourself. The behavior of these functions also differs between Unix and Windows. The package escapes each argument for the operating system, collects or streams the output, and stops the command at a timeout.

## When to use it

- Run an external program, for example git or ffmpeg, with arguments that come from user input.
- Show the output of a long command to the user while the command runs.
- Stop a command that runs too long or that writes no output for some time.
- Send data to the standard input of a command while the command runs.
- Start a command in the background and get its result later.
- Run a PHP script or a console command of the application in a new PHP process with the same PHP settings.
- Run a shell command in a queue worker instead of in the web request, with [Messenger](messenger.md).
- Check that a binary such as ffprobe is installed, and get its path.
- Open an interactive program such as vim in the terminal, or capture the colored output of a command.

## Use it instead of

- `exec("cd $dir && git log $branch")`, `shell_exec()`, `system()`, `passthru()` or backticks -> `(new Process(['git', 'log', $branch], $dir))->mustRun()->getOutput()`
- `escapeshellarg()` and string concatenation to build a command line -> an array command line, or `"${:NAME}"` placeholders with `Process::fromShellCommandline()`
- `proc_open()` with a descriptor array, `stream_select()` and an `fread()` loop -> `Process::start()` with a callback, or `foreach ($process as $type => $data)`
- A `microtime(true)` check that calls `proc_terminate()` on a slow command -> `setTimeout()` or `setIdleTimeout()`, then a `catch` of `ProcessTimedOutException`
- `exec($command, $lines, $exitCode)` followed by `if (0 !== $exitCode) { throw ... }` -> `mustRun()` and `ProcessFailedException`
- `exec('command -v ffprobe')` or a loop over the `PATH` directories -> `(new ExecutableFinder())->find('ffprobe')`
- `PHP_BINARY` or a hard-coded `/usr/bin/php` in a command line -> `(new PhpExecutableFinder())->find()`, `PhpProcess` or `PhpSubprocess`
- `exec('php -d memory_limit=-1 bin/console app:import')` to repeat the ini settings of the parent -> `new PhpSubprocess(['bin/console', 'app:import'])`
- `exec('nohup ./bin/convert-video.sh in.mp4 > /dev/null 2>&1 &')` in a controller -> a `RunProcessMessage` that you dispatch to an async Messenger transport
- `popen($command, 'w')` with `fwrite()` calls -> `setInput()` or an `InputStream`
