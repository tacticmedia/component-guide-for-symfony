# Symfony Requirements Checker (`symfony/requirements-checker`): details

**Applies to:** Requirements Checker 2.0

## Key features and concepts

- **Requirements and recommendations:** The checker has two types of checks. A failed requirement prints `E` (with `-v`: `[ERROR]`) and sets the exit code to 1. A failed recommendation prints `W` (with `-v`: `[WARN]`) and does not change the exit code. Entry point: `Symfony\Requirements\Requirement::isOptional()`.
- **PHP extension checks:** The requirements test the iconv, JSON, session, ctype, Tokenizer, SimpleXML and PCRE extensions. This is the extension list of the setup docs, plus JSON. The recommendations test DOM (`DomDocument`), mbstring, filter, posix (not on Windows), intl and PDO with at least one driver. The XML recommendation tests `utf8_decode()`. Since PHP 8.2, ext/standard defines this function, so the check passes without the XML extension. Entry point: `Symfony\Requirements\SymfonyRequirements`.
- **php.ini checks:** If the mbstring extension is loaded, `mbstring.func_overload` must be 0. If Xdebug is loaded, `xdebug.show_exception_trace` and `xdebug.scream` must be off. The recommendations include `short_open_tag` and `session.auto_start` off, `xdebug.max_nesting_level` above 100 and `intl.error_level` 0. Entry point: `Symfony\Requirements\PhpConfigRequirement`.
- **Memory, upload and cache values:** The checker recommends a `memory_limit` greater than `post_max_size`, and a `post_max_size` greater than `upload_max_filesize`. On Windows only, it also recommends a `realpath_cache_size` of at least 5M. Entry point: `Symfony\Requirements\SymfonyRequirements`.
- **Opcode cache:** The checker recommends an enabled PHP accelerator, for example OPcache with `opcache.enable`. It does not check the OPcache values that the performance docs recommend, for example `opcache.memory_consumption`. Entry point: `Symfony\Requirements\SymfonyRequirements`.
- **ICU data check:** This recommendation runs only if the `intl` extension is loaded and symfony/intl is installed. It compares the ICU version of the extension with the ICU data version of symfony/intl. Entry point: `Symfony\Component\Intl\Intl::getIcuDataVersion()`.
- **Project checks:** If the current directory contains `composer.json`, or if you give a directory argument, the checker also checks the project. It checks a minimum PHP version (8.1.0 for Symfony 6 and later), the default timezone and the `vendor/composer/` directory. If `var/cache/` and `var/log/` exist, it checks that the current user can write to them. It does not check the web server user. It reads custom `vendor-dir` and `var-dir` values from the `extra` or `config` section of `composer.json`. The Symfony version detection ignores a custom `vendor-dir`: it always reads `vendor/symfony/http-kernel/Kernel.php`. Entry point: `Symfony\Requirements\ProjectRequirements`.
- **Composer auto-script:** The docs add the checker to `scripts.auto-scripts` as `"vendor/bin/requirements-checker": "php-script"`. Flex runs a `php-script` entry with the PHP binary and the php.ini file of the Composer process. If the checker returns 1, Flex throws a `ScriptExecutionException`, and the Composer command returns the exit code 1. Entry point: `scripts.auto-scripts`.
- **Order of auto-scripts:** Flex runs the `auto-scripts` entries in their order and stops at the first failure. The Flex recipe adds `"requirements-checker": "script"` at the end of the list. Keep only one checker entry. Put it first, as in the docs example. Then it runs before the other entries. Entry point: `scripts.auto-scripts`.
- **CLI and web server:** The checker tests only the PHP binary and the php.ini file that run it. It prints the path of the loaded php.ini file, or a warning if PHP loads no php.ini file. At the end, it prints a note: the web server can use a different php.ini file. Entry point: `vendor/bin/requirements-checker`.
- **Same code as the Symfony CLI:** `symfony check:requirements` (alias `check:req`) runs an embedded single-file build of this package. This build is identical to the build of v2.0.3. The CLI copy runs from the cache directory of the Symfony CLI, so it does not load the `vendor/autoload.php` file of the project. Thus, it skips the ICU data check of symfony/intl, and polyfills do not pass its function checks. Entry point: `symfony check:requirements`.
- **No framework dependency:** The package requires only PHP `>=5.3.9`. It has no bundle, no services and no configuration keys. Entry point: `vendor/bin/requirements-checker`.
- **PHP API:** The classes in `Symfony\Requirements\` are plain PHP classes. `RequirementCollection::getFailedRequirements()` and `getFailedRecommendations()` return the failed checks. `Requirement::getTestMessage()` and `getHelpText()` give the check message and the fix. The Symfony docs do not describe this API. Entry point: `new Symfony\Requirements\SymfonyRequirements()`.

## Entry points

- `composer require symfony/requirements-checker` (Flex alias `req-checker`). Do not add `--dev`. On production, `composer install --no-dev` does not install development packages.
- `vendor/bin/requirements-checker [<project-directory>] [-v]`: the exit code is 0 when all requirements pass and 1 when a requirement fails. `-vv` and `-vvv` work like `-v`.
- The `scripts.auto-scripts` entry in `composer.json`: `"vendor/bin/requirements-checker": "php-script"` (docs) or `"requirements-checker": "script"` (Flex recipe 2.0).
- Symfony CLI: `symfony check:requirements [--dir=<project-directory>]` (alias `check:req`; `--directory` is an alias of `--dir`).
- PHP classes in the `Symfony\Requirements\` namespace: `SymfonyRequirements`, `ProjectRequirements` (constructor argument: the project directory), `RequirementCollection`, `Requirement` and `PhpConfigRequirement`.
- Without FrameworkBundle: the package needs only PHP. Run `vendor/bin/requirements-checker`, or create `new Symfony\Requirements\SymfonyRequirements()` and read the failed checks with `RequirementCollection::getFailedRequirements()` and `getFailedRecommendations()`.
- The package has no services, attributes, config keys, Twig functions or test helpers.

## Symbiotic packages

- [Symfony Flex](../packages/flex.md): the Flex recipe adds the checker to `scripts.auto-scripts`, and Flex runs these entries after `composer install` and `composer update` in a skeleton-based project.
- [Intl](../packages/intl.md): if symfony/intl is installed, the checker compares the ICU version of the `intl` extension with the ICU data that symfony/intl bundles.
- [HttpKernel](../packages/http-kernel.md): the checker reads `Kernel::VERSION` of symfony/http-kernel to select the minimum PHP version, which is too low for Symfony 7 and 8.
- [FrameworkBundle](../packages/framework-bundle.md): its `about` command shows information such as the PHP version and the OPcache status, but it always returns 0 and cannot stop a deployment.
- [Symfony Polyfill](../packages/polyfill.md): when it runs from `vendor/bin`, the checker loads `vendor/autoload.php`, so a polyfill function passes its check, for example `mb_strlen()` from symfony/polyfill-mbstring.

## Status

- Low release activity: v2.0.3 (2024-11-14) is the latest release, and on 2026-10-09 the `main` branch has no later commit. Packagist does not mark the package as abandoned, and GitHub does not show the repository as archived. The Symfony CLI embeds v2.0.3.
- The PHP version check does not know Symfony 7 and 8. For each Symfony version from 6.0.0, the checker requires only PHP 8.1.0. Symfony 7.x requires PHP 8.2, and Symfony 8.1 requires PHP 8.4.1 (the setup docs say 8.4). If the project uses Symfony 7 or 8, do not rely on the checker for the minimum PHP version. To check the PHP version and the `ext-*` requirements of the installed packages, run `composer check-platform-reqs --no-dev`.
- Version 2 is a command-line tool only. The `public/check.php` web page of version 1 does not exist in version 2.

## Docs

- https://symfony.com/doc/current/deployment.html
- https://symfony.com/doc/current/setup.html
- https://symfony.com/doc/current/setup/flex.html
- https://symfony.com/doc/current/migration.html
- https://symfony.com/doc/current/performance.html
- https://github.com/symfony/requirements-checker
