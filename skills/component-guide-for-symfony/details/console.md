# Console (`symfony/console`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Invokable commands.** A class with `#[AsCommand]` and an `__invoke()` method is a command. `__invoke()` returns `Command::SUCCESS`, `Command::FAILURE` or `Command::INVALID`. The command passes `InputInterface`, `RawInputInterface`, `OutputInterface`, `SymfonyStyle`, `Cursor`, `Application` or `Command` objects to the parameters with these types. Entry point: `Symfony\Component\Console\Attribute\AsCommand`.
- **Method-based commands (8.1).** `#[AsCommand]` on public methods registers several commands in one class. A class-level `#[AsCommand]` name becomes the prefix, and the method-level names must be relative to it. Entry point: `#[AsCommand('create')]` on a public method.
- **Arguments and options.** `#[Argument]` and `#[Option]` on `__invoke()` parameters define the command input. The parameter type and the default value set the mode: required, optional, array or negatable `bool`. An option parameter must have a default value, and the default value can be an object (8.1). `suggestedValues` lists the values for shell completion. The `completion` command dumps the completion script for Bash, Zsh or Fish. Entry points: `Symfony\Component\Console\Attribute\Argument`, `Symfony\Component\Console\Attribute\Option`.
- **Input objects (DTOs).** `#[MapInput]` fills an object whose public properties have `#[Argument]`, `#[Option]` or a nested `#[MapInput]`. If the container has a `validator` service, the Validator constraints on these properties apply (8.1). A violation throws `InputValidationFailedException`. Entry point: `Symfony\Component\Console\Attribute\MapInput`.
- **Interactive input.** `#[Ask]` asks for a required argument that the user did not give. A `bool` parameter gets a yes/no question. An `InputFile` parameter (8.1) accepts a file path, or a pasted image in a terminal with the Kitty or iTerm2 image protocol. `#[Ask(constraints: [...])]` asks again until the answer is valid. If the application has an event dispatcher, only a `console.question_answered` listener such as `ValidateQuestionInputListener` applies the constraints. FrameworkBundle registers this listener when `framework.validation` is enabled. `#[AskChoice]` (8.1) shows the values of `choices` or of a `BackedEnum`. `#[Interact]` marks a public method with custom interaction logic. Entry points: `Symfony\Component\Console\Attribute\Ask`, `Symfony\Component\Console\Attribute\AskChoice`, `Symfony\Component\Console\Attribute\Interact`.
- **Value resolvers (8.1).** The console argument resolver converts the value of an `#[Argument]` or `#[Option]` parameter to the parameter type. It supports `BackedEnum` cases, `\DateTimeInterface` objects, Uid objects and `InputFile` objects. `#[MapDateTime(format: 'Y-m-d')]` sets a date format. With ConsoleBundle or FrameworkBundle, the resolver also gives services, and `#[ValueResolver]` pins one resolver or disables it for one parameter. Entry point: `Symfony\Component\Console\ArgumentResolver\ValueResolver\ValueResolverInterface`.
- **SymfonyStyle.** One object writes titles, sections, lists, tables, trees, admonitions (`note()`, `caution()`) and result blocks (`success()`, `error()`, `warning()`, `info()`). It also asks questions (`ask()`, `askHidden()`, `confirm()`, `choice()`, `askFile()`) and shows progress (`progressIterate()`). The `outlineSuccess()` method and the other `outline*()` methods are new in 8.1. `getErrorStyle()` returns a `SymfonyStyle` object that writes to the error output. If the output is not a `ConsoleOutputInterface`, this object writes to the same output. Entry point: `Symfony\Component\Console\Style\SymfonyStyle`.
- **Helpers.** `ProgressBar` shows the progress of a task, and `ProgressIndicator` shows activity when the duration is unknown. In 8.1, `ProgressBar` also sends OSC 9;4 sequences for terminal taskbar progress when the output is decorated. `Table`, `TreeHelper`, `Cursor`, `FormatterHelper`, `ProcessHelper` and `DebugFormatterHelper` cover tables, trees, cursor moves, text blocks and external processes. `QuestionHelper` asks a `Question`, `ChoiceQuestion`, `ConfirmationQuestion` or `FileQuestion`. `Question::setConstraints()` (8.1) validates the answer with Validator constraints and asks again until the answer is valid. If the `QuestionHelper` or `SymfonyStyle` object has an event dispatcher, only a `console.question_answered` listener applies the constraints. Entry point: `Symfony\Component\Console\Helper\ProgressBar`.
- **Output control.** The verbosity options (`--silent`, `-q`, `-v`, `-vv`, `-vvv`) and the `SHELL_VERBOSITY` variable filter messages. A section from `ConsoleOutputInterface::section()` can overwrite or clear its own lines. Tags such as `<info>`, `<comment>`, `<error>` and `<href=...>` add colors and links. `Terminal` gives the width, the height and the color mode of the terminal. Entry point: `Symfony\Component\Console\Output\OutputInterface`.
- **Events.** Listeners of `ConsoleEvents::COMMAND`, `ERROR`, `TERMINATE` and `SIGNAL` can skip a command, replace an error or change the exit code. If the container has a `logger` service, the `console.error_listener` service logs command errors and non-zero exit codes. Entry point: `Symfony\Component\Console\ConsoleEvents`.
- **Signals and alarms.** `SignalableCommandInterface` gives one command a handler for `pcntl` signals such as `SIGINT` and `SIGTERM`. `Application::setAlarmInterval()` schedules a `SIGALRM` signal at an interval. If the application has an event dispatcher, the application also dispatches a `ConsoleAlarmEvent` for each alarm. Entry point: `Symfony\Component\Console\Command\SignalableCommandInterface`.
- **Command locks.** `LockableTrait` adds `lock()` and `release()` to a command. It uses `SemaphoreStore` when it is supported, else `FlockStore`, unless the `$lockFactory` property holds your own `LockFactory`. Entry point: `Symfony\Component\Console\Command\LockableTrait`.
- **Tests.** `runCommand()` (8.1) runs a command and returns an `ExecutionResult` with the output, the error output, the display and the status code. `CommandTester`, `ApplicationTester` and `CommandCompletionTester` also work in standalone projects without a kernel. `runCommand()` and `CommandTester` do not dispatch console events. To test the events, use `ApplicationTester`. Entry point: `Symfony\Bundle\FrameworkBundle\Test\KernelTestCase::runCommand()`.
- **ConsoleBundle (8.1).** The bundle adds service discovery, autoconfiguration, autowiring, lazy commands and the value resolvers to a console application without HttpKernel or FrameworkBundle. It works with the `AbstractKernel` class and the `KernelTrait` trait of DependencyInjection. FrameworkBundle registers it automatically. Entry point: `Symfony\Component\Console\ConsoleBundle`.
- **Standalone applications.** `Application::addCommand()` adds commands to an application without the framework. `SingleCommandApplication` or `setDefaultCommand($name, true)` makes a tool with one command. `FactoryCommandLoader` creates commands only when they run. Entry point: `Symfony\Component\Console\Application`.

## Entry points

- Attributes: `Symfony\Component\Console\Attribute\AsCommand`, `Argument`, `Option`, `MapInput`, `Ask`, `AskChoice`, `Interact`, `MapDateTime`, `ValueResolver`, `AsTargetedValueResolver` (all in `Symfony\Component\Console\Attribute`).
- Command base class and exit codes: `Symfony\Component\Console\Command\Command` (`SUCCESS`, `FAILURE`, `INVALID`; `configure()` and `execute()` for the legacy syntax; `initialize()` and `interact()` lifecycle hooks).
- Types to receive in `__invoke()`: `Symfony\Component\Console\Style\SymfonyStyle`, `Symfony\Component\Console\Input\InputInterface`, `Symfony\Component\Console\Input\RawInputInterface`, `Symfony\Component\Console\Output\OutputInterface`, `Symfony\Component\Console\Cursor`, `Symfony\Component\Console\Application`.
- Helpers: `Symfony\Component\Console\Helper\ProgressBar`, `ProgressIndicator`, `Table`, `TreeHelper`, `TreeNode`, `TreeStyle`, `QuestionHelper`, `ProcessHelper`, `FormatterHelper`, `DebugFormatterHelper` (all in `Symfony\Component\Console\Helper`).
- Questions and files: `Symfony\Component\Console\Question\Question`, `ChoiceQuestion`, `ConfirmationQuestion`, `FileQuestion`; `Symfony\Component\Console\Input\File\InputFile`.
- Signals and locks: `Symfony\Component\Console\Command\SignalableCommandInterface`, `Symfony\Component\Console\Command\LockableTrait`, `Symfony\Component\Console\SignalRegistry\SignalMap::getSignalName()`.
- Events: `Symfony\Component\Console\ConsoleEvents` (`console.command`, `console.error`, `console.terminate`, `console.signal`, `console.question_answered`), `Symfony\Component\Console\Event\ConsoleAlarmEvent` (dispatched by class name).
- Value resolvers: `Symfony\Component\Console\ArgumentResolver\ValueResolver\ValueResolverInterface`; service tags `console.argument_value_resolver` and `console.targeted_value_resolver`; service ID `console.argument_resolver`.
- Command registration: service tag `console.command` (its `command` attribute gives the name for lazy loading); service ID `console.command_loader`.
- Bundle: `Symfony\Component\Console\ConsoleBundle` in `config/bundles.php` of an HTTP-less application. It has no configuration keys.
- Without FrameworkBundle: `Symfony\Component\Console\Application` (`addCommand()`, `setDefaultCommand()`, optional PSR-11 container as the third constructor argument), `Symfony\Component\Console\SingleCommandApplication`, `Symfony\Component\Console\CommandLoader\FactoryCommandLoader`.
- Logs and async runs: `Symfony\Component\Console\Logger\ConsoleLogger`; `Symfony\Component\Console\Messenger\RunCommandMessage`.
- Console commands: `list`, `help`, `completion` (built in); `debug:dotenv` (registered by ConsoleBundle when symfony/dotenv is installed).
- Test helpers: `Symfony\Bundle\FrameworkBundle\Test\KernelTestCase::runCommand()` with `assertCommandIsSuccessful()`, `assertCommandFailed()`, `assertCommandIsInvalid()` and `assertCommandResultEquals()`; `Symfony\Component\Console\Tester\CommandTester` (`run()`, `execute()`, `setInputs()`), `ApplicationTester`, `CommandCompletionTester`, `ExecutionResult`, `ConsoleAssertionsTrait` (all in `Symfony\Component\Console\Tester`).

## Symbiotic packages

- [FrameworkBundle](../packages/framework-bundle.md): Its kernel-aware `Console\Application` runs the application commands and adds the `--env`, `--no-debug` and `--profile` options, and FrameworkBundle registers ConsoleBundle automatically.
- [FrameworkBundle test tools](../packages/framework-bundle-testing.md): `KernelTestCase::runCommand()` runs a command through `CommandTester`, and the console assertions check its `ExecutionResult`.
- [WebProfilerBundle](../packages/web-profiler-bundle.md): With debug mode, `symfony/stopwatch` and `framework.profiler`, the `--profile` option of the FrameworkBundle console application saves a command profile that WebProfilerBundle shows.
- [DependencyInjection](../packages/dependency-injection.md): Its `AbstractKernel` and `KernelTrait` build the container of a ConsoleBundle application without HttpKernel.
- [Tui](../packages/tui.md): Tui is the experimental 8.1 package for interactive terminal UIs with widgets inside a Console command; Console covers arguments, prompts, tables and progress bars.
- [Lock](../packages/lock.md): `LockableTrait` needs this package to prevent parallel runs of one command.
- [Messenger](../packages/messenger.md): A `RunCommandMessage` runs a command in a worker, and its handler returns a `RunCommandContext` with the exit code and the output.
- [Scheduler](../packages/scheduler.md): `#[AsCronTask]` or `#[AsPeriodicTask]` on a command class runs that command on a schedule through a `RunCommandMessage`.
- [Validator](../packages/validator.md): It validates the `#[MapInput]` objects and the answers of questions with `constraints`.
- [Process](../packages/process.md): Process starts external programs, and the Console `ProcessHelper` uses it to show their command lines and output by verbosity.
- [EventDispatcher](../packages/event-dispatcher.md): It dispatches the console events to listeners and subscribers.
- [Monolog Bridge](../packages/monolog-bridge.md): Its `ConsoleHandler` shows `LoggerInterface` messages by verbosity, and `ConsoleLogger` does the same job without Monolog.
- [Doctrine Bridge](../packages/doctrine-bridge.md): Its `Symfony\Bridge\Doctrine\ArgumentResolver\Console\EntityValueResolver` loads an entity from an `#[Argument]` or `#[Option]` value, with an optional `#[MapEntity]`.
- [Uid](../packages/uid.md): `UidValueResolver` converts an argument or an option to a `Uuid` or `Ulid` parameter.
- [Clock](../packages/clock.md): `DateTimeValueResolver` uses the `clock` service for an empty date value and for the time zone.
- [Mime](../packages/mime.md): `InputFile::getMimeType()` uses `MimeTypes` when Mime is installed, else PHP `finfo`.
- [Dotenv](../packages/dotenv.md): ConsoleBundle registers the `debug:dotenv` command when Dotenv is installed.
- [Runtime](../packages/runtime.md): The `bin/console` file can return an `Application` from a closure through `vendor/autoload_runtime.php`.
- [MakerBundle](../packages/maker-bundle.md): `make:command` generates a command class with an `__invoke()` method.
- [HttpKernel](../packages/http-kernel.md): HttpKernel has classes with the same names (`MapDateTime`, `ValueResolver`, `AsTargetedValueResolver`, `ValueResolverInterface`) for controller arguments. In a command, import the Console classes.
- [Routing](../packages/routing.md): a command autowires `UrlGeneratorInterface`, and absolute URLs need `framework.router.default_uri`, because without it they start with `http://localhost/`.
- [VarDumper](../packages/var-dumper.md): the `Dumper` helper formats a variable for command output with `CliDumper`; without VarDumper, it falls back to `print_r()`.

## Changed in 8.0/8.1

- `$application->add(new CreateUserCommand());` -> `$application->addCommand(new CreateUserCommand());` (8.0 removes `add()`).
- `public static function getDefaultName()` and `getDefaultDescription()` -> `#[AsCommand('app:create-user', 'Creates users')]` (8.0 removes both methods).
- `$command->setCode(function ($input, $output) { ... });` -> `$command->setCode(function (InputInterface $input, OutputInterface $output): int { ... });` (8.0 requires the types).
- An override of `Bundle::registerCommands()` -> `#[AsCommand]` or the `console.command` service tag (8.1 deprecates the override).
- `new CommandTester($command)` with `execute()` and `getDisplay()` -> `static::runCommand()` in a `KernelTestCase` that returns an `ExecutionResult` (8.1).
- One class for each command -> `#[AsCommand]` on several public methods of one class (8.1).
- A hand-built `ContainerBuilder` for a CLI tool -> `ConsoleBundle` with the DependencyInjection `AbstractKernel` and `KernelTrait` (8.1).
- `$input->getArgument('id')` plus manual conversion -> typed `#[Argument]` or `#[Option]` parameters of `__invoke()` that the console value resolvers convert (8.1).

## Status

Signal handling and `Application::setAlarmInterval()` need the `pcntl` PHP extension. The alarm feature is not available on Windows.

## Docs

- https://symfony.com/doc/current/console.html
- https://symfony.com/doc/current/console/input.html
- https://symfony.com/doc/current/console/value_resolver.html
- https://symfony.com/doc/current/console/style.html
- https://symfony.com/doc/current/console/helpers/questionhelper.html
- https://symfony.com/doc/current/console/helpers/progressbar.html
- https://symfony.com/doc/current/console/helpers/progressindicator.html
- https://symfony.com/doc/current/console/helpers/table.html
- https://symfony.com/doc/current/console/helpers/tree.html
- https://symfony.com/doc/current/console/helpers/cursor.html
- https://symfony.com/doc/current/console/helpers/processhelper.html
- https://symfony.com/doc/current/console/helpers/formatterhelper.html
- https://symfony.com/doc/current/console/helpers/debug_formatter.html
- https://symfony.com/doc/current/console/lockable_trait.html
- https://symfony.com/doc/current/console/verbosity.html
- https://symfony.com/doc/current/console/calling_commands.html
- https://symfony.com/doc/current/console/command_in_controller.html
- https://symfony.com/doc/current/console/lazy_commands.html
- https://symfony.com/doc/current/logging/monolog_console.html
- https://symfony.com/doc/current/configuration/front_controllers_and_kernel.html
- https://symfony.com/doc/current/testing.html
- https://symfony.com/doc/current/tui/integrations/symfony_console.html
