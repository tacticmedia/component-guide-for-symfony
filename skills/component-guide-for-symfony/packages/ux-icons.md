# UX Icons (`symfony/ux-icons`)

**Applies to:** Symfony UX 3.5

**Elevator pitch:** Use when HTML pages must show SVG icons from your own files or from icon sets such as Font Awesome, Bootstrap Icons or Heroicons. It inlines each icon by name from a local file or the Iconify API, caches it and hides decorative icons from screen readers. It needs no icon font and no JavaScript.

**Details:** [../details/ux-icons.md](../details/ux-icons.md)

## Why it exists

Templates that inline the full SVG markup of each icon are long and repeat the same markup. The package renders an icon from its name: a local SVG file or one of more than 200,000 open source icons from the Iconify API. It also caches the icons, saves remote icons into the project and hides decorative icons from screen readers.

## When to use it

- Render an SVG icon inline in a Twig template, with a CSS class or a size.
- Show icons from Font Awesome, Bootstrap Icons, Tabler, Heroicons or Material Design without an icon font.
- Render your own SVG files from one project directory by name.
- Download the remote icons that the templates use into the repository before deployment.
- Give all icons, or all icons of one icon set, the same default attributes.
- Hide decorative icons from screen readers and give informative icons a label.
- Find an icon set prefix or an icon name from the command line.
- Render an icon as an HTML string in PHP code, for example for a map marker.

## Use it instead of

- `{{ source('icons/check.svg') }}`, `{{ include('icons/check.svg') }}` or SVG markup pasted into a template -> `{{ ux_icon('check', {class: 'size-4'}) }}` with the file in `assets/icons/check.svg`.
- `<img src="{{ asset('images/check.svg') }}" alt="">` -> `{{ ux_icon('check') }}`: the inline `<svg>` has `fill="currentColor"` and takes the CSS text color.
- `<i class="bi bi-check"></i>` plus an icon font stylesheet -> `{{ ux_icon('bi:check') }}` (on-demand), then `php bin/console ux:icons:lock`.
- `file_get_contents('https://api.iconify.design/mdi.json?icons=home')` plus `file_put_contents('assets/icons/mdi/home.svg', ...)` -> `php bin/console ux:icons:import mdi:home`.
- `aria-hidden="true"` typed by hand on each decorative `<svg>` -> the automatic `aria-hidden="true"` of `ux_icon()`; pass `{'aria-label': '...'}` for an informative icon.
- A Twig macro that adds the same `class` or `fill` to each icon -> `default_icon_attributes`, or `icon_sets.<prefix>.icon_attributes` for one icon set.
- `$cache->get('icon_'.$name, fn () => file_get_contents($svgPath))` -> the built-in icon cache, filled with `php bin/console ux:icons:warm-cache`.
