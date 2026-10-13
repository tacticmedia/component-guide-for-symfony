# WebpackEncoreBundle (`symfony/webpack-encore-bundle`): details

**Applies to:** WebpackEncoreBundle 2.4, Encore 7.2

## Key features and concepts

- **Entry tags**: `encore_entry_script_tags()` renders one `<script>` tag for each JavaScript file of the entry. `encore_entry_link_tags()` renders one `<link rel="stylesheet">` tag for each CSS file. Both read `entrypoints.json` in `output_path`, so `splitEntryChunks()` and `enableSingleRuntimeChunk()` need no template change. The entry name is the first argument of `Encore.addEntry()`. Entry point: `{{ encore_entry_script_tags('app') }}`.
- **File lists and entry check**: `encore_entry_js_files()` and `encore_entry_css_files()` return the file paths of an entry as an array. Use them to build the tags yourself. `encore_entry_exists()` returns `true` if `entrypoints.json` contains the entry. Entry point: `{% if encore_entry_exists('admin') %}`.
- **No duplicate files in a request**: the lookup of each build returns a file only once per request, also across entries. The file-list functions and the tag functions share this state. If you render two templates in one request, call `reset()` before each render. The bundle resets the state after the main request and on each `kernel.exception` event. Entry point: `EntrypointLookupInterface::reset()`.
- **URLs through the Asset component**: the tag functions give each path from `entrypoints.json` to `Packages::getUrl()`. The second Twig argument is the name of an asset package; `null` selects the default package. The paths in `entrypoints.json` already contain the public path or CDN URL, and the hash if versioning is on. By default, the local paths in `entrypoints.json` start with `/`, and the keys in `manifest.json` do not. Thus, if the asset package has `json_manifest_path` and `strict_mode: true`, the tag functions throw `AssetNotFoundException`. Entry point: `framework.assets.packages`.
- **Versioned names from `manifest.json`**: `manifest.json` maps keys like `build/images/logo.png` to the versioned path. Set `framework.assets.json_manifest_path` to this file, then use `asset()` for images, fonts and files from `Encore.copyFiles()`. The Flex recipe sets this key in `config/packages/webpack_encore.yaml`. Entry point: `{{ asset('build/images/logo.png') }}`.
- **Tag attributes**: `script_attributes` and `link_attributes` add attributes to all tags, and the recipe sets `defer: true`. If an inline script in a template uses a global variable from the entry, set `script_attributes.defer` to `false`. The fourth Twig argument `attributes` adds or replaces attributes for one call. The value `true` renders only the attribute name, and `false` removes the attribute. Entry point: `{{ encore_entry_script_tags('app', attributes={defer: false}) }}`.
- **Tag event**: the bundle dispatches `RenderAssetTagEvent` for each tag. A listener can read the URL and change the attributes, for example to add a CSP `nonce`. Entry point: `Symfony\WebpackEncoreBundle\Event\RenderAssetTagEvent` (`isScriptTag()`, `getUrl()`, `setAttribute()`, `removeAttribute()`).
- **Subresource integrity**: if `Encore.enableIntegrityHashes()` is on, `entrypoints.json` contains an `integrity` map, and each tag gets an `integrity` attribute. To add the `crossorigin` attribute, set `webpack_encore.crossorigin` to `anonymous` or `use-credentials` (default `false`). Entry point: `webpack_encore.crossorigin`.
- **Preload headers**: with `webpack_encore.preload: true`, the bundle adds a `Link` header with `rel="preload"` and `as="script"` or `as="style"` for each rendered tag. This option needs `symfony/web-link`. Without it, the container build stops with a `\LogicException`. Entry point: `webpack_encore.preload`.
- **Multiple builds**: `webpack_encore.builds` maps a build name to the directory of its `entrypoints.json`. Give the build name as the third Twig argument. If `builds` is set, `output_path: false` disables the default build. Entry point: `{{ encore_entry_script_tags('app', null, 'firstConfig') }}`.
- **Remote `entrypoints.json`**: if a build path starts with `http`, the bundle downloads `<path>/entrypoints.json` with the HttpClient component. Use this when a CDN or another server holds the build. Entry point: `webpack_encore.builds` (for example `frontend: 'https://cdn.example.com/frontend/build'`).
- **Strict mode**: `strict_mode` is `true` by default. Then a missing `entrypoints.json` file or an unknown entry name causes an exception. If tests run without built assets, set `strict_mode: false` under `when@test`. The functions then render nothing. Entry point: `webpack_encore.strict_mode`.
- **Entrypoints cache**: with `cache: true` (the recipe suggests it under `when@prod`), the lookups read the data of each `entrypoints.json` from `%kernel.build_dir%/webpack_encore.cache.php`. The cache warmer writes this file. If `entrypoints.json` changes, rebuild the Symfony cache. Entry point: `webpack_encore.cache`.
- **Stimulus and Symfony UX**: this bundle has no `stimulus_*` Twig functions; install `symfony/stimulus-bundle`. Its recipe adds `.enableStimulusBridge('./assets/controllers.json')` and creates `assets/stimulus_bootstrap.js`, which calls `startStimulusApp()` from `@symfony/stimulus-bridge`. Install that npm package with `npm install --save-dev @symfony/stimulus-bridge`. A controller with the comment `/* stimulusFetch: 'lazy' */` goes into a separate file. The browser downloads this file only when a matching element is on the page. After you install a UX package, run `npm install --force`. Then restart Encore. Entry point: `Encore.enableStimulusBridge()`.
- **The npm package**: `@symfony/webpack-encore` (https://github.com/symfony/webpack-encore) is the Node.js side, configured in `webpack.config.js`. Since Encore 7.0, this file is an ES module that ends with `export default await Encore.getWebpackConfig();`. With `npm run dev-server`, the Twig functions point to the dev server with no template change. Entry point: `webpack.config.js`.

## Entry points

- Install: `composer require symfony/webpack-encore-bundle`, then `npm install`. The Flex recipe creates `config/packages/webpack_encore.yaml`, `webpack.config.js`, `package.json`, `assets/app.js` and `assets/styles/app.css`. It also adds the two tag functions to `templates/base.html.twig`.
- Switch a new `symfony new --webapp` project from AssetMapper: `composer remove symfony/ux-turbo symfony/asset-mapper symfony/stimulus-bundle`, then `composer require symfony/webpack-encore-bundle symfony/ux-turbo symfony/stimulus-bundle`, `npm install` and `npm run dev`.
- Twig functions: `encore_entry_script_tags(entryName, packageName = null, entrypointName = '_default', attributes = [])` and `encore_entry_link_tags(entryName, packageName = null, entrypointName = '_default', attributes = [])`.
- Twig functions: `encore_entry_js_files(entryName, entrypointName = '_default')`, `encore_entry_css_files(entryName, entrypointName = '_default')` and `encore_entry_exists(entryName, entrypointName = '_default')`.
- Config `webpack_encore`: `output_path` (required; a directory, or `false` if `builds` is set), `builds`, `script_attributes` and `link_attributes`.
- Config `webpack_encore`: `crossorigin` (`false`, `anonymous` or `use-credentials`), `preload` (default `false`), `cache` (default `false`) and `strict_mode` (default `true`).
- Config `framework.assets.json_manifest_path`, and `framework.assets.packages.<name>.json_manifest_path` for each extra build.
- Services: autowire `Symfony\WebpackEncoreBundle\Asset\EntrypointLookupInterface` (default build) or `Symfony\WebpackEncoreBundle\Asset\EntrypointLookupCollectionInterface` (`getEntrypointLookup('<build>')`). The service ID of a build is `webpack_encore.entrypoint_lookup[<build>]`.
- Event: `Symfony\WebpackEncoreBundle\Event\RenderAssetTagEvent`.
- Exceptions: `Symfony\WebpackEncoreBundle\Exception\EntrypointNotFoundException` (unknown entry) and `Symfony\WebpackEncoreBundle\Exception\UndefinedBuildException` (unknown build).
- npm: `@symfony/webpack-encore` in `webpack.config.js` (`Encore.setOutputPath()`, `setPublicPath()`, `addEntry()`, `splitEntryChunks()`, `enableVersioning()`, `enableIntegrityHashes()`, `enableStimulusBridge()`, `getWebpackConfig()`).
- npm scripts of the recipe: `npm run dev`, `npm run watch`, `npm run dev-server` and `npm run build` (`encore production --progress`).
- Symfony CLI: `symfony run -d npx encore dev --watch`, or a worker in `.symfony.local.yaml` with `cmd: ['npm', 'run', 'watch']`. The Symfony CLI ignores the `npm_encore_watch: ~` worker that the docs show. The built-in `yarn_encore_watch: ~` worker runs `yarn encore dev --watch`.

## Symbiotic packages

- [AssetMapper](../packages/asset-mapper.md): the docs recommend AssetMapper for new projects, Reprise for new projects that need a bundler, and Encore for projects that use it already.
- [Symfony Reprise](../packages/reprise.md): the successor of Encore for Vite and Rsbuild; it writes another `entrypoints.json` format (key `entryPoints`), which only its own `RepriseBundle` and `reprise_entry_*` functions read. Reprise 1.x is stable (1.0.0, 2026-08-26). The Symfony docs call it experimental.
- [Asset](../packages/asset.md): the tag functions give each path to `Packages::getUrl()`, and `framework.assets.json_manifest_path` reads `manifest.json` for `asset()`.
- [StimulusBundle](../packages/stimulus-bundle.md): gives the `stimulus_*` Twig functions, and its recipe adds `enableStimulusBridge()` and `assets/stimulus_bootstrap.js` for Encore.
- [Symfony UX Turbo](../packages/ux-turbo.md): add `'data-turbo-track': reload` to `script_attributes` and `link_attributes`, so that Turbo Drive reloads the page when a versioned file changes.
- [Symfony UX React](../packages/ux-react.md): the recipe adds `.enableReactPreset()` to `webpack.config.js`; install the Babel preset with `npm install -D @babel/preset-react --force`.
- [Symfony UX Vue.js](../packages/ux-vue.md): the recipe adds `.enableVueLoader()` to `webpack.config.js`; `.vue` single-file components need a bundler such as Encore.
- [WebLink](../packages/web-link.md): `webpack_encore.preload: true` needs this package to send the `Link` preload headers.
- [HttpClient](../packages/http-client.md): downloads `entrypoints.json` when a build path is an `http` URL.
- [Symfony Flex](../packages/flex.md): the recipe writes the Encore files, and Flex adds the `file:vendor/...` npm package of each UX bundle to `package.json`.
- [Dotenv](../packages/dotenv.md): Encore runs in Node.js and does not read `.env` files; give a value to JavaScript with `configureDefinePlugin()` at build time.

## Changed in 2.0 to 2.4 and Encore 7.0

- 2.0: `stimulus_controller()`, `stimulus_action()` and `stimulus_target()` are removed from this bundle (deprecated in 1.17). Install `symfony/stimulus-bundle` to get them.
- 2.2: a `builds` path can be a URL. The bundle then downloads `entrypoints.json` with HttpClient.
- 2.3: Symfony 8 is supported. Symfony 8 has no XML configuration and no fluent PHP config builders. Write the config in YAML or as a PHP array, for example `App::config([...])`. Do not write `webpack_encore.xml` or `$webpackEncore->cache(true)`.
- Encore 7.0: `webpack.config.js` is ESM only. Use `import Encore from '@symfony/webpack-encore'` and `export default await Encore.getWebpackConfig();`, not `require()` and `module.exports`. Add `"type": "module"` to `package.json`, or name the file `webpack.config.mjs`.
- Encore 7.0: with `"type": "module"`, relative imports need the file extension (`import greet from './greet.js'`). In `webpack.config.js`, use `import.meta.dirname` instead of `__dirname`.
- Encore 7.0: in `assets/stimulus_bootstrap.js` (before: `assets/bootstrap.js`), replace `require.context()` with `import.meta.webpackContext(path, { recursive: true, regExp: /\.[jt]sx?$/ })`.
- Encore 7.0: `configureTerserPlugin()` is removed; use `configureJsMinimizerPlugin()`. CSS is not minified by default. To minify CSS, select a minifier with `configureCssMinimizerPlugin()`.
- Encore 7.0: Babel 8 is required, and the `useBuiltIns` and `corejs` options are removed. For polyfills, use `babel-plugin-polyfill-corejs3`; the recipe adds it with `configureBabel()`.

## Status

- Webpack Encore is in low-maintenance mode: bug fixes, security patches and `peerDependencies` updates only. If a project needs a bundler, the bundle README and symfony-docs recommend a migration to Reprise.
- The build needs Node.js. Encore 7 requires Node.js `^22.18.0 || ^24.11.0 || >=26.0`. The production server needs only the built files in `public/build/`.

## Docs

- https://symfony.com/bundles/WebpackEncoreBundle/current/index.html
- https://symfony.com/doc/current/frontend.html
- https://symfony.com/doc/current/frontend/encore/index.html
- https://symfony.com/doc/current/frontend/encore/installation.html
- https://symfony.com/doc/current/frontend/encore/simple-example.html
- https://symfony.com/doc/current/frontend/encore/versioning.html
- https://symfony.com/doc/current/frontend/encore/split-chunks.html
- https://symfony.com/doc/current/frontend/encore/copy-files.html
- https://symfony.com/doc/current/frontend/encore/advanced-config.html
- https://symfony.com/doc/current/frontend/encore/cdn.html
- https://symfony.com/doc/current/frontend/encore/dev-server.html
- https://symfony.com/doc/current/frontend/encore/minification.html
- https://symfony.com/doc/current/frontend/encore/faq.html
- https://symfony.com/doc/current/frontend/asset_mapper.html
- https://symfony.com/doc/current/reference/configuration/framework.html
- https://symfony.com/bundles/StimulusBundle/current/index.html
- https://symfony.com/bundles/ux-turbo/current/webpack-encore.html
- https://symfony.com/bundles/reprise/current/index.html
- https://github.com/symfony/webpack-encore
