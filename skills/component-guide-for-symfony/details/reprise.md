# Symfony Reprise (`symfony/reprise`): details

**Applies to:** Reprise 1.3

## Key features and concepts

- **Twig functions**: `reprise_entry_link_tags()` renders a `<link rel="stylesheet">` tag for each CSS file of the entry. `reprise_entry_script_tags()` renders `<link rel="modulepreload">` tags for the chunks that the entry imports statically (Vite build only), then `<script type="module">` tags. `reprise_entry_js_files()` and `reprise_entry_css_files()` return the URLs without HTML. `reprise_entry_exists()` returns `true` or `false`. Entry point: `{{ reprise_entry_script_tags('app') }}`.
- **Bundler plugins**: the default exports of `@symfony/reprise/vite` and `@symfony/reprise/rsbuild` create the plugin from one options object. Give each entry a name in Vite `input` (Vite 8.1 and older: `build.rollupOptions.input`) or in Rsbuild `source.entry`. Entry point: `import Symfony from '@symfony/reprise/vite'`.
- **Generated files**: the plugin writes `entrypoints.json` (the files of each entry) and `manifest.json` (logical name to hashed URL) into `outputPath`, default `public/build`. To keep the two files out of the public directory, set `metadataPath`. Then set `reprise.output_path` to the same directory. The `entrypoints.json` format is not the Encore format (top-level key `entryPoints`, not `entrypoints`), so only `RepriseBundle` reads it. Entry point: `reprise.output_path`.
- **URL resolution**: the bundle sends each file reference through `Packages::getUrl()`, so the `base_path` and `base_urls` of the asset package apply. Absolute URLs (dev server, CDN) stay unchanged. A version strategy on the default package (`version`, `version_strategy`, or `json_manifest_path` with `strict_mode: true`) changes or rejects the entry URLs. In that case, set `reprise.asset_package` to a package with `version: ~`. Do not use `version: false` from the Reprise docs, because FrameworkBundle 8.1 then adds a trailing `?` to each URL. Entry point: `reprise.asset_package`.
- **Dev server and HMR**: when `npx vite` listens, the plugin writes a dev `entrypoints.json` that points at the dev server. Then `reprise_entry_script_tags()` adds the `@vite/client` script once per page for each build. If the Vite config uses `@vitejs/plugin-react`, the function also adds the React Fast Refresh preamble. Under `npx rsbuild dev`, Rsbuild compiles the HMR client into the bundle. Reprise supports the standalone Vite dev server, not middleware mode. Entry point: `npx vite` or `npx rsbuild dev`.
- **Dev server behind a proxy**: if the browser uses another address for the dev server (proxy, Docker, local domain), set `devServerOrigin` to it. The proxy must also forward WebSocket connections, or HMR stops. Entry point: plugin option `devServerOrigin`.
- **Stimulus controllers**: set the `stimulus` option to `assets/controllers.json`. Then call `startStimulusApp()` in the entry. The app registers the controllers of `controllers.json` and each local `*_controller.js` (also `.jsx`, `.ts` and `.tsx`) file. A `stimulusFetch: 'lazy'` comment makes the app load a controller on demand. Install `@hotwired/stimulus` with npm. Reprise resolves the UX controllers of `controllers.json` from `node_modules`. After Flex adds a UX package to `package.json`, run `npm install --force`. Entry point: `startStimulusApp()` from `@symfony/reprise/stimulus`.
- **Style entries**: an entry that points at a `.css`, `.scss`, `.sass`, `.less`, `.styl`, `.stylus`, `.postcss` or `.pcss` file builds to CSS only. No empty `<script>` tag appears on the page. Entry point: a stylesheet in Vite `input` or in Rsbuild `source.entry`.
- **File copy**: the `copy` option copies static files into the build and adds them to `manifest.json`. In build mode, each file name gets a content hash, unless the entry sets `hash: false`. Set `framework.assets.json_manifest_path` to that file, so that `asset('build/images/logo.svg')` returns the hashed URL. Entry point: plugin option `copy: [{ from, to, pattern, includeSubdirectories, hash }]`.
- **CDN**: for the production build, set `publicPath` to the absolute CDN URL. With an absolute `publicPath`, `manifestKeyPrefix` is necessary. The tags and the `manifest.json` values then contain CDN URLs. Entry point: plugin options `publicPath` and `manifestKeyPrefix`.
- **Subresource Integrity**: `integrity: { enabled: true }` adds a hash for each file to `entrypoints.json`, in build mode only. The default algorithm is `sha384`, and the option also accepts `sha256` and `sha512`. The bundle then renders `integrity` and `crossorigin` (`anonymous`, or the value of `reprise.crossorigin`). Entry point: plugin option `integrity`.
- **Tag attributes and events**: `reprise.script_attributes` and `reprise.link_attributes` add attributes to each tag, and the `attributes` argument overrides them for one call. A `false` value removes an attribute, and `true` renders the attribute without a value. Before the bundle writes a tag, it dispatches `RenderAssetTagEvent`, so a listener can change `$event->attributes`. Entry point: `Symfony\Reprise\Event\RenderAssetTagEvent`.
- **Preload headers**: if the application has `symfony/web-link`, the bundle also adds each rendered file to the HTTP `Link:` response header as `preload` or `modulepreload`. The header copies the `integrity`, `crossorigin` and `nonce` values of the tag. Entry point: `reprise.preload` (default `true`).
- **Multiple builds**: under `reprise.builds`, map each extra build name to its output directory. Then pass `build='widget'` to a `reprise_entry_*` function. Each build has its own bundler config and its own dev server. A build can also have its own Stimulus controllers through its own `stimulus` option. If you set `metadataPath`, give each build its own directory, because each write replaces both JSON files. If only named builds exist, set `reprise.output_path: false`. Entry point: `reprise.builds`.
- **Strict mode, cache and request state**: if `reprise.strict_mode` is `true` (default), a missing `entrypoints.json` or entry causes an exception. If it is `false`, the functions render nothing. `reprise.cache: true` keeps the parsed file in a PHP file that `cache:warmup` creates, and it needs `symfony/cache`. If the cache is on, clear the Symfony cache after each asset build. The Flex recipe sets `strict_mode: false` and `cache: true` for `prod`. A file that several entries share renders only once per request, and this state resets after each main request. Entry point: `reprise.strict_mode` and `reprise.cache`.

## Entry points

- Installation: `composer require symfony/reprise` and `npm install @symfony/reprise --save-dev`. Also install the bundler: `npm install --save-dev vite` or `npm install --save-dev @rsbuild/core`. The Flex recipe registers `Symfony\Reprise\RepriseBundle` and adds the two tag functions to `templates/base.html.twig`. It also adds a `vite` worker (`npx vite`) to `.symfony.local.yaml` and sets `framework.assets.json_manifest_path` in `config/packages/reprise.yaml`.
- Bundler plugins: `import Symfony from '@symfony/reprise/vite'` and `import Symfony from '@symfony/reprise/rsbuild'`. The `Options` type comes from `@symfony/reprise/types`.
- Plugin options: `outputPath` (default `public/build`), `metadataPath`, `publicPath` (default `/build/`), `manifestKeyPrefix`, `devServerOrigin`, `stimulus` (path, or `{ controllersJson, controllersDir }`), `integrity` (`{ enabled, algorithms }`), `copy`.
- Stimulus: `startStimulusApp()` from `@symfony/reprise/stimulus`. It returns the Stimulus `Application`, so you can call `app.register()` for more controllers.
- Twig functions: `reprise_entry_script_tags(entryName, packageName = null, build = null, attributes = {})`, `reprise_entry_link_tags(entryName, packageName = null, build = null, attributes = {})`, `reprise_entry_js_files(entryName, packageName = null, build = null)`, `reprise_entry_css_files(entryName, packageName = null, build = null)`, `reprise_entry_exists(entryName, build = null)`. The second argument of `reprise_entry_js_files()` and `reprise_entry_css_files()` is the asset package, not the build as in `encore_entry_js_files()`. To select a build, use the named argument: `reprise_entry_js_files('widget', build='widget')`.
- Config keys: `reprise.output_path`, `reprise.builds`, `reprise.strict_mode`, `reprise.cache`, `reprise.preload`, `reprise.asset_package`, `reprise.crossorigin`, `reprise.script_attributes`, `reprise.link_attributes`. Related key: `framework.assets.json_manifest_path` for `asset()`.
- Event: `Symfony\Reprise\Event\RenderAssetTagEvent` with `TYPE_SCRIPT`, `TYPE_LINK`, `TYPE_MODULEPRELOAD`, `isScript()`, `isLink()`, `isModulepreload()` and the public `$attributes` array.
- Services to autowire: `Symfony\Reprise\Asset\EntrypointsLookupCollectionInterface` (`getEntrypointsLookup(?string $build = null)`) and `Symfony\Reprise\Asset\EntrypointsLookupInterface` (default build only). A lookup returns each file only once per request.
- Exceptions: `Symfony\Reprise\Exception\EntrypointsFileNotFoundException`, `EntrypointNotFoundException`, `InvalidEntrypointsException` and `UndefinedBuildException`, all with `ExceptionInterface`.
- Service IDs: `reprise.tag_renderer`, `reprise.entrypoints_lookup` (default build), `reprise.entrypoints_lookup.<name>`, `reprise.entrypoints_lookup_collection`, `reprise.cache` (only with `cache: true`).
- Commands: the bundle has no console command. Build with `npx vite build` or `npx rsbuild build`. Start the dev server with `npx vite` or `npx rsbuild dev`. `bin/console cache:warmup` fills `reprise.cache`.
- Test helpers: none.

## Symbiotic packages

- [AssetMapper](../packages/asset-mapper.md): symfony-docs recommend AssetMapper for new projects (no Node.js, no build step); if a project needs Vite or Rsbuild, use Reprise.
- [WebpackEncoreBundle](../packages/webpack-encore-bundle.md): keep it only for an existing Webpack build, because Encore is in low-maintenance mode. If you migrate, replace it with Reprise: `encore_entry_*` becomes `reprise_entry_*`, and `webpack_encore.output_path` becomes `reprise.output_path`.
- [Asset](../packages/asset.md): Reprise resolves each entry URL through `Packages::getUrl()`, and `framework.assets.json_manifest_path` lets `asset()` read the Reprise `manifest.json`.
- [StimulusBundle](../packages/stimulus-bundle.md): it supplies the Stimulus Twig helpers, and with Reprise its Flex recipe writes `startStimulusApp()` from `@symfony/reprise/stimulus` into `assets/stimulus_bootstrap.js`.
- [Symfony UX Turbo](../packages/ux-turbo.md): set `data-turbo-track: reload` in `reprise.script_attributes` and `reprise.link_attributes`, so that Turbo reloads the page after a new build.
- [Symfony UX React](../packages/ux-react.md): its docs say that it works best with Reprise, and with the Vite dev server, Reprise renders the Fast Refresh preamble for `@vitejs/plugin-react`.
- [Symfony UX Vue.js](../packages/ux-vue.md): its docs say that it works best with Reprise, with `registerVueControllerComponents(import.meta.glob(...))` and the Vue plugin of the bundler.
- [WebLink](../packages/web-link.md): when the application has WebLink, Reprise adds each rendered file to the HTTP `Link:` header (`reprise.preload`).
- [Cache](../packages/cache.md): `reprise.cache: true` needs it, because a `PhpArrayAdapter` file that `cache:warmup` creates holds the parsed `entrypoints.json`.
- [TwigBundle](../packages/twig-bundle.md): it registers the `reprise_entry_*` functions through the `twig.extension` and `twig.runtime` tags.
- [FrameworkBundle](../packages/framework-bundle.md): it supplies the `assets.packages` service and the `framework.assets` configuration that Reprise uses to build URLs.
- [EventDispatcher](../packages/event-dispatcher.md): it dispatches `RenderAssetTagEvent` for each tag, and you register a listener with `#[AsEventListener]`.

## Changed in 0.5 to 1.3

- 1.3.0: `RenderAssetTagEvent` also fires for `<link rel="modulepreload">` tags (`TYPE_MODULEPRELOAD`, `isModulepreload()`), and `isScript()` and `isLink()` return `false` for them. If a CSP listener uses separate script and style nonces, give these tags the script nonce.
- 1.3.0: a `nonce` in `attributes` or `script_attributes` also goes to the modulepreload tags and to their `Link:` header.
- 1.3.0: local Stimulus controllers can be `.jsx` or `.tsx` files. In dev, the page reloads when you add or remove a local controller or its lazy comment, or when `controllers.json` changes.
- 1.2.0: the new plugin option `metadataPath` writes the two JSON files outside `outputPath`.
- 1.1.3: an entry that points at a stylesheet builds to CSS only, with no `<script>` tag.
- 1.1.0: dev mode reads the top-level Vite `input` option of Vite 8.2. On Vite 8.1 and older, use `build.rollupOptions.input`.
- 1.0.0 (2026-08-26): the first stable release, with the Symfony Backward Compatibility promise.
- 0.5.0 to 0.8.0: Vite 7 and Rsbuild 1.7 became the minimum (0.5.0). The React Fast Refresh preamble also arrived in 0.5.0: the CHANGELOG lists it under 0.4.0, but Reprise has no 0.4.0 release. Per-call `attributes`, `reprise_entry_exists()` and `reprise.builds` arrived in 0.6.0, `RenderAssetTagEvent` in 0.7.0, and `copy` with `hash: false` in 0.8.0.

## Status

- Reprise 1.x is stable (1.0.0, 2026-08-26). The Symfony docs call it experimental. The Reprise CHANGELOG calls 1.0.0 a "Stable release", and the Reprise docs say that the bundle aims to follow the Symfony Backward Compatibility promise. The README, the bundle docs and the source contain no "experimental" marker.
- The symfony-docs page `frontend.rst` shows the warning "Symfony Reprise is **experimental**" and the table rows "Production Ready? no" and "Stable? no". The StimulusBundle docs also say "(experimental)". Both texts are out of date.
- Requirements: PHP 8.4 or higher, Symfony 7.4 or 8.x, and Node.js `^22.18.0 || ^24.11.0 || >=26.0`. The bundler is Vite 7 or 8, or Rsbuild 1.7 or 2. If the application runs PHP 8.2 or 8.3, Composer cannot install Reprise.

## Docs

- https://symfony.com/bundles/reprise/current/index.html
- https://symfony.com/doc/current/frontend.html
- https://symfony.com/bundles/StimulusBundle/current/index.html
- https://symfony.com/bundles/ux-turbo/current/reprise.html
- https://symfony.com/doc/current/frontend/encore/index.html
