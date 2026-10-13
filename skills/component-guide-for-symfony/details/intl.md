# Intl (`symfony/intl`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- Country names and codes: `Countries` gives the names of 249 ISO 3166-1 countries, sorted by name in the display locale. It converts alpha-2 codes to alpha-3 and numeric codes, and back. Numeric codes are strings with leading zeros, for example `'020'` for `AD`. `Countries::getNames()`, `getName('GB', 'de')`, `getAlpha3Code()`, `getNumericCode()`, `getAlpha2FromNumeric()`
- Language and script names: `Languages` gives ISO 639 language names and converts alpha-2 codes to alpha-3 codes. A full locale gives a regional name: `Languages::getName('en_US')` returns `American English`. `Scripts` gives ISO 15924 script names, for example `Simplified` for `Hans`. `Languages::getName()`, `Languages::getAlpha3Code()`, `Scripts::getName()`
- Locale names: `Locales` gives the names of the ICU locales, for example `Chinese (Simplified, Macao SAR China)` for `zh_Hans_MO`. `Locales::getNames()`, `Locales::getName()`, `Locales::getLocales()`
- Currency names, symbols and numeric codes: the symbol depends on the display locale. For `USD`, it is `$` in `en` and `$ US` in `fr_CA`. `getNumericCode('EUR')` returns `978`, and `forNumericCode(32)` returns `ARA`, `ARP` and `ARS`. `Currencies::getName()`, `getSymbol()`, `getNumericCode()`, `forNumericCode()`
- Decimal places and rounding: `getFractionDigits('JPY')` returns `0`. For cash, `getCashFractionDigits('SEK')` returns `0`, and `getCashRoundingIncrement('CAD')` returns `5`. An unknown currency code gets the default values, for example 2 decimal places. `Currencies::getFractionDigits()`, `getCashFractionDigits()`, `getRoundingIncrement()`, `getCashRoundingIncrement()`
- Currency validity by country and date: `forCountry('FR')` returns the legal-tender currencies that are active today (`['EUR']`). The `legalTender`, `active` and `date` arguments change the filter. To disable the `legalTender` or `active` filter, set it to `null`. For an unknown currency code, `isValidInCountry()` and `isValidInAnyCountry()` throw the global `\InvalidArgumentException`. For an unknown country code, `forCountry()` throws `MissingResourceException`, but `isValidInCountry()` returns `false`. `Currencies::forCountry()`, `isValidInCountry()`, `isValidInAnyCountry()`
- Currencies without validity dates and `CurrencyType`: 10 country and currency pairs in the data have no dates, for example `BOV` in `BO`. All 10 pairs are not legal tender, so the default `legalTender: true` removes them. With `legalTender: null` or `false`, the `includeUndated` argument (default `true`) makes these pairs count as active. The `CurrencyType` form field uses the same filters. By default, it shows only the legal-tender currencies that are active today (153 of 294 on 2026-10-09). To show all currencies, set its `active_at` and `legal_tender` options to `null`. If you set `not_active_at`, also set `active_at` to `null`. Otherwise, the field throws an `InvalidOptionsException`. `includeUndated`, `CurrencyType`
- Timezones: `Timezones` gives the localized names of 439 ICU timezone IDs, the country of a timezone and the timezones of a country. `forCountryCode()` accepts only uppercase country codes. `Timezones::exists()` also accepts PHP IDs such as `UTC`, but `getName('UTC')` throws an exception. `Timezones::getNames()`, `getName()`, `getCountryCode()`, `forCountryCode()`, `getIds()`
- GMT offsets: `getRawOffset()` returns the offset in seconds, and `getGmtOffset()` returns a localized string such as `GMT+05:45`. An optional timestamp argument gives the offset at that time, for example during daylight saving time. Both methods use PHP's `\DateTimeZone`. Some Intl IDs are old names, such as `Asia/Calcutta`. If the PHP timezone database has no alias for such a name, the methods throw an exception. `Timezones::getRawOffset()`, `Timezones::getGmtOffset()`
- Display locale: each name method takes the display locale as its last argument. Without it, the method uses `\Locale::getDefault()`. In a Symfony application with the `intl` extension, `Request::setLocale()` and `LocaleSwitcher::setLocale()` set this default. If the data has no entry for a display locale, the method uses the parent locale and then English. A display locale of one subtag with four or more letters, for example `nope`, has no fallback, so the method throws `MissingResourceException`.
- Unknown codes: a name or code method throws `MissingResourceException` for an unknown code. To check a code first, call `exists()` on the class. Codes are case-sensitive: `Countries::exists('gb')`, `Currencies::exists('eur')` and `Languages::exists('FR')` return `false`. `Symfony\Component\Intl\Exception\MissingResourceException`
- Kosovo: if the `SYMFONY_INTL_WITH_USER_ASSIGNED` environment variable is true, `Countries` also accepts `XK`, `XKK` and `983`. Then `getNames()` returns 250 countries. The class reads the variable once, at the first call. `Countries::withUserAssigned(true)` sets the same flag in code.
- Bundled ICU data: `Intl::getIcuDataVersion()` returns the version of the bundled data (`78.3`). `Intl::getIcuVersion()` returns the ICU version of the `intl` extension (`74.2` on the test machine), or `78.3` without the extension. `Intl::getIcuDataVersion()`, `Intl::getIcuVersion()`, `Intl::isExtensionLoaded()`
- Data updates in patch releases: the maintenance policy allows updates of external data such as ICU in patch versions, case by case. For example, v8.0.0 contains ICU 77.1 data, and v8.0.8 contains ICU 78.3 data. Thus, `composer update` can change names and lists. For `CL`, the docs show three timezones, but the 78.3 data gives four (with `America/Coyhaique`). Do not hard-code exact names or list lengths in tests.
- Disk space: `php vendor/symfony/intl/Resources/bin/compress` compresses the data files with gzip. In a test, the data went from 16 MB to 3.6 MB. The component then reads the `.php.gz` files, and these files need the `zlib` extension. `Resources/bin/compress`

## Entry points

- `Symfony\Component\Intl\Countries`, `Languages`, `Scripts`, `Locales`, `Currencies` and `Timezones`: final classes with static methods. Their parent class has a private constructor, so you cannot create or autowire them. No service exists, so call the static methods.
- Without FrameworkBundle: call the same static methods. The package has no service and no configuration key.
- `Symfony\Component\Intl\Intl::getIcuDataVersion()`, `getIcuVersion()` and `isExtensionLoaded()`.
- `Symfony\Component\Intl\Exception\MissingResourceException`: the exception for unknown codes. The Intl exceptions implement `Symfony\Component\Intl\Exception\ExceptionInterface`, but the `\InvalidArgumentException` of the currency validity methods does not.
- The `SYMFONY_INTL_WITH_USER_ASSIGNED` environment variable, or `Countries::withUserAssigned(true)`: add Kosovo.
- `php vendor/symfony/intl/Resources/bin/compress`: a PHP script, not a console command. The docs suggest that you run it after `composer install`.
- `Symfony\Component\Intl\Util\IntlTestHelper::requireIntl($this)`: sets the default locale to `en` in a PHPUnit test. It skips the test if the `intl` extension has an ICU major version below 78. `requireFullIntl($this)` also skips the test when the extension is missing.
- The package has no config key, attribute, console command or Twig function. The form types and constraints that use it are under "Symbiotic packages".

## Symbiotic packages

- [Form](../packages/form.md): `CountryType`, `CurrencyType`, `LanguageType` and `LocaleType` always load their choices from Intl, and `TimezoneType` does this only with `'intl' => true`, so these fields need `symfony/intl`.
- [Validator](../packages/validator.md): the `Country`, `Currency`, `Language`, `Locale` and `Bic` constraints need Intl, `Timezone` also accepts Intl timezone IDs, and `NoSuspiciousCharacters` needs only the `intl` extension.
- [HttpFoundation](../packages/http-foundation.md): `Request::setLocale()` calls `\Locale::setDefault()`, so Intl names without a display locale use the request locale when the `intl` extension is installed.
- [Translation](../packages/translation.md): `LocaleSwitcher::runWithLocale()` calls `\Locale::setDefault()` for its callback, and `+intl-icu` messages format numbers and dates with `NumberFormatter` and `IntlDateFormatter`.
- [Emoji](../packages/emoji.md): Intl contained `EmojiTransliterator` until 8.0, so use `Symfony\Component\Emoji\EmojiTransliterator` from `symfony/emoji` to convert or remove emojis.
- [Symfony Polyfill](../packages/polyfill.md): `symfony/polyfill-intl-icu` supplies `\Locale` and `\Collator` for the `en` locale only, so without the `intl` extension, `getNames('de')` throws an exception.
- [String](../packages/string.md): often confused with Intl: String changes, slugs and transliterates text, and Intl gives only locale data such as names and codes.

## Changed in 8.0/8.1

- 8.0: `Symfony\Component\Intl\Transliterator\EmojiTransliterator` -> `Symfony\Component\Emoji\EmojiTransliterator` (run `composer require symfony/emoji`). Intl deprecated the old class in 7.1.
- 8.0 (also 7.4): `Currencies::forCountry()`, `isValidInCountry()` and `isValidInAnyCountry()` replace hand-written checks of legal tender and validity dates.
- 8.0 (also 7.4): Kosovo is an optional region. Enable it with `SYMFONY_INTL_WITH_USER_ASSIGNED` or `Countries::withUserAssigned(true)`.

## Status

Intl needs the `intl` PHP extension for sorted lists and for a default locale in languages other than English. Its `composer.json` requires only `php >=8.4.1`, so Composer does not check for the extension. The classes call `\Locale::getDefault()` and sort lists with `\Collator`. Without the extension or a polyfill, the list methods and the name methods without a display locale fail with a `LogicException` or `Error: Class "Locale" not found`. With `symfony/polyfill-intl-icu`, the default locale is always `en`, and `\Locale::setDefault('de')` and `getNames('de')` throw exceptions. Single names in other display locales still work, for example `Countries::getName('GB', 'de')`. The translation docs also say that the polyfills support only English. The `compress` script and the `.php.gz` data files need the `zlib` extension.

## Docs

- https://symfony.com/doc/current/components/intl.html
- https://symfony.com/doc/current/reference/forms/types/country.html
- https://symfony.com/doc/current/reference/forms/types/currency.html
- https://symfony.com/doc/current/reference/forms/types/language.html
- https://symfony.com/doc/current/reference/forms/types/locale.html
- https://symfony.com/doc/current/reference/forms/types/timezone.html
- https://symfony.com/doc/current/reference/constraints/Country.html
- https://symfony.com/doc/current/reference/constraints/Currency.html
- https://symfony.com/doc/current/reference/constraints/Language.html
- https://symfony.com/doc/current/reference/constraints/Locale.html
- https://symfony.com/doc/current/reference/constraints/Timezone.html
- https://symfony.com/doc/current/reference/constraints/Bic.html
- https://symfony.com/doc/current/reference/constraints/NoSuspiciousCharacters.html
- https://symfony.com/doc/current/translation.html
- https://symfony.com/doc/current/reference/formats/message_format.html
- https://symfony.com/doc/current/emoji.html
- https://symfony.com/doc/current/contributing/code/maintenance.html
- https://symfony.com/doc/current/contributing/core_team.html
- https://github.com/symfony/polyfill-intl-icu
