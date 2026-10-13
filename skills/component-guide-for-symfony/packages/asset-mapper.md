# AssetMapper (`symfony/asset-mapper`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when an application must load JavaScript, CSS and npm packages in the browser without Node.js or a build step. It serves the files through a native browser importmap, with content-hashed URLs. If you need a bundler, see [Reprise](reprise.md) for Vite or Rsbuild, or [Webpack Encore](webpack-encore-bundle.md) in an existing Encore project.

**Details:** [../details/asset-mapper.md](../details/asset-mapper.md)

## Why it exists

Modern browsers support JavaScript import statements and importmaps, and HTTP/2 lets them download many small files in parallel. The package uses these features to serve your JavaScript, CSS and npm packages with versioned file names, without a Node.js bundler. The docs recommend it for new projects. For new projects that need a bundler, they propose [Reprise](reprise.md), and they keep [Webpack Encore](webpack-encore-bundle.md) for existing Encore projects.

## When to use it

- Add JavaScript and CSS to a server-rendered application without Node.js, npm or a build step.
- Install an npm package, for example Bootstrap or Chart.js, and import it in your JavaScript.
- Give images, fonts, CSS and JavaScript files cache-busting URLs that change with the file content.
- Load extra JavaScript or CSS on one page only.
- Compile the front-end assets for a production deployment, with pre-compressed files for the web server.
- Check the JavaScript dependencies for security advisories and new versions in CI.
- Add a CSP nonce to the script tags that load your JavaScript.
- Expose the public files of a reusable package to the applications that install it.

## Use it instead of

- `<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js">` or a minified copy in `public/js/` -> `php bin/console importmap:require bootstrap`, then `import { Alert } from 'bootstrap';`
- `<link href="/css/app.css?v={{ 'now'|date('U') }}">` or a `filemtime()` query string -> `{{ asset('styles/app.css') }}`, which returns a URL with a content hash
- A hand-written `<script type="importmap">{"imports": {...}}</script>` block -> `importmap.php` and `{{ importmap('app') }}`
- `webpack.config.js`, `package.json` and `npm run build` for server-rendered Twig pages -> `assets/app.js` as the `app` entrypoint, with no build step
- A controller that returns files from `assets/` with `BinaryFileResponse` or `readfile()` -> the dev server (`framework.asset_mapper.server`), then `asset-map:compile` for production
- One hand-written `<link rel="preload">` or `<link rel="modulepreload">` tag for each module -> `importmap()`, which preloads the import chain of the entrypoints
- `gzip -9 -k` or `brotli` commands over `public/` in a deploy script -> `framework.asset_mapper.precompress` and `asset-map:compile`
- `fetch('/data/users.json').then((response) => response.json())` for a JSON file of the application -> `import usersPromise from './data/users.json';`
- A manual check of the versions and advisories of CDN libraries -> `importmap:outdated` and `importmap:audit` in CI
