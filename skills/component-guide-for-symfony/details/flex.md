# Symfony Flex (`symfony/flex`): details

**Applies to:** Symfony Flex 2.11

## Key features and concepts

- **Recipes:** A recipe is a `manifest.json` file plus files for one package. Flex applies the recipe after `composer require`, `composer update` and `composer remove`, but not after `composer install` with an existing `composer.lock` file. The manifest configurators are `bundles`, `container`, `copy-from-recipe`, `copy-from-package`, `env`, `dotenv`, `makefile`, `composer-scripts`, `composer-commands`, `gitignore`, `dockerfile`, `docker-compose`, `add-lines` and `post-install-output`. Paths use placeholders such as `%CONFIG_DIR%` and `%PUBLIC_DIR%`, and the `extra.config-dir` and `extra.public-dir` keys change them. Flex does not overwrite existing files, except with `composer recipes:install --force`. The `env`, `gitignore` and `makefile` keys write their lines between `###> vendor/package ###` and `###< vendor/package ###`. On `composer remove`, Flex removes the copied files, these sections and the `config/bundles.php` line of the package. Entry point: `composer require <package>`.
- **Official and contrib recipes:** The official repository `symfony/recipes` holds the recipes of selected, maintained packages and all aliases. The contrib repository `symfony/recipes-contrib` holds community recipes and has no aliases. Flex reads both indexes by default. Before Flex applies a contrib recipe, it asks: `y`, `n`, `a` (all packages, this run only) or `p` (always). The answer `p` writes `"allow-contrib": true` to `extra.symfony`. In non-interactive mode, Flex skips the contrib recipe. After `n`, `composer recipes` shows `(recipe not installed)`, and `composer recipes:install <package> --force -v` applies the recipe later. Entry point: `extra.symfony.allow-contrib`, `SYMFONY_ALLOW_CONTRIB`.
- **Recipe selection:** Flex selects the recipe with the highest version that is not higher than the major.minor version of the package. If a recipe conflicts with the installed packages, Flex tries an older recipe or skips the package. If a package has no recipe, Flex uses an auto-generated recipe that registers the bundle class of the package in `config/bundles.php`. Flex finds the bundle class from the PSR-4 or PSR-0 namespaces of the package, and the class file must contain `Symfony\Component\HttpKernel\Bundle\Bundle` or `Symfony\Component\HttpKernel\Bundle\AbstractBundle`. A package from `require-dev` gets `['dev' => true, 'test' => true]`, and other packages get `['all' => true]`. Flex does not change the environments of a bundle that is already in `config/bundles.php`. Entry point: the `recipe.version` value in `symfony.lock`.
- **Aliases:** An alias is a short package name from a recipe index, usually the official index. Examples: `logger` (`symfony/monolog-bundle`), `orm` and `doctrine` (`symfony/orm-pack`), `debug`, `profiler`, `test`, `twig`, `serializer`, `webapp`, `security`, `mailer`, `maker` and `dump` (`symfony/var-dumper`). Flex resolves aliases for `require`, `update` and `remove`. For an unknown name without a slash, Flex stops with an error such as `"<name>" is not a valid alias.` and can list similar aliases. For a `symfony/*` package of the Symfony release set, the versions `lts`, `previous`, `stable`, `next` and `dev` become constraints from the index. On 2026-10-09, they are `^7.4`, `^8.0`, `^8.1`, `^8.2@dev` and `^8.2@dev`. Entry point: `composer require <alias>`, `composer require symfony/<package>:lts`.
- **One Symfony version:** `extra.symfony.require` (or the `SYMFONY_REQUIRE` environment variable) restricts all packages of the `symfony/symfony` release set to one constraint, for example `8.1.*`. Flex removes the other versions before Composer resolves the dependencies. If you run `composer require symfony/<package>` without a version, Flex writes this constraint. Packages with their own version line, for example `symfony/monolog-bundle`, are not restricted. To upgrade, change `extra.symfony.require` and the `symfony/*` constraints. If these constraints are `*`, change only `extra.symfony.require`. Then run `composer update "symfony/*"`. For the CI of a reusable bundle, the docs install Flex globally and set `SYMFONY_REQUIRE`, for example `7.*`. Entry point: `extra.symfony.require`.
- **Packs:** A pack is a Composer package of the type `symfony-pack` that only lists other packages. After `composer require <pack>`, Flex unpacks the pack: it removes the pack from `composer.json` and adds the listed packages with real version constraints. Entries that the pack also lists in its `require-dev` go to your `require-dev`. Flex unpacks a pack inside a pack too. A pack with no requirements, for example `symfony/apache-pack`, stays in `composer.json`. Flex 2 has no `unpack` command. Entry point: `composer require <pack>`. The packs on Packagist on 2026-10-09 (no pack is marked abandoned):
  - `symfony/serializer-pack` v1.4.0 (2026-03-03), alias `serializer`: `symfony/serializer`, `symfony/property-access`, `symfony/property-info`, `phpdocumentor/reflection-docblock`, `phpstan/phpdoc-parser`. It conflicts with `symfony/serializer` and `symfony/property-info` <7.4.
  - `symfony/orm-pack` v2.7.0 (2026-01-07), aliases `orm` and `doctrine`: `doctrine/orm`, `doctrine/doctrine-bundle`, `doctrine/doctrine-migrations-bundle`.
  - `symfony/debug-pack` v1.1.0 (2025-11-25), alias `debug`: `symfony/debug-bundle` and `symfony/profiler-pack` (both to `require-dev`) and `symfony/monolog-bundle` ^3.0|^4.0. Since v1.0.10 it does not list `symfony/var-dumper`, but DebugBundle requires it.
  - `symfony/webapp-pack` v1.4.0 (2025-11-25), alias `webapp`: 26 packages, for example `symfony/asset-mapper`, `symfony/form`, `symfony/mailer`, `symfony/security-bundle`, `symfony/stimulus-bundle`, `symfony/ux-turbo`, `symfony/validator`, `symfony/orm-pack`, `symfony/serializer-pack` and `symfony/twig-pack`. `symfony/debug-pack`, `symfony/profiler-pack`, `symfony/maker-bundle` and `symfony/test-pack` go to `require-dev`. Its recipe adds `config/packages/messenger.yaml` with an `async` transport and a `failed` transport.
  - `symfony/test-pack` v1.2.0 (2025-05-20), aliases `test`, `tests` and `phpunit`: `phpunit/phpunit` (conflict <11.1), `symfony/browser-kit`, `symfony/css-selector`, all to `require-dev`. Since v1.2.0 it does not install `symfony/phpunit-bridge`.
  - `symfony/psr7-pack` v1.3.0 (2023-05-06), alias `psr7`: `symfony/psr-http-message-bridge`, `php-http/discovery` ^1.18, `psr/http-factory-implementation`. Its recipe adds `config/packages/psr_http_message_bridge.yaml` with the factory services.
  - `symfony/profiler-pack` v1.0.6 (2021-08-20), alias `profiler`: `symfony/web-profiler-bundle` and `symfony/stopwatch`, both to `require-dev`.
  - `symfony/twig-pack` v1.0.1 (2020-10-19), alias `twig`: `symfony/twig-bundle`, `twig/twig` ^2.12|^3.0, `twig/extra-bundle` ^2.12|^3.0.
  - `symfony/amqp-pack` v1.0.13 (2020-10-19), alias `amqp`: `symfony/messenger`, `symfony/serializer-pack`, `ext-amqp`. It does not list the AMQP transport `symfony/amqp-messenger`. The Messenger docs install `symfony/amqp-messenger` directly.
  - `symfony/apache-pack` v1.0.1 (2017-12-12), no alias: an empty pack. Its recipe in the contrib repository copies `public/.htaccess`, so Flex asks for permission.
  - `symfony/platformsh-pack` does not exist on Packagist. The alias `platformsh` installs `symfonycorp/platformsh-pack` v1.0.0 (2021-10-20): `blackfireio/blackfire-symfony-meta` and `symfonycorp/platformsh-meta`.
- **`symfony/skeleton`:** The minimal project template (v8.1.99, 2026-05-29) requires PHP >=8.4, `ext-ctype`, `ext-iconv` and `symfony/flex` ^2. Its `flex-require` section lists `symfony/console`, `symfony/dotenv`, `symfony/framework-bundle`, `symfony/runtime` and `symfony/yaml`. After Flex installs itself, it moves `flex-require` into `require` and replaces `*` with the `extra.symfony.require` value `8.1.*`. On `composer create-project`, Flex deletes `LICENSE`, sets `"license": "proprietary"` and removes `name`, `description` and `extra.branch-alias`. The skeleton sets `"allow-contrib": false` and a conflict with `symfony/symfony`. For a web application, run `composer require webapp` after `create-project`. Entry point: `composer create-project symfony/skeleton:"8.1.*" my_project_directory`.
- **`symfony.lock`:** Flex writes this file next to `composer.lock`. For each package, it stores `version`, `recipe` (`repo`, `branch`, `version`, `ref`) and the `files` that the recipe copied. Commit it. Flex does not apply a recipe again when `symfony.lock` has the same `ref`. On `composer remove`, Flex keeps a file that `symfony.lock` also lists for another package. `composer recipes:update` uses the stored `ref` to get the original recipe. `SYMFONY_LOCKFILE` sets another path. Entry point: `symfony.lock`.
- **Recipe status and reinstall:** `composer recipes` lists the recipes of the installed packages and marks `(update available)` or `(recipe not installed)`. With a package name, it shows the details of that recipe. With `--outdated` (`-o`), it shows only outdated recipes and returns the exit code 1 when it finds one. `composer recipes:install` applies the recipes of installed packages that have no `symfony.lock` entry. With `--force`, Flex also applies a recipe if `symfony.lock` has no `ref` or an old `ref` for it, and overwrites the existing files. `--force` needs `git`. Flex asks before it overwrites a file with uncommitted changes, and `--yes` answers yes. If `symfony.lock` already has the latest `ref`, `--force` does not apply the recipe again. To apply it again, for example to restore a deleted file, add `--reset` to `--force`. Entry point: `composer recipes`, `composer recipes:install`.
- **Recipe update:** `composer recipes:update [<package>]` updates an installed recipe to its latest version. Without a package, it asks which outdated recipe to update. It gets the original recipe from the `ref` in `symfony.lock`, makes a patch to the new recipe and applies it with `git apply -3`. Conflicts appear as Git conflicts. If you deleted a recipe file, the command does not create it again. The command needs `git` and stops if tracked files have uncommitted changes. It stages the changes and `symfony.lock`. It prints a changelog of the recipe pull requests, unless you add `--no-changelog`. Entry point: `composer recipes:update`.
- **Compiled `.env` file:** `composer dump-env prod` reads all `.env` files for the `prod` environment and writes the final values to `.env.local.php`. With `--empty`, the file contains only `APP_ENV`, for servers that set real environment variables. The command needs `symfony/dotenv` and reads `extra.runtime` (`dotenv_path`, `env_var_name`, `test_envs`, `env`). If Composer is not on the server, register `Symfony\Component\Dotenv\Command\DotenvDumpCommand` as a service. Then run `php bin/console dotenv:dump`. Entry point: `composer dump-env`.
- **Auto-scripts:** Recipes add commands to `scripts.auto-scripts` in `composer.json`. The skeleton runs `@auto-scripts` after `composer install` and `composer update`. Each entry has a type: `symfony-cmd` runs `bin/console <command>`, `php-script` runs a PHP file and `script` runs a shell command. Flex skips `symfony-cmd` entries when `symfony/console` is not installed. If a script fails, Flex prints its output and stops with a `ScriptExecutionException`. Entry point: `scripts.auto-scripts`.
- **Docker configuration:** Recipes with `docker-compose` or `dockerfile` keys add services to `compose.yaml` and lines to the `Dockerfile`. The `Dockerfile` must already contain the line `###> recipes ###`: Flex adds the recipe lines after it. Flex asks before it applies Docker configuration. The answers `y` and `n` apply to the current run, and `p` and `x` write `"docker": true` or `false` to `extra.symfony`. In non-interactive mode, Flex uses the default answer `y`. To skip the question, set `extra.symfony.docker` or `SYMFONY_DOCKER`. `SYMFONY_DOCKER` also writes its value to `extra.symfony.docker`. Entry point: `extra.symfony.docker`.
- **UX package assets:** After `composer require`, `update` or `remove`, Flex reads the `package.json` in the `assets/` directory of each installed package with the Composer keyword `symfony-ux`. If `importmap.php` exists, Flex runs `importmap:require` for the JavaScript packages. Otherwise, it adds `file:vendor/...` links and peer dependencies to `package.json`. In both cases, it adds the Stimulus controllers to `assets/controllers.json`. To stop this, set `synchronize_package_json` to `false` under `extra.symfony/flex`. Entry point: `assets/controllers.json`.
- **Private recipe repositories:** Put your recipes and an `index.json` file in a private GitHub or GitLab repository. Then set `extra.symfony.endpoint` to an array: the URL of `index.json` first, then `flex://defaults`. For GitHub, the URL must start with `https://api.github.com/repos`. Flex reads the endpoints in this order, so a private recipe wins over a public recipe for the same package. If `flex://defaults` is missing and `extra.symfony.require` is set, Flex throws a `LogicException` about the missing `"splits"` entry. The index example in the docs sets `"is_contrib": true`, so Flex asks for permission as for contrib recipes. Entry point: `extra.symfony.endpoint`, `SYMFONY_ENDPOINT`.

## Entry points

- `Symfony\Flex\Flex`: the Composer plugin class (package type `composer-plugin`). Put `symfony/flex` in the root `require`. Allow it in `config.allow-plugins`.
- `composer create-project symfony/skeleton:"8.1.*" <directory>`
- `composer require <package|alias|pack>`, `composer remove <package|alias>`
- `composer recipes [<package>] [--outdated|-o]` (command `symfony:recipes`)
- `composer recipes:install [<packages>...] [--force] [--reset] [--yes]` (command `symfony:recipes:install`; aliases `symfony:sync-recipes`, `sync-recipes`, `fix-recipes`)
- `composer recipes:update [<package>] [--no-changelog]` (command `symfony:recipes:update`)
- `composer dump-env [<env>] [--empty]` (command `symfony:dump-env`)
- `composer.json` keys under `extra.symfony`: `require`, `allow-contrib`, `endpoint`, `docker`, `root-dir`
- `composer.json` keys under `extra`: `bin-dir`, `config-dir`, `src-dir`, `var-dir`, `public-dir`, `runtime` (`dotenv_path`, `env_var_name`, `test_envs`, `env`)
- `composer.json`: `"extra": {"symfony/flex": {"synchronize_package_json": false}}`
- `composer.json` sections `flex-require`, `flex-require-dev` and `scripts.auto-scripts`
- Environment variables: `SYMFONY_REQUIRE`, `SYMFONY_ALLOW_CONTRIB`, `SYMFONY_DOCKER`, `SYMFONY_ENDPOINT`, `SYMFONY_CAFILE`, `SYMFONY_LOCKFILE`
- Files: `symfony.lock`, `config/bundles.php`, the `###> vendor/package ###` sections in `.env`, `.gitignore` and `Makefile`, and `###> recipes ###` in `Dockerfile`
- Composer package type `symfony-pack` (packs) and Composer keyword `symfony-ux` (UX packages)

## Symbiotic packages

- [Dotenv](../packages/dotenv.md): `composer dump-env` needs symfony/dotenv to read the `.env` files, and recipes write default values to `.env` between `###> vendor/package ###` lines.
- [Runtime](../packages/runtime.md): the skeleton installs symfony/runtime through `flex-require`, and Flex reads `extra.runtime` for `.env` recipes and `composer dump-env`.
- [FrameworkBundle](../packages/framework-bundle.md): Flex applies the FrameworkBundle recipe directly after the recipes of Flex, packs and metapackages, and the 8.1 recipe creates `src/Kernel.php`, `config/preload.php`, `AGENTS.md` and `CLAUDE.md`.
- [Console](../packages/console.md): `symfony-cmd` auto-scripts run through `bin/console`, and Flex skips them when symfony/console is not installed.
- [AssetMapper](../packages/asset-mapper.md): if `importmap.php` exists, Flex runs `importmap:require` for the JavaScript dependencies of installed UX packages.
- [StimulusBundle](../packages/stimulus-bundle.md): Flex adds the Stimulus controllers of installed UX packages to `assets/controllers.json`.
- [MakerBundle](../packages/maker-bundle.md): often confused with Flex; MakerBundle generates code with `make:*` commands, and Flex installs and configures packages (`composer require --dev maker`).
- [DebugBundle](../packages/debug-bundle.md): the `debug` alias installs symfony/debug-pack, which adds DebugBundle, MonologBundle and symfony/profiler-pack.
- [WebProfilerBundle](../packages/web-profiler-bundle.md): the `profiler` alias installs symfony/profiler-pack, which adds WebProfilerBundle and Stopwatch to `require-dev`.
- [MonologBundle](../packages/monolog-bundle.md): the `logger` alias installs MonologBundle; the setup docs use it as the first Flex example.
- [VarDumper](../packages/var-dumper.md): the `dump` alias installs only VarDumper; symfony/debug-pack does not list it, but DebugBundle requires it.
- [PHPUnit Bridge](../packages/phpunit-bridge.md): symfony/test-pack 1.2 does not install the bridge; if you need it, require `symfony/phpunit-bridge` (alias `phpunit-bridge`).
- [BrowserKit](../packages/browser-kit.md): the `test` alias installs symfony/test-pack, which adds BrowserKit, CssSelector and PHPUnit for application tests.
- [Messenger](../packages/messenger.md): the `amqp` alias installs symfony/amqp-pack without the AMQP transport; for AMQP, install `symfony/amqp-messenger` as the Messenger docs show.
- [PSR-7 Bridge](../packages/psr-http-message-bridge.md): the `psr7` alias installs symfony/psr7-pack, and its recipe registers the PSR-7 factory services.
- [Serializer](../packages/serializer.md): the `serializer` alias installs symfony/serializer-pack with PropertyAccess, PropertyInfo and the PHPDoc parsers.
- [TwigBundle](../packages/twig-bundle.md): the `twig` alias installs symfony/twig-pack with Twig and `twig/extra-bundle`.
- [Symfony Requirements Checker](../packages/requirements-checker.md): its Flex recipe adds the `"requirements-checker": "script"` auto-script, so Flex runs the checker after `composer install` and `composer update`.
- [UX Toolkit](../packages/ux-toolkit.md): a UX Toolkit recipe is a set of UI files that `ux:install` copies, not a Flex recipe for a Composer package.
- [WebpackEncoreBundle](../packages/webpack-encore-bundle.md): if the project has no `importmap.php`, Flex adds the `file:vendor/...` npm package of each UX bundle to `package.json`; then run `npm install --force`.

## Changed in 2.0 to 2.11

- 2.0: `composer unpack <pack>` (deprecated since 1.4) does not exist. Flex unpacks packs during `composer require`.
- 2.5.0: `"extra": {"symfony/flex": {"synchronize_package_json": false}}` stops the `package.json`, `importmap.php` and `controllers.json` updates.
- 2.6.0: `composer recipes:install --yes` overwrites files without questions, and recipes can use the `composer-commands` key.
- 2.9.0: Flex needs PHP 8.1 or later.
- 2.10.0: `symfony/http-kernel` 7.4 and 8.x conflict with `symfony/flex` <2.10. Update Flex before you update to Symfony 7.4 or 8.
- 2.11.0: `SYMFONY_ALLOW_CONTRIB=1` allows contrib recipes without a change to `composer.json`, for example in CI.
- 2.11.0: `composer recipes:update --no-changelog` does not get the changelog from GitHub.

## Status

Flex is a Composer plugin with its own 2.x version line. It needs the PHP `openssl` extension: without it, Flex disables itself and prints a warning. `composer recipes:update` and `composer recipes:install --force` need the `git` command. Flex applies recipes only when `symfony/flex` is in the root `require` or `require-dev`, and not from a global installation.

## Docs

- https://symfony.com/doc/current/setup.html
- https://symfony.com/doc/current/setup/flex.html
- https://symfony.com/doc/current/setup/flex_private_recipes.html
- https://symfony.com/doc/current/setup/upgrade_minor.html
- https://symfony.com/doc/current/setup/upgrade_major.html
- https://symfony.com/doc/current/setup/docker.html
- https://symfony.com/doc/current/configuration.html
- https://symfony.com/doc/current/deployment.html
- https://symfony.com/doc/current/configuration/override_dir_structure.html
- https://symfony.com/doc/current/bundles/best_practices.html
- https://symfony.com/doc/current/frontend/create_ux_bundle.html
- https://symfony.com/doc/current/quick_tour/flex_recipes.html
- https://github.com/symfony/flex
- https://github.com/symfony/recipes
- https://github.com/symfony/recipes-contrib
