# String (`symfony/string`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- Three string classes: `ByteString` works on bytes, `CodePointString` works on code points, and `UnicodeString` works on grapheme clusters (the characters that a reader sees). The docs call `UnicodeString` the most commonly used class. It stores the text in NFC form and throws an `InvalidArgumentException` for invalid UTF-8. `Symfony\Component\String\UnicodeString`
- Helper functions: `u()` creates a `UnicodeString` and `b()` creates a `ByteString`. `s()` creates a `UnicodeString` for valid UTF-8 and a `ByteString` for other bytes. Import each function with `use function`. `Symfony\Component\String\u()`
- Immutable chained calls: each method that changes the text returns a new object. The original object does not change. Cast the result with `(string)` or call `toString()`. `AbstractString::toString()`
- Length and width: `length()` counts bytes, code points or grapheme clusters, as the class defines. `width()` returns the number of monospaced columns for console output and ignores ANSI color codes. For text with many lines, it returns the width of the longest line. `AbstractString::width()`
- Case conversion: `lower()`, `upper()`, `title()`, `camel()`, `snake()`, `kebab()` and `pascal()` change the case. `folded()` returns a form for case-insensitive comparison. `localeLower()`, `localeUpper()` and `localeTitle()` apply the rules of a locale (`nl` gives `IJssel`). `AbstractString::snake()`
- Search and replace: `startsWith()`, `endsWith()`, `containsAny()`, `equalsTo()`, `indexOf()` and `indexOfLast()` find text. The index methods return `null` when nothing matches. `replace()`, `replaceMatches()` (with a replacement string or a closure) and `match()` work with text or regular expressions. Call `ignoreCase()` first to ignore the letter case in the next call. `AbstractString::replaceMatches()`
- Cut and combine: in a `UnicodeString`, `slice()`, `truncate()`, `wordwrap()`, `split()`, `chunk()`, `splice()` and `reverse()` work on grapheme clusters. `truncate()` takes an ellipsis and a `TruncateMode` (`Char`, `WordBefore` or `WordAfter`). `join()` takes an optional last glue, for example `' and '`. `Symfony\Component\String\TruncateMode`
- Edges and padding: `before()`, `after()`, `beforeLast()` and `afterLast()` return the text around a needle. `ensureStart()`, `ensureEnd()`, `trimPrefix()` and `trimSuffix()` add or remove a fixed prefix or suffix. `padStart()`, `padEnd()` and `padBoth()` add padding characters (a space by default). `collapseWhitespace()` trims the text and replaces each run of whitespace with one space. `trim()`, `trimStart()` and `trimEnd()` of a Unicode string also remove non-breaking spaces and the byte order mark by default. `AbstractString::trimPrefix()`
- Unicode and encodings: `ascii()` transliterates text to ASCII (`спасибо` gives `spasibo`). `normalize()` applies the NFC, NFD, NFKC or NFKD form. `ByteString::toUnicodeString($fromEncoding)` and `toByteString($toEncoding)` convert between UTF-8 and other encodings, such as Windows-1252. `AbstractUnicodeString::ascii()`
- Random strings: `ByteString::fromRandom($length, $alphabet)` returns random characters from an alphabet. The defaults are 16 characters and a base58 alphabet. It uses `Random\Randomizer`, which uses the secure engine of PHP by default. `ByteString::fromRandom()`
- Lazy strings: `LazyString::fromCallable()` and `LazyString::fromStringable()` return a `Stringable` object. The object runs the callback only when code casts it to a string, and then keeps the value. `Symfony\Component\String\LazyString`
- Slugger: `slug($string, $separator, $locale)` transliterates the text to ASCII. Then it replaces each run of characters that are not ASCII letters or digits with the separator (default `-`). It returns an `AbstractUnicodeString` object, not a PHP string, and it keeps the letter case. For a lowercase PHP string, call `->lower()->toString()`. The slugger does not detect the language, and without a locale it applies no locale rules. To apply them, set a locale (for example, `de` changes `ä` to `ae`). `Symfony\Component\String\Slugger\AsciiSlugger`
- Slugger symbols map: for `en` locales, the default map changes `&` to `and` and `@` to `at`. A custom map replaces the default map. An array map runs after transliteration, so use it for ASCII symbols such as `%`. A closure runs before transliteration, so use it for non-ASCII symbols such as `€`. The closure does not run on ASCII-only text, and it can miss ASCII symbols before the first non-ASCII character. `new AsciiSlugger($locale, $symbolsMap)`
- Emoji in slugs: `withEmoji()` returns a new slugger that writes emoji as words in the slug locale. `withEmoji('github')`, `withEmoji('gitlab')`, `withEmoji('slack')` or `withEmoji('fr')` sets a fixed emoji locale. Without any locale, the slugger removes the emoji. The method is on `AsciiSlugger`, not on `SluggerInterface`. `AsciiSlugger::withEmoji()`
- Inflectors: `EnglishInflector`, `FrenchInflector` and `SpanishInflector` implement `InflectorInterface`. `singularize()` and `pluralize()` return an array, because some words have more than one form (`person` gives `persons` and `people`). `Symfony\Component\String\Inflector\EnglishInflector`

## Entry points

- `composer require symfony/string`: install the package.
- `Symfony\Component\String\Slugger\SluggerInterface`: autowire it in a Symfony application. The service ID is `slugger`, an `AsciiSlugger` with the `kernel.locale_aware` tag.
- Without FrameworkBundle: `Symfony\Component\String\Slugger\AsciiSlugger`, created with `new AsciiSlugger($locale, $symbolsMap)`.
- `Symfony\Component\String\u()`, `Symfony\Component\String\b()` and `Symfony\Component\String\s()`: import each function with `use function`.
- `Symfony\Component\String\UnicodeString`, `Symfony\Component\String\ByteString` and `Symfony\Component\String\CodePointString`. Use `AbstractString` or `AbstractUnicodeString` as a parameter type.
- `Symfony\Component\String\TruncateMode`: the enum for the third argument of `truncate()`.
- `Symfony\Component\String\LazyString`
- `Symfony\Component\String\Inflector\EnglishInflector`, `FrenchInflector`, `SpanishInflector` and `InflectorInterface`.
- `Symfony\Component\String\Exception\InvalidArgumentException` and `Symfony\Component\String\Exception\RuntimeException`: both implement `Symfony\Component\String\Exception\ExceptionInterface`.
- `framework.default_locale`: sets the default locale of the `slugger` service. The package has no own config key, attribute or console command.
- Twig: the `u`, `slug`, `plural` and `singular` filters come from the separate package `twig/string-extra` (`Twig\Extra\String\StringExtension`). In Symfony, install `twig/extra-bundle` to register the filters. The `slug` filter then uses a new `AsciiSlugger` without a locale, not the `slugger` service. If you need locale rules, pass the locale, for example `title|slug('-', 'de')`.

## Symbiotic packages

- [Emoji](../packages/emoji.md): Emoji provides the `EmojiTransliterator` that `AsciiSlugger::withEmoji()` uses to write emoji as words in a slug.
- [FrameworkBundle](../packages/framework-bundle.md): FrameworkBundle registers the `slugger` service and the `SluggerInterface` alias, with `framework.default_locale` as the default locale.
- [HttpKernel](../packages/http-kernel.md): the `LocaleAwareListener` of HttpKernel gives the request locale to the `slugger` service at the start of each request.
- [Translation](../packages/translation.md): `LocaleSwitcher::runWithLocale()` also changes the locale of the `slugger` service, because that service has the `kernel.locale_aware` tag.
- [Symfony Contracts](../packages/contracts.md): `AsciiSlugger` implements `LocaleAwareInterface` from `symfony/translation-contracts`, so the slugger needs that package.
- [PropertyInfo](../packages/property-info.md): `ReflectionExtractor` uses `EnglishInflector` (or another `InflectorInterface`) to find the adder and remover methods of a collection property.
- [PropertyAccess](../packages/property-access.md): `PropertyAccessor` writes a `$children` array through `addChild()` and `removeChild()`, and the String inflector finds the singular name.
- [HttpFoundation](../packages/http-foundation.md): the upload docs slug the name from `UploadedFile::getClientOriginalName()` to make a safe file name.
- [Security](../packages/security-bundle.md): the `oidc`, `oidc_user_info` and `oauth2` token handlers need this package to create the default user, and a `UserBadge` normalizer (the fourth argument) can use `u()`.
- [Symfony Polyfill](../packages/polyfill.md): this package requires the `mbstring`, `ctype`, `intl-grapheme` and `intl-normalizer` polyfills, so it runs without those PHP extensions.
- [Uid](../packages/uid.md): use Uid for UUID and ULID identifiers, and use `ByteString::fromRandom()` for a random code from your own alphabet.
- [Intl](../packages/intl.md): often confused; Intl gives only locale data such as names and codes, and String changes, slugs and transliterates text.

## Changed in 8.0/8.1

- If you extend a string class, implement `__serialize()` and `__unserialize()`. Since 8.0, the string classes do not use `__sleep()` and `__wakeup()`.

## Status

The package needs no PHP extension, because Composer installs the polyfills. Some features need the `intl` PHP extension:
- `localeLower()`, `localeUpper()` and `localeTitle()` use the `\Transliterator` class of `intl`.
- `ascii()` and the slugger give the best transliteration with `intl`. Without `intl`, they use built-in rules and `iconv`, and the slugger uses locale transliteration only for `de`.
- `withEmoji()` needs `symfony/emoji`, which requires `intl`.
- In a Symfony application without `intl`, FrameworkBundle triggers a deprecation notice that asks you to install the extension.

## Docs

- https://symfony.com/doc/current/string.html
- https://symfony.com/doc/current/emoji.html
- https://symfony.com/doc/current/controller/upload_file.html
- https://symfony.com/doc/current/security/custom_authenticator.html
- https://symfony.com/doc/current/components/property_access.html
- https://symfony.com/doc/current/translation.html
- https://symfony.com/doc/current/reference/dic_tags.html
- https://twig.symfony.com/doc/3.x/filters/u.html
- https://twig.symfony.com/doc/3.x/filters/slug.html
- https://twig.symfony.com/doc/3.x/filters/plural.html
- https://twig.symfony.com/doc/3.x/filters/singular.html
