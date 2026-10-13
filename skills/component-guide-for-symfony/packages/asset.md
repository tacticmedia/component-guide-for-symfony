# Asset (`symfony/asset`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when links to images, stylesheets, scripts or uploaded files must work from a subdirectory or a CDN, and browsers must load each changed file. It builds these URLs, with a version, for HTML pages, emails, feeds and command-line output. To build or bundle the JavaScript and CSS files, see [AssetMapper](asset-mapper.md), [Reprise](reprise.md) or [Webpack Encore](webpack-encore-bundle.md).

**Details:** [../details/asset.md](../details/asset.md)

## Why it exists

Hard-coded file URLs break when the application moves to a subdirectory or to a CDN. Browsers also keep old copies of a changed file when its URL stays the same. The package builds each public file URL from one base path or host, and adds a version, for example a deployment number or a content hash from a build tool.

## When to use it

- Link an image, a stylesheet or a script from an HTML template.
- Add a version to the file URLs at each deployment, so that browsers load the new files.
- Use the hashed file names that a front-end build tool writes to a manifest file.
- Serve the static files from one or more CDN hosts.
- Keep the file links correct when the application runs in a subdirectory.
- Give a group of files its own base path, host or version, for example the user avatars.
- Build an absolute file URL for an email, a feed or a command-line script.
- Get a file URL in PHP code, outside a template.

## Use it instead of

- `<img src="/images/logo.png">` or `<link href="/css/app.css" rel="stylesheet">` in a template -> `src="{{ asset('images/logo.png') }}"` and `href="{{ asset('css/app.css') }}"`, which add the subdirectory and the version.
- `'/css/app.css?v=' ~ 'now'|date('U')` in Twig or `'/css/app.css?v='.filemtime($file)` in PHP -> `framework.assets.version` with a new value at each deployment, or `framework.assets.json_manifest_path`.
- `json_decode(file_get_contents($projectDir.'/public/build/manifest.json'), true)['build/app.js']` -> `framework.assets.json_manifest_path` and `asset('build/app.js')`.
- `'https://cdn.example.com/' ~ path` in Twig or `$_ENV['CDN_URL'].'/'.$path` in PHP -> `framework.assets.base_urls`.
- `$request->getBasePath().'/uploads/'.$fileName` in a controller -> `Symfony\Component\Asset\Packages::getUrl('uploads/'.$fileName)`.
- `'http://localhost/images/logo.png'` or `app.request.schemeAndHttpHost ~ '/images/logo.png'` in an email template -> `{{ absolute_url(asset('images/logo.png')) }}`, plus `framework.router.default_uri` for console commands.
- A Twig global `avatars_url` and `avatars_url ~ user.avatar` -> the named package `framework.assets.packages.avatars` and `asset(user.avatar, 'avatars')`.
- A custom Twig function that adds a hash from a file to the URL -> a `VersionStrategyInterface` service in `framework.assets.version_strategy`.
