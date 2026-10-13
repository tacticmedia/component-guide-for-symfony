# Symfony UX Vue.js (`symfony/ux-vue`): details

**Applies to:** Symfony UX 3.5

## Key features and concepts

- **Vue controller components**: These are the top-level components that Twig renders. Put them in `assets/vue/controllers/`, also in subdirectories. The component name is the file path in that directory without the extension, for example `Admin/Form` for `Admin/Form.vue`. Each module must export the component as `export default`. With a bundler, the name lookup tries only `<name>.vue`. If the name is unknown, the controller throws `Vue controller "<name>" does not exist. Possible values: ...`. Entry point: `assets/vue/controllers/`.
- **Render from Twig**: `vue_component()` writes the attributes of the `@symfony/ux-vue/vue` Stimulus controller. Put the call inside the opening tag of an element, for example `<div {{ vue_component('Hello', {'name': app.user.fullName}) }}></div>`. The function JSON-encodes the props and escapes them for the attribute. If the props are empty, the function writes no props attribute. Entry point: `vue_component(componentName, props = {})`.
- **Mount in the browser**: When the element connects, the Stimulus controller resolves the component name and calls `createApp(component, props)`. Then the controller mounts the app on the element, so each element gets its own Vue app. When the element disconnects, the controller unmounts the app. The controller reads the props one time, when it connects. A later change of the props attribute does not update the component. Vue renders only in the browser; the PHP code writes only the attributes. Entry point: the Stimulus controller `symfony--ux-vue--vue` with the values `component` and `props`.
- **Register for Vite or Rsbuild (Symfony Reprise)**: In `assets/app.js`, call `registerVueControllerComponents(import.meta.glob('./vue/controllers/**/*.vue', { eager: true }))`. Install `@vitejs/plugin-vue` for Vite or `@rsbuild/plugin-vue` for Rsbuild. Add the plugin to the `plugins` list of `vite.config.ts` or `rsbuild.config.ts`. This setup needs `symfony/ux-vue` 3.4 or later. The function removes the directory path that all matched files share. Thus, if all components are in one subdirectory, their names do not include that subdirectory. Entry point: `registerVueControllerComponents()` from `@symfony/ux-vue`.
- **Lazy components**: To load each component only when a page shows it, remove `{ eager: true }` from the `import.meta.glob()` call. The function then wraps each component in `defineAsyncComponent()` and loads it when the controller resolves the name. Entry point: `import.meta.glob('./vue/controllers/**/*.vue')`.
- **Stimulus with Reprise**: Add the Reprise plugin with the option `stimulus: './assets/controllers.json'` to the bundler config. Start Stimulus with `startStimulusApp()` from `@symfony/reprise/stimulus`. Reprise resolves the `@symfony/ux-vue` controller from `node_modules`. Thus, after Flex changes `package.json`, run `npm install --force`. Entry point: `Symfony({ stimulus: './assets/controllers.json' })` from `@symfony/reprise/vite` or `@symfony/reprise/rsbuild`.
- **Register for Webpack Encore**: In `assets/app.js`, call `registerVueControllerComponents(require.context('./vue/controllers', true, /\.vue$/))`. The Flex recipe adds `.enableVueLoader()` after `.splitEntryChunks()` in `webpack.config.js`. Install the Vue loader with `npm install -D vue-loader --force`. Then run `npm run watch`. For this feature, Encore requires the npm packages `vue`, `vue-loader` and `@vue/compiler-sfc`. With StimulusBundle 3.3 or later, install `@symfony/stimulus-bridge` yourself. With Encore, the bridge loads the controllers of `controllers.json`, including the `vue` controller. Entry point: `Encore.enableVueLoader()`.
- **Encore 7 and ES modules**: The Encore 7 upgrade guide says to add `"type": "module"` to `package.json` or to rename the config file to `webpack.config.mjs`. If `package.json` has `"type": "module"`, webpack treats the `.js` files as ES modules and does not parse `require.context()` in them. In that case, give `import.meta.webpackContext('./vue/controllers', { recursive: true, regExp: /\.vue$/ })` to `registerVueControllerComponents()`. The webpack docs say that this call returns the same value as `require.context()`. The upgrade guide of Encore 7 and the StimulusBundle recipe use `import.meta.webpackContext()` for the Stimulus controllers. The UX Vue.js docs and recipe show only `require.context()`. If the config file is `webpack.config.mjs`, add `.enableVueLoader()` to it yourself, because the recipe changes only `webpack.config.js`. Entry point: `import.meta.webpackContext()`.
- **Use with AssetMapper**: The `.vue` format is not pure JavaScript, so AssetMapper cannot use it. Write each Vue controller component as a `.js` file that exports a component object. The object can use a `template` string and a `setup()` function. In `assets/app.js`, call `registerVueControllerComponents()` without an argument. The Flex recipe also copies `assets/vue/controllers/Hello.vue`. With AssetMapper, rewrite this example as `Hello.js`, because the asset compiler finds only `*.js` files by default. Entry point: `registerVueControllerComponents()` from the importmap entry `@symfony/ux-vue`.
- **AssetMapper component map**: An asset compiler finds the files in `vue.controllers_path` that match `vue.name_glob` (default `*.js`). It writes a static `import` for each file into the `components.js` module of the package. The name of each component is its relative path without the extension. If a component file is outside the AssetMapper paths, the compiler throws a `LogicException`. The bundle maps its `assets/dist` directory as `@symfony/ux-vue`. Entry point: `Symfony\UX\Vue\AssetMapper\VueControllerLoaderAssetCompiler`.
- **Packages that Flex adds**: With AssetMapper, Flex runs `importmap:require` for `@hotwired/stimulus`, `vue` and `@symfony/ux-vue`. The `vue` entry uses the file `vue/dist/vue.esm-bundler.js`, and the `@symfony/ux-vue` entry points to `loader.js`. With Encore or Reprise, Flex adds `@symfony/ux-vue` (`file:vendor/symfony/ux-vue/assets`), `vue` and `@hotwired/stimulus` to `package.json`. Then run `npm install --force`, as the Flex message says. In both cases, Flex enables the `vue` controller in `assets/controllers.json`. Entry point: the `symfony` block of `vendor/symfony/ux-vue/assets/package.json`.
- **Flex recipe**: The recipe 3.4 registers the bundle and copies `assets/vue/controllers/Hello.vue`. It adds the import of `registerVueControllerComponents` to `assets/app.js`. It also adds the call that matches the installed package: `symfony/reprise`, `symfony/webpack-encore-bundle` or `symfony/asset-mapper`. If `webpack.config.js` exists, the recipe adds `.enableVueLoader()` to it. Entry point: `composer require symfony/ux-vue`.
- **Events**: The controller dispatches events on the element, with the `vue:` prefix. `vue:before-mount` gives `componentName`, `component`, `props` and `app`. Listen to it to add plugins, global directives or a router to the Vue app before it mounts. `vue:mount` gives `componentName`, `component` and `props`, and `vue:unmount` gives `componentName` and `props`. The source also dispatches `vue:connect` (`componentName`, `props`) before it resolves the component, but the docs do not describe it. The events bubble, so a listener on `document` receives the events of all components. Entry point: `document.addEventListener('vue:before-mount', (event) => event.detail.app.use(router))`.
- **Vue Router**: Add the router in a `vue:before-mount` listener with `app.use(router)`. To keep the Vue routes away from Symfony controllers, use the hash or memory history mode. For the web history mode, add a catch-all Symfony route that renders the same template, for example `#[Route('/survey/{path<.+>}')]`. Then start all Vue routes with that prefix, for example `/survey/list`. Entry point: `VueRouter.createWebHashHistory()`, or `VueRouter.createWebHistory()` with a catch-all route.

## Entry points

- Twig function: `vue_component(componentName, props = {})`. PHP: `Symfony\UX\Vue\Twig\VueComponentExtension::renderVueComponent()` (service ID `twig.extension.vue`).
- JavaScript: `registerVueControllerComponents()` from `@symfony/ux-vue`. The npm entry (`dist/register_controller.js`) takes an `import.meta.glob()` result or a `require.context()` result. The importmap entry (`dist/loader.js`) takes an optional map of component names to components. If you call it without an argument, it uses the map that the asset compiler writes.
- Stimulus controller: `@symfony/ux-vue/vue` (HTML name `symfony--ux-vue--vue`), with the values `component` and `props` (attributes `data-symfony--ux-vue--vue-component-value` and `data-symfony--ux-vue--vue-props-value`). Flex enables it in `assets/controllers.json` with `"fetch": "eager"`.
- Browser events: `vue:connect`, `vue:before-mount`, `vue:mount`, `vue:unmount`.
- Config (only for AssetMapper): `vue.controllers_path` (default `%kernel.project_dir%/assets/vue/controllers`), `vue.name_glob` (default `['*.js']`).
- Directory: `assets/vue/controllers/`.
- Bundle: `Symfony\UX\Vue\VueBundle`. Install it with `composer require symfony/ux-vue` (Flex recipe 3.4).
- Bundler setup: `@vitejs/plugin-vue` (Vite), `@rsbuild/plugin-vue` (Rsbuild), `Encore.enableVueLoader()` with `vue-loader` (Webpack Encore).
- AssetMapper compiler: `Symfony\UX\Vue\AssetMapper\VueControllerLoaderAssetCompiler` (service ID `vue.asset_mapper.vue_controller_loader_compiler`, tag `asset_mapper.compiler`).
- Console, attributes and tests: the package has no console command, no PHP attribute and no test helper.

## Symbiotic packages

- [StimulusBundle](../packages/stimulus-bundle.md): the required dependency; `vue_component()` builds its attributes with `StimulusHelper` (service `stimulus.helper`), and the Stimulus application loads the `vue` controller from `assets/controllers.json`.
- [Symfony UX React](../packages/ux-react.md): the same pattern for React (`react_component()`, `registerReactControllerComponents()`); UX React adds a `permanent` option but cannot lazy-load components.
- [Symfony Reprise](../packages/reprise.md): the docs say that UX Vue.js works best with Reprise (Vite or Rsbuild); Reprise 1.x is stable, but symfony-docs calls it experimental.
- [WebpackEncoreBundle](../packages/webpack-encore-bundle.md): the Encore setup uses `require.context()` (`import.meta.webpackContext()` for ES modules) and `Encore.enableVueLoader()`; the Symfony docs put Encore in low-maintenance mode and recommend Reprise for a new bundler setup.
- [AssetMapper](../packages/asset-mapper.md): the setup without a build step; write the components as `.js` files, because AssetMapper cannot use `.vue` files.
- [UX Live Component](../packages/ux-live-component.md): use it for interactive UI in PHP and Twig only; its docs compare its data binding with React or Vue.
- [Symfony Flex](../packages/flex.md): the recipe registers the bundle, copies `Hello.vue`, writes the registration call in `assets/app.js` and adds `.enableVueLoader()` to an existing `webpack.config.js`; Flex also syncs `package.json` or `importmap.php`.
- [TwigBundle](../packages/twig-bundle.md): TwigBundle collects the services with the `twig.extension` tag, which makes `vue_component()` available in templates.
- [Abandoned Symfony UX packages](../packages/ux-abandoned.md): UX Svelte (`symfony/ux-svelte`), the Svelte counterpart of this package, is abandoned on Packagist.

## Changed in UX 2.5 to 3.5

- UX 3.4: `registerVueControllerComponents()` accepts an `import.meta.glob()` result, eager or lazy, for Vite or Rsbuild through Symfony Reprise. The Flex recipe 3.4 writes this call when the project has `symfony/reprise`.
- UX 3.0: The minimum versions are PHP 8.4 and Symfony 7.4. UX 3.0 removes the compatibility layer for the `StimulusTwigExtension` of WebpackEncoreBundle 1.x; use StimulusBundle.
- UX 2.9: AssetMapper support. Call `registerVueControllerComponents()` without an argument, and write the components as `.js` files. The package requires `symfony/stimulus-bundle`, not `symfony/webpack-encore-bundle`.
- UX 2.6: The JavaScript package moved from `Resources/assets/` to `assets/`. In `package.json`, use `file:vendor/symfony/ux-vue/assets`.
- UX 2.5: The package can lazy-load components, and it dispatches the `vue:before-mount` event.

## Docs

- https://symfony.com/bundles/ux-vue/current/index.html
- https://ux.symfony.com/vue (demo)
- https://symfony.com/doc/current/frontend.html
- https://symfony.com/doc/current/frontend/asset_mapper.html
- https://symfony.com/doc/current/frontend/encore/vuejs.html
- https://symfony.com/doc/current/frontend/encore/index.html
- https://symfony.com/bundles/reprise/current/index.html
- https://symfony.com/bundles/StimulusBundle/current/index.html
- https://symfony.com/bundles/ux-live-component/current/index.html
- https://github.com/symfony/webpack-encore/blob/v7.2.0/UPGRADE.md (Encore 7: `require.context()` and ES modules)
- https://webpack.js.org/api/module-variables/ (`import.meta.webpackContext()`)
