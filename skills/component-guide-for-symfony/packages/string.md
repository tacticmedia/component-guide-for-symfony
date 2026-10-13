# String (`symfony/string`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when code must cut or measure UTF-8 text by visible characters, make URL slugs, or convert names between case styles. It also transliterates text to ASCII, gives plural and singular forms of nouns, makes random codes and delays string computation. For locale data such as country names, see [Intl](intl.md).

**Details:** [../details/string.md](../details/string.md)

## Why it exists

PHP byte functions count and cut bytes, and the multibyte functions work on code points. Both can split a character that a reader sees as one, for example an emoji or a letter with an accent. The package wraps a string in an immutable object that works on bytes, code points or grapheme clusters. It also gives a slugger, ASCII transliteration and the singular and plural forms of nouns.

## When to use it

- Make a URL slug or a safe file name from a title or an uploaded file name.
- Count, cut, pad or compare text with accents, emoji or non-Latin scripts.
- Shorten a text for a preview at a word boundary and add an ellipsis.
- Convert names between camelCase, snake_case, kebab-case and PascalCase.
- Get the plural or singular form of an English, French or Spanish noun.
- Transliterate text to ASCII, for example to normalize a username or a search key.
- Generate a random code from a custom set of characters.
- Delay an expensive string computation until code reads the value.
- Measure the column width of text for aligned terminal output, also with color codes.

## Use it instead of

- `strlen($text)`, `substr($text, 0, 50)` or `strrev($text)` on UTF-8 text -> `u($text)->length()`, `u($text)->slice(0, 50)` or `u($text)->reverse()` (`UnicodeString` counts grapheme clusters, not bytes)
- `mb_strtolower($text, 'UTF-8')`, `mb_substr()` or `str_pad()` on UTF-8 text -> `u($text)->lower()`, `u($text)->slice()` or `u($text)->padEnd()`
- `strtolower(trim(preg_replace('/[^A-Za-z0-9]+/', '-', $title), '-'))` -> `$slugger->slug($title)->lower()` with an autowired `SluggerInterface`
- `iconv('UTF-8', 'ASCII//TRANSLIT', $text)` -> `u($text)->ascii()`
- `substr($text, 0, 100).'...'` -> `u($text)->truncate(100, '…', TruncateMode::WordBefore)`
- `lcfirst(str_replace(' ', '', ucwords(str_replace(['-', '_'], ' ', $name))))` -> `u($name)->camel()` (or `snake()`, `kebab()`, `pascal()`)
- `$noun.'s'` or a custom table of irregular plurals -> `(new EnglishInflector())->pluralize($noun)` (an array of candidates)
- `substr(str_shuffle($alphabet), 0, 8)` or a loop with `random_int()` -> `ByteString::fromRandom(8, $alphabet)`
- A class with a `__toString()` method that computes and caches a value -> `LazyString::fromCallable($callback)`
- `str_starts_with($name, 'get') ? $name : 'get'.$name` or `substr($file, strlen('file-'))` -> `u($name)->ensureStart('get')` or `u($file)->trimPrefix('file-')`
