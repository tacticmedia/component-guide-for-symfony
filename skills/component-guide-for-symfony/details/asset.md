# Asset (`symfony/asset`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **`asset()` and the default package:** `asset('images/logo.png')` returns `/images/logo.png` for the file `public/images/logo.png`. If the application runs in the subdirectory `/my_app`, it returns `/my_app/images/logo.png`. The default package is a `PathPackage` with a `RequestStackContext`, which adds the base path of the main request. Do not start the path with `/`: `PathPackage` then returns the path without the base path and without the subdirectory. `getUrl()` returns a full URL (`https://…` or `//…`) unchanged. Entry point: `{{ asset('images/logo.png') }}`.
- **Static version:** `framework.assets.version: 'v2'` adds `?v2` to each asset URL, for example `/images/logo.png?v2`. `version_format` is a `sprintf()` pattern: argument 1 is the path and argument 2 is the version. The default pattern is `%%s?%%s`. Write each `%` two times in the configuration. For example, `version-%%2$s/%%1$s` with the version `5` gives `/version-5/images/logo.png`. Change the `version` value at each deployment, for example with a container parameter. Without `version`, `json_manifest_path` or `version_strategy`, `asset()` adds no version. You can set only one of these three keys in the same scope. Entry point: `framework.assets.version` and `framework.assets.version_format` (`StaticVersionStrategy`).
- **JSON manifest:** `framework.assets.json_manifest_path` points to a `manifest.json` file that maps each source path to its built file, for example `"build/app.js": "/build/app.123abc.js"`. `asset('build/app.js')` then returns `/build/app.123abc.js`. If the key or the manifest file is missing, `asset()` returns the path without a version, for example `/build/missing.js`. If a manifest value starts with `/`, `asset()` adds no base path and no subdirectory to it. `json_manifest_path` can also be a URL, for example `https://cdn.example.com/manifest.json`. Symfony then downloads the manifest with the `http_client` service at the first lookup and keeps it in memory. With PHP-FPM, Symfony downloads it again on each request. Install `symfony/http-client` for a remote manifest. `RemoteJsonManifestVersionStrategy` does not exist. Use a URL in `framework.assets.json_manifest_path`. Entry point: `framework.assets.json_manifest_path` (`JsonManifestVersionStrategy`).
- **Strict mode:** If `strict_mode` is true, `asset()` throws `AssetNotFoundException` for each path that is not in the manifest, also for uploaded files. If similar keys exist, the message lists them. A missing manifest file throws `RuntimeException`. The docs recommend `strict_mode: '%kernel.debug%'`. Quote this value in YAML, because a plain YAML value cannot start with `%`. The Encore and Reprise tags also fail in strict mode. Their `entrypoints.json` files contain built paths (for example `/build/app.123abc.js` or `build/app-a1b2.js`), not manifest keys. Link the uploaded files and these tags through a named package with `version: ~`. Entry point: `framework.assets.strict_mode`.
- **Base URLs and CDNs:** `base_urls` makes the package a `UrlPackage`, so `asset()` returns full URLs, also for paths that start with `/`. If you give several base URLs, the choice depends only on the path, so each file always uses the same host. If the request uses HTTPS and some base URLs start with `https://` or `//`, the package uses only these URLs. A base URL without a scheme, for example `cdn.example.com`, throws `InvalidArgumentException`. An empty base URL, for example an empty environment variable, makes `asset()` return paths without a host, such as `/images/logo.png`. Entry point: `framework.assets.base_urls`.
- **Base path:** `base_path: '/images'` makes `asset('logo.png')` return `/images/logo.png`. A package cannot have `base_path` and `base_urls` together: the container build then throws a `LogicException`. Entry point: `framework.assets.base_path`.
- **Named packages:** `framework.assets.packages.<name>` creates a package with its own `base_path`, `base_urls`, `version`, `version_format`, `version_strategy`, `json_manifest_path` and `strict_mode`. Use it in Twig with `asset('avatar.png', 'avatars')`. If a named package sets none of `version`, `version_strategy` and `json_manifest_path`, it uses the version strategy of the default package. Set `version: ~` to remove the version from one package, also when a global manifest exists. Do not set `version: false`: Symfony then uses an empty version and adds `?` to each URL. An unknown package name throws `InvalidArgumentException`. Entry point: `framework.assets.packages`.
- **Named packages in PHP:** FrameworkBundle registers each named package as the service `assets._package_<name>` with a named autowiring alias. Inject it with `#[Target('avatars')] PackageInterface $package`. No autowiring alias of `PackageInterface` exists for the default package. For the default package, autowire `Packages` and call `getUrl($path)`. Entry point: `Symfony\Component\DependencyInjection\Attribute\Target`.
- **Custom version strategy:** Implement `getVersion(string $path)` and `applyVersion(string $path)` of `VersionStrategyInterface`. Register the class as a service. Put its service ID in `framework.assets.version_strategy`, for all assets or for one named package. Entry point: `Symfony\Component\Asset\VersionStrategy\VersionStrategyInterface`.
- **Custom package:** Autoconfiguration adds the `assets.package` tag to each service that implements `PackageInterface`. The `package` attribute of the tag gives the package name. If the tag has no `package` attribute, `#[AsTaggedItem('avatars')]` on the autoconfigured class gives the name. Without both, the service ID is the name. Entry point: the `assets.package` service tag.
- **`asset_version()`:** `asset_version(path, packageName)` returns the version that the package adds to the path. With `version: 'v2'`, it returns `v2`. With a JSON manifest, it returns the mapped path, for example `/build/app.123abc.js`. With AssetMapper, it returns the version of the default package, not the content hash. Entry point: `{{ asset_version('images/logo.png') }}`.
- **Absolute URLs and console commands:** `absolute_url(asset('images/logo.png'))` adds the scheme and the host of the current request. A console command has no request. For console commands, set `framework.router.default_uri`. The asset packages then take the base path and the HTTPS state from this URI. `absolute_url()` takes the scheme and the host from it. To use other values for the assets, set the container parameters `asset.request_context.base_path` and `asset.request_context.secure`. Entry point: `{{ absolute_url(asset('images/logo.png')) }}`.
- **AssetMapper integration:** If AssetMapper is enabled, `MapperAwareAssetPackage` decorates the default package. `asset('images/duck.png')` then takes a logical path in `assets/` and returns the versioned URL, for example `/assets/images/duck-3c16d92.png`. Since 8.1.7, mapped files get no second version from `framework.assets.version`. The `base_path` or `base_urls` of the default package still apply. Named packages do not use AssetMapper. Entry point: `Symfony\Component\AssetMapper\MapperAwareAssetPackage`.
- **Webpack Encore integration:** The Encore recipe sets `framework.assets.json_manifest_path` to `public/build/manifest.json` in `config/packages/webpack_encore.yaml`. Link the copied images with `asset('build/images/logo.png')`. `encore_entry_script_tags()` and `encore_entry_link_tags()` read `entrypoints.json` and send each file through `Packages::getUrl()`. Their second argument is a package name. In strict mode, use this argument for a package with `version: ~`. `webpack_encore.strict_mode` controls errors for `entrypoints.json`, and `framework.assets.strict_mode` controls errors for `manifest.json`. Entry point: `{{ encore_entry_link_tags('app') }}`.
- **Bundle assets:** `assets:install` copies the `public/` or `Resources/public/` directory of each bundle to `public/bundles/<name>/`. The name is the bundle name in lowercase without the `bundle` suffix. The `--symlink` option makes symbolic links instead of copies. Link the files with `asset('bundles/acme/js/loader.js')`. Entry point: `php bin/console assets:install`.

## Entry points

- Twig functions: `asset(path, packageName = null)` and `asset_version(path, packageName = null)` from `Symfony\Bridge\Twig\Extension\AssetExtension`; `absolute_url(path)` from `Symfony\Bridge\Twig\Extension\HttpFoundationExtension`.
- Autowire `Symfony\Component\Asset\Packages` (service `assets.packages`): `getUrl(string $path, ?string $packageName = null)`, `getVersion(string $path, ?string $packageName = null)`, `getPackage(?string $name = null)`.
- Autowire a named package: `#[Symfony\Component\DependencyInjection\Attribute\Target('avatars')] Symfony\Component\Asset\PackageInterface $package`.
- Absolute URL in PHP: autowire `Symfony\Component\HttpFoundation\UrlHelper` and call `getAbsoluteUrl($packages->getUrl($path))`.
- Config: `framework.assets` with `enabled`, `base_path`, `base_urls` (singular form `base_url`), `version`, `version_format`, `version_strategy`, `json_manifest_path`, `strict_mode` and `packages`. Each `framework.assets.packages.<name>` takes the same keys, except `enabled` and `packages`.
- Container parameters: `asset.request_context.base_path` and `asset.request_context.secure`.
- Service tag: `assets.package` with the attribute `package`. Attribute: `Symfony\Component\DependencyInjection\Attribute\AsTaggedItem`.
- Interfaces to implement: `Symfony\Component\Asset\PackageInterface`, `Symfony\Component\Asset\VersionStrategy\VersionStrategyInterface`, `Symfony\Component\Asset\Context\ContextInterface`.
- Without FrameworkBundle: `Symfony\Component\Asset\Package`, `PathPackage`, `UrlPackage`, `Packages`, `VersionStrategy\EmptyVersionStrategy`, `VersionStrategy\StaticVersionStrategy`, `VersionStrategy\JsonManifestVersionStrategy`, `Context\RequestStackContext`, `Context\NullContext`.
- Exceptions: `Symfony\Component\Asset\Exception\AssetNotFoundException` (with `getAlternatives()`), `InvalidArgumentException`, `LogicException` and `RuntimeException`. All implement `Symfony\Component\Asset\Exception\ExceptionInterface`.
- Console command (FrameworkBundle): `assets:install [target] [--symlink] [--relative] [--no-cleanup]`.
- Install: `composer require symfony/asset`. Without the package, Twig reports `Did you forget to run "composer require symfony/asset"? Unknown function "asset".`
- Tests: the component has no test helpers. In a unit test, create `new Packages(new Package(new EmptyVersionStrategy()))`.

## Symbiotic packages

- [AssetMapper](../packages/asset-mapper.md): AssetMapper decorates the default package, so `asset()` returns versioned URLs for logical paths; use it for JavaScript and CSS without a build step.
- [WebpackEncoreBundle](../packages/webpack-encore-bundle.md): the Encore recipe sets `framework.assets.json_manifest_path`, and `encore_entry_script_tags()` and `encore_entry_link_tags()` use `Packages::getUrl()`; Encore is in low-maintenance mode.
- [Symfony Reprise](../packages/reprise.md): this Vite and Rsbuild integration renders its tags through `Packages`, uses `framework.assets.json_manifest_path` for `asset()` and selects a named package with `reprise.asset_package`. Define this package with `version: ~`, not with `version: false` as in the Reprise docs. Reprise 1.x is stable (1.0.0, 2026-08-26). The Symfony docs call it experimental.
- [Twig Bridge](../packages/twig-bridge.md): `AssetExtension` of the bridge defines `asset()` and `asset_version()`, and both functions call `Packages`.
- [TwigBundle](../packages/twig-bundle.md): TwigBundle registers `AssetExtension` only if the `assets.packages` service exists.
- [FrameworkBundle](../packages/framework-bundle.md): FrameworkBundle reads `framework.assets`, creates `assets.packages` and the named packages, and adds the `assets:install` command.
- [HttpFoundation](../packages/http-foundation.md): `RequestStackContext` reads the base path and the HTTPS state of the main request, and `UrlHelper` builds the URL of `absolute_url()`.
- [Routing](../packages/routing.md): outside a request, `framework.router.default_uri` gives the base path and the HTTPS state of the asset URLs, and the host for `absolute_url()`.
- [HttpClient](../packages/http-client.md): a remote `json_manifest_path` URL needs the `http_client` service.
- [WebLink](../packages/web-link.md): `preload(asset('build/app.css'), {as: 'style'})` adds a preload `Link` header with the versioned URL to the response.
- [DependencyInjection](../packages/dependency-injection.md): `#[Target]` selects a named package for injection, and `#[AsTaggedItem]` gives a name to a custom package.

## Changed in 8.0/8.1

- Deprecated in 8.1: injection of a named package by the argument name only, for example `PackageInterface $fooPackagePackage` -> `#[Target('foo_package')] PackageInterface $package`. The framework reference shows `PackageInterface $fooPackage`. That name matches no alias.
- Deprecated in 8.1: `public static function getDefaultPackageName()` on a custom package class -> `#[AsTaggedItem('avatars')]` on the class, or the `package` attribute of the `assets.package` tag.
- Deprecated in 8.1: the parameters `router.request_context.host` and `router.request_context.scheme` for URLs in console commands -> `framework.router.default_uri`.
- Removed in 8.0: XML configuration, for example `<framework:assets base-path="/images"/>` -> YAML, or a PHP file that returns `App::config([...])`.
- Removed in 8.0: the fluent PHP configuration, for example `$framework->assets()->package('avatars')->baseUrls([...])` -> `return App::config(['framework' => ['assets' => ['packages' => ['avatars' => ['base_urls' => ['https://cdn.example.com/avatars']]]]]]);` in the namespace `Symfony\Component\DependencyInjection\Loader\Configurator`.

## Docs

- https://symfony.com/doc/current/components/asset.html
- https://symfony.com/doc/current/templates.html
- https://symfony.com/doc/current/reference/configuration/framework.html
- https://symfony.com/doc/current/reference/twig_reference.html
- https://symfony.com/doc/current/frontend/custom_version_strategy.html
- https://symfony.com/doc/current/reference/dic_tags.html
- https://symfony.com/doc/current/service_container/autowiring.html
- https://symfony.com/doc/current/frontend/asset_mapper.html
- https://symfony.com/doc/current/frontend.html
- https://symfony.com/doc/current/frontend/encore/versioning.html
- https://symfony.com/doc/current/frontend/encore/copy-files.html
- https://symfony.com/doc/current/frontend/encore/advanced-config.html
- https://symfony.com/doc/current/frontend/encore/faq.html
- https://symfony.com/doc/current/routing.html
- https://symfony.com/doc/current/web_link.html
- https://symfony.com/doc/current/controller/upload_file.html
- https://symfony.com/bundles/WebpackEncoreBundle/current/index.html
- https://symfony.com/bundles/reprise/current/index.html
