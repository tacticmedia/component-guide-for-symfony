# Symfony Polyfill (`symfony/polyfill-*`)

**Applies to:** Symfony Polyfill 1.43, Symfony 8.1

**Elevator pitch:** Use when PHP code must run on an older PHP version but call newer PHP functions, or run on a server without some PHP extensions. Each small package defines the missing functions, classes and constants in plain PHP. It covers functions such as str_contains and array_first, and the mbstring, intl, iconv, ctype, uuid and deepclone extensions.

**Details:** [../details/polyfill.md](../details/polyfill.md)

## Why it exists

A library that supports several PHP versions cannot call a function that its oldest PHP version does not have. Some servers also do not have an extension, for example mbstring or intl. Each polyfill package defines the missing functions, classes and constants in plain PHP, but only when PHP does not define them.

## When to use it

- In a library that supports older PHP versions, call newer functions such as str_contains, array_find or array_first.
- On a server without the mbstring, iconv or ctype extension, run code that calls the functions of these extensions.
- Without the intl extension, convert an internationalized domain name to ASCII.
- Without the intl extension, format English messages, numbers or dates.
- Without the uuid extension, create, parse or compare UUIDs with the uuid functions.
- Without the deepclone extension, deep-clone or hydrate objects with the deepclone functions.
- On PHP 8.1 to 8.5, use the stream polling API or the duration class of PHP 8.6.
- On older PHP versions, read new PHP attributes such as Override or Deprecated through reflection.
- Remove the polyfill packages that your minimum PHP version and your extensions make unnecessary.

## Use it instead of

- `if (!function_exists('str_contains')) { function str_contains(...) { ... } }` -> `symfony/polyfill-php80`, which defines `str_contains()` only when PHP does not define it.
- `function_exists('mb_strlen') ? mb_strlen($s, 'UTF-8') : strlen($s)` -> a direct `mb_strlen($s)` call, with `symfony/polyfill-mbstring` when the extension can be missing.
- `reset($array)` or `$array[array_key_first($array)]` -> `array_first($array)` (`symfony/polyfill-php85`), which returns `null` for an empty array.
- A `foreach` loop that returns the first element that matches a condition -> `array_find($array, $callback)` (`symfony/polyfill-php84`).
- `max($min, min($max, $value))` -> `clamp($value, $min, $max)` (`symfony/polyfill-php86`), which throws a `\ValueError` on PHP 8 when `$max` is less than `$min`.
- `json_decode($json)` followed by a `json_last_error()` check -> `json_validate($json)` (`symfony/polyfill-php83`).
- A hand-written Punycode encoder for a domain name -> `idn_to_ascii($domain)` (`symfony/polyfill-intl-idn`).
- `sprintf('%04x%04x-%04x-...', mt_rand(...), ...)` to make a UUID -> `uuid_create(\UUID_TYPE_RANDOM)` (`symfony/polyfill-uuid`) in a library, or `Uuid::v7()` from Uid in an application.
- `unserialize(serialize($object))` to copy an object -> `deepclone_from_array(deepclone_to_array($object))` (`symfony/polyfill-deepclone`) in a library, or `DeepCloner::deepClone($object)` from VarExporter in an application.
- `ReflectionClass::newInstanceWithoutConstructor()` followed by `ReflectionProperty::setValue()` calls -> `deepclone_hydrate(Foo::class, ['name' => $name])` (`symfony/polyfill-deepclone`).
