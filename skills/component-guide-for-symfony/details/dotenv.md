# Dotenv (`symfony/dotenv`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **File cascade:** `loadEnv()` loads `.env`, then the files `.env.local`, `.env.<env>` and `.env.<env>.local` that exist. A value from a later file replaces the value from an earlier file. `loadEnv()` reads `APP_ENV` after `.env` and `.env.local`, so a real environment variable or one of these files selects `<env>`. Without a value, `APP_ENV` gets `dev`. If only `.env.dist` exists, `loadEnv()` loads it in place of `.env`. Entry point: `Dotenv::loadEnv()`.
- **Test environments:** if `APP_ENV` is in `$testEnvs` (default `['test']`), `loadEnv()` does not load `.env.local`. It still loads `.env.test` and `.env.test.local`. Thus, tests give the same results on all machines. Entry point: the `$testEnvs` argument of `loadEnv()`, the runtime option `test_envs`.
- **Priority of real environment variables:** Dotenv does not replace a variable that exists in `$_ENV` or `$_SERVER` before the load. A request header in `$_SERVER` (a name that starts with `HTTP_`) does not count as a real environment variable. Entry point: `Dotenv::populate()`.
- **Override of real environment variables:** if `.env` values must replace real environment variables, pass `overrideExistingVars: true` to `loadEnv()`, `bootEnv()` or `populate()`. `overload()` loads files with the same rule. The runtime option `dotenv_overload` sets this argument when Symfony Runtime starts the application. The Runtime docs say that `dotenv_overload` lets `.env.local` replace `.env` values, but `.env.local` does this also without the option. Entry point: `Dotenv::overload()`.
- **Boot of an application:** `bootEnv()` loads `.env.local.php` when this file exists; otherwise, it calls `loadEnv()`. Then it adds the `$_ENV` entries that are missing in `$_SERVER`. If `APP_DEBUG` has no value, `bootEnv()` sets `'0'` for the environments in `setProdEnvs()` (default `['prod']`) and `'1'` for all other environments. Entry point: `Dotenv::bootEnv()`, `Dotenv::setProdEnvs()`.
- **Compiled file for production:** `composer dump-env prod` or `php bin/console dotenv:dump prod` reads all `.env` files once and writes the final values to `.env.local.php`. `bootEnv()` then does not parse the `.env` files. Real environment variables still have priority over the values in the file. If a real `APP_ENV` is different from the value in the file, `bootEnv()` ignores the file. With `--empty`, the file contains only `APP_ENV`. Use `--empty` when the server sets real environment variables for all other values. Entry point: `dotenv:dump`, `composer dump-env`.
- **File syntax:** each line has the form `NAME=value`, with an optional `export ` prefix. Outside quotes, `#` starts a comment at the start of a line, directly after `=`, or after a space or a tab. Thus, an unquoted value that starts with `#`, such as `COLOR=#fff`, is empty. Single quotes keep a value literal. Double quotes expand `${VAR}` and the escapes `\n`, `\r` and `\"`. A value with spaces needs quotes. A space before `=`, or between `=` and the value, causes an error. Entry point: `Dotenv::parse()`.
- **References and defaults:** `${VAR}` inserts the value of another variable. `${VAR:-default}` inserts `default` when `VAR` is empty or not defined. `$(command)` inserts the output of a shell command. Commands need `symfony/process` and do not work on Windows. Entry point: `Dotenv::parse()`.
- **Deferred references:** since 8.0.7, `load()`, `loadEnv()`, `bootEnv()` and `overload()` resolve `${VAR}` and `$(command)` after they load all files. Thus, a reference in `.env` gets the value from `.env.local`, and the line order has no effect. `parse()` resolves each line immediately, in the order of the lines. If the values still change after five passes, Dotenv throws `VariableCircularReferenceException`. Entry point: `Dotenv::loadEnv()`.
- **No `putenv()` by default:** Dotenv writes only `$_ENV` and `$_SERVER`, because `putenv()` is not thread safe. Thus, `getenv('NAME')` returns `false` for a `.env` value. If a library reads values with `getenv()`, call `usePutenv()` or set the runtime option `use_putenv`. Entry point: `Dotenv::usePutenv()`.
- **Marker variables:** `SYMFONY_DOTENV_VARS` contains the names of the variables that Dotenv set. A later `.env` file can replace these variables, but not real environment variables. `SYMFONY_DOTENV_PATH` contains the path that `loadEnv()` or `bootEnv()` received. If a child process must keep the values that it inherits, remove `SYMFONY_DOTENV_VARS` from its environment. Entry point: `$_SERVER['SYMFONY_DOTENV_VARS']`, `$_SERVER['SYMFONY_DOTENV_PATH']`.
- **Inspection:** `debug:dotenv` shows the files in the order of priority and the value of each variable in each file. The optional argument keeps only the names that start with the given text, with no case sensitivity. `debug:container --env-vars` shows the variables that the container configuration uses. Entry point: `php bin/console debug:dotenv DATABASE`.
- **Runtime integration:** Symfony Runtime calls `bootEnv()` from `vendor/autoload_runtime.php` before the kernel boots. Set the options `dotenv_path`, `dotenv_extra_paths`, `disable_dotenv`, `dotenv_overload`, `prod_envs`, `test_envs` and `use_putenv` in `extra.runtime` of `composer.json`. Then run `composer dump-autoload`. The option `dotenv_extra_paths` is in the source, but not in the docs. It lists more files, relative to the project directory. Symfony Runtime loads them after the `.env` files, and each file must exist. Their values replace the `.env` values, but real environment variables keep priority unless `dotenv_overload` is `true`. The console options `--env` and `--no-debug` set `APP_ENV` and `APP_DEBUG` before Dotenv starts, so they act as real environment variables. Entry point: `extra.runtime` in `composer.json`.
- **Errors:** `FormatException` reports a syntax error with the file name and the line number (`getContext()`). A variable name contains letters, digits and underscores, and starts with a letter after optional underscores. Thus, a dot in a name (`FOO.BAR=1`) causes a `FormatException`. A byte-order mark or a NUL byte in a file also causes a `FormatException`. `PathException` reports a missing or unreadable file. Entry point: `Symfony\Component\Dotenv\Exception\FormatException`, `PathException`.

## Entry points

- Class `Symfony\Component\Dotenv\Dotenv` with the methods `bootEnv()`, `loadEnv()`, `load()`, `overload()`, `populate()`, `parse()`, `usePutenv()` and `setProdEnvs()`. The constructor takes `$envKey = 'APP_ENV'` and `$debugKey = 'APP_DEBUG'`. No container service exists for it; create it with `new Dotenv()`.
- Without FrameworkBundle: create `new Dotenv()` and call `bootEnv()` or `loadEnv()`, for example in a test bootstrap file or a plain PHP script. `ConsoleBundle` registers `debug:dotenv` also in a console application without FrameworkBundle.
- Console command `debug:dotenv [filter]` (class `Symfony\Component\Dotenv\Command\DebugCommand`, service `console.command.dotenv_debug`). `ConsoleBundle` registers it, and FrameworkBundle requires `ConsoleBundle`.
- Console command `dotenv:dump [env] [--empty]` (class `Symfony\Component\Dotenv\Command\DotenvDumpCommand`). Before you use it, register it in `config/services.yaml`: `Symfony\Component\Dotenv\Command\DotenvDumpCommand: ~`.
- Composer command `composer dump-env [env] [--empty]` from Symfony Flex (command name `symfony:dump-env`, alias `dump-env`).
- Runtime options in `extra.runtime` of `composer.json` or in `$_SERVER['APP_RUNTIME_OPTIONS']`: `dotenv_path`, `dotenv_extra_paths`, `disable_dotenv`, `dotenv_overload`, `prod_envs`, `test_envs`, `use_putenv`, `env_var_name` and `debug_var_name`.
- Environment variables `APP_ENV`, `APP_DEBUG`, `SYMFONY_DOTENV_VARS` and `SYMFONY_DOTENV_PATH`.
- Console options `--env` (`-e`) and `--no-debug`.
- Files `.env`, `.env.local`, `.env.<env>`, `.env.<env>.local`, `.env.dist` and `.env.local.php`. Commit `.env` and `.env.<env>`. Do not commit the files that end with `.local`.
- Exceptions `Symfony\Component\Dotenv\Exception\FormatException`, `PathException` and `VariableCircularReferenceException`, with the interface `ExceptionInterface`.
- Container inspection: `php bin/console debug:container --env-vars` and `php bin/console debug:container --env-var=NAME`.
- Install the package with `composer require symfony/dotenv`. A new project from `symfony/skeleton` lists it in `require`. If `composer.json` lists it only in `require-dev`, `composer install --no-dev` does not install it. Then the runtime loads no `.env` file and no `.env.local.php` file, and `APP_ENV` gets `dev` unless a real environment variable sets it.
- The package has no configuration key, Twig function or attribute for applications.

## Symbiotic packages

- [Runtime](../packages/runtime.md): `SymfonyRuntime` creates `Dotenv` and calls `bootEnv()` with the `extra.runtime` options before the kernel boots.
- [FrameworkBundle](../packages/framework-bundle.md): its secrets vault stores encrypted secrets; a non-empty environment variable with the same name overrides a secret, and `secrets:set --local` writes to `.env.<env>.local`.
- [DependencyInjection](../packages/dependency-injection.md): `%env(NAME)%` parameters and the env var processors read the values that Dotenv loads, and an `EnvVarLoaderInterface` service adds other sources.
- [Console](../packages/console.md): `ConsoleBundle` registers the `debug:dotenv` command, but you must register `dotenv:dump` as a service.
- [Symfony Flex](../packages/flex.md): recipes add default variables to `.env` between `###> <package> ###` and `###< <package> ###` lines, and `composer dump-env` writes `.env.local.php`.
- [Process](../packages/process.md): Dotenv needs Process to run `$(command)` values, and `'SYMFONY_DOTENV_VARS' => false` makes the Dotenv of a child process keep the inherited values.
- [WebProfilerBundle](../packages/web-profiler-bundle.md): the request panel shows the server parameters "Defined in .env" apart from the "regular env variables".
- [Panther](../packages/panther.md): if the test bootstrap loads `.env` files, pass `'SYMFONY_DOTENV_VARS' => false` in the `env` option of `createPantherClient()` to keep the `env` values.
- [PHPUnit Bridge](../packages/phpunit-bridge.md): `simple-phpunit` reads `SYMFONY_PHPUNIT_VERSION` from `phpunit.dist.xml` or from a real environment variable, not from a `.env` file.
- [FrameworkBundle test tools](../packages/framework-bundle-testing.md): `tests/bootstrap.php` calls `bootEnv()`, and the `test` environment reads `.env`, `.env.test` and `.env.test.local`, but not `.env.local`.
- [WebpackEncoreBundle](../packages/webpack-encore-bundle.md): Encore runs in Node.js and does not read `.env` files; give a value to JavaScript with `configureDefinePlugin()` at build time.
- [AI Mate](../packages/ai-mate.md): for a coding agent, the Mate tool `symfony-dotenv-check` replaces `bin/console debug:dotenv` and shows only masked values.

## Changed in 8.0/8.1

- **8.0.7, deferred references:** `load()`, `loadEnv()`, `bootEnv()` and `overload()` resolve `${VAR}` and `$(command)` after they load all files. A reference can come before its variable, and `.env.local` can change a referenced value. The warning about the line order in the 8.1 docs is not correct for these methods.
- **8.0, DebugCommand:** the properties `$defaultName` and `$defaultDescription` no longer exist. The `#[AsCommand]` attribute gives the name `debug:dotenv` and the description.
- **8.1, DependencyInjection:** `%env(FOO.BAR)%` accepts a dot in the variable name. A `.env` file still rejects such a name with a `FormatException`.
- **8.1, Console:** the new `ConsoleBundle` registers `debug:dotenv`, also in a console application without FrameworkBundle.

## Docs

- https://symfony.com/doc/current/configuration.html
- https://symfony.com/doc/current/deployment.html
- https://symfony.com/doc/current/configuration/secrets.html
- https://symfony.com/doc/current/components/runtime.html
- https://symfony.com/doc/current/configuration/env_var_processors.html
- https://symfony.com/doc/current/configuration/override_dir_structure.html
- https://symfony.com/doc/current/testing.html
- https://symfony.com/doc/current/testing/bootstrap.html
- https://symfony.com/doc/current/testing/end_to_end.html
- https://github.com/symfony/dotenv
