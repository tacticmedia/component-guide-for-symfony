# StimulusBundle (`symfony/stimulus-bundle`): details

**Applies to:** Symfony UX 3.5

## Key features and concepts

- **Automatic registration**: `startStimulusApp()` registers each `*_controller.js` file in `assets/controllers/`. The file name gives the controller name: `hello_controller.js` is `hello`, and `admin/user_controller.js` is `admin--user`. AssetMapper, Encore and Reprise also accept `-controller.js`, and `_` in the name becomes `-`. Entry point: `assets/controllers/`.
- **Values, CSS classes and outlets**: `stimulus_controller()` renders `data-controller` and one `data-<controller>-<key>-value` attribute for each value. It changes camelCase keys to kebab-case and writes booleans as `true` or `false`. It JSON-encodes arrays and objects, but casts a `Stringable` object to a string. It skips `null` values and escapes all output. The third argument adds `-class` attributes, and the fourth argument adds `-outlet` attributes. Use the named arguments `controllerClasses:` and `controllerOutlets:` to skip the values argument. Entry point: `stimulus_controller('hello', values, classes, outlets)`.
- **Name normalization**: the helpers remove a leading `@`, and they change `/` to `--` and `_` to `-`. Thus `stimulus_controller('@symfony/ux-chartjs/chart')` renders `data-controller="symfony--ux-chartjs--chart"`. Entry point: `stimulus_controller()`.
- **Actions and targets**: `stimulus_action('controller', 'method', 'click')` renders `data-action="click->controller#method"`. Its fourth argument adds action parameters as `data-<controller>-<key>-param` attributes. `stimulus_target('controller', 'myTarget secondTarget')` renders `data-controller-target="myTarget secondTarget"`. Entry point: `stimulus_action()`, `stimulus_target()`.
- **Chained filters and arrays**: the `stimulus_controller`, `stimulus_action` and `stimulus_target` filters add to one attribute set, in any order. Call `.toArray()` on the result to give the attributes to the `attr` option of `form_start()` or `form_row()`. Entry point: `|stimulus_controller`, `|stimulus_action`, `|stimulus_target`.
- **Plain attributes first**: the docs recommend raw `data-*` attributes because they are clear. The helpers are optional, but they JSON-encode and escape values, normalize the controller names of UX packages and return arrays for forms. Entry point: `<div data-controller="hello">`.
- **Attributes from PHP**: `StimulusHelper::createStimulusAttributes()` returns a `StimulusAttributes` object with `addController()`, `addAction()`, `addTarget()` and `addAttribute()`. `toArray()` returns unescaped values for the `attr` option of a form field. A string cast returns escaped HTML attributes. Entry point: `Symfony\UX\StimulusBundle\Helper\StimulusHelper`.
- **UX package controllers**: Symfony Flex adds each controller of an installed UX package to `assets/controllers.json`. Each entry has `enabled` and `fetch` (`eager` or `lazy`). An entry can also have `autoimport`: files, for example CSS, that load with the controller. When Flex updates the file, it keeps your `enabled`, `fetch` and `autoimport` values. A UX bundle declares its controllers under `symfony.controllers` in its `assets/package.json`, and its `composer.json` needs the `symfony-ux` keyword. Entry point: `assets/controllers.json`.
- **Lazy controllers**: a `/* stimulusFetch: 'lazy' */` comment above the class, or `"fetch": "lazy"` in `controllers.json`, keeps the controller out of the first download. The loader imports the controller when a matching `data-controller` element appears, also in HTML that JavaScript adds later. Use a block comment with single quotes, because the AssetMapper loader detects only that form. Entry point: `/* stimulusFetch: 'lazy' */`.
- **AssetMapper setup**: Flex adds `@symfony/stimulus-bundle` and `@hotwired/stimulus` to `importmap.php`. In a Flex project, the path of `@symfony/stimulus-bundle` is `./vendor/symfony/stimulus-bundle/assets/dist/loader.js`. The docs show the logical path `@symfony/stimulus-bundle/loader.js`, which points to the same file. `assets/stimulus_bootstrap.js` calls `startStimulusApp()` from `@symfony/stimulus-bundle`, with no arguments. An asset compiler of the bundle writes the controller imports, and `kernel.debug` sets the Stimulus debug mode. Entry point: `stimulus.controller_paths`, `stimulus.controllers_json`.
- **Webpack Encore setup**: the recipe adds `.enableStimulusBridge('./assets/controllers.json')` to `webpack.config.js`. `assets/stimulus_bootstrap.js` calls `startStimulusApp()` from the npm package `@symfony/stimulus-bridge`, with a webpack context that uses `@symfony/stimulus-bridge/lazy-controller-loader`. The recipe (2.25 and later) writes this context with `import.meta.webpackContext()`. The docs show `require.context()`. With Encore 7, use `import.meta.webpackContext()`. If `package.json` has `"type": "module"`, webpack treats the `.js` files as ES modules and does not parse `require.context()` in them. Since 3.3, install the bridge yourself with `npm install --save-dev @symfony/stimulus-bridge`. Then run `npm install` and restart Encore. Do not install `@symfony/stimulus-bundle` from npm: that JavaScript package is private and not published. The Symfony docs put Encore in low-maintenance mode. For a new project, they recommend AssetMapper, or Reprise if the project needs a bundler. Entry point: `Encore.enableStimulusBridge()`.
- **Reprise setup**: set the `stimulus` option of the `Symfony()` Vite or Rsbuild plugin to `./assets/controllers.json`. Then call `startStimulusApp()` from `@symfony/reprise/stimulus`. Reprise 1.x is stable. symfony-docs and the StimulusBundle docs call it experimental, but the Reprise docs and CHANGELOG do not. Entry point: `@symfony/reprise/stimulus`.
- **Recipe files**: the Flex recipe creates `assets/stimulus_bootstrap.js` and imports it in `assets/app.js`. It also creates `assets/controllers.json`, `assets/controllers/hello_controller.js` and `assets/controllers/csrf_protection_controller.js`. Recipes before 2.24 and the Encore pages of symfony-docs use the old name `assets/bootstrap.js`. Entry point: `assets/stimulus_bootstrap.js`.
- **Controllers per application area**: by default, each page loads all eager controllers. Only Encore and Reprise can give an area, for example an admin, its own controllers. With Encore, give each entry its own webpack context. Each entry still registers all enabled controllers of `controllers.json`. With Reprise, give the area its own build config, with its own `controllers.json` and controllers directory. Then register the build under `reprise.builds`. With AssetMapper, `startStimulusApp()` always reads the full `controllers.json`. Entry point: `startStimulusApp(context)` from `@symfony/stimulus-bridge`, or the Reprise option `stimulus: { controllersJson, controllersDir }`.
- **TypeScript controllers**: if you use AssetMapper, install `sensiolabs/typescript-bundle` and include `assets/controllers` in its source directories. Then write `*_controller.ts` files. Entry point: `sensiolabs_typescript.source_dir`.

## Entry points

- `composer require symfony/stimulus-bundle` (the Flex recipe creates the files below).
- Twig functions: `stimulus_controller()`, `stimulus_action()`, `stimulus_target()`.
- Twig filters with the same names: `|stimulus_controller`, `|stimulus_action`, `|stimulus_target`.
- `Symfony\UX\StimulusBundle\Helper\StimulusHelper` (autowire it; service ID `stimulus.helper`).
- `Symfony\UX\StimulusBundle\Dto\StimulusAttributes`: `addController()`, `addAction()`, `addTarget()`, `addAttribute()`, `toArray()`, `toEscapedArray()`, string cast.
- Config keys (used with AssetMapper): `stimulus.controller_paths` (default `['%kernel.project_dir%/assets/controllers']`) and `stimulus.controllers_json` (default `'%kernel.project_dir%/assets/controllers.json'`).
- Files: `assets/controllers/`, `assets/controllers.json`, `assets/stimulus_bootstrap.js`.
- JavaScript with AssetMapper: `import { startStimulusApp } from '@symfony/stimulus-bundle'` (importmap path `./vendor/symfony/stimulus-bundle/assets/dist/loader.js`, or the logical path `@symfony/stimulus-bundle/loader.js`).
- JavaScript with Webpack Encore: `Encore.enableStimulusBridge('./assets/controllers.json')` and `startStimulusApp()` from `@symfony/stimulus-bridge`.
- JavaScript with Reprise: `Symfony({ stimulus: './assets/controllers.json' })` and `startStimulusApp()` from `@symfony/reprise/stimulus`.
- Lazy marker: `/* stimulusFetch: 'lazy' */`.
- Console: `make:stimulus-controller` from MakerBundle (option `--typescript`). StimulusBundle has no console command and no test helpers.

## Symbiotic packages

- [AssetMapper](../packages/asset-mapper.md): the recommended asset system for new projects; the bundle maps its `assets/dist` directory under `@symfony/stimulus-bundle` and writes the controller imports without a build step.
- [WebpackEncoreBundle](../packages/webpack-encore-bundle.md): with Encore, the npm package `@symfony/stimulus-bridge` loads the controllers, and this bundle gives the `stimulus_*` Twig functions that WebpackEncoreBundle 2.x does not have.
- [Symfony Reprise](../packages/reprise.md): the Vite and Rsbuild integration reads `controllers.json` through its `stimulus` plugin option and starts the application from `@symfony/reprise/stimulus`.
- [Symfony Flex](../packages/flex.md): the recipe creates the Stimulus files, and Flex adds the controllers of each UX package to `controllers.json` and its JavaScript to `importmap.php` or `package.json`.
- [TwigBundle](../packages/twig-bundle.md): TwigBundle adds the `stimulus.twig_extension` service (tag `twig.extension`) to Twig, so templates can call the `stimulus_*` functions and filters.
- [Symfony UX Turbo](../packages/ux-turbo.md): UX Turbo requires this bundle, and Flex enables its `turbo-core` controller in `controllers.json`.
- [UX Live Component](../packages/ux-live-component.md): UX Live Component requires this bundle, and its `live` controller loads through `controllers.json`.
- [UX Twig Component](../packages/ux-twig-component.md): pass `stimulus_controller()` to `attributes.defaults()` to put a Stimulus controller on the root element of a component.
- [UX Chart.js](../packages/ux-chartjs.md): UX Chart.js requires this bundle, and the docs use its `@symfony/ux-chartjs/chart` controller as the example of a UX package controller.
- [UX Autocomplete](../packages/ux-autocomplete.md): its docs require a StimulusBundle setup, and its `autocomplete` controller loads the Tom Select CSS through `autoimport`.
- [Symfony UX Dropzone](../packages/ux-dropzone.md): its docs require a StimulusBundle setup, and Flex adds its `dropzone` controller to `controllers.json`.
- [Symfony UX React](../packages/ux-react.md): UX React requires this bundle, and Flex adds its `react` controller to `controllers.json`.
- [Symfony UX Vue.js](../packages/ux-vue.md): UX Vue requires this bundle, and Flex adds its `vue` controller to `controllers.json`.
- [Form](../packages/form.md): give `stimulus_controller(...).toArray()` to the `attr` option of `form_start()` or `form_row()`, or build the attributes in a form type with `StimulusHelper`.
- [Security CSRF](../packages/security-csrf.md): the `csrf_protection_controller.js` of the recipe adds the optional cookie and header check of stateless CSRF tokens.
- [MakerBundle](../packages/maker-bundle.md): `make:stimulus-controller` writes `assets/controllers/<name>_controller.js` (or `.ts`) and requires this bundle.
- [Mercure](../packages/mercure.md): give the hub URL from `mercure()` to a Stimulus controller as a value with `stimulus_controller()`.

## Changed in 3.0 to 3.5

- 3.0: `{{ ux_controller_link_tags() }}` is removed. Delete the call. With AssetMapper 6.4 or later, the loader imports the `autoimport` CSS of each controller.
- 3.3: `@symfony/stimulus-bridge` is no longer an npm peer dependency. If you use Webpack Encore, run `npm install --save-dev @symfony/stimulus-bridge`.
- 3.3: The lazy marker also works in a preserved comment: `/*! stimulusFetch: 'lazy' */`.
- 3.3: The bundle supports Reprise (Vite and Rsbuild). Call `startStimulusApp()` from `@symfony/reprise/stimulus`.
- 3.5: `StimulusHelper` has an alias for its class name. Type-hint `StimulusHelper` in a constructor instead of the service ID `stimulus.helper`.

## Docs

- https://symfony.com/bundles/StimulusBundle/current/index.html
- https://symfony.com/doc/current/frontend.html
- https://symfony.com/doc/current/frontend/create_ux_bundle.html
- https://symfony.com/doc/current/frontend/encore/index.html
- https://symfony.com/doc/current/frontend/encore/simple-example.html
- https://symfony.com/bundles/reprise/current/index.html
- https://symfony.com/doc/current/security/csrf.html
- https://github.com/symfony/stimulus-bridge
