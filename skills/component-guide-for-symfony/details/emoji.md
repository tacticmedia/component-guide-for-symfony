# Emoji (`symfony/emoji`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- Emoji names: `create('en')` returns a transliterator that replaces each emoji with its CLDR name, for example 🍕 with `pizza`. Some text symbols with an emoji form also get a name, for example ™ gives `trade mark`. The ID is a locale such as `fr`, `uk` or `en_gb`. The `emoji-` prefix is optional, and the ID is not case-sensitive. An ID without a data file causes an `\IntlException`. `EmojiTransliterator::create()`, `transliterate()`
- Locale coverage: 118 of the 164 locale data files have at least 3,900 names, but 17 have fewer than 1,000 (`ceb` has 1). The transliterator keeps an emoji that has no name in the data file.
- Variation selector U+FE0F: the locale data files and `emoji-github` have no keys with this invisible character. Thus, U+FE0F stays in the output. A zero-width joiner (ZWJ) sequence with U+FE0F in the middle gives the names of its parts: 🏳️‍🌈 gives `white flag` and `rainbow`. For these IDs, remove U+FE0F first: `str_replace("\u{FE0F}", '', $text)`. Do not remove it for `emoji-gitlab` or `emoji-slack`, because their keys contain U+FE0F.
- Short codes of one service: `emoji-github`, `emoji-gitlab` and `emoji-slack` replace emojis with short codes. `github-emoji`, `gitlab-emoji` and `slack-emoji` replace short codes with emojis. The codes differ: 👍 is `:thumbsup:` on GitHub and GitLab, but `:+1:` on Slack.
- Universal short codes: `text-emoji` reads the codes of all three services, and `emoji-text` writes one code for each emoji. This catalog uses a dash in place of each underscore: it reads `:kiwi-fruit:` but not the GitHub code `:kiwi_fruit:`. If the short codes contain underscores, use the ID of the service, for example `slack-emoji`.
- Reverse direction: `create($id, EmojiTransliterator::REVERSE)` and `createInverse()` work only for the GitHub, GitLab, Slack and text IDs. For a locale ID such as `en`, they cause an `\IntlException`.
- Emoji removal: the special `strip` ID removes each of the 5,223 emoji sequences in its data file, also sequences with skin tones and ZWJ sequences. It also removes text symbols with an emoji form, such as ©, ®, ™, ♥ and ↔. `EmojiTransliterator::create('strip')`
- Twig filter: `emojify` replaces short codes with emojis in a template. Its default catalog is `text`, which does not read codes with underscores, such as `:heart_eyes:`. The `github`, `gitlab` and `slack` catalogs select one service. A locale such as `en` is not a catalog and causes a `LogicException`. With the `github` catalog, `:+1:` stays unchanged, so use `:thumbsup:`. `{{ comment|emojify('slack') }}`
- Twig registration: if `symfony/emoji` and the `intl` extension are available, TwigBundle registers the filter as the `twig.extension.emoji` service. If the package is missing, the Twig error for `emojify` tells you to run `composer require symfony/emoji`. `Symfony\Bridge\Twig\Extension\EmojiExtension`
- Emoji slugs: `withEmoji()` returns a new slugger that writes the emoji names of the slug locale into the slug. `withEmoji('github')` or `withEmoji('fr')` selects one data file. If no data file exists for a regional locale, the slugger uses the parent locale (`de_AT` uses `de`). `AsciiSlugger::withEmoji()`
- Slug locale: if the slugger has no locale and `slug()` gets no locale, `withEmoji()` without an argument converts no emojis. `withEmoji()` is a method of `AsciiSlugger`, not of `SluggerInterface`. The framework `slugger` service is an `AsciiSlugger` with the request locale.
- `\Transliterator` compatibility: `EmojiTransliterator` is a `final` subclass of `\Transliterator`. Thus, `UnicodeString::ascii()` accepts it in its list of rules. `transliterate()` also accepts `$start` and `$end` offsets in UTF-16 code units.
- Data compression: the `compress` script compresses the data files (about 37 MB) with gzip. It keeps a `.php.gz` file only when this file is smaller than the `.php` file. In a test run, the data files took about 5 MB after compression. `create()` and `listIDs()` read both formats, but `.php.gz` files need the `zlib` extension. `Resources/bin/compress`
- Available IDs: `EmojiTransliterator::listIDs()` returns the IDs of all 174 data files: 164 locales, `emoji-strip`, `emoji-root` and the eight short-code files. `emoji-root` gives CLDR internal IDs such as `E10-282`, not names.
- Data source: the build configuration uses Unicode CLDR `release-48` and the emoji lists of GitHub, GitLab and Slack. The Composer package does not contain the build script.

## Entry points

- `Symfony\Component\Emoji\EmojiTransliterator::create(string $id, int $direction = self::FORWARD)`: create a transliterator. No service exists for this class, so call the static method.
- Without FrameworkBundle: `EmojiTransliterator::create()`. For slugs, `(new AsciiSlugger('en'))->withEmoji()`.
- `EmojiTransliterator::transliterate(string $string, int $start = 0, int $end = -1)`, `createInverse()` and `EmojiTransliterator::listIDs()`.
- IDs for `create()`: a locale (`en`, `fr`, `en_gb`, ...), `strip`, `emoji-github`, `github-emoji`, `emoji-gitlab`, `gitlab-emoji`, `emoji-slack`, `slack-emoji`, `emoji-text` and `text-emoji`.
- Twig filter `emojify`: `{{ text|emojify }}` or `{{ text|emojify('github') }}`. The class is `Symfony\Bridge\Twig\Extension\EmojiExtension`, and the service ID is `twig.extension.emoji`.
- `Symfony\Component\String\Slugger\AsciiSlugger::withEmoji(bool|string $emoji = true)`: get a slugger that converts emojis. No autowiring alias exists for `AsciiSlugger`. To inject the `slugger` service as an `AsciiSlugger`, use `#[Autowire(service: 'slugger')]` (`Symfony\Component\DependencyInjection\Attribute\Autowire`).
- `php vendor/symfony/emoji/Resources/bin/compress`: a PHP script, not a console command. Run it after `composer install`, for example as an automated script.
- `composer require symfony/emoji`: install the package explicitly. String and TwigBridge list it only in `require-dev`.
- The package has no config keys, attributes, console commands or test helpers.

## Symbiotic packages

- [String](../packages/string.md): `AsciiSlugger::withEmoji()` adds an `EmojiTransliterator` to the slug rules, to write emoji names or short codes into slugs.
- [Twig Bridge](../packages/twig-bridge.md): `EmojiExtension` defines the `emojify` filter. It calls `EmojiTransliterator::create()` with the `REVERSE` direction.
- [TwigBundle](../packages/twig-bundle.md): TwigBundle registers and tags the `twig.extension.emoji` service when `symfony/emoji` and the `intl` extension are available.
- [FrameworkBundle](../packages/framework-bundle.md): FrameworkBundle registers the `slugger` service, an `AsciiSlugger` with the request locale. `withEmoji()` is not part of `SluggerInterface`.
- [Intl](../packages/intl.md): often confused with Emoji. Since 8.0, Intl has no emoji transliterator. Use Intl for language, script, country, locale, currency and timezone names.
- [Notifier](../packages/notifier.md): often confused by name. `Notification::emoji()` only stores the icon string of a notification, and it does not use this package.

## Changed in 8.0/8.1

- 8.0: `Symfony\Component\Intl\Transliterator\EmojiTransliterator` -> `Symfony\Component\Emoji\EmojiTransliterator` (run `composer require symfony/emoji`). Intl deprecated the old class in 7.1.

## Status

Needs the `intl` PHP extension: `composer.json` requires `ext-intl`, and the class throws a `LogicException` without it. The `compress` script and the `.php.gz` data files need the `zlib` extension.

## Docs

- https://symfony.com/doc/current/emoji.html
- https://symfony.com/doc/current/string.html
- https://symfony.com/doc/current/reference/twig_reference.html
