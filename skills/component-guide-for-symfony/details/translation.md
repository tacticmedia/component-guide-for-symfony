# Translation (`symfony/translation`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Translator**: `trans()` returns the message for a translation key in the current locale or in the locale that you give. If the catalogs have no message for the key, `trans()` returns the key. Entry point: `Symfony\Contracts\Translation\TranslatorInterface::trans(string $id, array $parameters = [], ?string $domain = null, ?string $locale = null)`.
- **Domains and translation files**: A domain is a group of messages, and `messages` is the default domain. Each translation file has the name `<domain>.<locale>.<format>`, for example `translations/messages.fr.yaml`. The formats are `yaml` (or `yml`), `xlf` (or `xliff`), `php`, `json`, `csv`, `ini`, `po`, `mo`, `ts` (Qt), `res` and `dat`. For an application, the docs recommend keyword keys, for example `user.login`. Messages in `translations/` override bundle messages that have the same domain and key. After you add a new translation file, clear the cache. Entry point: `framework.translator.default_path` (default `%kernel.project_dir%/translations`) and `framework.translator.paths`.
- **Placeholders**: `trans()` replaces each parameter key in the message with its value through `strtr()`. The `%name%` form is a convention, not a rule. Entry point: `$translator->trans('say_hello', ['%name%' => $name])`.
- **ICU MessageFormat**: If the file name has the `+intl-icu` suffix after the domain, for example `messages+intl-icu.en.yaml`, the translator formats its messages with the ICU `MessageFormatter`. Use `{name}` placeholders and the `select`, `plural`, `selectordinal`, `ordinal`, `number`, `date` and `time` functions. In code, give the domain without the suffix. To format an ICU string that is not in a file, give the domain `messages+intl-icu`. Files without the suffix keep the legacy pipe syntax for plurals, for example `{0} No results|one result|%count% results`. Entry point: `Symfony\Component\Translation\MessageCatalogueInterface::INTL_DOMAIN_SUFFIX`.
- **Translatable objects**: `TranslatableMessage` and the `t()` function store a translation key, its parameters and its domain. The translation occurs later, when the Twig `trans` filter (also in form themes) or `TranslatableNormalizer` calls `trans()` on the object. A parameter can also be a translatable object. To control the translation, implement `TranslatableInterface`, for example on an enum. `StaticMessage` holds text that the translator must not change. If the `trans` filter receives a translatable object, give only a locale as its argument. Entry point: `Symfony\Component\Translation\TranslatableMessage`, `Symfony\Component\Translation\t()`, `Symfony\Contracts\Translation\TranslatableInterface`, `Symfony\Component\Translation\StaticMessage`.
- **Request locale**: The `_locale` route parameter sets the locale of the request. If the request has no locale, `framework.default_locale` (default `en`) applies. If `framework.set_locale_from_accept_language` is `true`, the `Accept-Language` header selects one of `framework.enabled_locales`. If `framework.enabled_locales` is empty, the first language of that header becomes the locale. `framework.enabled_locales` also becomes the requirement of the `_locale` route parameter. In a controller, `$request->setLocale()` does not change the locale of the translator. Use the URL, `LocaleSwitcher` or a `kernel.request` listener with a priority higher than 16 (`LocaleListener`). Entry point: `Symfony\Component\HttpFoundation\Request::getLocale()`, `framework.enabled_locales`.
- **Fallback locales**: If a message is missing for `es_AR`, the translator tries the ICU parent locale `es_419`, then `es`, then `framework.translator.fallbacks`. The default value of `fallbacks` is `framework.default_locale`. `LocaleFallbackProvider` (new in 8.1) computes the same chain outside the translator. Entry point: `framework.translator.fallbacks`, `Symfony\Component\Translation\LocaleFallbackProvider::computeFallbackLocales()`.
- **Locale switcher**: `LocaleSwitcher::setLocale()` changes the locale of all `kernel.locale_aware` services, for example the translator. It also calls `\Locale::setDefault()` and sets `_locale` in the router context, so generated URLs use the new locale. `runWithLocale()` runs a callback in one locale and then restores the previous locale. The change applies to the current request only. Entry point: `Symfony\Component\Translation\LocaleSwitcher` (`setLocale()`, `getLocale()`, `runWithLocale()`, `reset()`).
- **Global parameters**: `framework.translator.globals` defines parameters for all messages, for example `{app_version}`. A global value can also be a translatable message with the `message`, `parameters` and `domain` keys. A parameter that you give to `trans()` overrides a global parameter. In the configuration, write a key with `%` characters as `%%app_name%%`. Entry point: `framework.translator.globals`.
- **Key extraction**: `translation:extract --force <locale>` writes missing translation keys from templates and PHP code into the translation files. `--dump-messages` shows them in the console, `--clean` removes the keys that the code does not use, and `--no-fill` leaves new messages empty. By default, a new message repeats the key with the `__` prefix (`--prefix`). If the `intl` extension or `symfony/polyfill-intl-messageformatter` is installed, new messages go to the `+intl-icu` file, for example `messages+intl-icu.fr.xlf`. But if the locale has a domain file without the suffix and no `+intl-icu` file, new messages go to the file without the suffix. The command writes XLIFF 1.2 files, unless `--format` sets another format, for example `--format=yaml`. The command finds `trans()` calls, `t()` calls, `new TranslatableMessage()` and the `*message` arguments of constraint attributes. Without `nikic/php-parser`, the command extracts no keys from PHP files. Entry point: `translation:extract`.
- **Missing and unused messages**: `debug:translation <locale>` shows the state of each message: missing, unused or fallback. The `--only-missing`, `--only-unused` and `--domain` options filter the list. If the command finds a problem, the exit code is 64 plus the bits 1 (missing), 2 (unused) and 4 (fallback). Entry point: `debug:translation`, `Symfony\Bundle\FrameworkBundle\Command\TranslationDebugCommand::EXIT_CODE_MISSING`.
- **Lint commands**: `lint:translations` translates every message and reports the messages that fail, for example because of invalid ICU syntax. `lint:xliff` validates XLIFF files against the XLIFF schema, and `lint:yaml` checks the YAML syntax. If `framework.enabled_locales` is empty, give `--locale` to `lint:translations`. Without locales, the command checks nothing and returns the exit code 0. Entry point: `lint:translations`, `lint:xliff`, `lint:yaml`.
- **Translation providers**: `translation:push <provider>` sends local messages to a translation provider. `translation:pull <provider>` writes the messages of the provider into the translation files. Without `--force`, both commands add only new messages. Configure each provider under `framework.translator.providers.<name>` with `dsn`, `domains` and `locales`. If no locales are set there or in `framework.enabled_locales`, `translation:push` fails. Install one bridge for each provider. Each bridge requires `symfony/http-client`:
  - Crowdin: `symfony/crowdin-translation-provider`, DSN `crowdin://PROJECT_ID:API_TOKEN@ORGANIZATION_DOMAIN.default` (`ORGANIZATION_DOMAIN` only for Crowdin Enterprise).
  - Loco: `symfony/loco-translation-provider`, DSN `loco://API_KEY@default` (optional `status` query option).
  - Lokalise: `symfony/lokalise-translation-provider`, DSN `lokalise://PROJECT_ID:API_KEY@default`.
  - Phrase: `symfony/phrase-translation-provider`, DSN `phrase://PROJECT_ID:API_TOKEN@default?userAgent=myProject`. The `userAgent` option is required. The bridge changes `pt_BR` to the RFC 4646 form `pt-BR`, then uses the Phrase locale with that code or name, or creates it.
  - Custom provider: implement `ProviderInterface` and a `ProviderFactoryInterface` factory, then tag the factory with `translation.provider_factory`.
  Entry point: `translation:push`, `translation:pull`, `framework.translator.providers`.
- **XLIFF 2 and PGS**: The XLIFF loader reads XLIFF 1.2, 2.0, 2.1 and 2.2 files. It converts XLIFF 2.2 PGS units (plural, gender and select) into ICU messages in the `+intl-icu` domain. Entry point: `Symfony\Component\Translation\Loader\XliffFileLoader`.
- **Pseudo-localization**: `framework.translator.pseudo_localization` replaces letters with accented letters, adds brackets and makes the text longer. Use it in development to find text that does not fit the layout. Entry point: `framework.translator.pseudo_localization` (`accents`, `brackets`, `expansion_factor`, `parse_html`, `localizable_html_attributes`).

## Entry points

- `Symfony\Contracts\Translation\TranslatorInterface`: autowire it to call `trans()`. The service ID is `translator`.
- `Symfony\Component\Translation\LocaleSwitcher`: autowire it to read or change the locale. The service ID is `translation.locale_switcher`.
- Translatable objects: `Symfony\Component\Translation\TranslatableMessage`, the function `Symfony\Component\Translation\t()`, `Symfony\Component\Translation\StaticMessage`, `Symfony\Contracts\Translation\TranslatableInterface`.
- `Symfony\Contracts\Translation\LocaleAwareInterface`: implement it to receive each locale change. Autoconfiguration adds the `kernel.locale_aware` tag.
- `Symfony\Component\Translation\LocaleFallbackProvider`: computes and validates fallback locales (new in 8.1).
- Config keys: `framework.default_locale`, `framework.enabled_locales`, `framework.set_locale_from_accept_language`, `framework.set_content_language_from_locale`, `framework.translator.fallbacks`, `framework.translator.default_path`, `framework.translator.paths`, `framework.translator.logging`, `framework.translator.formatter`, `framework.translator.cache_dir`, `framework.translator.pseudo_localization`, `framework.translator.providers`, `framework.translator.globals`, `framework.validation.translation_domain`.
- Container parameters: `kernel.default_locale` and `kernel.enabled_locales` contain the values of `framework.default_locale` and `framework.enabled_locales`. To read the enabled locales in a service, for example for a language menu, use `#[Autowire(param: 'kernel.enabled_locales')]`. If an environment variable in `framework.enabled_locales` is empty, `kernel.enabled_locales` contains an empty string. Remove empty strings with `array_filter()`.
- Console commands: `translation:extract`, `debug:translation`, `lint:translations`, `lint:xliff`, `lint:yaml`, `translation:push`, `translation:pull`.
- Twig: the `trans` filter, the `t()` function, the `{% trans %}...{% endtrans %}` tag, the `{% trans_default_domain %}` tag, and the `app.locale` and `app.enabled_locales` variables.
- Service tags: `translation.loader` (custom `LoaderInterface` for a new file format), `translation.dumper`, `translation.extractor`, `translation.provider_factory`, `kernel.locale_aware`.
- Test helpers: `Symfony\Component\Translation\IdentityTranslator` implements `TranslatorInterface` without catalogs. It returns the key with the parameters and the plural selection applied. For a custom provider: `Symfony\Component\Translation\Test\ProviderTestCase`, `Symfony\Component\Translation\Test\AbstractProviderFactoryTestCase`, `Symfony\Component\Translation\Test\IncompleteDsnTestTrait`.
- Installation: `composer require symfony/translation`. The Flex recipe creates `config/packages/translation.yaml` and the `translations/` directory.

## Symbiotic packages

- [FrameworkBundle](../packages/framework-bundle.md): FrameworkBundle registers the `translator` service, reads the `framework.translator` and locale keys, and registers the translation commands.
- [Symfony Contracts](../packages/contracts.md): `symfony/translation-contracts` defines `TranslatorInterface`, `TranslatableInterface` and `LocaleAwareInterface`, the types that your code type-hints.
- [Twig Bridge](../packages/twig-bridge.md): The bridge gives the `trans` filter, the `t()` function and the `trans` tags, and its `TwigExtractor` finds template messages for `translation:extract`.
- [TwigBundle](../packages/twig-bundle.md): TwigBundle registers the translation Twig extension and the Twig extractor as services.
- [HttpKernel](../packages/http-kernel.md): `LocaleListener` sets the request locale from `_locale` or `Accept-Language`, and `LocaleAwareListener` gives it to the `kernel.locale_aware` services.
- [HttpFoundation](../packages/http-foundation.md): `Request::getLocale()` and `Request::getPreferredLanguage()` give the locale of one request, and the session can keep the locale across requests.
- [Routing](../packages/routing.md): The `_locale` parameter and localized routes put the locale in the URL, and `framework.enabled_locales` becomes the requirement of `_locale`.
- [Validator](../packages/validator.md): The validator translates constraint messages in the `validators` domain (`framework.validation.translation_domain`), and `translation:extract` finds the `*message` arguments of constraint attributes.
- [Form](../packages/form.md): The `label`, `help` and `placeholder` options accept `TranslatableMessage` objects, a `choice_label` callable can return one, and `EnumType` uses a `TranslatableInterface` enum as the choice label.
- [Serializer](../packages/serializer.md): `TranslatableNormalizer` changes `TranslatableInterface` objects into translated strings, and the `translatable_normalization_locale` context key sets the locale.
- [Mailer](../packages/mailer.md): `TemplatedEmail::locale('de')` renders the email templates in that locale, because the Twig body renderer calls `LocaleSwitcher::runWithLocale()`.
- [HttpClient](../packages/http-client.md): Each provider bridge requires `symfony/http-client`, and without the `http_client` service, FrameworkBundle removes the provider factories.
- [String](../packages/string.md): The `slugger` service has the `kernel.locale_aware` tag, so it follows the request locale and `LocaleSwitcher`.
- [Yaml](../packages/yaml.md): YAML translation files need the Yaml component, and `lint:yaml` checks their syntax.
- [Intl](../packages/intl.md): Intl gives the names of languages, countries, currencies and time zones in a locale, and Translation translates your own messages.
- [Symfony Polyfill](../packages/polyfill.md): `symfony/polyfill-intl-messageformatter` replaces the `intl` `MessageFormatter` for English only, so other languages need the `intl` extension.
- [Symfony UX Translator](../packages/ux-translator.md): UX Translator dumps the catalogs to JavaScript when the cache warms up, so front-end code calls `trans()` with the same keys.
- [Symfony Language Tools](../packages/language-tools.md): In CI, `symfony-lsp check` reports parameters that do not match the message placeholders and, with `--translation-diagnostics`, unknown translation keys and domains.
- [MonologBundle](../packages/monolog-bundle.md): If `framework.translator.logging` is `true`, the translator logs missing messages to the `translation` channel.
- [WebProfilerBundle](../packages/web-profiler-bundle.md): The Translation panel of the profiler shows each message of a request as defined, missing or fallback.

## Changed in 8.0/8.1

- `(string) $translatableMessage` -> `$translatableMessage->trans($translator)` or `getMessage()`. Version 8.0 removes `TranslatableMessage::__toString()`, so code that gives a `TranslatableMessage` to a `string` parameter, for example of `buildViolation()`, causes a `TypeError`.
- `bin/console translation:update` -> `bin/console translation:extract`. Version 7.0 removes the command name, and version 8.0 removes the `TranslationUpdateCommand` class.
- `extends ProviderFactoryTestCase` -> `extends AbstractProviderFactoryTestCase`, plus `IncompleteDsnTestTrait` for incomplete DSN tests (removed in 8.0).
- `CsvFileLoader::setCsvControl(';', '"', '\\')` -> `setCsvControl(';', '"')`. Version 8.0 removes the `$escape` parameter.
- `extends Symfony\Bundle\FrameworkBundle\Translation\Translator` -> a decorator of the `translator` service, as FrameworkBundle does for `translator.pseudo`. Version 8.0 makes this class and `DataCollectorTranslator` `final`.
- Manual fallback chains -> `LocaleFallbackProvider::computeFallbackLocales()` (new in 8.1).
- XLIFF 1.2 and 2.0 only -> also XLIFF 2.1 and 2.2 files, with XLIFF 2.2 PGS units loaded as ICU messages (new in 8.1).
- A fixed `framework.enabled_locales` list -> entries with environment variables, for example `'%env(LOCALE_1)%'`. Symfony ignores empty values (new in 8.1).

## Status

The ICU MessageFormat needs the PHP `intl` extension. The `symfony/polyfill-intl-messageformatter` package supports English only. If neither is installed, an ICU message causes a `LogicException`.

## Docs

- https://symfony.com/doc/current/translation.html
- https://symfony.com/doc/current/reference/formats/message_format.html
- https://symfony.com/doc/current/reference/formats/xliff.html
- https://symfony.com/doc/current/reference/configuration/framework.html
- https://symfony.com/doc/current/reference/twig_reference.html
- https://symfony.com/doc/current/reference/dic_tags.html
- https://symfony.com/doc/current/validation/translations.html
- https://symfony.com/doc/current/routing.html
- https://symfony.com/doc/current/session.html
- https://github.com/symfony/symfony/blob/8.1/src/Symfony/Component/Translation/Bridge/Crowdin/README.md
- https://github.com/symfony/symfony/blob/8.1/src/Symfony/Component/Translation/Bridge/Loco/README.md
- https://github.com/symfony/symfony/blob/8.1/src/Symfony/Component/Translation/Bridge/Lokalise/README.md
- https://github.com/symfony/symfony/blob/8.1/src/Symfony/Component/Translation/Bridge/Phrase/README.md
