# Symfony UX Translator (`symfony/ux-translator`): details

**Applies to:** Symfony UX 3.5

## Key features and concepts

- **Dump at cache warm-up**: An optional cache warmer writes `index.js` and `index.d.ts` to `var/translations/` when `cache:warmup` or `cache:clear` runs. It writes `index.d.ts` only if `dump_typescript` is `true`. `index.js` exports `messages` (each key with its messages by domain and locale) and `localeFallbacks`. The dump contains the catalogs that the `translator` service loads, including the `+intl-icu` domains. The option `--no-optional-warmers` skips the dump. After you change a translation file, run `cache:warmup` again. If the debug mode is off, as in `prod`, run `cache:clear` instead, because `cache:warmup` keeps the old translator cache. Entry point: `ux_translator.dump_directory` (default `%kernel.project_dir%/var/translations`).
- **Refresh command**: `ux:translator:warm-cache` runs only the UX Translator warmer, not the other cache warmers. This warmer dumps only the catalogs that the `translator` service has already loaded in the same process. If the command writes an empty or incomplete dump, run `cache:warmup`. Entry point: `ux:translator:warm-cache`.
- **Translator factory**: `createTranslator()` takes `messages` and the optional `locale`, `localeFallbacks` and `throwWhenNotFound`. It returns an object with `trans()`, `setLocale()`, `getLocale()` and `setThrowWhenNotFound()`. The recipe file `assets/translator.js` creates one translator and exports only `trans`. If other modules must change the locale, also export `setLocale`. Entry point: `createTranslator()` from `@symfony/ux-translator`.
- **Translation function**: `trans(id, parameters, domain, locale)` has the same argument order as the PHP `TranslatorInterface::trans()`. The domain defaults to `messages`, and the locale defaults to the current locale of the translator. For each key, `trans()` uses the `<domain>+intl-icu` messages first, then the messages of the plain domain. If a key is ICU in some locales and plain in others, `trans()` can return the key or a wrong text. Use the same format for a key in all locales. The result is not HTML-escaped. If a parameter comes from a user, insert the result with `textContent`, not `innerHTML`. Entry point: `trans()`.
- **Symfony message format**: Messages in a plain domain use placeholders such as `%name%`, and `trans()` replaces them as `strtr()` does. Pass the placeholders as keys, for example `{ '%name%': 'Fabien' }`. If the parameters contain `%count%`, `trans()` selects a plural form from `|`-separated forms, intervals such as `{0}` or `]1,Inf]`, and labels such as `one:`. A missing placeholder stays in the text. If no plural form matches, `trans()` throws an error. Entry point: `trans('apples', { '%count%': 3 })`.
- **ICU MessageFormat**: Messages from files with the `+intl-icu` suffix, such as `messages+intl-icu.en.yaml`, go through `IntlMessageFormat` from the `intl-messageformat` package (FormatJS). They support `select`, `plural`, `selectordinal`, `date`, `time` and `number` arguments, and number skeletons such as `{price, number, ::currency/EUR}`. Pass the parameter names without `%`, for example `{ count: 3 }`. A missing ICU parameter throws an error. HTML tags in a message stay as literal text (`ignoreTag`). Entry point: `trans('apples', { count: 3 })`.
- **Default locale**: Without a `locale` option, `createTranslator()` reads `<html data-symfony-ux-translator-locale>`, then `<html lang>` (`de-AT` becomes `de_AT`). If both attributes are missing or empty, it uses `en`. It reads these attributes once, when it creates the translator. To change the locale later, call `setLocale()`, or pass a locale to one `trans()` call. Entry point: `getDefaultLocale()` and `<html lang="{{ app.request.locale|replace({'_': '-'}) }}">`.
- **Locale fallbacks**: The dump writes `localeFallbacks` from the fallback catalog of each catalog. Examples: `{"en":null,"fr":"en"}` with `framework.translator.fallbacks: ['en']`, and `{"de_AT":"de","de":null}` for a parent locale. If a message does not exist in the requested locale, `trans()` follows this chain. Pass `localeFallbacks` to `createTranslator()`, as the recipe file does. Entry point: the `localeFallbacks` export of `var/translations/index.js`.
- **Missing translations**: By default, `trans()` returns the key when it finds no message. With `throwWhenNotFound: true` or `setThrowWhenNotFound(true)`, it throws `No translation message found with id "..."`. It throws only for a key that is in the dump but has no message for the domain and the locale chain. A key that is not in the dump always returns the key. Entry point: `setThrowWhenNotFound()`.
- **TypeScript types**: `index.d.ts` declares each key with its domains, locales and parameter types. `%count%`, `plural` and `number` give `number`. `date` and `time` give `Date`. `select` gives its option names, with `other` as `string`. To check each `trans()` call, rename `assets/translator.js` to `assets/translator.ts`. Entry point: `ux_translator.dump_typescript` (default `true`).
- **ICU check during the dump**: If `dump_typescript` is `true`, the dump parses each ICU message with a PHP port of the FormatJS parser. A message that this parser rejects, for example `{place, ordinal}`, makes the cache warm-up fail. Use `selectordinal` instead of `ordinal`. With AssetMapper, the docs set `dump_typescript: false` in `when@prod`, because no code reads the types there. Entry point: `when@prod: { ux_translator: { dump_typescript: false } }`.
- **Domain filter**: By default, the dump contains all domains. `domains` takes one domain or a list. Prefix a domain with `!` to exclude it. You cannot mix included and excluded domains. Use the domain name without `+intl-icu`: `messages` also selects the `messages+intl-icu` messages. Entry point: `ux_translator.domains`.
- **Key filter**: `keys_patterns` keeps only the keys that match a pattern, and a pattern with `!` removes the keys that match it. `*` matches any characters, including dots, and a pattern must match the full key. An exclude pattern wins over an include pattern. Entry point: `ux_translator.keys_patterns`.
- **Bundle size**: `var/translations/index.js` is one module with all dumped keys, domains and locales. A bundler cannot remove unused keys (no tree-shaking). The docs call this size negligible with compression. To reduce it, use `domains`, `keys_patterns` and `framework.enabled_locales`. If Validator, Form or Security is installed, the dump also contains its `validators` or `security` domain, unless `domains` excludes it. If `framework.enabled_locales` is empty, the dump contains every locale that has a translation file. Entry point: `framework.enabled_locales`.
- **Asset setup**: With AssetMapper, Flex runs `importmap:require` for `@symfony/ux-translator` and `intl-messageformat`. The bundle maps `%kernel.project_dir%/var/translations`, so `assets/translator.js` can import the dump. This mapping ignores `dump_directory`, so keep the default directory with AssetMapper. With Webpack Encore, Flex adds `@symfony/ux-translator` (`file:vendor/symfony/ux-translator/assets`) and `intl-messageformat` to `package.json`. Then run `npm install --force` and restart Encore. The package has no Stimulus controller, although its file name is `translator_controller.js`. Entry point: `importmap.php` or `package.json`.

## Entry points

- `composer require symfony/ux-translator`: registers `Symfony\UX\Translator\UxTranslatorBundle`. The Flex recipe creates `assets/translator.js`, `config/packages/ux_translator.yaml` and a placeholder `var/translations/index.js`.
- Config `ux_translator`: `dump_directory` (default `%kernel.project_dir%/var/translations`), `dump_typescript` (default `true`), `domains`, `keys_patterns`.
- Config of FrameworkBundle that changes the dump: `framework.enabled_locales` and `framework.translator.fallbacks`.
- Console commands: `cache:warmup` and `cache:clear` (both run the dump; `--no-optional-warmers` skips it), and `ux:translator:warm-cache`.
- Generated files: `var/translations/index.js` (exports `messages` and `localeFallbacks`) and `var/translations/index.d.ts`. Do not edit them.
- JavaScript module `@symfony/ux-translator`: `createTranslator()`, `getDefaultLocale()`, and the types `Message`, `Messages`, `MessageId`, `DomainType`, `LocaleType`, `NoParametersType` and `ParametersType`.
- Translator object: `trans(id, parameters, domain, locale)`, `setLocale()`, `getLocale()`, `setThrowWhenNotFound()`.
- HTML attributes on `<html>`: `data-symfony-ux-translator-locale` (Symfony format, for example `de_AT`) and `lang` (for example `de-AT`).
- npm dependency `intl-messageformat`: the peer range is `^10.5.11`, and Flex adds it.
- npm package `@symfony/ux-translator`: only for setups that keep JavaScript dependencies apart from PHP dependencies. Its version must match the version of the PHP package.
- Service `ux.translator.translations_dumper` (`Symfony\UX\Translator\TranslationsDumper::dump()`): writes a dump from your own list of catalogs. The warmer, the command and the parser classes are `@internal`.
- The package has no PHP attributes, Twig functions, events or test helpers.

## Symbiotic packages

- [Translation](../packages/translation.md): provides the catalogs, the loaders and the `+intl-icu` format that the dump reads; use Translation (`|trans` in Twig, `TranslatorInterface` in PHP) for text that the server renders.
- [FrameworkBundle](../packages/framework-bundle.md): provides the `translator` service, `framework.enabled_locales` and `framework.translator.fallbacks`, and runs the dump in `cache:warmup` and `cache:clear`.
- [AssetMapper](../packages/asset-mapper.md): the bundle adds `@symfony/ux-translator` and `var/translations` to the AssetMapper paths, and Flex adds the importmap entries.
- [WebpackEncoreBundle](../packages/webpack-encore-bundle.md): with Encore, Flex links `@symfony/ux-translator` and adds `intl-messageformat` in `package.json`.
- [Symfony Reprise](../packages/reprise.md): the Reprise playground imports `trans` from `assets/translator.js` in a Stimulus controller and links `@symfony/ux-translator` in `package.json`.
- [StimulusBundle](../packages/stimulus-bundle.md): the docs ask for it before the installation, but the package has no Stimulus controller; import `trans` in your own controllers.
- [Symfony Flex](../packages/flex.md): installs the recipe files and writes the `importmap.php` or `package.json` entries.

## Changed in UX 2.32 to 3.4

- UX 2.32: `createTranslator()` replaces the global `trans()` and the generated constants. Old: `import { trans } from '@symfony/ux-translator'; import { SYMFONY_GREAT } from '@app/translations'; trans(SYMFONY_GREAT);`. New: `const { trans } = createTranslator({ messages, localeFallbacks }); trans('symfony.great');`.
- UX 2.32: The global functions `setLocale()`, `getLocale()`, `setLocaleFallbacks()`, `getLocaleFallbacks()` and `throwWhenNotFound()` are removed. Use the methods of the translator object and the `localeFallbacks` and `throwWhenNotFound` options.
- UX 2.32: The dump has only `var/translations/index.js` and `index.d.ts`, without `configuration.js`. With AssetMapper, remove the `@app/translations` and `@app/translations/configuration` entries from `importmap.php`.
- UX 2.32: The options `keys_patterns` and `dump_typescript` are new. A bundler can no longer remove unused keys (no tree-shaking).
- UX 3.0: The package requires PHP 8.4 and Symfony 7.4 or 8.x.
- UX 3.1: The command `ux:translator:warm-cache` is new.
- UX 3.4: The package is no longer experimental.

## Docs

- https://symfony.com/bundles/ux-translator/current/index.html
- https://symfony.com/doc/current/translation.html
- https://symfony.com/doc/current/reference/formats/message_format.html (the PHP side; the UX dump rejects `{place, ordinal}`)
- https://symfony.com/doc/current/reference/configuration/framework.html (`default_locale`, `enabled_locales`, `translator.fallbacks`)
- https://formatjs.github.io/docs/intl-messageformat/ (the ICU formatter that `trans()` uses; the source comment links `formatjs.io`, which redirects here)
- https://ux.symfony.com/translator (live demo; its code samples show the removed 2.x constant API)
