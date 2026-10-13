# Symfony Requirements Checker (`symfony/requirements-checker`)

**Applies to:** Requirements Checker 2.0

**Elevator pitch:** Use when a deployment must check that a server has the PHP extensions and php.ini values that the framework needs. It runs the same checks as the Symfony CLI and can make a Composer install fail on errors. Its PHP version check is too low for Symfony 7 and 8.

**Details:** [../details/requirements-checker.md](../details/requirements-checker.md)

## Why it exists

Symfony needs some PHP extensions and correct php.ini values. The docs recommend a check command of the Symfony CLI on a development machine, but a production server does not always have the Symfony CLI. This Composer package runs the same checks on the server and returns the exit code 1 when a requirement fails.

## When to use it

- Check a production server for the PHP extensions that Symfony needs, without the Symfony CLI.
- Make a Composer install fail on a server without a required PHP extension.
- Check the php.ini values that Symfony needs, for example the mbstring function overload setting and the Xdebug settings.
- Show which php.ini file the PHP command line uses.
- Check that the command-line user can write to the cache and log directories after a deployment.
- Get recommendations for the PHP setup, for example an enabled OPcache and the intl extension.
- Read the failed checks and their fixes from PHP code.
- Replace the requirements script of an old project that uses the Symfony Standard Edition.

## Use it instead of

- A hand-written `check.php` with `extension_loaded('intl')` or `function_exists('ctype_alpha')` tests -> `vendor/bin/requirements-checker`.
- `php -m | grep -q ctype || exit 1` in a deployment script -> the auto-script `"vendor/bin/requirements-checker": "php-script"`, which makes `composer install` fail on errors.
- `php --ini` and `php -i` output that you read by hand -> `vendor/bin/requirements-checker -v`, which prints the php.ini path and the result of each check.
- `is_writable('var/cache')` and `is_writable('var/log')` calls in a deployment script -> the project checks of `Symfony\Requirements\ProjectRequirements`, which run when the current directory contains `composer.json`.
- `ini_get('memory_limit')` compared with `ini_get('post_max_size')` by hand -> the memory and upload recommendations of `Symfony\Requirements\SymfonyRequirements`.
- A copy of the `bin/symfony_requirements` script from the Symfony Standard Edition -> `composer require symfony/requirements-checker`.
