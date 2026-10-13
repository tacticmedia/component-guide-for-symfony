# UX Icons (`symfony/ux-icons`): details

**Applies to:** Symfony UX 3.5

## Key features and concepts

- **Twig function:** `ux_icon()` returns the icon as an inline `<svg>` element, and Twig does not escape it. The optional second argument adds HTML attributes, for example `class`, `style` or `aria-label`. Entry point: `{{ ux_icon('user-profile', {class: 'w-4 h-4'}) }}`.
- **HTML syntax:** If the application has `symfony/ux-twig-component`, `<twig:ux:icon name="mdi:home" class="w-4 h-4" />` gives the same result. The self-closing tag calls the icon renderer directly, without the component overhead. The tag does not support content between an opening and a closing tag. Always use the self-closing form. Entry point: `<twig:ux:icon name="..." />`.
- **Icon names and aliases:** A name is `prefix:name` (for example `mdi:check`) or `name` only. The prefix and the name must be slugs: lowercase letters, digits and hyphens. The package reports a name with an underscore or an uppercase letter as not found. The `aliases` option maps a short name to a full name, for example `dots: 'clarity:ellipsis-horizontal-line'`. Entry point: `ux_icons.aliases`.
- **Local icons:** Store the SVG files in `assets/icons/`. Commit them to the repository. The file name is the icon name, and a subdirectory is the prefix: `assets/icons/admin/user-profile.svg` is `admin:user-profile`. A local icon has priority over an on-demand icon with the same name. Entry point: `ux_icons.icon_dir` (default `%kernel.project_dir%/assets/icons`).
- **On-demand icons:** If the prefix is an Iconify icon set (for example `bi`, `tabler` or `lucide`), the package downloads the icon at the first render. Then it caches the icon. This feature needs `symfony/http-client`. To find an icon, search ux.symfony.com/icons or run `php bin/console ux:icons:search tabler arrow`. Entry point: `ux_icons.iconify` (`enabled`, `on_demand`, `endpoint`).
- **Import and lock:** `ux:icons:import flowbite:user-solid` saves the icon as `assets/icons/flowbite/user-solid.svg`. `ux:icons:lock` imports the on-demand icons that it finds in the templates and in `aliases`. With `--force`, it overwrites existing files. The scan finds quoted `prefix:name` strings in the `*.twig` files, so it can find false positives. It cannot find a name that a template builds at runtime, for example `'flag-' ~ locale`. Commit the imported files, so that production sends no requests to the Iconify API. Entry point: `ux:icons:import`, `ux:icons:lock`.
- **Custom icon finders (3.5):** A service that implements `IconFinderInterface` returns more icon names, for example from a PHP enum or a database. Autoconfiguration adds the tag `ux_icons.finder`. `ux:icons:lock` and the cache warm-up use these names together with the template scan. Entry point: `Symfony\UX\Icons\IconFinderInterface::icons(): iterable`.
- **Automatic lock (3.4):** With `iconify.auto_lock: true`, the package saves each on-demand icon to `icon_dir` the first time that it renders the icon. Enable it only under `when@dev`. Commit the new files. Entry point: `ux_icons.iconify.auto_lock`.
- **Default attributes:** `default_icon_attributes` adds attributes to all icons. Its default value is `fill: currentColor`, so icons take the CSS text color. If you set the option, your value replaces this default. If you need the CSS text color, add `fill: currentColor` again. Attributes merge in this order, and the last one wins: the SVG file, `default_icon_attributes`, the icon set, the suffix, the call. The value `false` removes an attribute, also a default one, but in Twig an `aria-*` attribute with `false` renders `"false"`. Entry point: `ux_icons.default_icon_attributes`.
- **Icon sets and suffixes:** `icon_sets.<prefix>.path` maps a prefix to a local directory, and `icon_sets.<prefix>.alias` maps a prefix to an Iconify icon set. Do not set both for the same prefix. `icon_attributes` gives the icons of one set their own attributes. `suffixes.<suffix>.icon_attributes` sets attributes by the end of the icon name: the key `20-solid` matches `heroicons:arrow-right-20-solid`. The longest matching suffix wins, and the empty suffix `''` applies when no other suffix matches. Entry point: `ux_icons.icon_sets`.
- **Accessibility:** The renderer adds `aria-hidden="true"` to an icon that has no `aria-hidden`, `aria-label`, `aria-labelledby` or `title` attribute. For an informative or interactive icon, pass `aria-label`. To stop the automatic `aria-hidden`, set `aria-hidden` to `false`. Entry point: `{{ ux_icon('cloud-rain', {'aria-label': 'Rainy weather'}) }}`.
- **Cache and warm-up:** The package keeps parsed icons in a cache pool that extends `cache.system`. Run `ux:icons:warm-cache` in production to fill this cache. If the application uses AssetMapper, `asset-map:compile` also warms it. `cache:warmup` does not warm icons. The docs describe this warm-up for the unreleased 3.6. After you change an icon file in development, run `cache:clear`. Entry point: `php bin/console ux:icons:warm-cache`.
- **Errors:** If an icon does not exist, the renderer throws `Symfony\UX\Icons\Exception\IconNotFoundException`. In a template, Twig wraps it in a `Twig\Error\RuntimeError`. With `ignore_not_found: true`, `ux_icon()` and `<twig:ux:icon>` render an empty string and log a warning. Entry point: `ux_icons.ignore_not_found`.
- **SVG sanitization:** The package removes `<script>`, `<foreignObject>`, `on*` event attributes and `javascript:` links from local files and Iconify icons. It keeps `<style>` elements, so that light and dark themes continue to work. Entry point: none, it applies to all icons.
- **PHP renderer:** Autowire `IconRendererInterface` to render an icon outside a template. `$iconRenderer->renderIcon('lucide:heart', ['class' => 'color-red'])` returns the `<svg>` string. It always throws `IconNotFoundException` for a missing icon, because `ignore_not_found` applies to Twig only. In PHP code, the `html_attr()` rules of Twig do not apply. Pass string values, for example `'aria-hidden' => 'false'`. Entry point: `Symfony\UX\Icons\IconRendererInterface`.

## Entry points

- Twig function: `ux_icon(name, attributes = {})`.
- Twig component (HTML syntax, needs `symfony/ux-twig-component`): `<twig:ux:icon name="..." class="..." />`.
- Service to autowire: `Symfony\UX\Icons\IconRendererInterface` (`renderIcon(string $name, array $attributes = []): string`).
- Interface to implement: `Symfony\UX\Icons\IconFinderInterface` (`icons(): iterable`), autoconfigured with the tag `ux_icons.finder`.
- Configuration: `ux_icons` in `config/packages/ux_icons.yaml`: `icon_dir`, `default_icon_attributes`, `aliases`, `icon_sets.<prefix>` (`path`, `alias`, `icon_attributes`, `suffixes.<suffix>.icon_attributes`), `iconify` (`enabled`, `on_demand`, `auto_lock`, `endpoint`), `ignore_not_found`. Inspect it with `php bin/console debug:config ux_icons`.
- Console commands: `ux:icons:search <prefix> [<name>]`, `ux:icons:import <prefix:name>...`, `ux:icons:lock [--force]`, `ux:icons:warm-cache`.
- Directory: `assets/icons/` (the default `icon_dir`).

## Symbiotic packages

- [UX Twig Component](../packages/ux-twig-component.md): If the application registers this bundle, the `<twig:ux:icon>` HTML syntax renders icons; without it, only `ux_icon()` works.
- [HttpClient](../packages/http-client.md): UX Icons uses it to download on-demand icons from the Iconify API and to run `ux:icons:import`, `ux:icons:lock` and `ux:icons:search`.
- [AssetMapper](../packages/asset-mapper.md): `asset-map:compile` warms the icon cache through a `PreAssetsCompileEvent` listener of UX Icons.
- [TwigBundle](../packages/twig-bundle.md): UX Icons requires it. It loads the `ux_icon()` extension, and the lock and warm-up scan reads the `*.twig` files in its template paths.
- [Cache](../packages/cache.md): The icon cache is a pool that extends `cache.system`. In development, run `cache:clear` to see a changed icon file.
- [FrameworkBundle](../packages/framework-bundle.md): UX Icons requires it. It provides the `cache.system` pool and the `http_client` service that UX Icons uses.
- [Console](../packages/console.md): It runs the four `ux:icons:*` commands.
- [UX Map](../packages/ux-map.md): UX Map renders `Icon::ux('fa:map-marker')` marker icons through `IconRendererInterface`. Without UX Icons, UX Map throws a `LogicException` for this icon type.
- [UX Toolkit](../packages/ux-toolkit.md): The Toolkit recipes that show icons (for example the shadcn `dialog` recipe) use `<twig:ux:icon>` and list `symfony/ux-icons` as a Composer dependency.

## Changed in 3.0 to 3.5

- 3.5: Implement `IconFinderInterface` to give `ux:icons:lock` and the cache warm-up the icon names that templates build at runtime.
- 3.5: In `ux_icon()` and `<twig:ux:icon>`, attribute values follow the `html_attr()` rules of `twig/html-extra`. `null` removes an attribute, `true` renders `name=""`, and `aria-*` booleans render `"true"` or `"false"`. Update tests that compare the `<svg>` tag.
- 3.5: Icons from local files now render `xmlns="http://www.w3.org/2000/svg"`. Generate output assertions again. After the upgrade, clear the icon cache.
- 3.5: The package needs the `dom` PHP extension, because it parses SVG with `Dom\XMLDocument`.
- 3.4: `iconify.auto_lock` saves on-demand icons to `icon_dir` at the first render. Use it in development instead of manual `ux:icons:lock` runs.
- 3.2: The package sanitizes the rendered SVG and removes scripts, event attributes and `javascript:` links. After the upgrade, clear the icon cache.
- 3.0: UX Icons needs PHP 8.4 or later and Symfony 7.4 or later.

## Status

UX Icons needs PHP 8.4 or later and the `dom` PHP extension (`ext-dom`). On-demand icons need network access to the Iconify API (`https://api.iconify.design`).

## Docs

- https://symfony.com/bundles/ux-icons/current/index.html (it describes the unreleased 3.6 `cache:warmup` change)
- https://ux.symfony.com/icons
