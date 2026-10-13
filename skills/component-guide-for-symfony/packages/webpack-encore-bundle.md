# WebpackEncoreBundle (`symfony/webpack-encore-bundle`)

**Applies to:** WebpackEncoreBundle 2.4, Encore 7.2

**Elevator pitch:** Use when a project already builds its JavaScript and CSS with Webpack Encore, and pages must load the built files. It renders the script and link tags of each entry, with hashed names and split chunks. Encore is in low-maintenance mode. For new projects, see [AssetMapper](asset-mapper.md), or [Reprise](reprise.md) for Vite or Rsbuild.

**Details:** [../details/webpack-encore-bundle.md](../details/webpack-encore-bundle.md)

## Why it exists

Webpack Encore is an npm package that builds your JavaScript and CSS files into a public directory. With split chunks, one entry needs several files, and with versioning, each file name contains a hash. Encore lists these files in a JSON file. The package reads this file and renders the matching script and link tags in Twig templates.

## When to use it

- Render the script and link tags of a Webpack Encore entry in a Twig layout.
- Load extra JavaScript or CSS on one page only, with a separate Encore entry.
- Link to images, fonts or copied files with the versioned names from the build manifest.
- Add defer, a CSP nonce, an integrity hash, a crossorigin value or the reload attribute of [UX Turbo](ux-turbo.md) to the Encore tags.
- Send HTTP preload headers for the JavaScript and CSS files of a page.
- Render tags from several Webpack builds, or from an entry list file on a CDN.
- Render the same entry again in a second email or PDF template during one request.
- Use the front-end controllers of the Symfony UX packages in a Webpack Encore project, with [StimulusBundle](stimulus-bundle.md).

## Use it instead of

- `<script src="{{ asset('build/app.js') }}"></script>` or `<script src="/build/app.js"></script>` written by hand, or a Twig loop over `json_decode(file_get_contents('public/build/entrypoints.json'), true)` -> `{{ encore_entry_script_tags('app') }}` and `{{ encore_entry_link_tags('app') }}`.
- `?v={{ 'now'|date('U') }}` or `filemtime()` version query strings -> `Encore.enableVersioning()` with the entry tag functions, and `asset()` with `framework.assets.json_manifest_path` for other files.
- A custom Twig function that reads `public/build/manifest.json` -> `framework.assets.json_manifest_path` and `{{ asset('build/images/logo.png') }}`.
- `str_replace('<script ', '<script nonce="..." ', $html)` on the rendered HTML -> a `RenderAssetTagEvent` listener that calls `$event->setAttribute('nonce', ...)`.
- `$response->headers->set('Link', '</build/app.js>; rel=preload; as=script')` -> `webpack_encore.preload: true` with `symfony/web-link`.
- `integrity="sha384-..."` values copied by hand into templates -> `Encore.enableIntegrityHashes()` and `webpack_encore.crossorigin`.
- `{% if app.environment != 'test' %}` around the tags, or a fake `entrypoints.json` for tests -> `webpack_encore.strict_mode: false` under `when@test`.
- A static array of printed file names against duplicate `<script>` tags -> the built-in duplicate check, with `EntrypointLookupInterface::reset()` between two renders.
- `Application.start()` from `@hotwired/stimulus` plus one `app.register()` call for each controller -> `symfony/stimulus-bundle` with `Encore.enableStimulusBridge()` and `startStimulusApp()`.
