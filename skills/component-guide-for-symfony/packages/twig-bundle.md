# TwigBundle (`symfony/twig-bundle`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when an application renders HTML pages, emails or custom 404 and 500 error pages with Twig templates. It sets up Twig with template directories, global variables, custom filters, form themes, overrides of third-party templates and a syntax check command. For the template functions that build URLs and forms, see [Twig Bridge](twig-bridge.md).

**Details:** [../details/twig-bundle.md](../details/twig-bundle.md)

## Why it exists

Without the package, an application must create the Twig environment, the template loaders and the Twig extensions itself. The package creates the Twig environment from one configuration. It registers the template directories and the Twig extensions of the installed components. It also adds the Twig commands, a warm-up of the compiled templates and Twig error pages.

## When to use it

- Render a Twig template from a controller, from other PHP code or for an email.
- Make a value or a shared object available as a variable in all templates.
- Load templates from more directories, or group them under a namespace, for example admin.
- Add a custom Twig filter, function or test.
- Apply one form theme, for example Bootstrap 5, to all forms of the application.
- Show custom 404 and 500 error pages in production.
- Write static HTML error pages that the web server can show.
- Change a template of a third-party package, and keep its files in the vendor directory unchanged.
- Check the syntax of all Twig templates in a CI pipeline.

## Use it instead of

- `new Environment(new FilesystemLoader(__DIR__.'/../templates'))` in a service -> autowire `Twig\Environment` (the `twig` service).
- An `AbstractExtension` subclass that returns `new TwigFilter('price', [$this, 'formatPrice'])` from `getFilters()` -> `#[AsTwigFilter('price')]` on a method of a class that does not extend `AbstractExtension` or implement `ExtensionInterface` (`Twig\Attribute\AsTwigFilter`).
- The same value in each `render()` call, for example `'ga_tracking' => $trackingCode` -> `twig.globals`.
- `|date('d.m.Y')` or `|number_format(2, ',', '.')` in each template -> `twig.date.format` and `twig.number_format`.
- A `kernel.exception` listener or a custom error controller that only renders an HTML 404 page -> `templates/bundles/TwigBundle/Exception/error404.html.twig` and `error.html.twig`.
- A copied or patched template in `vendor/acme/blog-bundle/` -> an override in `templates/bundles/AcmeBlogBundle/` with `{% extends '@!AcmeBlog/...' %}`.
- A CI script that calls `$twig->createTemplate()` for each file in a `try`/`catch` block -> `php bin/console lint:twig --format=github`.
- `{{ value|raw }}` at each use of a trusted HTML value object -> the `twig.safe_class` resource tag.
- `$loader->addPath('backend/templates', 'admin')` in a manual loader setup -> `twig.paths: { 'backend/templates': 'admin' }`.
