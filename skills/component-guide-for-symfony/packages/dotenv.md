# Dotenv (`symfony/dotenv`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when settings such as database URLs and API keys must come from environment variables, with default values in committed dotenv files. Real environment variables keep priority, and local or per-environment files override the defaults. A command compiles the files into one PHP file for production. For encrypted secrets, see [FrameworkBundle](framework-bundle.md).

**Details:** [../details/dotenv.md](../details/dotenv.md)

## Why it exists

Applications read infrastructure settings, such as database URLs and API keys, from environment variables. Without help, each machine must set these variables in the shell or in the web server. The package reads them from dotenv files into the PHP superglobals, and real environment variables keep their priority.

## When to use it

- Load database URLs, API keys and other infrastructure settings from a dotenv file.
- Override a committed default value on one machine only, for example a local database password.
- Set different values for the test environment, for example the URL of a test database.
- Select the environment name and the debug mode of the application.
- Build one value from other variables, for example a database URL from a user name and a password.
- Compile the dotenv files into one PHP file, so that production does not parse them at each request.
- Find which dotenv file sets the value of an environment variable.
- Load dotenv files in a test bootstrap file, a CLI tool or a plain PHP script without the framework.

## Use it instead of

- `file('.env')` with `explode('=', $line)` and `putenv("$name=$value")` -> `new Dotenv()->bootEnv(dirname(__DIR__).'/.env')` or `loadEnv()`.
- `if (is_file(__DIR__.'/.env.local')) { ... }` checks for local and per-environment files -> `Dotenv::loadEnv()`, which applies the file cascade and the test rule.
- `getenv('DATABASE_URL')` in application code -> `%env(DATABASE_URL)%` in the service configuration, `#[Autowire(env: 'DATABASE_URL')]` on a constructor argument, or `$_ENV['DATABASE_URL']`. Without `usePutenv()`, `getenv()` returns `false` for `.env` values.
- `$debug = 'prod' !== $_SERVER['APP_ENV'];` in a front controller or a script -> `Dotenv::bootEnv()` with `setProdEnvs()`, which sets `APP_DEBUG`.
- A hand-written PHP array of production values, loaded with `require` -> `composer dump-env prod` or `php bin/console dotenv:dump prod`, which write `.env.local.php`.
- `var_dump($_ENV)` or `phpinfo()` to find the origin of a value -> `php bin/console debug:dotenv DATABASE_URL`.
- Production passwords in the committed `.env` file -> `.env.local` or `.env.prod.local` on the server, real environment variables, or the FrameworkBundle secrets vault (`secrets:set`).
- A full copy of `DATABASE_URL` in `.env.local` to change only the password -> `DATABASE_URL="mysql://${DB_USER}:${DB_PASS}@127.0.0.1:3306/app"` in `.env`, and only `DB_PASS=...` in `.env.local`.
