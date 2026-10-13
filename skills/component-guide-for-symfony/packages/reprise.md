# Symfony Reprise (`symfony/reprise`)

**Applies to:** Reprise 1.3

**Elevator pitch:** Use when you build JavaScript, TypeScript, Sass, React or Vue code with Vite or Rsbuild, and server-rendered pages must load the result. It renders the script and link tags of each entry, with hot module replacement in development. It is the successor of [Webpack Encore](webpack-encore-bundle.md). To skip the Node.js build step, see [AssetMapper](asset-mapper.md).

**Details:** [../details/reprise.md](../details/reprise.md)

## Why it exists

Vite and Rsbuild compile, split and hash JavaScript and CSS, but they do not know which files a server-rendered page must load. The npm plugin of the package writes an entry list and a manifest from the bundler output, in build mode and in dev-server mode. The PHP side reads the entry list and renders the script and link tags of each entry in Twig templates.

## When to use it

- Build JavaScript, TypeScript, Sass or CSS with Vite or Rsbuild for a PHP application.
- Render the script and stylesheet tags of a bundler entry in a Twig layout.
- Use hot module replacement from the Vite or Rsbuild dev server on pages that PHP renders.
- Move a [Webpack Encore](webpack-encore-bundle.md) project to Vite or Rsbuild, with a one-to-one change of the template functions.
- Load the JavaScript controllers of the Symfony UX packages and your own controllers in a Vite or Rsbuild build, with [StimulusBundle](stimulus-bundle.md).
- Serve the built files from a CDN, with Subresource Integrity hashes on the tags.
- Add a CSP nonce or the reload attribute of [UX Turbo](ux-turbo.md) to each rendered asset tag.
- Build a second JavaScript bundle, for example an embeddable widget, with its own bundler configuration and output directory.

## Use it instead of

- Hard-coded `<script src="/build/app.js">` tags, or a Twig lookup of the hashed name in `manifest.json` -> `reprise_entry_script_tags('app')` and `reprise_entry_link_tags('app')`.
- `json_decode(file_get_contents('public/build/entrypoints.json'), true)` in a custom Twig extension -> `reprise_entry_js_files('app')`, `reprise_entry_css_files('app')` and `reprise_entry_exists('app')`.
- `{% if app.environment == 'dev' %}<script type="module" src="http://localhost:5173/@vite/client"></script>{% endif %}` -> `reprise_entry_script_tags()`, which reads the dev `entrypoints.json` that `npx vite` writes.
- A copy of the React Fast Refresh preamble (`window.$RefreshReg$ = ...`) in `base.html.twig` -> the preamble that `reprise_entry_script_tags()` adds when the Vite config uses `@vitejs/plugin-react`.
- `import.meta.glob('./controllers/*_controller.js')` plus one `app.register()` call for each controller -> plugin option `stimulus` and `startStimulusApp()` from `@symfony/reprise/stimulus`.
- `str_replace('<script ', '<script nonce="..." ', $html)` on the rendered tags -> a `RenderAssetTagEvent` listener, or the `attributes` argument of `reprise_entry_script_tags()`.
- `openssl dgst -sha384 -binary app.js | openssl base64 -A` to write `integrity="..."` by hand -> plugin option `integrity: { enabled: true }`.
- `cp -r assets/images public/build/images` in an npm script, with hard-coded image paths -> plugin option `copy`, `framework.assets.json_manifest_path` and `asset()`.
- `$response->headers->set('Link', '</build/app.js>; rel=preload; as=script')` -> `reprise.preload` with `symfony/web-link`.
