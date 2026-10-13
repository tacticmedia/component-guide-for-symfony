# Console (`symfony/console`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when a PHP command-line tool must parse arguments and options, ask questions, print tables or progress bars, or handle signals. It works inside a full application or as a standalone tool, and it has test tools. For an interactive terminal UI with widgets and key bindings, see [Tui](tui.md).

**Details:** [../details/console.md](../details/console.md)

## Why it exists

PHP code that runs in a terminal must read the raw command-line arguments, ask for input and write readable output. The package gives each command a declared input, styled output, interactive questions, events and test tools. Symfony applications and many other PHP tools use it.

## When to use it

- Create a command-line command that receives arguments and options.
- Ask the user for a missing value, a choice or a confirmation.
- Show progress bars, tables, trees and result messages during a long task.
- Prevent two processes from running the same command at the same time.
- Stop a long-running command cleanly when it receives a SIGINT or SIGTERM signal.
- Test a command and check its exit code, standard output and error output.
- Build a standalone command-line tool, also with dependency injection, without the web parts of the framework.
- Run a command from PHP code, a controller, a background worker or a scheduled task.
- Give the users shell completion for the arguments and options.

## Use it instead of

- `$name = $argv[1] ?? null;`, `getopt('', ['dry-run'])` and casts such as `(int) $opts['limit']` -> typed `#[Argument]` and `#[Option]` parameters of `__invoke()` (`Symfony\Component\Console\Attribute\Argument`).
- `$email = trim(fgets(STDIN));` inside a `while (!filter_var($email, FILTER_VALIDATE_EMAIL))` loop -> `#[Ask('Email?', constraints: [new Email()])]` on an `#[Argument]` parameter (`Symfony\Component\Console\Attribute\Ask`).
- `echo "\033[32m[OK] Done\033[0m\n";` -> `$io->success('Done');` (`Symfony\Component\Console\Style\SymfonyStyle`).
- `printf("%-20s %s\n", $name, $email);` inside a `foreach` loop -> `$io->table($headers, $rows);` or the `Table` helper (`Symfony\Component\Console\Helper\Table`).
- `echo "\r{$i}/{$total}";` inside a loop -> `foreach ($io->progressIterate($items) as $item)` (`SymfonyStyle::progressIterate()`).
- `if (file_exists('/tmp/import.lock')) { exit(0); } touch('/tmp/import.lock');` -> `use LockableTrait;` and `if (!$this->lock()) { return Command::SUCCESS; }` (`Symfony\Component\Console\Command\LockableTrait`).
- `pcntl_signal(SIGTERM, function () use (&$stop) { $stop = true; });` -> `getSubscribedSignals()` and `handleSignal()` (`Symfony\Component\Console\Command\SignalableCommandInterface`).
- `if ($output->isVerbose()) { $output->writeln('...'); }` around each message -> `$logger = new ConsoleLogger($output);` and `$logger->notice('...');` (`Symfony\Component\Console\Logger\ConsoleLogger`).
- `exec('php bin/console app:report --force', $lines, $code);` -> `$application->doRun(new ArrayInput(['command' => 'app:report', '--force' => true]), $output)` (`Symfony\Component\Console\Application::doRun()`).
- `ob_start();` around a command call in a test -> `$result = static::runCommand('app:report');` and `$this->assertCommandIsSuccessful($result);` (`Symfony\Bundle\FrameworkBundle\Test\KernelTestCase`).
