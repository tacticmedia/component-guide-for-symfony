# Symfony Flex (`symfony/flex`)

**Applies to:** Symfony Flex 2.11

**Elevator pitch:** Use when a Composer install of a package must also register it, create its configuration files and add its environment variables. The Composer plugin applies a setup template when Composer adds, updates or removes a package. It also resolves short package names, expands package sets and keeps all Symfony packages on one minor version. To generate code, see [MakerBundle](maker-bundle.md).

**Details:** [../details/flex.md](../details/flex.md)

## Why it exists

Most Symfony packages need setup before they work: a line that enables the package, a configuration file and variables in a dotenv file. The package is a Composer plugin that does this setup from a setup template when Composer adds, updates or removes a package. It also keeps all Symfony packages on one minor version.

## When to use it

- Install a Symfony feature and its configuration with one Composer command.
- Create a new Symfony application from the minimal project template.
- Install a set of related packages, for example the database ORM or the debug tools, with one command.
- Update the configuration files of installed packages to the latest template version.
- Keep all Symfony packages on one minor version, for example 8.1.
- Install the setup templates of your private packages from a private repository.
- Accept community setup templates without a question in a CI script.
- Compile the dotenv files to one PHP file for production.
- Restore a deleted setup file, for example the test configuration file or the test bootstrap file.
- Add the container services that a package needs, for example a database, to the compose file of the project.
- Run console commands automatically after each Composer install or update.

## Use it instead of

- `Acme\FooBundle\AcmeFooBundle::class => ['all' => true],` typed into `config/bundles.php` after `composer require acme/foo-bundle` -> the recipe or the auto-generated recipe that `composer require acme/foo-bundle` applies.
- Config files and `DATABASE_URL=...` lines copied from a package README into `config/packages/` and `.env` -> the package recipe from `composer require <alias>`.
- Recipe files copied by hand from GitHub to restore a deleted file -> `composer recipes:install <package> --force --reset`.
- `composer require doctrine/orm doctrine/doctrine-bundle doctrine/doctrine-migrations-bundle` -> `composer require orm` (`symfony/orm-pack`, unpacked).
- `"symfony/console": "8.1.*"` edited by hand in each line, and different Symfony versions in one project -> `*` constraints, `extra.symfony.require` and `composer update "symfony/*"`.
- A manual comparison of your configuration files with the recipe repository on GitHub -> `composer recipes:update <package>`.
- PHP code that parses the `.env` files on each production request, or a hand-written `.env.local.php` -> `composer dump-env prod`.
- `yes | composer require ...` in a CI script to accept contrib recipes -> `SYMFONY_ALLOW_CONTRIB=1` or `extra.symfony.allow-contrib`.
- A `post-install-cmd` entry `php bin/console <command>` -> an `auto-scripts` entry `"<command>": "symfony-cmd"`.
- A `database` service typed into `compose.yaml` by hand -> the Docker configuration of the recipe, with `extra.symfony.docker` set to `true`.
