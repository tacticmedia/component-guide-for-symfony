# Symfony UX Translator (`symfony/ux-translator`)

**Applies to:** Symfony UX 3.5

**Elevator pitch:** Use when JavaScript code in the browser must show translated text with the same message keys, plurals and ICU formats as the PHP code. It writes the translation catalogs to a JavaScript module when the cache warms up, and a small JavaScript function reads them. For text that the server renders, see [Translation](translation.md).

**Details:** [../details/ux-translator.md](../details/ux-translator.md)

## Why it exists

The translator of the application runs on the server, so JavaScript code cannot read the translation catalogs. The package writes the catalogs to a JavaScript module when the cache warms up. Its translation function uses the same keys, domains, locales and plural syntax as the PHP translator. It formats ICU messages with FormatJS.

## When to use it

- Translate text in JavaScript or TypeScript with the same keys as the PHP and Twig code.
- Show translated text that JavaScript builds, for example in a widget, a toast or a client-side error message.
- Format plurals, select cases, ordinals, dates, percentages and prices in the browser with ICU MessageFormat.
- Use the request locale and the fallback locales of the application in JavaScript.
- Check translation keys, domains, locales and parameters at compile time with TypeScript.
- Send only some domains, keys or locales to the browser to make the JavaScript bundle smaller.

## Use it instead of

- A hard-coded message object in JavaScript, such as `const labels = { en: { save: 'Save' }, fr: { save: 'Enregistrer' } }` -> the dumped `messages` and `trans('save')` from `assets/translator.js`.
- `data-label="{{ 'cart.add'|trans }}"` attributes in Twig, read with `this.element.dataset.label` -> `trans('cart.add')` in the JavaScript module.
- A Symfony controller that returns `$translator->getCatalogue($locale)->all('messages')` as JSON, plus `fetch()` in JavaScript -> the cache warm-up dump `var/translations/index.js`.
- `` count === 1 ? '1 item' : `${count} items` `` -> `{count, plural, one {# item} other {# items}}` in `messages+intl-icu.en.yaml` and `trans('cart.items', { count })`.
- `` element.innerHTML = `Hello ${name}!` `` -> `trans('say_hello', { name })` with `say_hello: 'Hello {name}!'` in an `+intl-icu` file, and `element.textContent`.
- `new Intl.NumberFormat(locale, { style: 'currency', currency: 'EUR' }).format(price)` inside a sentence -> `{price, number, ::currency/EUR}` in an ICU message.
- `navigator.language` to guess the locale -> `<html lang="{{ app.request.locale|replace({'_': '-'}) }}">`, which `createTranslator()` reads with `getDefaultLocale()`.
- A separate JavaScript i18n library (for example i18next) with its own JSON message files -> the Symfony translation files and `createTranslator()`.
