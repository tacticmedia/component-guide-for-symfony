# Routing (`symfony/routing`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Route definitions:** `#[Route]` on a controller method connects a path and a route name to that method. `#[Route]` on the class adds a path prefix, a name prefix and shared options to each route of the class. The `routing.controllers` resource loads the routes of all autoconfigured services that use `#[Route]`. YAML files and PHP files that return `Routes::config([...])` are the other two formats. Entry point: `Symfony\Component\Routing\Attribute\Route`.
- **Placeholders and requirements:** `{slug}` captures a part of the path. The `requirements` option limits a placeholder to a regular expression. `Requirement` supplies patterns such as `DIGITS`, `POSITIVE_INT`, `ASCII_SLUG`, `UUID`, `ULID`, `DATE_YMD` and `CATCH_ALL`. A placeholder value cannot contain `/`, unless the requirement allows it, for example `Requirement::CATCH_ALL`. The inline form `{page<\d+>?1}` sets a requirement and a default value. A placeholder with a default value is optional if the path has only optional placeholders after it. `{!page}` keeps the default value in generated URLs, and a URL without a page value does not match the route. Entry point: `Symfony\Component\Routing\Requirement\Requirement`.
- **Backed enum parameters:** If a controller argument has a backed enum type, the argument receives the case that matches the placeholder value. An invalid value gives a 404 response. `EnumRequirement` limits the placeholder to all cases or to a list of cases. `generate()` and `path()` do not convert an enum case to a string. To generate a URL, give the `value` of the case, for example `['status' => $status->value]`. Entry point: `Symfony\Component\Routing\Requirement\EnumRequirement`.
- **Object parameters:** `{slug:post}` maps the `slug` placeholder to the `$post` argument. With DoctrineBridge, Symfony finds the entity by its `slug` property and gives a 404 response when no entity matches. If two entities use the same property name, write `{authorName:author.name}`. Entry point: `#[Route('/blog/{slug:post}')]`.
- **Match options:** The `methods`, `host` and `schemes` options limit the requests that a route matches. The `host` option accepts placeholders, for example `{subdomain}.example.com`. The `env` option loads a route only in the given environments. In `#[Route]`, a higher `priority` value makes Symfony check the route before routes with a lower value (default `0`). The `condition` option is an ExpressionLanguage expression with the `context`, `request` and `params` variables and the `env()` and `service()` functions. If no route matches, Symfony sends a 404 response. If only the HTTP method is wrong, Symfony sends a 405 response. Entry point: `#[Route(methods: ['POST'], condition: '...')]`.
- **Special parameters:** `_format` sets the request format, and `_locale` sets the request locale. `_fragment` adds a `#fragment` to a generated URL. `_query` adds an array of query parameters that never fill a placeholder. Entry point: `#[Route(format: 'json', locale: 'en')]`.
- **Localized routes:** A `path` array with locale keys creates one route for each locale. The URL generator selects the route for the current `_locale` and falls back from `fr_BE` to `fr`. In `#[Route]`, an array entry without a locale key is the fallback path for all other locales. In YAML and PHP route files, this entry creates a route named `<name>.0`, and `generate()` throws `RouteNotFoundException` for other locales. A route import accepts one `prefix` or one `host` for each locale. Do not combine a fallback path with a path prefix or a host for each locale. The route loader then uses the fallback path for each locale, ignores the fallback path or throws a `LogicException`. The locales in `framework.enabled_locales` become the requirement of the `_locale` placeholder. Entry point: `#[Route(path: ['en' => '/about-us', 'nl' => '/over-ons'], name: 'about_us')]`.
- **Route groups:** A route import sets a common `prefix`, `name_prefix`, `host`, `schemes`, `requirements` and `defaults` for many routes. A class-level `#[Route]` does the same with its `path`, `name` and other options. In a route import with the prefix `/blog`, `trailing_slash_on_root: false` gives a route with an empty path the URL `/blog` instead of `/blog/`. Entry point: `Symfony\Component\Routing\Loader\Configurator\RoutingConfigurator::import()`.
- **Route aliases:** The `alias` option of `#[Route]` gives one route more names. `DeprecatedAlias` keeps an old route name and triggers a deprecation when code generates a URL with it. Entry point: `Symfony\Component\Routing\Attribute\DeprecatedAlias`.
- **URL generation:** `generate()` returns an absolute path by default. `UrlGeneratorInterface::ABSOLUTE_URL` adds the scheme and the host. In a request, the host comes from the current request. To reject a forged `Host` header, configure `framework.trusted_hosts`. Parameters that are not placeholders go into the query string. An unknown route name throws `RouteNotFoundException`, and a missing placeholder value throws `MissingMandatoryParametersException`. Entry point: `Symfony\Component\Routing\Generator\UrlGeneratorInterface`.
- **URLs outside a request:** A console command has no request, so absolute URLs use `http://localhost/` by default. `framework.router.default_uri` sets the scheme, the host and the base path for these URLs. Localized routes then use `framework.default_locale`, unless you give a `_locale` parameter. In a request, the values of the request replace the `default_uri` values. Entry point: `framework.router.default_uri`.
- **Routes without controller code:** `RedirectController` redirects to a route (`route` default) or to a URL (`path` default). The redirect is a 302 response, or a 301 response if `permanent` is `true`. `TemplateController` renders a Twig template (`template` default). For these two controllers, set `controller` to the class name, because both classes are invokable. For `GET` and `HEAD` requests, a URL that differs only by a trailing slash gets a 301 redirect. Entry point: `Symfony\Bundle\FrameworkBundle\Controller\RedirectController`.
- **Stateless routes:** `stateless: true` declares that the route does not use the session. If code uses the session, Symfony throws `UnexpectedSessionUsageException` in debug mode. Otherwise, it logs a warning. Entry point: `#[Route(stateless: true)]`.
- **Signed URIs:** `UriSigner::sign()` adds a `_hash` query parameter and an optional `_expiration` timestamp. `check()` and `checkRequest()` return a boolean. `verify()` throws `UnsignedUriException`, `UnverifiedSignedUriException` or `ExpiredSignedUriException`. `#[IsSignatureValid]` verifies the request before the controller runs. A missing or invalid signature then gives a 404 response, and an expired URI gives a 403 response. Entry point: `Symfony\Component\HttpFoundation\UriSigner`.
- **Custom route loaders:** To load routes from a service method, import `resource: 'service_id::method'` with `type: service`. The method must return a `RouteCollection`. The service needs the `routing.route_loader` tag. Autoconfiguration adds this tag if the service class implements `RouteLoaderInterface`. The router caches the loaded routes. If the source data changes, clear the cache. For a new resource type, extend `Symfony\Component\Config\Loader\Loader`. Tag this loader service `routing.loader`. Entry point: `Symfony\Bundle\FrameworkBundle\Routing\RouteLoaderInterface`.

## Entry points

- `Symfony\Component\Routing\Attribute\Route` (attribute on a controller class or method)
- `Symfony\Component\Routing\Attribute\DeprecatedAlias`
- `Symfony\Component\Routing\Generator\UrlGeneratorInterface` (autowire it to generate URLs in services and commands)
- `Symfony\Component\Routing\RouterInterface` (matcher and generator; do not call `getRouteCollection()` at runtime, because it is slow)
- `Symfony\Component\Routing\RequestContext` (autowire it to read or change the context for URL generation)
- `Symfony\Component\Routing\Requirement\Requirement` and `Symfony\Component\Routing\Requirement\EnumRequirement`
- `Symfony\Component\Routing\Exception\RouteNotFoundException` (catch it to test if a route exists)
- `Symfony\Bundle\FrameworkBundle\Controller\AbstractController::generateUrl()` and `::redirectToRoute()`
- `Symfony\Bundle\FrameworkBundle\Controller\ControllerHelper::generateUrl()` and `::redirectToRoute()` (for controllers that do not extend `AbstractController`)
- `Symfony\Bundle\FrameworkBundle\Controller\RedirectController` and `Symfony\Bundle\FrameworkBundle\Controller\TemplateController`
- `Symfony\Bundle\FrameworkBundle\Routing\Attribute\AsRoutingConditionService` (makes a service available to `service()` in conditions)
- `Symfony\Bundle\FrameworkBundle\Routing\RouteLoaderInterface`
- `Symfony\Component\HttpFoundation\UriSigner` (service `uri_signer`) and `Symfony\Component\HttpKernel\Attribute\IsSignatureValid`
- Route files: `config/routes.yaml` (or `config/routes.php` if `config/routes.yaml` does not exist), `config/routes/*.yaml` and `config/routes/*.php` (PHP files return `Routes::config([...])` in namespace `Symfony\Component\Routing\Loader\Configurator`)
- Route resource: `routing.controllers` (for example `controllers: { resource: routing.controllers }`)
- Config keys: `framework.router` (`resource`, `type`, `default_uri`, `http_port`, `https_port`, `strict_requirements`, `utf8`), `framework.default_locale`, `framework.enabled_locales`
- Service IDs: `router` (aliases `RouterInterface`, `UrlGeneratorInterface`, `UrlMatcherInterface`), `router.request_context`
- Service tags: `routing.loader`, `routing.route_loader`, `routing.condition_service`, `routing.expression_language_provider`, `routing.controller`
- Console commands: `debug:router` (options `--show-controllers`, `--show-aliases`, `--method`, `--sort`) and `router:match`
- Twig: `path()`, `url()`, `app.current_route`, `app.current_route_parameters`
- Request attributes: `_route`, `_route_params`
- Test assertion: `Symfony\Bundle\FrameworkBundle\Test\BrowserKitAssertionsTrait::assertRouteSame()` (available in `WebTestCase`)

## Symbiotic packages

- [FrameworkBundle](../packages/framework-bundle.md): FrameworkBundle registers the `router` service, the `framework.router` config, the `debug:router` and `router:match` commands, and the `generateUrl()` and `redirectToRoute()` helpers.
- [HttpKernel](../packages/http-kernel.md): `RouterListener` stores the matched route parameters as request attributes, and value resolvers convert them into typed controller arguments.
- [HttpFoundation](../packages/http-foundation.md): `UriSigner` signs and verifies URLs, and the `Request` object holds the route name and parameters in its attributes.
- [ExpressionLanguage](../packages/expression-language.md): ExpressionLanguage evaluates the `condition` option of a route, and a route condition throws a `LogicException` without this package.
- [Twig Bridge](../packages/twig-bridge.md): The Twig functions `path()` and `url()` generate URLs from route names in templates.
- [TwigBundle](../packages/twig-bundle.md): `TemplateController` renders a template from the route configuration, and it throws a `LogicException` when TwigBundle is not installed.
- [Doctrine Bridge](../packages/doctrine-bridge.md): `{slug:post}` and `#[MapEntity]` load an entity from a route placeholder and give a 404 response when no entity matches.
- [Translation](../packages/translation.md): The `_locale` parameter sets the request locale, and `LocaleSwitcher` changes the `_locale` that the URL generator uses.
- [Security](../packages/security-bundle.md): The login link `check_route` and logout `path` options accept route names, and `requires_channel` is an alternative to route `schemes`.
- [Messenger](../packages/messenger.md): The `router_context` middleware keeps the original host and scheme, so message handlers can generate absolute URLs.
- [Console](../packages/console.md): A command autowires `UrlGeneratorInterface` and needs `framework.router.default_uri` for absolute URLs.
- [Config](../packages/config.md): A custom route loader for a new resource type extends `Symfony\Component\Config\Loader\Loader`.
- [DependencyInjection](../packages/dependency-injection.md): Route paths, requirements, defaults, hosts and conditions accept `%parameter%` placeholders, but not `%env()%` placeholders.
- [Yaml](../packages/yaml.md): YAML route files need `symfony/yaml`, and `!php/const` uses `Requirement` constants in YAML.
- [Uid](../packages/uid.md): `Requirement::UUID` and `Requirement::ULID` match UID placeholders, and a controller argument with a UID type receives a UID object.
- [String](../packages/string.md): `Requirement::ASCII_SLUG` matches the default output of `AsciiSlugger`.
- [Asset](../packages/asset.md): Use `asset()` for links to images, CSS and JavaScript files. Use `path()` or `url()` for links to routes.
- [Clock](../packages/clock.md): If `symfony/clock` is installed, `UriSigner` uses it for the expiration, so tests can mock the time.
- [FrameworkBundle test tools](../packages/framework-bundle-testing.md): `assertRouteSame()` checks the route name and parameters of the last request.
- [WebProfilerBundle](../packages/web-profiler-bundle.md): The routing panel of the profiler shows the matched route and why each route before it in the match order did not match.

## Changed in 8.0/8.1

- `use Symfony\Component\Routing\Annotation\Route;` -> `use Symfony\Component\Routing\Attribute\Route;` (8.0 removed the `Annotation` aliases).
- XML route files (`routes.xml`, `errors.xml`, `wdt.xml`) -> attributes, YAML or PHP files such as `errors.php` (8.0 removed the XML format).
- Getter calls on route attributes, such as `$attribute->getPath()` -> public properties, such as `$attribute->path` (8.0).
- `#[Route('/blog/{slug}')]` with a `BlogPost $post` argument (Doctrine auto-mapping) -> `{slug:post}` or `#[MapEntity(mapping: ['slug' => 'slug'])]` (8.0 removed auto-mapping; `{id}` still finds the entity by its primary key).
- `class AppRouter extends Router` (FrameworkBundle) -> do not extend this class, because it is `final` since 8.0.
- Container parameters `router.request_context.host` and `router.request_context.scheme` -> `framework.router.default_uri` (deprecated in 8.1).
- A manual check of `int`, `float`, `bool` or `string` route values -> a typed controller argument (8.1 sends a 404 response for an invalid value).
- A separate route for the root path of a prefixed PHP route collection -> `->prefix('/blog', trailingSlashOnRoot: false)` (8.1).

## Docs

- https://symfony.com/doc/current/routing.html
- https://symfony.com/doc/current/routing/custom_route_loader.html
- https://symfony.com/doc/current/routing/routing_from_database.html
- https://symfony.com/doc/current/reference/configuration/framework.html
- https://symfony.com/doc/current/controller.html
- https://symfony.com/doc/current/controller/value_resolver.html
- https://symfony.com/doc/current/templates.html
- https://symfony.com/doc/current/reference/twig_reference.html
- https://symfony.com/doc/current/reference/dic_tags.html
