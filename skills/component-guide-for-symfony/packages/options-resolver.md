# OptionsResolver (`symfony/options-resolver`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when a PHP class or function takes an array of options and must apply defaults, check types and reject unknown keys. It also handles required keys, allowed values, computed defaults, nested arrays and deprecated options. Form field types also define their options with it. For configuration trees that merge several files, see [Config](config.md).

**Details:** [../details/options-resolver.md](../details/options-resolver.md)

## Why it exists

A class that takes an options array needs default values, required keys and type checks. A plain array merge adds the defaults, but it accepts a misspelled key without an error. With the package, you define each option in one place. It then validates the given array and returns the complete array.

## When to use it

- Merge the options that a caller gives with default values.
- Reject unknown or misspelled option keys with an exception.
- Validate required options, option types and allowed option values.
- Change an option value after validation, for example add a URL scheme to a host name.
- Add a custom option to a form field type, or to all fields of one type.
- Calculate the default value of an option from another option.
- Validate a nested options array, or a list of arrays with the same keys.
- Deprecate an option or some values of an option.
- Change the defaults, the allowed types or the value transformations of a parent class in a subclass.

## Use it instead of

- `$this->options = array_replace(['port' => 25], $options);` or `$options['port'] ?? 25` -> `setDefaults()` and `resolve()` (`OptionsResolver::resolve()`).
- `if (array_diff_key($options, $defaults)) { throw new \InvalidArgumentException('Unknown option'); }` -> the `UndefinedOptionsException` of `resolve()`, which lists the defined options.
- `if (!isset($options['host'])) { throw new \InvalidArgumentException('The "host" option is required.'); }` -> `setRequired('host')`.
- `if (!\is_int($options['port'])) { throw ...; }` or `\in_array($options['transport'], ['smtp', 'mail'], true)` -> `setAllowedTypes('port', 'int')` and `setAllowedValues('transport', ['smtp', 'mail'])`.
- `$options['host'] = 'https://'.$options['host'];` after the merge -> `setNormalizer('host', fn (Options $options, string $value): string => ...)`.
- `$options['port'] ??= 'ssl' === $options['encryption'] ? 465 : 25;` -> a lazy default: `setDefault('port', fn (Options $options): int => 'ssl' === $options['encryption'] ? 465 : 25)`.
- `foreach ($options['connections'] as $name => $connection) { $options['connections'][$name] += ['user' => 'root']; }` -> `setOptions('connections', ...)` with `setPrototype(true)` and `setDefaults(['user' => 'root'])`.
- `trigger_error('The "hostname" option is deprecated.', \E_USER_DEPRECATED)` -> `setDeprecated('hostname', 'acme/package', '1.2')`.
- A form type copy that changes one field -> a custom option in `configureOptions()`, given in the third argument of `createForm()`.
