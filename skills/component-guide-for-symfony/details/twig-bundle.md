# TwigBundle (`symfony/twig-bundle`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Twig service**: The bundle registers the `twig` service, a `Twig\Environment` with the `app` global variable. Autowire it to render a template in a service. `AbstractController::render()` uses the same service. Entry point: `Twig\Environment`.
- **Template directories**: Twig loads templates from `twig.default_path` (default: `%kernel.project_dir%/templates`). `twig.paths` adds directories, relative to the project directory or absolute, each with an optional namespace. Twig searches the directories without a namespace before `templates/`. Refer to a namespaced template as `@admin/layout.html.twig`. Entry point: `twig.paths`.
- **Bundle namespaces and overrides**: The templates of `AcmeBlogBundle` have the namespace `@AcmeBlog`. A file in `templates/bundles/AcmeBlogBundle/` replaces the bundle template that has the same relative path. To extend the original template in the override, use the `@!AcmeBlog/` prefix. `debug:twig @AcmeBlog/layout.html.twig` shows the matched file and the overridden files. Entry point: `templates/bundles/<BundleName>/`.
- **Global variables**: `twig.globals` adds variables to all templates. A value that starts with `@` is a service ID, and `@@` escapes a literal `@`. Twig creates the referenced service when Twig loads, also when no template uses the variable. Entry point: `twig.globals`.
- **Default date and number formats**: `twig.date` sets the defaults of the `date` filter: `format` (`F j, Y H:i`), `interval_format` (`%d days`) and `timezone` (default: the PHP default time zone). `twig.number_format` sets the defaults of the `number_format` filter: `decimals` (`0`), `decimal_point` (`.`) and `thousands_separator` (`,`). Entry point: `twig.date`, `twig.number_format`.
- **Strict variables and debug**: If `twig.strict_variables` is `true`, Twig throws an exception for an unknown variable, attribute or method. If it is `false`, Twig uses `null`. The default is `%kernel.debug%`, and the Flex recipe sets `true` in the `test` environment. `twig.debug` defaults to `%kernel.debug%`. If `twig.auto_reload` is not set, it follows `twig.debug`. Entry point: `twig.strict_variables`.
- **Compiled template cache**: Twig compiles templates to PHP classes in `%kernel.cache_dir%/twig` (`twig.cache: true`). If `twig.auto_reload` is false and `kernel.build_dir` differs from `kernel.cache_dir`, the warmer writes to `%kernel.build_dir%/twig`. Twig then reads that read-only copy first. The warmer ignores templates that do not compile. `twig.file_name_pattern` limits the files that the warmer compiles. Do not set `twig.cache: false`, also not in `dev`, because `auto_reload` compiles changed templates again. Entry point: `twig.cache`.
- **Escaping strategy**: Twig selects the escaping strategy from the file name. It escapes `*.html.twig` templates for HTML and `*.js.twig` templates for JavaScript. To select the strategy with your own service, set `twig.autoescape_service`. If that service is not invokable, also set `twig.autoescape_service_method`. Entry point: `twig.autoescape_service`.
- **Safe classes (8.1)**: The `twig.safe_class` resource tag marks a class whose objects Twig does not escape for the given strategies, so templates need no `|raw`. The class must implement `Stringable`. The `strategy` attribute takes one strategy or a list: `html`, `js`, `css`, `url`, `html_attr`, `html_attr_relaxed`, `all` or a custom name. Add the tag with `resource_tags` in YAML, `->resourceTag()` in PHP or `#[AutoconfigureResourceTag('twig.safe_class', ['strategy' => 'html'])]`. The attribute needs an autoconfigured definition of the class, for example from the `App\` resource, not from an `exclude` path. If you use `tags` instead of `resource_tags`, the container compilation fails. Entry point: `twig.safe_class`.
- **Extensions with attributes**: Add `#[AsTwigFilter('price')]`, `#[AsTwigFunction('area')]` or `#[AsTwigTest('discounted')]` to a method of a service class. The first argument of each attribute is the name in Twig. TwigBundle then registers a `Twig\Extension\AttributeExtension` for the class. If the method is not static, the class becomes a lazy runtime service, so constructor injection works. Do not use these attributes in a class that extends `AbstractExtension` or implements `ExtensionInterface`. If you do, the container compilation fails with a `LogicException`. Without autoconfiguration, tag the service `twig.attribute_extension`, and also `twig.runtime` for non-static methods. Entry point: `Twig\Attribute\AsTwigFilter`.
- **Tagged extensions, runtimes and loaders**: Autoconfiguration adds the tag `twig.extension` to each `Twig\Extension\ExtensionInterface` service, `twig.runtime` to each `RuntimeExtensionInterface` service and `twig.loader` to each `Twig\Loader\LoaderInterface` service. The `priority` attribute sorts extensions and loaders. Twig tries the loader with the highest priority first. Entry point: `twig.extension`.
- **Global form themes**: `twig.form_themes` applies form themes to all forms, for example `bootstrap_5_layout.html.twig`. If the list does not contain `form_div_layout.html.twig`, the bundle adds it as the first theme. Each theme overrides the themes before it. Entry point: `twig.form_themes`.
- **Error page templates**: If `kernel.debug` is false, `TwigErrorRenderer` renders `templates/bundles/TwigBundle/Exception/error<code>.html.twig`, or else `error.html.twig`. If neither template exists, the default HTML error page of ErrorHandler shows. The template gets the variables `exception` (a `FlattenException`), `status_code` and `status_text`. In `dev`, the URL `/_error/404` previews the template. To write static HTML error pages for the web server, run `APP_ENV=prod php bin/console error:dump var/cache/prod/error_pages/`. Security data, such as the current user, is not available on 404 pages. Entry point: `templates/bundles/TwigBundle/Exception/`.
- **Console commands**: `lint:twig` checks the syntax of files, directories or `STDIN` (`-`), and returns exit code 1 for errors. Its options are `--format=txt|json|github`, `--show-deprecations` and `--excludes`. In GitHub Actions, the default format is `github`. If you give no file, the command checks all directories of the default `FilesystemLoader`. `lint:twig @AcmeBlogBundle` checks the templates of one bundle. `debug:twig` lists the functions, filters, tests and globals (`--filter`, `--format=txt|json`), or the files of one template name. Entry point: `lint:twig`, `debug:twig`.
- **Component integrations**: If a component is installed, the bundle wires it. For Mailer, a listener renders the templates of each `TemplatedEmail`, and `twig.mailer.html_to_text_converter` sets the converter for the text part. For Validator, the bundle registers the validator of the `Twig` constraint. For Translation, `translation:extract` reads the templates with `TwigExtractor`. For AssetMapper, the bundle adds the `importmap()` function. For Form, it adds the form extension and the form renderer. Entry point: `Symfony\Component\Mime\BodyRendererInterface`.

## Entry points

- `Symfony\Bundle\TwigBundle\TwigBundle`: the bundle class. The Flex recipe enables it in all environments and creates `config/packages/twig.yaml` and `templates/base.html.twig`.
- `Twig\Environment`: the `twig` service. Autowire it.
- Config root `twig`: `default_path`, `paths`, `globals`, `form_themes`, `date`, `number_format`, `strict_variables`, `debug`, `auto_reload`, `cache`, `charset`, `optimizations`, `autoescape_service`, `autoescape_service_method`, `file_name_pattern`, `mailer.html_to_text_converter`. `php bin/console config:dump-reference twig` shows the defaults.
- `Twig\Attribute\AsTwigFilter`, `Twig\Attribute\AsTwigFunction`, `Twig\Attribute\AsTwigTest` (package `twig/twig` 3.21 or later).
- `Twig\Extension\ExtensionInterface`, `Twig\Extension\AbstractExtension`, `Twig\Extension\RuntimeExtensionInterface`, `Twig\Loader\LoaderInterface`.
- Service tags: `twig.extension` (`priority`), `twig.runtime`, `twig.loader` (`priority`), `twig.attribute_extension`. Resource tag: `twig.safe_class` (`strategy`); attribute: `Symfony\Component\DependencyInjection\Attribute\AutoconfigureResourceTag`.
- Console commands: `lint:twig` (`Symfony\Bundle\TwigBundle\Command\LintCommand`), `debug:twig` (`Symfony\Bridge\Twig\Command\DebugCommand`).
- Template paths: `templates/`, `templates/bundles/<BundleName>/`, `templates/bundles/TwigBundle/Exception/error<code>.html.twig`, `@<namespace>/...`, `@!<BundleNamespace>/...`.
- `Symfony\Component\Mime\BodyRendererInterface`: renders a `TemplatedEmail` before `$mailer->send()`, for example when the context is not serializable for Messenger.
- The Twig functions, filters and tags, the `app` variable and `#[Template]`: see [Twig Bridge](../packages/twig-bridge.md).

## Symbiotic packages

- [Twig Bridge](../packages/twig-bridge.md): TwigBundle requires the bridge and registers its extensions, commands and error renderer; the bridge provides the functions, filters, `TemplatedEmail` and `#[Template]`.
- [FrameworkBundle](../packages/framework-bundle.md): `AbstractController::render()`, `renderView()`, `stream()` and `TemplateController` need the `twig` service from TwigBundle; without it, they throw a `LogicException`.
- [Form](../packages/form.md): If `symfony/form` is installed, TwigBundle registers the form extension and the form renderer, and `twig.form_themes` sets the themes of all forms.
- [Mailer](../packages/mailer.md): TwigBundle registers the listener that renders the templates of each `TemplatedEmail` before the mailer sends the email.
- [Validator](../packages/validator.md): If `symfony/validator` is installed, TwigBundle registers the validator of the `Twig` constraint, which checks that a string has valid Twig syntax.
- [Translation](../packages/translation.md): TwigBundle registers the translation extension and the `TwigExtractor` for `translation:extract`; for translation parameters, use `framework.translator.globals`, not `twig.globals`.
- [ErrorHandler](../packages/error-handler.md): The Twig error renderer decorates the `error_renderer.html` service; if no error template exists, the default ErrorHandler page shows.
- [HttpKernel](../packages/http-kernel.md): For a custom HTML error page, an error template is enough; the HttpKernel `kernel.exception` event is for your own exception logic.
- [DebugBundle](../packages/debug-bundle.md): DebugBundle adds the `{% dump %}` tag and its `dump()` function; both cause an error in `prod`, and without DebugBundle, debug mode has only `dump()`.
- [WebProfilerBundle](../packages/web-profiler-bundle.md): TwigBundle registers the `data_collector.twig` service for the Twig profiler panel; in debug mode, its profiler extension records the render time of each template.
- [DependencyInjection](../packages/dependency-injection.md): TwigBundle uses autoconfiguration for the Twig interfaces and attributes, and `twig.safe_class` uses the resource tags of the container.
- [AssetMapper](../packages/asset-mapper.md): If `symfony/asset-mapper` is installed and enabled, TwigBundle registers the `importmap()` function.
- [UX Twig Component](../packages/ux-twig-component.md): UX Twig Component needs TwigBundle; for a reusable fragment with its own data, use a component, not `include()` or `render(controller())`.
- [Asset](../packages/asset.md): TwigBundle registers the `asset()` and `asset_version()` functions only if the `assets.packages` service exists.
- [Emoji](../packages/emoji.md): TwigBundle registers the `emojify` filter only when `symfony/emoji` and the `intl` extension are available.
- [HtmlSanitizer](../packages/html-sanitizer.md): TwigBundle registers the `sanitize_html` filter only when the `html_sanitizer` service exists.
- [Symfony Language Tools](../packages/language-tools.md): `lint:twig` checks the Twig syntax, and `symfony-lsp check` reports `template.not_found` for an unknown template name.
- [Stopwatch](../packages/stopwatch.md): the `{% stopwatch %}` tag needs Stopwatch, and TwigBundle enables it only in debug mode.
- [WebLink](../packages/web-link.md): TwigBundle enables `link()`, `preload()` and the other WebLink functions only when FrameworkBundle registers `AddLinkHeaderListener`.
- [Workflow](../packages/workflow.md): TwigBundle registers the `workflow_*()` functions only when the workflow registry exists.
- [Yaml](../packages/yaml.md): the `yaml_encode` and `yaml_dump` filters need the Yaml component; without it, TwigBundle removes their extension.

## Changed in 8.0/8.1

- 8.1: The `twig.safe_class` resource tag marks a trusted value object class once, instead of `|raw` in each template. It needs Twig 3.25 or later.
- 8.1: The Twig Bridge adds the `daisyui_5_layout.html.twig` form theme for `twig.form_themes`.
- 8.0: The `twig.base_template_class` option is removed. Delete it, because the configuration rejects unknown options.
- 8.0: The configuration rejects the `twig.exception_controller` option, also with the value `null` (deprecated in 7.4). Delete the line. For a custom error controller, use `framework.error_controller`.
- 8.0: `debug:twig --format=text` is removed. Use `--format=txt`.
- 8.0: `TemplateCacheWarmer` is `final`. Do not extend it.

## Docs

- https://symfony.com/doc/current/templates.html
- https://symfony.com/doc/current/reference/configuration/twig.html
- https://symfony.com/doc/current/controller/error_pages.html
- https://symfony.com/doc/current/bundles/override.html
- https://symfony.com/doc/current/form/form_themes.html
- https://symfony.com/doc/current/reference/dic_tags.html
- https://symfony.com/doc/current/reference/attributes.html
- https://symfony.com/doc/current/service_container/tags.html
- https://symfony.com/doc/current/mailer.html
- https://symfony.com/doc/current/reference/twig_reference.html
- https://symfony.com/doc/current/reference/constraints/Twig.html
- https://symfony.com/doc/current/configuration/override_dir_structure.html
- https://twig.symfony.com/doc/3.x/advanced.html
