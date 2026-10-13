# Intl (`symfony/intl`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when an application must show country, language, locale, currency or time zone names in the language of the user, or check ISO codes. It contains the ICU data and gives currency symbols, decimal places and time zone offsets. To format numbers, dates or prices, use the formatter classes of the PHP intl extension.

**Details:** [../details/intl.md](../details/intl.md)

## Why it exists

Many applications show country, language, currency or time zone names in the language of the user, and check ISO codes. Hand-written lists get no updates, and the intl extension on each server can use a different ICU version. The package contains the ICU data as PHP files and supplies static classes that read this data.

## When to use it

- Show a list of countries, languages, locales, currencies or time zones in the language of the user.
- Show the name of one country, language, script, locale, currency or time zone in a given language.
- Check that a country, language, script, locale, currency or time zone code exists.
- Convert country codes between alpha-2, alpha-3 and numeric forms, or language codes between alpha-2 and alpha-3.
- Get the symbol, the decimal places and the cash rounding of a currency.
- Find the currencies that are legal tender in a country on a given date.
- Get the time zones of a country and their GMT offsets.
- Accept Kosovo as a country, with its user-assigned codes.

## Use it instead of

- `['FR' => 'France', 'DE' => 'Germany', ...]` in a PHP or JSON file -> `Countries::getNames($locale)`, or the `CountryType` form field
- `\Locale::getDisplayRegion('-GB', 'de')`, which uses the ICU data of the server (74.2 on the test machine) -> `Countries::getName('GB', 'de')`, which uses the bundled ICU 78.3 data
- `preg_match('/^[A-Z]{2}$/', $code)` or `in_array($code, $countryCodes)` -> `Countries::exists($code)`, or the `#[Assert\Country]` constraint on a property
- `['FR' => 'FRA', ...]` or `['FR' => '250', ...]` arrays -> `Countries::getAlpha3Code('FR')`, `Countries::getNumericCode('FR')`, `Countries::getAlpha2FromNumeric('250')`
- `['EUR' => '€', 'USD' => '$']` -> `Currencies::getSymbol('USD', $locale)`
- `round($amount, 2)` or `number_format($amount, 2)` for all currencies -> `Currencies::getFractionDigits($currency)` (`0` for `JPY`) and `Currencies::getCashRoundingIncrement($currency)`
- A hand-written list of the currencies of each country -> `Currencies::forCountry('FR')`
- A hand-written list of timezone labels and offsets -> `Timezones::getNames($locale)` and `Timezones::getGmtOffset($timezone)`
- `['fr' => 'Français', 'de' => 'Deutsch']` for a language switcher -> `Languages::getName($code, $code)`, or the `LanguageType` form field with `'choice_self_translation' => true`
