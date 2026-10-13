# StimulusBundle (`symfony/stimulus-bundle`)

**Applies to:** Symfony UX 3.5

**Elevator pitch:** Use when server-rendered HTML needs JavaScript behavior, written as Stimulus controllers that attach to elements through data attributes. It registers your controllers and the controllers of installed Symfony UX packages. It loads large controllers only when a page uses them, and writes the attributes from templates. To serve the JavaScript files, see [AssetMapper](asset-mapper.md), [Webpack Encore](webpack-encore-bundle.md) or [Reprise](reprise.md).

**Details:** [../details/stimulus-bundle.md](../details/stimulus-bundle.md)

## Why it exists

Stimulus connects JavaScript classes, called controllers, to HTML elements through data attributes. By hand, you import and register each controller, and you encode and escape each value in the attributes. The package registers all controllers of one directory and of installed Symfony UX packages with one call, eagerly or on first use. It also writes the data attributes from Twig or PHP, with escaped and JSON-encoded values.

## When to use it

- Add JavaScript behavior to HTML that the server renders, with a Stimulus controller.
- Register every controller file of one directory, without one import and one registration call per file.
- Load a large controller only on the pages that use it.
- Activate the JavaScript of a Symfony UX package after you install the package with Composer.
- Write the controller, action and target attributes in a Twig template, with escaped and JSON-encoded values.
- Add the Stimulus attributes to a form field from PHP code.
- Pass CSS class names and outlets to a controller from a Twig template.
- Set up Stimulus without a build step through [AssetMapper](asset-mapper.md), or with a bundler through [Webpack Encore](webpack-encore-bundle.md) or [Reprise](reprise.md).

## Use it instead of

- `document.addEventListener('DOMContentLoaded', ...)` with `document.querySelectorAll('.js-widget').forEach(...)` -> a controller file in `assets/controllers/` that `startStimulusApp()` registers. Stimulus also connects the controller to HTML that Ajax adds later.
- One `import` and one `app.register('hello', HelloController)` call for each controller in `app.js` -> `startStimulusApp()`, which registers `assets/controllers/` and the enabled controllers of `assets/controllers.json`.
- `data-chart-points-value="{{ points|json_encode|e('html_attr') }}"` -> `{{ stimulus_controller('chart', { points: points }) }}`.
- A hand-typed `data-controller="symfony--ux-dropzone--dropzone"` -> `stimulus_controller('@symfony/ux-dropzone/dropzone')`.
- `'attr' => ['data-controller' => 'country-picker', 'data-action' => 'change->country-picker#refresh']` in a form type -> `$stimulusHelper->createStimulusAttributes()` with `addController()`, `addAction()` and `toArray()`.
- A manual `import()` call and a `MutationObserver` that load a large script on some pages -> `/* stimulusFetch: 'lazy' */`, or `"fetch": "lazy"` in `assets/controllers.json`.
- A vendor script and its CSS that you copy to `public/` and include with `<script>` and `<link>` tags -> a Symfony UX package. Flex enables its controller and its `autoimport` CSS in `assets/controllers.json`.
- Custom JavaScript that copies a CSRF token into a cookie and a header -> `assets/controllers/csrf_protection_controller.js` from the recipe, for stateless CSRF tokens.
