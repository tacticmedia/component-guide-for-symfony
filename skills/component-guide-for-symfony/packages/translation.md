# Translation (`symfony/translation`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when an application must show its text in several languages, with plurals, placeholders and a fallback for missing translations. It supports ICU MessageFormat, switches the locale, finds missing keys and exchanges files with online translation platforms. For country, language or currency names, see [Intl](intl.md).

**Details:** [../details/translation.md](../details/translation.md)

## Why it exists

A multilingual application needs one message for each locale, plural rules and a fallback when a translation is missing. The package loads message catalogs from translation files, selects the message for the current locale and replaces placeholders with values. Its command-line tools find new and missing translation keys and exchange the files with online translation platforms.

## When to use it

- Show the user interface in the language of the current user.
- Insert values, for example a user name, into a translated message.
- Show the correct plural form in each language, for example "1 file" and "5 files".
- Format numbers, dates, ordinals and gender-specific text inside a translated message.
- Send an email or a notification in the language of the recipient.
- Translate enum labels, form labels and validation error messages.
- Find missing or unused translation keys before a release.
- Check the syntax of all translation files in a CI job.
- Find text that does not fit the layout, with pseudo-localized text in development.
- Send translation files to Crowdin, Loco, Lokalise or Phrase, and get the translations back.

## Use it instead of

- An array of texts for each language, for example `$labels[$locale]['welcome'] ?? 'Welcome'` -> a translation file in `translations/` and `$translator->trans('welcome')` (`TranslatorInterface`).
- `$count === 1 ? 'one file' : $count.' files'` -> the ICU message `{count, plural, one {# file} other {# files}}` in `messages+intl-icu.en.yaml`.
- `str_replace('{name}', $name, $text)` or `sprintf($text, $name)` after a manual lookup -> the `$parameters` argument of `trans()`.
- `(new \NumberFormatter($locale, \NumberFormatter::CURRENCY))->format($value)` inside a sentence -> `{value, number, currency}` in an ICU message.
- `$old = $translator->getLocale(); $translator->setLocale('de'); /* ... */ $translator->setLocale($old);` -> `LocaleSwitcher::runWithLocale('de', $callback)`, or `TemplatedEmail::locale('de')` for the Twig templates of an email.
- `explode(',', $_SERVER['HTTP_ACCEPT_LANGUAGE'])` to select a language -> `framework.set_locale_from_accept_language: true` with `framework.enabled_locales`.
- `$response->headers->set('Content-Language', $request->getLocale())` in each controller -> `framework.set_content_language_from_locale: true`.
- A `match ($this)` enum method that returns English labels -> `TranslatableMessage` objects from that method and `{{ role.label|trans }}` in Twig, or `TranslatableInterface` on the enum and `{{ role|trans }}`.
- A script that searches templates for `|trans` to find new keys -> `translation:extract --force <locale>` and `debug:translation <locale> --only-missing`.
- HTTP calls to the Crowdin or Lokalise API in a custom upload script -> `translation:push` and `translation:pull` with a provider bridge.
