# Abandoned Symfony UX packages (`symfony/ux-svelte`, `symfony/ux-swup`, `symfony/ux-typed`, `symfony/ux-lazy-image`, `symfony/ux-toggle-password`, `symfony/ux-turbo-mercure`)

**Applies to:** Symfony UX 3.5

**Elevator pitch:** Use when old code or a tutorial needs an abandoned front-end package for Svelte, Swup, Typed.js, lazy images, password toggles or Mercure streams. Symfony UX 3 does not include these packages. The file gives the last version and the replacement of each package. Svelte has no replacement.

**Details:** [../details/ux-abandoned.md](../details/ux-abandoned.md)

## Why it exists

Packagist marks six Symfony UX packages as abandoned and suggests no replacement package. Symfony UX 3.0 does not include them, but code and tutorials for UX 2.x still use them. This file gives the last version of each package and the replacement that a verified source names.

## When to use it

- Replace the UX Swup page transitions with the Swup library and a JavaScript controller from the README.
- Replace the UX Typed text animation with the Typed.js library and a JavaScript controller from the README.
- Replace the UX LazyImage controller with the native lazy-loading attribute of HTML images.
- Keep BlurHash placeholders after you remove UX LazyImage.
- Keep the show and hide button of password fields after you remove UX TogglePassword.
- Replace the abandoned Mercure bridge package with the Mercure support in [UX Turbo](ux-turbo.md).
- Decide what to do with the Svelte components of Twig templates before you upgrade to Symfony UX 3.
- Check if a Symfony UX package is abandoned or unreleased before you add it with Composer.

## Use it instead of

- `composer require symfony/ux-swup` and `<body {{ stimulus_controller('symfony/ux-swup/swup') }}>` -> `php bin/console importmap:require swup @swup/fade-theme @swup/slide-theme @swup/forms-plugin @swup/debug-plugin`, the README controller in `assets/controllers/swup_controller.js`, and `<body {{ stimulus_controller('swup') }}>`
- `<span data-controller="symfony--ux-typed" data-symfony--ux-typed-strings-value="…">` -> `php bin/console importmap:require typed.js`, the README controller in `assets/controllers/typed_controller.js`, and `<span data-controller="typed" data-typed-strings-value="…">`
- `<img src="{{ asset('image/small.png') }}" {{ stimulus_controller('symfony/ux-lazy-image/lazy-image', { src: asset('image/large.png') }) }}>` -> `<img src="{{ asset('image/large.png') }}" loading="lazy">`
- `{{ data_uri_thumbnail('public/image/large.png', 20, 15) }}` and `{{ blur_hash('public/image/large.png') }}` -> your own code with `kornrunner\Blurhash\Blurhash` from `kornrunner/blurhash`. `encode()` takes a two-dimensional array of pixel colors and returns the BlurHash string. For a thumbnail, `decode()` returns the pixels; encode them as an image data URI.
- `$builder->add('password', PasswordType::class, ['toggle' => true])` with `symfony/ux-toggle-password` -> the same option from your own `App\Form\Extension\TogglePasswordTypeExtension` (`extends AbstractTypeExtension`, `getExtendedTypes()` returns `[PasswordType::class]`), copied from the README
- `composer require symfony/ux-turbo-mercure` -> `composer require symfony/mercure-bundle` (UX Turbo contains the Mercure bridge since 2.6.1)
- `<div id="tasks" {{ turbo_stream_listen('App\\Entity\\Task') }}></div>` -> `{{ turbo_stream_from('App\\Entity\\Task') }}` or `<twig:Turbo:Stream:From topics="App\\Entity\\Task" />` (UX Turbo 3.1 and later). The old function returns HTML attributes; the new function returns a `<turbo-mercure-stream-source>` element. MercureBundle 0.6.0 sets `protocol_version` to `1.0` by default, and then this class subscription gets no updates. For a 0.x hub, set `protocol_version: '0.x'`.
