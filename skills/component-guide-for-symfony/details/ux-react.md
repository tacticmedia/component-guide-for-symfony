# Symfony UX React (`symfony/ux-react`): details

**Applies to:** Symfony UX 3.5

## Key features and concepts

- **React controller components**: These are the top-level components that Twig renders. Put them in `assets/react/controllers/`, also in subdirectories. The component name is the file path in that directory without the extension, for example `Admin/OtherComponent`. Each module must export the component as `export default`. Entry point: `assets/react/controllers/`.
- **Render from Twig**: `react_component()` writes the attributes of the `@symfony/ux-react/react` Stimulus controller. Put the call inside the opening tag of the root element: `<div {{ react_component('Hello', {fullName: 'Fabien'}) }}>Loading...</div>`. The function JSON-encodes the props and escapes them for the attribute. If the props are empty, it writes no props attribute. Entry point: `react_component(componentName, props, options)`.
- **Mount in the browser**: When the root element connects, the Stimulus controller resolves the component name and renders the component with `createRoot()`. When the root element disconnects, the controller unmounts the component. React renders only in the browser; the package does not render React on the server. The docs example puts `Loading...` in the root element as a placeholder, and React replaces it when it renders the component. The controller renders the component only in `connect()`, so a change of the props attribute alone does not render it again. Entry point: the Stimulus controller `symfony--ux-react--react` with the values `component`, `props` and `permanent`.
- **Permanent components**: If code moves the root element in the DOM, pass `{permanent: true}` as the third argument. This also applies when code removes the root element and immediately adds it again. The controller then does not unmount the component on disconnect. The docs name Turbo and its `data-turbo-permanent` attribute as an example. Only a boolean value has an effect. Entry point: `react_component('Hello', props, {permanent: true})`.
- **Register for Vite or Rsbuild (Symfony Reprise)**: In `assets/app.js`, call `registerReactControllerComponents(import.meta.glob('./react/controllers/**/*.{jsx,tsx}', { eager: true }))`. The `eager: true` option is necessary, because a lazy glob causes an error. Install `@vitejs/plugin-react` for Vite or `@rsbuild/plugin-react` for Rsbuild, so that the bundler compiles JSX. Set the `stimulus: './assets/controllers.json'` option of the Reprise plugin, so that Reprise loads the `react` controller. This call needs `symfony/ux-react` 3.4 or later. The docs also name `symfony/reprise` 0.4, but Reprise has no 0.4.0 release. React Fast Refresh with Vite in dev mode needs Reprise 0.5.0 or later, which renders the preamble. Entry point: `registerReactControllerComponents()` from `@symfony/ux-react`.
- **Register for Webpack Encore**: In `assets/app.js`, call `registerReactControllerComponents(require.context('./react/controllers', true, /\.(j|t)sx?$/))`. If `webpack.config.js` exists, the Flex recipe adds `.enableReactPreset()` to it. Install the Babel React preset with `npm install -D @babel/preset-react --force`. If you also call `enableTypeScriptLoader()`, `ts-loader` processes the `.tsx` files. With StimulusBundle 3.3 or later, install `@symfony/stimulus-bridge` yourself. With Encore, the bridge loads the controllers of `controllers.json`, including the `react` controller. Entry point: `Encore.enableReactPreset()`.
- **Encore 7 and ES modules**: The Encore 7 docs say to add `"type": "module"` to `package.json` or to rename the config file to `webpack.config.mjs`. If `package.json` has `"type": "module"`, webpack treats the `.js` files as ES modules and does not parse `require.context()` in them. In that case, pass `import.meta.webpackContext('./react/controllers', { recursive: true, regExp: /\.(j|t)sx?$/ })` to `registerReactControllerComponents()`. The webpack docs say that this call returns the same value as `require.context()`. The UX React docs and recipe show only `require.context()`. If the config file is `webpack.config.mjs`, add `.enableReactPreset()` to it yourself, because the recipe changes only `webpack.config.js`. Encore 7 also needs Babel 8, so it needs `@babel/preset-react` 8. Entry point: `import.meta.webpackContext()`.
- **Component names with a bundler**: With Vite, Rsbuild or Encore, the name lookup tries only `<name>.jsx` and `<name>.tsx`. Give each React controller component a `.jsx` or `.tsx` extension. The Encore pattern also matches `.js` and `.ts` files, but a `.js` or `.ts` component causes a "does not exist" error. With `import.meta.glob()`, the function removes the directory path that all matched files share. So if all components are in one subdirectory, their names do not include that subdirectory. Entry point: the file names in `assets/react/controllers/`.
- **Use with AssetMapper**: JSX is not pure JavaScript. Compile the `.jsx` files to `.js` files with Babel and `@babel/preset-react` first. Then set `react.controllers_path` to the output directory. In `assets/app.js`, call `registerReactControllerComponents()` without an argument. In a `.jsx` source file, import another component with the `.js` extension. The ux.symfony.com application also excludes its JSX sources with `framework.asset_mapper.excluded_patterns`. Entry point: `react.controllers_path` in `config/packages/react.yaml`.
- **AssetMapper component map**: An asset compiler finds the files in `react.controllers_path` that match `react.name_glob` (default `*.js` and `*.jsx`). It writes them as imports into the `components.js` module of the package. If a component file is outside the AssetMapper paths, the compiler throws a `LogicException`. The `@symfony/ux-react` importmap entry points to `loader.js`, and its `registerReactControllerComponents()` reads this map. Entry point: `Symfony\UX\React\AssetMapper\ReactControllerLoaderAssetCompiler`.
- **Packages that Flex adds**: With AssetMapper, Flex runs `importmap:require` for `@hotwired/stimulus`, `react`, `react-dom/client` and `@symfony/ux-react` (path to `loader.js`). With Encore or Reprise, Flex adds `@symfony/ux-react` (`file:vendor/symfony/ux-react/assets`), `react`, `react-dom` and `@hotwired/stimulus` to `package.json`. Then run `npm install --force`, as the Flex message says. In both cases, Flex enables the `react` controller in `assets/controllers.json`. Entry point: the `symfony` block of `vendor/symfony/ux-react/assets/package.json`.
- **Lifecycle events** (in the source, not in the docs): The controller dispatches `react:connect` (detail `component`, `props`), `react:mount` (detail `componentName`, `component`, `props`) and `react:unmount` (detail `component`, `props`) on the root element. In `react:connect` and `react:unmount`, `component` is the component name; in `react:mount`, it is the resolved component. `react:connect` occurs before the controller resolves the name. `react:mount` occurs immediately after the call to `root.render()`, which is not synchronous, so the rendered markup can be missing from the DOM at that time. The events bubble, so a listener on `document` also receives them. A permanent component sends no `react:unmount` event. Entry point: `document.addEventListener('react:mount', (event) => ...)`.
- **React versions**: The package supports React 18 and React 19 (peer dependencies `^18.0 || ^19.0`). For React 19, update `react` and `react-dom` together to `^19.0`. Entry point: `package.json` or `importmap.php`.

## Entry points

- Twig function: `react_component(componentName, props = {}, options = {})`, with the option `permanent` (bool). PHP: `Symfony\UX\React\Twig\ReactComponentExtension::renderReactComponent()` (private service `twig.extension.react`).
- JavaScript: `registerReactControllerComponents()` from `@symfony/ux-react`. The npm entry (`dist/register_controller.js`) takes an `import.meta.glob()` result or a `require.context()` result. The importmap entry (`dist/loader.js`) needs no argument, because by default it reads the component map that AssetMapper compiles.
- Stimulus controller: `@symfony/ux-react/react` (HTML name `symfony--ux-react--react`), with the values `component`, `props` and `permanent`. Flex enables it in `assets/controllers.json`.
- Browser events: `react:connect`, `react:mount`, `react:unmount` (they bubble).
- Config (only for AssetMapper): `react.controllers_path` (default `%kernel.project_dir%/assets/react/controllers`), `react.name_glob` (default `['*.js', '*.jsx']`).
- Directory: `assets/react/controllers/`.
- Bundle: `Symfony\UX\React\ReactBundle`. Install it with `composer require symfony/ux-react` (Flex recipe 3.4).
- Bundler setup: `@vitejs/plugin-react` (Vite), `@rsbuild/plugin-react` (Rsbuild), `Encore.enableReactPreset()` with `@babel/preset-react` (Webpack Encore).
- Console (AssetMapper without Flex): `php bin/console importmap:require @hotwired/stimulus react react-dom/client`, then `php bin/console importmap:require @symfony/ux-react --path=./vendor/symfony/ux-react/assets/dist/loader.js`. These are the entries of the `symfony.importmap` block in `vendor/symfony/ux-react/assets/package.json`.
- Tests: the package has no test helper.

## Symbiotic packages

- [StimulusBundle](../packages/stimulus-bundle.md): the required dependency; `react_component()` builds its attributes with `StimulusHelper`, and the Stimulus application loads the `react` controller from `assets/controllers.json`.
- [AssetMapper](../packages/asset-mapper.md): the setup without a Node bundler; an asset compiler builds the component map, but JSX needs a separate Babel step first.
- [Symfony Reprise](../packages/reprise.md): the docs say that UX React works best with Reprise (Vite or Rsbuild); register the components with `import.meta.glob()`. Reprise 1.x is stable, but symfony-docs calls it experimental.
- [WebpackEncoreBundle](../packages/webpack-encore-bundle.md): the Encore setup uses `require.context()` (`import.meta.webpackContext()` for ES modules) and `Encore.enableReactPreset()`; the Symfony docs put Encore in low-maintenance mode and recommend Reprise for a new bundler setup.
- [UX Twig Component](../packages/ux-twig-component.md): use it for reusable server-rendered fragments without React; the Symfony docs call Twig components the recommended way to render and reuse small template fragments.
- [UX Live Component](../packages/ux-live-component.md): use it for interactive UI in PHP and Twig only; it re-renders with Ajax and binds inputs to properties, like React or Vue.
- [Symfony UX Vue.js](../packages/ux-vue.md): the same pattern for Vue.js (`vue_component()`, `registerVueControllerComponents()`); choose the package that matches the front-end framework.
- [Symfony UX Turbo](../packages/ux-turbo.md): if Turbo moves a root element (`data-turbo-permanent`), pass `{permanent: true}` so that the React component stays mounted.
- [Symfony Flex](../packages/flex.md): the recipe registers the bundle, copies `assets/react/controllers/Hello.jsx` and adds the registration call for `symfony/reprise`, `symfony/webpack-encore-bundle` or `symfony/asset-mapper` to `assets/app.js`.

## Changed in UX 2.21 to 3.5

- UX 3.4: `registerReactControllerComponents()` accepts an `import.meta.glob(..., { eager: true })` result, for Vite or Rsbuild through Symfony Reprise. The Flex recipe 3.4 writes this call when the project has `symfony/reprise`.
- UX 3.0: The minimum versions are PHP 8.4 and Symfony 7.4. UX 3.0 removes the compatibility layer for the `StimulusTwigExtension` of WebpackEncoreBundle 1.x; use StimulusBundle.
- UX 2.33: The package supports React 19. Update `react` and `react-dom` together to `^19.0`.
- UX 2.28: The render controller imports `react-dom/client`, not `react-dom`. With AssetMapper but without Flex, run `importmap:remove react-dom` and then `importmap:require react-dom/client`.
- UX 2.21: The `permanent` option of `react_component()` keeps the component mounted when its root element disconnects.

## Docs

- https://symfony.com/bundles/ux-react/current/index.html
- https://symfony.com/doc/current/frontend.html
- https://symfony.com/doc/current/frontend/asset_mapper.html
- https://symfony.com/doc/current/frontend/encore/reactjs.html
- https://symfony.com/doc/current/frontend/encore/typescript.html
- https://symfony.com/doc/current/frontend/encore/index.html
- https://symfony.com/doc/current/frontend/encore/installation.html (Encore 7: `"type": "module"` or `webpack.config.mjs`)
- https://symfony.com/bundles/reprise/current/index.html
- https://symfony.com/bundles/StimulusBundle/current/index.html
- https://symfony.com/doc/current/templates.html
- https://symfony.com/bundles/ux-twig-component/current/index.html
- https://symfony.com/bundles/ux-live-component/current/index.html
- https://symfony.com/bundles/ux-vue/current/index.html
- https://github.com/symfony/ux.symfony.com/blob/main/assets/react/build/package.json (the Babel build example that the docs link)
- https://github.com/symfony/webpack-encore/blob/v7.2.0/UPGRADE.md (Encore 7: `require.context()` and ES modules)
- https://webpack.js.org/api/module-variables/ (`import.meta.webpackContext()`)
- https://react.dev/reference/react-dom/client/createRoot (`root.render()` clears the root element and is not synchronous)
- https://ux.symfony.com/react (demo; its "Server rendering" text does not match the source, which renders only in the browser)
