# MakerBundle (`symfony/maker-bundle`)

**Applies to:** MakerBundle 1.68

**Elevator pitch:** Use when you must generate starter code during development, for example database entities, migrations, controllers, forms, console commands, login forms or tests. Each generator is a console command that asks for the missing values, writes the new files and updates related files. To install packages with their default configuration, see [Symfony Flex](flex.md).

**Details:** [../details/maker-bundle.md](../details/maker-bundle.md)

## Why it exists

Developers who are new to a framework feature need a working starting point before they write their own code. The package generates this boilerplate code with the current recommended practices and minimal configuration. Each generator is a console command. It asks for the missing values, writes the new files and updates existing files, for example entities and the security configuration.

## When to use it

- Create a database entity class with fields, relations and a migration.
- Create a controller with a route and a template, or all create, read, update and delete pages for an entity.
- Add a user class, a login form, a registration form or a password reset to the security setup.
- Create a console command with typed arguments and options.
- Create a starter class for an event listener, an access decision, a form type, a validation constraint or a decorator.
- Create a message class with its handler for background work, or a webhook parser with its consumer.
- Create a reusable UI component with its template, an interactive component, a template extension or a JavaScript controller.
- Create a test class for a unit, integration, web, API or [Panther](panther.md) browser test.
- Add a database server to the container configuration of the project.
- Generate code from a script or a terminal without input, with options in place of questions.

## Use it instead of

- A hand-written `src/Entity/Product.php` with `#[ORM\Column]` properties, getters and setters -> `php bin/console make:entity Product --field=name:string:255 --field=price:integer` (`make:entity`).
- A hand-written `CREATE TABLE` or `ALTER TABLE` script -> `php bin/console make:migration`, then `doctrine:migrations:migrate` (`make:migration`).
- A controller, a form type and the list, show, new and edit templates, written by hand for one entity -> `php bin/console make:crud Product` (`make:crud`).
- `class SendReportCommand extends Command` with `configure()`, `execute()` and `$input->getArgument('recipient')` -> `php bin/console make:command app:send-report --argument=recipient --option=dry-run` (`make:command`).
- A login check with `password_verify($_POST['password'], $row['password'])` and `$_SESSION['user_id']` -> `make:user`, then `make:security:form-login` (`form_login` authenticator).
- Reset tokens from `bin2hex(random_bytes(32))` in your own table, sent with `mail()` -> `php bin/console make:reset-password` (`symfonycasts/reset-password-bundle`).
- A `docker run -e POSTGRES_PASSWORD=...` command, or a database service typed by hand into `compose.yaml` -> `php bin/console make:docker:database` (`make:docker:database`).
- A Twig extension with `getFilters()` that returns `new TwigFilter('price', [$this, 'formatPrice'])` -> `php bin/console make:twig-extension` (`#[AsTwigFilter]` and `#[AsTwigFunction]` methods).
