# Abandoned Symfony UX packages (`symfony/ux-svelte`, `symfony/ux-swup`, `symfony/ux-typed`, `symfony/ux-lazy-image`, `symfony/ux-toggle-password`, `symfony/ux-turbo-mercure`): details

**Applies to:** Symfony UX 3.5

## Key features and concepts

- **UX Svelte (`symfony/ux-svelte`)**: renders Svelte 3 or 4 components from Twig with `svelte_component()`. Last version: v2.36.0 (2026-05-06). Symfony UX deprecated it in 2.35, and Symfony UX 3.0 does not include it. No verified source names a replacement. The README gives two reasons. First, Symfony UX could not add Svelte 5 support for AssetMapper or Webpack Encore. Second, the package is less popular than UX React and UX Vue. For a front-end framework such as Svelte, the Symfony docs recommend the native tools of the framework and Symfony as a pure API. This is general advice, not a named replacement.
- **UX Swup (`symfony/ux-swup`)**: page transitions with the Swup library, through `stimulus_controller('symfony/ux-swup/swup')`. Last version: v2.36.0 (2026-05-06). Symfony UX deprecated it in 2.26.0 and removed it in 3.0. Replacement (README migration steps): Install `swup` and its plugins. Add the controller code from the README as `assets/controllers/swup_controller.js`. Change `stimulus_controller('symfony/ux-swup/swup')` to `stimulus_controller('swup')`. The old bundle used `swup` `^3.0`.
- **UX Typed (`symfony/ux-typed`)**: animated typed text with Typed.js, through the `symfony/ux-typed` controller (`data-controller="symfony--ux-typed"`). Last version: v2.36.0 (2026-05-06). Symfony UX deprecated it in 2.26.0 and removed it in 3.0. Replacement (README migration steps): Install `typed.js`. Add the controller code from the README as `assets/controllers/typed_controller.js`. Change `symfony--ux-typed` to `typed` in the `data-controller` and `data-*-value` attributes.
- **UX LazyImage (`symfony/ux-lazy-image`)**: the `symfony/ux-lazy-image/lazy-image` controller shows a small placeholder and then loads the large image. The Twig function `data_uri_thumbnail()` returns a BlurHash thumbnail as a data URI, and `blur_hash()` returns the BlurHash string. Last version: v2.36.0 (2026-05-06). Symfony UX deprecated it in 2.26.0 and removed it in 3.0. Replacement (README): the native `<img loading="lazy">` attribute. For BlurHash, the README names `kornrunner/php-blurhash` (Composer name `kornrunner/blurhash`, class `kornrunner\Blurhash\Blurhash`).
- **UX TogglePassword (`symfony/ux-toggle-password`)**: the `toggle` option adds a show/hide button to `PasswordType` fields. Last version: v2.36.0 (2026-05-06). Symfony UX deprecated it in 2.29.0 and removed it in 3.0. Replacement (README migration steps): Remove the package. Add four files from the README: `src/Form/Extension/TogglePasswordTypeExtension.php`, a form theme, `assets/controllers/toggle_password_controller.js` and `assets/styles/toggle_password.css`. The README type extension keeps the nine options of the bundle with the same defaults. Put the form theme in `templates/`. Add it to `twig.form_themes`, because the old bundle registered its own theme automatically. The README writes `template/form_theme.html.twig`. The names change: the block `ux_toggle_password_widget` becomes `toggle_password_widget`, and the controller `symfony--ux-toggle-password--toggle-password` becomes `toggle-password`.
- **UX Turbo-Mercure (`symfony/ux-turbo-mercure`)**: the Mercure bridge for UX Turbo 1.x and 2.x: a broadcaster, a renderer for `turbo_stream_listen()` and a `turbo-stream` Stimulus controller. Last version: v2.6.0 (2022-11-22). UX Turbo 2.6.1 (2022-12-02) moved the bridge into `symfony/ux-turbo`. Replacement (UX Turbo CHANGELOG and the `2.x` README): `symfony/ux-turbo` with `symfony/mercure-bundle`.
- **Abandoned flag**: all six packages have `"abandoned": true` on Packagist, without a replacement package. Read the flag in `https://repo.packagist.org/p2/symfony/<name>.json`.
- **Deprecation notice**: the bundle class file of each of the five 2.x bundles calls `trigger_deprecation()` when PHP loads it, for example `Symfony\UX\Swup\SwupBundle`. The Swup, Typed and TogglePassword messages link to the migration steps. The LazyImage and Svelte messages have no link.
- **Migration guides**: the READMEs of the Swup, Typed and TogglePassword split repositories (default branch `2.x`) give migration steps. The LazyImage README names the replacements but gives no steps. The Svelte README has no migration steps. The UX website lists the five bundles (not `symfony/ux-turbo-mercure`) under "Deprecated and removed packages" and links each README.
- **Install constraints of the last versions**: the v2.36.0 releases require PHP 8.1 or later. When they require Symfony components, they accept `^5.4|^6.0|^7.0|^8.0`. UX Svelte v2.36.0 also accepts `symfony/stimulus-bundle` `^3.0`. `symfony/ux-turbo-mercure` v2.6.0 requires `symfony/mercure-bundle` `^0.3`, `symfony/twig-bundle` `^5.2|^6.0` and `symfony/ux-turbo` `^2.0`. Because of these constraints, Composer cannot install it with Symfony 7, Symfony 8, UX Turbo 3 or MercureBundle 0.4 and later.

## Entry points

- `php bin/console importmap:require` (`symfony/asset-mapper`): installs `swup`, its plugins or `typed.js`. With Webpack Encore, use `npm install`.
- `stimulus_controller()` Twig function (`symfony/stimulus-bundle`): attaches the app controllers `swup` and `typed`.
- `Symfony\Component\Form\AbstractTypeExtension` for `Symfony\Component\Form\Extension\Core\Type\PasswordType`: the base of the replacement for the `toggle` option.
- `twig.form_themes` (TwigBundle): registers the replacement form theme with the `toggle_password_widget` block.
- `turbo_stream_from()` Twig function (`symfony/ux-turbo` 3.1 and later): subscribes the page to Mercure topics, entity objects or entity class names.
- `<twig:Turbo:Stream:From>` Twig component (`symfony/ux-turbo` 3.1 and later): the component form of `turbo_stream_from()`.
- `Symfony\UX\Turbo\Attribute\Broadcast` (`#[Broadcast]`): broadcasts the changes of a Doctrine entity.
- `Symfony\Component\Mercure\HubInterface` and `Symfony\Component\Mercure\Update` (`symfony/mercure`, a dependency of `symfony/mercure-bundle`): publish an update to a hub.
- `composer remove symfony/ux-<name>`: removes an abandoned package after the migration.

## Symbiotic packages

- [Symfony UX Turbo](../packages/ux-turbo.md): It contains the Mercure bridge of `symfony/ux-turbo-mercure` since 2.6.1; since 3.1, subscribe with `turbo_stream_from()` or `<twig:Turbo:Stream:From>`.
- [Mercure](../packages/mercure.md): Install `symfony/mercure-bundle` in place of `symfony/ux-turbo-mercure`; it gives the hub configuration and `HubInterface` that UX Turbo broadcasts use.
- [StimulusBundle](../packages/stimulus-bundle.md): The Swup, Typed and TogglePassword migrations put your own controller in `assets/controllers/`; `stimulus_controller()` or a `data-controller` attribute attaches it.
- [AssetMapper](../packages/asset-mapper.md): Install `swup` or `typed.js` with `importmap:require`; the unreleased `2.x` branches of the five bundles conflict with `symfony/asset-mapper` 8.2 and later.
- [WebpackEncoreBundle](../packages/webpack-encore-bundle.md): With Webpack Encore, install `swup` or `typed.js` with `npm install` instead of `importmap:require`.
- [Form](../packages/form.md): A `PasswordType` type extension that extends `AbstractTypeExtension` replaces the `toggle` option of `symfony/ux-toggle-password`.
- [TwigBundle](../packages/twig-bundle.md): Add the replacement form theme to `twig.form_themes`; the old bundle added `@TogglePassword/form_theme.html.twig` there automatically.
- [WebLink](../packages/web-link.md): For the Largest Contentful Paint image, the LazyImage docs do not use the lazy-image controller; they use `preload()` with `fetchpriority: 'high'`.
- [UX Twig Component](../packages/ux-twig-component.md): `<twig:Turbo:Stream:From>` is a Twig component, so it needs this package; the `turbo_stream_from()` function does not.
- [Symfony UX React](../packages/ux-react.md): The UX Svelte README compares Svelte with UX React, but no source names UX React as a replacement for UX Svelte.
- [Symfony UX Vue.js](../packages/ux-vue.md): The UX Svelte README compares Svelte with UX Vue, but no source names UX Vue as a replacement for UX Svelte.

## Changed in 2.6.1 to 3.1

- UX Turbo 2.6.1: `symfony/ux-turbo-mercure` -> `symfony/ux-turbo` plus `symfony/mercure-bundle`. Then set `mercure-turbo-stream` to `"enabled": true` in `assets/controllers.json`. UX Turbo 3.1 deprecates this step.
- UX 2.26.0: deprecates Swup, Typed and LazyImage. Their `trigger_deprecation()` messages give the version 2.27.0.
- UX 2.29.0: deprecates TogglePassword. The `PasswordType` reference marks the `toggle` option as deprecated since 2.29.
- UX 2.35: deprecates Svelte.
- UX 3.0.0 (2026-04-09): removes LazyImage, Swup, TogglePassword and Typed (`UPGRADE-3.0.md`). Svelte is not in 3.0 either. UX 3.0 requires PHP 8.4.
- UX Turbo 3.1.0: `turbo_stream_listen()` -> `turbo_stream_from()` or `<twig:Turbo:Stream:From>`. The `mercure-turbo-stream` controller -> the `<turbo-mercure-stream-source>` element. The deprecation message announces the removal of `turbo_stream_listen()` in 4.0.

## Status

- **Abandoned**: all six packages. The split repositories keep `2.x` as the default branch. The last tags are v2.36.0 (five packages) and v2.6.0 (`symfony/ux-turbo-mercure`). Packagist also lists a `3.x-dev` branch for five packages. No 3.x tag exists, and the `splitsh.json` file of Symfony UX 3.x does not split them.
- **Unreleased change**: the `2.x` branches of the five bundles have `"conflict": {"symfony/asset-mapper": ">=8.2"}`. No tag contains this change.
- **Experimental and unreleased**: the four packages below have no stable version on Packagist. Each has only `3.x-dev`, no tag, an "EXPERIMENTAL" README notice and a CHANGELOG for 3.6.0. They require PHP 8.4 or later and Symfony 7.4 or 8.x.
  - `symfony/ux-image`: responsive images through URL-based image providers. Its docs show `<twig:ux:image>`, `ux_image()` and `ux_picture()`. Its images get `loading="lazy"` unless you set `priority`. No source names it as a replacement for `symfony/ux-lazy-image`.
  - `symfony/ux-cloudflare-image`: the Cloudflare provider bridge for `symfony/ux-image` (`UX_IMAGE_DSN=cloudflare://…`). It requires `symfony/ux-image` `^3.6`.
  - `symfony/ux-keycdn-image`: the KeyCDN provider bridge for `symfony/ux-image` (`UX_IMAGE_DSN=keycdn://…`). It requires `symfony/ux-image` `^3.6`.
  - `symfony/ux-inspector`: a browser panel that inspects Stimulus controllers, Live Components and Turbo elements. Use it only in `dev` (`composer require --dev symfony/ux-inspector:3.x-dev`). Without the `3.x-dev` constraint, Composer refuses the package under the default `stable` minimum stability. No Flex recipe exists, so register `Symfony\UX\Inspector\UXInspectorBundle` and its route manually.
  - symfony.com publishes the docs of `symfony/ux-image` and `symfony/ux-inspector`, and ux.symfony.com lists Inspector as a package.

## Docs

- https://ux.symfony.com/packages
- https://github.com/symfony/ux/blob/v3.5.1/UPGRADE-3.0.md
- https://github.com/symfony/ux-swup
- https://github.com/symfony/ux-typed
- https://github.com/symfony/ux-lazy-image
- https://github.com/symfony/ux-toggle-password
- https://github.com/symfony/ux-svelte
- https://github.com/symfony/ux-turbo-mercure
- https://github.com/symfony/ux/blob/v3.5.1/src/Turbo/CHANGELOG.md
- https://symfony.com/bundles/ux-turbo/current/index.html
- https://symfony.com/doc/current/mercure.html
- https://symfony.com/doc/current/reference/forms/types/password.html
- https://symfony.com/doc/current/form/form_themes.html
- https://symfony.com/doc/current/frontend.html
- https://web.dev/learn/images/performance-issues
- https://github.com/kornrunner/php-blurhash
- https://symfony.com/bundles/ux-svelte/current/index.html
- https://symfony.com/bundles/ux-swup/current/index.html
- https://symfony.com/bundles/ux-typed/current/index.html
- https://symfony.com/bundles/ux-lazy-image/current/index.html
- https://symfony.com/bundles/ux-toggle-password/current/index.html
- https://packagist.org/packages/symfony/ux-svelte
- https://packagist.org/packages/symfony/ux-swup
- https://packagist.org/packages/symfony/ux-typed
- https://packagist.org/packages/symfony/ux-lazy-image
- https://packagist.org/packages/symfony/ux-toggle-password
- https://packagist.org/packages/symfony/ux-turbo-mercure
- https://symfony.com/bundles/ux-image/current/index.html
- https://symfony.com/bundles/ux-inspector/current/index.html
- https://github.com/symfony/ux-cloudflare-image
- https://github.com/symfony/ux-keycdn-image
- https://packagist.org/packages/symfony/ux-image
- https://packagist.org/packages/symfony/ux-inspector
