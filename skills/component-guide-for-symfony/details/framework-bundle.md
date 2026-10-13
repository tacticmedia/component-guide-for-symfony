# FrameworkBundle (`symfony/framework-bundle`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Required bundles:** `FrameworkBundle` declares `#[RequiredBundle(ServicesBundle::class)]` and `#[RequiredBundle(ConsoleBundle::class, ignoreOnInvalid: true)]`. The kernel registers `ServicesBundle` automatically. It registers `ConsoleBundle` only when `symfony/console` is installed, because FrameworkBundle does not require `symfony/console`. Entry point: `Symfony\Component\DependencyInjection\Kernel\RequiredBundle`.
- **Core services:** The bundle registers the services that handle a request: `http_kernel`, `request_stack`, `controller_resolver` and `error_controller`. It also registers `url_helper`, `uri_signer`, `slugger`, `cache_warmer` and `cache_clearer`. Of these services, only `http_kernel`, `request_stack`, `url_helper`, `uri_signer` and `slugger` have an autowiring alias (see "Types to autowire" below). Entry point: `Symfony\Component\HttpFoundation\UrlHelper`.
- **The `framework.*` configuration tree:** Each top-level key configures one feature or one component. If the component package is installed, its key is on by default, for example `form`, `validation`, `serializer`, `mailer`, `messenger` and `http_client`. The keys `router`, `session`, `http_cache`, `esi`, `ssi`, `fragments`, `profiler` and `workflows` stay off until you configure them. `MicroKernelTrait` configures `router` for you, and the Flex recipe sets `session: true` in `config/packages/framework.yaml`. If a key is on but its package is missing, the bundle throws a `LogicException` that shows the `composer require` command. Entry point: `php bin/console config:dump-reference framework`.
- **Config reference file:** In debug mode, the bundle writes `config/reference.php`. This file contains the array shapes of the configuration of each bundle in `config/bundles.php`. IDEs and static analysis tools use it to check the keys in `App::config([...])` and `Routes::config([...])`. Entry point: `config/reference.php`.
- **MicroKernelTrait:** `src/Kernel.php` extends `Symfony\Component\HttpKernel\Kernel` and uses this trait. The trait registers the bundles from `config/bundles.php`, or only `FrameworkBundle` when that file does not exist. It imports `config/packages/*`, `config/packages/<env>/*`, `config/services.yaml` and `config/services_<env>.yaml` (or the `.php` files). It imports the route files in `config/routes/<env>/`, `config/routes/` and `config/routes.yaml` (or `routes.php`), and the `#[Route]` attributes of the kernel class. Entry point: `Symfony\Bundle\FrameworkBundle\Kernel\MicroKernelTrait`.
- **Allowed environments (8.1):** Define a private `getAllowedEnvs()` method in the kernel that returns the valid `APP_ENV` values. The default method returns an empty list, which allows all environment names. If the list is not empty and the current environment is not in it, the kernel throws an `InvalidArgumentException` at boot time. In the `src/Kernel.php` file of the 8.1 Flex recipe, the method returns `['prod', 'dev', 'test']`. If you add an environment, for example `staging`, also add it to this list. Entry point: `MicroKernelTrait::getAllowedEnvs()`.
- **Kernel directories:** `kernel.cache_dir` is `var/cache/<env>` and `kernel.logs_dir` is `var/log` by default. `kernel.build_dir` and `kernel.share_dir` use the cache directory by default. Set the `APP_CACHE_DIR`, `APP_BUILD_DIR`, `APP_SHARE_DIR` or `APP_LOG_DIR` env var to move one directory. For `APP_CACHE_DIR`, `APP_BUILD_DIR` and `APP_SHARE_DIR`, the kernel adds `/<env>` to the path. The Flex recipe sets `APP_SHARE_DIR` to `var/share`, so `kernel.share_dir` is `var/share/<env>`. Entry point: `%kernel.share_dir%`.
- **Secrets vault:** `secrets:set NAME` encrypts a value with the public key in `config/secrets/<env>/`. The `APP_RUNTIME_ENV` env var selects `<env>`, and its default is the `APP_ENV` value. To write to the `prod` vault, run `APP_RUNTIME_ENV=prod php bin/console secrets:set NAME`. The application reads the value as an env var, for example `%env(NAME)%`. The private key comes from `config/secrets/<env>/<env>.decrypt.private.php` or from the base64-encoded `SYMFONY_DECRYPTION_SECRET` env var. Do not commit the `prod` private key. To override a vault secret only on your computer, use the `--local` option, which writes the value to `.env.<APP_ENV>.local`. A non-empty env var takes precedence over a vault secret with the same name. Entry point: `framework.secrets`.
- **Derived kernel secret:** If `APP_SECRET` is empty or not defined and the `SYMFONY_DECRYPTION_SECRET` env var contains the decryption key, the vault derives `kernel.secret` from that key. Then you do not need a separate `APP_SECRET` value. Entry point: `framework.secret`.
- **Controller helpers:** A controller that extends `AbstractController` gets protected helper methods. The Twig helpers are `render()`, `renderView()`, `renderBlock()`, `renderBlockView()` and `stream()`. The response helpers are `json()`, `file()`, `redirect()`, `redirectToRoute()` and `forward()`. The security helpers are `isGranted()`, `denyAccessUnlessGranted()`, `getAccessDecision()`, `getUser()` and `isCsrfTokenValid()`. The form helpers are `createForm()`, `createFormBuilder()` and `createFormFlowBuilder()`. The other helpers are `generateUrl()`, `addFlash()`, `getParameter()`, `createNotFoundException()`, `createAccessDeniedException()`, `addLink()` and `sendEarlyHints()`. All Twig helpers except `stream()` call `createView()` on each form parameter. `render()` and `renderBlock()` return status 422 when a submitted form in the parameters is not valid. `json()` uses the `serializer` service when it exists. Entry point: `Symfony\Bundle\FrameworkBundle\Controller\AbstractController`.
- **ControllerHelper:** The `controller.helper` service has the same helpers as public methods. If a controller must not extend `AbstractController`, inject only the helpers that it needs with `#[AutowireMethodOf(ControllerHelper::class)]`. Entry point: `Symfony\Bundle\FrameworkBundle\Controller\ControllerHelper`.
- **Controllers in route configuration:** `RedirectController` redirects to a route (`route` default) or to a path or URL (`path` default). It sends 302 or 301 (`permanent: true`), or 307 or 308 with `keepRequestMethod: true`. `TemplateController` renders a Twig template and can set the `maxAge`, `sharedAge` and `private` cache options. Entry point: `Symfony\Bundle\FrameworkBundle\Controller\RedirectController`.
- **Route condition services:** `#[AsRoutingConditionService('alias')]` makes a service available in a route condition as `service('alias')`. The `env()` function reads an env var in a route condition. Entry point: `Symfony\Bundle\FrameworkBundle\Routing\Attribute\AsRoutingConditionService`.
- **PHP reverse proxy:** `framework.http_cache: true` makes the `http_cache` service public. The kernel then sends each main request through `HttpCache`, which stores responses in `%kernel.share_dir%/http_cache` and supports ESI. To add cache invalidation, extend `HttpCache`. Then use your class to decorate the `http_cache` service. Entry point: `Symfony\Bundle\FrameworkBundle\HttpCache\HttpCache`.
- **Console application and commands:** `bin/console` runs the FrameworkBundle `Application`, which adds the `--env` (`-e`), `--no-debug` and `--profile` options. The bundle also adds its own commands, for example `cache:clear`, `debug:container`, `debug:router`, `secrets:set` and `assets:install`. Entry point: `Symfony\Bundle\FrameworkBundle\Console\Application`.

## Entry points

- Bundle class: `Symfony\Bundle\FrameworkBundle\FrameworkBundle` (in `config/bundles.php`).
- Kernel: `Symfony\Component\HttpKernel\Kernel` with `Symfony\Bundle\FrameworkBundle\Kernel\MicroKernelTrait`.
- Controllers: `Symfony\Bundle\FrameworkBundle\Controller\AbstractController`, `Symfony\Bundle\FrameworkBundle\Controller\ControllerHelper` (with `Symfony\Component\DependencyInjection\Attribute\AutowireMethodOf`), `Symfony\Bundle\FrameworkBundle\Controller\RedirectController`, `Symfony\Bundle\FrameworkBundle\Controller\TemplateController`.
- Attribute: `Symfony\Bundle\FrameworkBundle\Routing\Attribute\AsRoutingConditionService`.
- Other classes: `Symfony\Bundle\FrameworkBundle\HttpCache\HttpCache`, `Symfony\Bundle\FrameworkBundle\Console\Application`, `Symfony\Bundle\FrameworkBundle\DataCollector\AbstractDataCollector` (base class for a custom profiler data collector), `Symfony\Bundle\FrameworkBundle\Secrets\SodiumVault` (service `secrets.vault`), `Symfony\Bundle\FrameworkBundle\Secrets\DotenvVault` (service `secrets.local_vault`).
- Types to autowire (services that this bundle registers): `Symfony\Component\HttpKernel\KernelInterface`, `Symfony\Component\HttpKernel\HttpKernelInterface`, `Symfony\Component\HttpFoundation\RequestStack`, `Symfony\Component\HttpFoundation\UrlHelper`, `Symfony\Component\HttpFoundation\UriSigner`, `Symfony\Component\String\Slugger\SluggerInterface` (needs `symfony/string` and `symfony/translation-contracts`), `Symfony\Component\HttpKernel\HttpCache\StoreInterface`.
- Config keys, kernel and request: `framework.secret`, `framework.secrets`, `framework.http_method_override`, `framework.allowed_http_method_override`, `framework.trusted_proxies`, `framework.trusted_headers`, `framework.trusted_hosts`, `framework.trust_x_sendfile_type_header`, `framework.default_locale`, `framework.enabled_locales`, `framework.set_locale_from_accept_language`, `framework.set_content_language_from_locale`, `framework.error_controller`, `framework.handle_all_throwables`, `framework.ide`, `framework.test`, `framework.php_errors`, `framework.exceptions`, `framework.disallow_search_engine_index`, `framework.cache`.
- Config keys that stay off until you configure them: `framework.router`, `framework.session`, `framework.request`, `framework.http_cache`, `framework.esi`, `framework.ssi`, `framework.fragments`, `framework.profiler`, `framework.workflows`.
- Config keys that are on when their package is installed: `framework.form` (`symfony/form`), `framework.csrf_protection` (`symfony/security-csrf`, plus a session or `stateless_token_ids`), `framework.assets` (`symfony/asset`), `framework.asset_mapper` (`symfony/asset-mapper`), `framework.translator` (`symfony/translation`), `framework.validation` (`symfony/validator`), `framework.serializer` (`symfony/serializer`), `framework.property_access` (`symfony/property-access`), `framework.property_info` (`symfony/property-info`), `framework.type_info` (`symfony/type-info`), `framework.lock` (`symfony/lock`), `framework.semaphore` (`symfony/semaphore`), `framework.web_link` (`symfony/web-link`), `framework.messenger` (`symfony/messenger`), `framework.scheduler` (`symfony/scheduler`), `framework.http_client` (`symfony/http-client`), `framework.mailer` (`symfony/mailer`), `framework.notifier` (`symfony/notifier`), `framework.webhook` (`symfony/webhook`), `framework.remote_event` (`symfony/remote-event`), `framework.rate_limiter` (`symfony/rate-limiter`), `framework.uid` (`symfony/uid`), `framework.html_sanitizer` (`symfony/html-sanitizer`), `framework.json_streamer` (`symfony/json-streamer`).
- Kernel parameters: `kernel.secret`, `kernel.project_dir`, `kernel.environment`, `kernel.runtime_environment`, `kernel.debug`, `kernel.cache_dir`, `kernel.build_dir`, `kernel.share_dir`, `kernel.logs_dir`, `kernel.default_locale`, `kernel.enabled_locales`, `kernel.trusted_hosts`.
- Env vars: `APP_RUNTIME_ENV`, `APP_CACHE_DIR`, `APP_BUILD_DIR`, `APP_SHARE_DIR`, `APP_LOG_DIR`, `SYMFONY_DECRYPTION_SECRET`, `SYMFONY_TRUSTED_PROXIES`, `SYMFONY_TRUSTED_HEADERS`, `SYMFONY_TRUSTED_HOSTS`, `SYMFONY_IDE`, `SYMFONY_TRUST_X_SENDFILE_TYPE_HEADER`.
- Console commands: `about`, `assets:install`, `cache:clear`, `cache:warmup`, `cache:pool:clear`, `cache:pool:delete`, `cache:pool:invalidate-tags`, `cache:pool:list`, `cache:pool:prune`, `config:dump-reference`, `debug:config`, `debug:container`, `debug:autowiring`, `debug:event-dispatcher`, `debug:router`, `router:match`, `lint:container`, `lint:yaml`, `lint:xliff`, `debug:translation`, `translation:extract`, `secrets:set`, `secrets:list`, `secrets:reveal`, `secrets:remove`, `secrets:generate-keys`, `secrets:decrypt-to-local`, `secrets:encrypt-from-local`, `error:dump`.
- Route condition functions: `env()`, `service()`.
- Routes to preview error pages: import `@FrameworkBundle/Resources/config/routing/errors.php` with the prefix `/_error` in the `dev` environment.
- Test helpers: see [FrameworkBundle test tools](../packages/framework-bundle-testing.md) (`KernelTestCase`, `WebTestCase`).

## Symbiotic packages

- [FrameworkBundle test tools](../packages/framework-bundle-testing.md): The same Composer package contains `KernelTestCase`, `WebTestCase` and the test assertions; use that file to test the application.
- [HttpKernel](../packages/http-kernel.md): HttpKernel supplies the `Kernel` base class, the kernel events and the controller argument resolvers, such as `#[MapRequestPayload]`, that FrameworkBundle registers.
- [DependencyInjection](../packages/dependency-injection.md): It supplies the container, `ServicesBundle` and `KernelTrait`; for a console tool without HTTP, use its `AbstractKernel` without FrameworkBundle.
- [Console](../packages/console.md): Its `ConsoleBundle` registers `#[AsCommand]` commands, and FrameworkBundle adds the `bin/console` options and its own commands when `symfony/console` is installed.
- [Config](../packages/config.md): The Config component defines and validates the `framework.*` tree, and `debug:config` and `config:dump-reference` show it.
- [Routing](../packages/routing.md): `framework.router` configures the router, and `debug:router`, `router:match` and `RedirectController` work with its routes.
- [HttpFoundation](../packages/http-foundation.md): The controller helpers return its `Response` classes, and `framework.session` and `framework.trusted_proxies` configure its session and its `Request` object.
- [Dotenv](../packages/dotenv.md): Dotenv loads `.env` files into env vars for plain settings; a non-empty env var takes precedence over a vault secret with the same name.
- [Runtime](../packages/runtime.md): `public/index.php` requires `vendor/autoload_runtime.php` and returns a closure that creates the kernel, and Runtime then runs the kernel.
- [Cache](../packages/cache.md): `framework.cache` creates the cache pools that the `cache:pool:*` commands manage; `framework.http_cache` is a different feature, an HTTP reverse proxy.
- [TwigBundle](../packages/twig-bundle.md): `render()`, `renderView()`, `stream()` and `TemplateController` need TwigBundle; without it, they throw a `LogicException`.
- [Security](../packages/security-bundle.md): `isGranted()`, `denyAccessUnlessGranted()` and `getUser()` need SecurityBundle; without it, they throw a `LogicException`.
- [Form](../packages/form.md): `createForm()`, `createFormBuilder()` and `createFormFlowBuilder()` create forms, and `render()` returns status 422 for a submitted form that is not valid.
- [Serializer](../packages/serializer.md): `json()` encodes the data with the `serializer` service when it exists.
- [WebProfilerBundle](../packages/web-profiler-bundle.md): It shows the data that `framework.profiler` collects; extend `AbstractDataCollector` to add a custom panel.
- [ErrorHandler](../packages/error-handler.md): FrameworkBundle registers its error renderers and its `error:dump` command, which writes the error pages as static HTML files.
- [Translation](../packages/translation.md): `framework.translator` configures the translator, and FrameworkBundle registers the `translation:extract`, `debug:translation` and `lint:xliff` commands.
- [MakerBundle](../packages/maker-bundle.md): `make:controller` generates a controller class, and a template when TwigBundle is installed; if MakerBundle is missing, a `make:*` command suggests `composer require symfony/maker-bundle --dev`.
- [Symfony Flex](../packages/flex.md): The 8.1 Flex recipe of `symfony/framework-bundle` creates `src/Kernel.php`, `config/preload.php`, the error preview routes, and `AGENTS.md` and `CLAUDE.md` files with instructions for AI agents.
- [RateLimiter](../packages/rate-limiter.md): `framework.rate_limiter` defines the limiters, and FrameworkBundle registers the listener that applies the `#[RateLimit]` controller attribute (8.1).
- [AI Mate](../packages/ai-mate.md): for a coding agent, the Mate tools `symfony-services` and `symfony-service-detail` replace `debug:container`; they read the container XML that debug mode dumps.
- [Security CSRF](../packages/security-csrf.md): the `isCsrfTokenValid()` controller helper needs its token manager from `framework.csrf_protection`; without it, the helper throws a `LogicException`.
- [Stopwatch](../packages/stopwatch.md): the console option `--profile` needs Stopwatch, debug mode and `framework.profiler`; without them, the command runs with a warning and no profile.
- [WebLink](../packages/web-link.md): the `addLink()` and `sendEarlyHints()` controller helpers need WebLink; without it, they throw a `LogicException`.

## Changed in 8.0/8.1

- Fluent config builders (`return function (FrameworkConfig $framework) { $framework->secret('...'); };`) and XML config files -> `return App::config(['framework' => ['secret' => '...']]);` or YAML (removed in 8.0).
- An override of `Bundle::registerCommands()` -> the `#[AsCommand]` attribute or the `console.command` service tag (deprecated in 8.1).
- `$application->add($command)` on the FrameworkBundle `Application` -> `$application->addCommand($command)` (removed in 8.0).
- `TranslationUpdateCommand` -> `translation:extract` (`TranslationExtractCommand`) (removed in 8.0).
- `@FrameworkBundle/Resources/config/routing/errors.xml` -> `@FrameworkBundle/Resources/config/routing/errors.php` (removed in 8.0).
- The `router.request_context.scheme` and `router.request_context.host` parameters -> the `router.request_context.base_url` parameter or `framework.router.default_uri` (deprecated in 8.1).
- A manual check of `APP_ENV` -> `getAllowedEnvs()` in the kernel (new in 8.1).
- Hand-made multi-step forms in a controller -> `$this->createFormFlowBuilder()` in `AbstractController` and `ControllerHelper` (new in 8.1).

## Status

The package needs PHP 8.4.1 or higher and the `xml` PHP extension. The secrets vault needs the `sodium` PHP extension or the `paragonie/sodium_compat` package.

## Docs

- https://symfony.com/doc/current/reference/configuration/framework.html
- https://symfony.com/doc/current/configuration.html
- https://symfony.com/doc/current/configuration/secrets.html
- https://symfony.com/doc/current/configuration/micro_kernel_trait.html
- https://symfony.com/doc/current/configuration/front_controllers_and_kernel.html
- https://symfony.com/doc/current/reference/configuration/kernel.html
- https://symfony.com/doc/current/configuration/override_dir_structure.html
- https://symfony.com/doc/current/bundles.html
- https://symfony.com/doc/current/controller.html
- https://symfony.com/doc/current/controller/service.html
- https://symfony.com/doc/current/controller/error_pages.html
- https://symfony.com/doc/current/routing.html
- https://symfony.com/doc/current/templates.html
- https://symfony.com/doc/current/http_cache.html
- https://symfony.com/doc/current/http_cache/cache_invalidation.html
- https://symfony.com/doc/current/deployment/proxies.html
- https://symfony.com/doc/current/console.html
- https://symfony.com/doc/current/profiler.html
- https://symfony.com/doc/current/reference/dic_tags.html
- https://symfony.com/doc/current/reference/attributes.html
