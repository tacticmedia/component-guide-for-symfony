# Yaml (`symfony/yaml`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when code must read or write YAML files or strings, handle custom YAML tags, or check YAML syntax in a CI job. It parses YAML into PHP values, writes valid YAML, and reports the line of a syntax error. To convert objects to YAML, see [Serializer](serializer.md).

**Details:** [../details/yaml.md](../details/yaml.md)

## Why it exists

Code that splits YAML lines by hand or writes YAML with string formatting breaks on colons, quotes, anchors and multi-line values. The package parses a subset of YAML 1.2 into PHP values and dumps PHP values as valid YAML. It also reports the line of the first syntax error. Its command-line linter checks YAML files in CI.

## When to use it

- Read a YAML configuration file into a PHP array.
- Write a PHP array to a YAML file with block style and readable indentation.
- Parse YAML from users or other systems with limits on aliases and nesting depth.
- Read custom YAML tags, for example an include tag, and handle them in PHP code.
- Resolve PHP constants and enum cases in YAML files that the application owns.
- Check the syntax of all YAML files in a CI job, with GitHub annotations.
- Validate that a form field or an API property contains valid YAML.
- Show the line number of a YAML syntax error to the user.
- Read or write YAML in a command-line tool or a library without the full framework.

## Use it instead of

- `explode("\n", file_get_contents('config.yaml'))` and `explode(': ', $line)` for each line -> `Yaml::parseFile('config.yaml')`.
- `Yaml::parse(file_get_contents($path))` -> `Yaml::parseFile($path)`, which throws a `ParseException` for a missing file and adds the file name to some error messages.
- `$yaml .= sprintf("%s: %s\n", $key, $value);` in a loop -> `Yaml::dump($data, 4)`, which quotes values such as `yes`, `1.10` and `Note: read me`.
- A `foreach` loop over `glob('config/*.yaml')` with `Yaml::parseFile()` in a CI script -> `php bin/console lint:yaml config translations --format=github` or `vendor/bin/yaml-lint`.
- `try { Yaml::parse($input); } catch (ParseException) { ... }` in a controller to check user input -> `#[Assert\Yaml]` on the property, with the `{{ error }}` and `{{ line }}` message parameters.
- `constant($config['limit'])` or `Status::from($config['status'])` after the parse of a file that the application owns -> `!php/const` and `!php/enum` tags with `Yaml::PARSE_CONSTANT`.
- `new \DateTimeImmutable('@'.$config['published_at'])` after the parse -> `Yaml::parse($yaml, Yaml::PARSE_DATETIME)`.
- `base64_encode()` before the dump and `base64_decode()` after the parse of binary data -> the automatic `!!binary` tag of `Yaml::dump()` and `Yaml::parse()`.
