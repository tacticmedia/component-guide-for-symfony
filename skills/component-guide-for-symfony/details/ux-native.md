# Symfony UX Native (`symfony/ux-native`): details

**Applies to:** Symfony UX 3.5

## Key features and concepts

- **Native request detection**: A `kernel.request` listener sets the request attribute `_ux_is_native` on each request. The value is `true` if the `User-Agent` header contains `Hotwire Native` (case-sensitive), else `false`. The Hotwire Native iOS and Android libraries put `Hotwire Native iOS` or `Hotwire Native Android` in the `User-Agent` header. The bundle adds no `Vary: User-Agent` header. If an HTTP cache stores a page that uses `ux_is_native()`, add this header to the response. Entry point: `Symfony\UX\Native\EventListener\NativeListener::NATIVE_ATTRIBUTE`.
- **Twig check**: The Twig function returns the value of the `_ux_is_native` request attribute. It returns `false` when there is no current request. Entry point: `ux_is_native()`.
- **Configuration objects**: A `Configuration` holds `settings` (an array) and `rules` (a list of `Rule` objects). A `Rule` holds `patterns` (regular expressions for URL paths) and `properties`, for example `'context' => 'modal'` or `'pull_to_refresh_enabled' => false`. A field that you do not set does not go into the JSON. The Hotwire Native docs say that a path configuration needs both `settings` and `rules`. The Hotwire Native iOS library also rejects the path configuration if a rule has no `patterns` or no `properties`. Set all four fields. The mobile client applies the rules in order, so a later matching rule overrides an earlier one. Entry points: `Symfony\UX\Native\Configuration\Configuration`, `Symfony\UX\Native\Configuration\Rule`.
- **Registration with attributes**: Put `#[AsNativeConfigurationProvider]` on a service class. Put `#[AsNativeConfiguration('/config/ios_v1.json')]` on each public, non-static method that returns `Configuration`. Autoconfiguration tags the class with `ux_native.configuration_provider`. If such a method is static or does not declare the return type `Configuration`, the container compilation fails with an `InvalidArgumentException`. The bundle ignores a non-public method without an error. Entry points: `Symfony\UX\Native\Attribute\AsNativeConfigurationProvider`, `Symfony\UX\Native\Attribute\AsNativeConfiguration`.
- **Registration with a service tag**: Tag a `Configuration` service with `ux_native.configuration` and a `path` attribute. A factory method can create this service. If the `path` attribute is missing, the container compilation fails. Entry point: the `ux_native.configuration` service tag.
- **One configuration for each platform and version**: Register each configuration at its own path, for example `/config/ios_v1.json` and `/config/android_v1.json`. If a new app version needs a breaking change, register a new path, for example `/config/ios_v2.json`. Keep the old configuration for older app versions. Entry point: the `path` of `#[AsNativeConfiguration]` or of the `ux_native.configuration` tag.
- **Live JSON response in debug mode**: If `kernel.debug` is `true`, a `kernel.request` listener with priority 33 runs before the router (priority 32). For a main request to a registered path, it returns a `JsonResponse` from the `Configuration`. You need no route and no dumped file. Entry point: the registered path, for example `GET /config/ios_v1.json`.
- **Build command for production**: The command writes each configuration as pretty-printed JSON to the output directory plus the registered path, for example `public/config/ios_v1.json`. It creates missing directories. If `kernel.debug` is `false`, the bundle does not serve the JSON. In this case, run the command during the deployment. Entry point: `php bin/console ux:native:build-configs`.
- **Output directory**: The `output_dir` option sets the target directory of the build command. If you do not set the option, the command uses `%kernel.project_dir%/public`. Entry point: `ux_native.output_dir` in `config/packages/ux_native.yaml`.
- **Bridge controller maker**: The command writes `assets/controllers/<name>_controller.js`, with the name in snake case. The class extends `BridgeComponent` from `@hotwired/hotwire-native-bridge` and sets `static component = "<name>"`. This name must match the name of the native component in the mobile app. The command asks before it overwrites a file. Attach the controller with `data-controller` and the name with dashes, for example `data-controller="contact-form"`. Entry point: `php bin/console make:native-bridge-controller ContactForm` (needs `symfony/maker-bundle`).
- **JavaScript dependencies**: The package declares `@hotwired/hotwire-native-bridge` (1.2.2) and `@hotwired/stimulus` (^3.0.0). Flex adds them to `importmap.php` (AssetMapper) or to `package.json` (Encore). Entry point: `composer require symfony/ux-native`.

## Entry points

- Bundle class: `Symfony\UX\Native\UXNativeBundle`. Flex registers it in `config/bundles.php`.
- Config key: `ux_native.output_dir` (the only option).
- Class attribute: `#[Symfony\UX\Native\Attribute\AsNativeConfigurationProvider]` (autoconfigured: it adds the `ux_native.configuration_provider` tag).
- Method attribute: `#[Symfony\UX\Native\Attribute\AsNativeConfiguration(path: '/config/ios_v1.json')]`.
- Value objects: `Symfony\UX\Native\Configuration\Configuration` (`settings`, `rules`) and `Symfony\UX\Native\Configuration\Rule` (`patterns`, `properties`).
- Service tag: `ux_native.configuration` with the `path` attribute.
- Request attribute: `Symfony\UX\Native\EventListener\NativeListener::NATIVE_ATTRIBUTE` (value `'_ux_is_native'`).
- Twig function: `ux_is_native()`.
- Console command: `ux:native:build-configs`.
- Maker command: `make:native-bridge-controller [name]` (needs `symfony/maker-bundle`).
- JavaScript base class: `BridgeComponent` from `@hotwired/hotwire-native-bridge`.
- The package has no public service to autowire and no test helpers.

## Symbiotic packages

- [Symfony UX Turbo](../packages/ux-turbo.md): UX Native requires UX Turbo, which adds Hotwire Turbo page navigation to the web app that the native shell shows.
- [StimulusBundle](../packages/stimulus-bundle.md): UX Native requires StimulusBundle, which loads the generated Bridge controllers from `assets/controllers/` and activates them with `data-controller` or the `stimulus_controller()` Twig function.
- [MakerBundle](../packages/maker-bundle.md): The `make:native-bridge-controller` command exists only when MakerBundle is installed.
- [AssetMapper](../packages/asset-mapper.md): With AssetMapper, Flex adds `@hotwired/hotwire-native-bridge` and `@hotwired/stimulus` to `importmap.php`, so you do not run `npm`.
- [WebpackEncoreBundle](../packages/webpack-encore-bundle.md): With Encore, Flex adds the two JavaScript packages to `package.json`, and you run `npm install --force` and restart Encore.
- [Symfony Flex](../packages/flex.md): Flex registers `UXNativeBundle` with an auto-generated recipe (no official recipe exists) and adds the JavaScript dependencies of the package.
- [TwigBundle](../packages/twig-bundle.md): TwigBundle adds the Twig extension of UX Native (tag `twig.extension`) to Twig, so `ux_is_native()` works in templates.
- [Symfony UX Notify](../packages/ux-notify.md): Do not confuse them: UX Notify sends browser notifications through Mercure, and UX Native has no notification feature.

## Changed in 2.35 to 3.5

- 3.2: `php bin/console ux-native:dump` -> `php bin/console ux:native:build-configs` (BC break). The old command name does not exist in 3.2 and later.
- 2.35: The package declares its JavaScript dependencies, so Flex adds `@hotwired/hotwire-native-bridge` and `@hotwired/stimulus`. You do not need to add these packages with `importmap:require` or `npm add`. With Encore, run `npm install --force` after the Composer install.

## Status

- Experimental. The README and the docs say that the package "is likely to change, or even change drastically". Release 3.2 renamed a command with a BC break. The CHANGELOG says: "This is a breaking change, but the UX Native component is still experimental."
- Version 3.x needs PHP 8.4 or later and the Symfony 7.4 or 8.x components.

## Docs

- https://symfony.com/bundles/ux-native/current/index.html
- https://ux.symfony.com/native
- https://native.hotwired.dev/
- https://native.hotwired.dev/overview/path-configuration
- https://native.hotwired.dev/reference/path-configuration
- https://native.hotwired.dev/reference/bridge-installation
- https://native.hotwired.dev/reference/bridge-components
