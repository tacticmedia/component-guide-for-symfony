# Yaml (`symfony/yaml`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Parse a string:** `Yaml::parse()` returns a PHP value. Mappings and sequences become arrays, and an empty document gives `null`. Plain values become `int`, `float`, `bool`, `null` or `string`. Only `true` and `false` are booleans, so `yes`, `no`, `on` and `off` stay strings. A date such as `2016-05-27` becomes a Unix timestamp. Entry point: `Yaml::parse($yaml, $flags)`.
- **Parse a file:** `Yaml::parseFile()` throws a `ParseException` when the file does not exist or PHP cannot read it. For some syntax errors, for example tabs as indentation, the message also gives the file name. Entry point: `Yaml::parseFile($path, $flags)`.
- **Dump:** `Yaml::dump()` writes nested arrays in block style down to level `$inline` (default 2), and deeper levels in flow style (`{ }`, `[ ]`). `$indent` sets the number of spaces for each level (default 4). The dumper quotes strings that YAML can read as a different value, for example `'yes'`, `'1.10'` or `'a: b'`. `Dumper::dump()` has the default `$inline = 0`, so it writes one flow line. A parse and dump cycle does not keep comments, anchors, aliases or merge keys. Entry point: `Yaml::dump($data, $inline, $indent, $flags)`.
- **Parse flags:** combine `Yaml::PARSE_*` constants with `|`. `PARSE_CONSTANT` resolves `!php/const` and `!php/enum`. `PARSE_CUSTOM_TAGS` returns `TaggedValue` objects. `PARSE_DATETIME` returns `\DateTimeImmutable` objects, in UTC when the date has no time zone. `PARSE_OBJECT_FOR_MAP` returns `stdClass` objects for mappings. `PARSE_EXCEPTION_ON_INVALID_TYPE` throws a `ParseException` for a `!php/object`, `!php/const` or `!php/enum` tag without its flag, instead of a `null` value. Entry point: `Yaml::PARSE_CONSTANT | Yaml::PARSE_CUSTOM_TAGS`.
- **Dump flags:** combine `Yaml::DUMP_*` constants with `|`. `DUMP_MULTI_LINE_LITERAL_BLOCK` writes multi-line strings as literal blocks (`|`, or `|-` when the string has no final newline). `DUMP_COMPACT_NESTED_MAPPING` writes a list of mappings as `- key: value` items. `DUMP_NULL_AS_TILDE` writes `~` for `null`, and `DUMP_NULL_AS_EMPTY` writes an empty value. The two null flags together throw an `\InvalidArgumentException`. `DUMP_NUMERIC_KEY_AS_STRING` quotes integer keys, and `DUMP_EMPTY_ARRAY_AS_SEQUENCE` writes `[]` instead of `{}`. `DUMP_FORCE_DOUBLE_QUOTES_ON_VALUES` puts double quotes around string values, but numeric and empty strings keep single quotes. In block style, it also puts double quotes around string keys. Entry point: `Yaml::dump($data, 4, 2, Yaml::DUMP_MULTI_LINE_LITERAL_BLOCK)`.
- **Objects in dumps:** by default, the dumper writes an object or a resource as `null` and gives no error. `\DateTimeInterface` values become ISO 8601 timestamps, and enum cases become `!php/enum` tags. `DUMP_OBJECT_AS_MAP` writes `stdClass` and `ArrayObject` objects as mappings. `DUMP_EXCEPTION_ON_INVALID_TYPE` throws a `DumpException` for other objects and for resources. Entry point: `Yaml::DUMP_OBJECT_AS_MAP`.
- **Custom tags:** with `PARSE_CUSTOM_TAGS`, a value such as `!my_tag { foo: bar }` becomes a `TaggedValue` object with `getTag()` and `getValue()`. Without the flag, a custom tag throws a `ParseException`. The dumper writes a `TaggedValue` as `!my_tag` followed by its value. Entry point: `Symfony\Component\Yaml\Tag\TaggedValue`.
- **Built-in tags:** `!!str` keeps a value as a string, `!!float` makes a float, and `!!binary` decodes base64 data. The dumper writes strings that are not valid UTF-8 as `!!binary`. Other `!!` tags, such as `!!set` or `!!int`, throw a `ParseException`. Entry point: `logo: !!binary iVBORw0KGgo...` in the YAML text.
- **PHP constants and enums:** with `PARSE_CONSTANT`, `!php/const E_ALL` gives the constant value and `!php/enum App\Status::Draft` gives the enum case. `!php/enum App\Status::Draft->value` gives the backed value. `!php/enum App\Status` gives the list of case objects from `cases()`. The docs example shows values. An unknown constant or enum throws a `ParseException`. Without the flag, these tags give `null`. Entry point: `Yaml::parse($yaml, Yaml::PARSE_CONSTANT)`.
- **PHP objects:** `DUMP_OBJECT` writes an object as a `!php/object` tag with `serialize()`. `PARSE_OBJECT` reads the tag back with `unserialize()`. If the YAML is not trusted, do not enable `PARSE_OBJECT` or `PARSE_CONSTANT`. Entry point: `Yaml::DUMP_OBJECT`, `Yaml::PARSE_OBJECT`.
- **Untrusted input:** `PARSE_EXCEPTION_ON_ALIAS` rejects each alias (`*name`) with a `ParseException`, also an alias in a merge key (`<<: *base`). It does not reject anchors, or a merge key whose value is a mapping, such as `<<: { a: 1 }`. The parser also throws a `ParseException` when a document has more than 128 nesting levels or more than 128 alias resolutions of collections. Aliases of scalar values do not count. Entry point: `Yaml::PARSE_EXCEPTION_ON_ALIAS`, `Yaml::parse($yaml, 0, $maxNestingLevel, $maxAliasesForCollections)`.
- **Errors:** a syntax error throws a `ParseException`. Its message has the form `Duplicate key "a" detected at line 2 (near "a: 2").`, and `getParsedLine()` returns the line. `getSnippet()` and `getParsedFile()` throw a `TypeError` when the parser did not set that value. Dump errors throw a `DumpException`. Both classes implement `ExceptionInterface`. Entry point: `catch (ParseException $e)`.
- **Strict syntax:** the parser throws a `ParseException` for a duplicate key and for a key that is a boolean, `null` or a float. It also throws for tabs as indentation, and for a plain value that starts with `@`, `` ` ``, `|`, `>` or `%`. A plain mapping value that contains `: ` also throws. Quote such keys and values. Entry point: `'true': 'yes'` in the YAML text.
- **Supported YAML subset:** the parser reads block and flow collections, also flow collections over several lines. It reads anchors, aliases, merge keys (`<<`), `|` and `>` block scalars, multi-line quoted strings and comments. Numbers can use `0o` octal, `0x` hexadecimal and `_` digit separators; `014` stays a string. A string or file can hold one document, with an optional `---` start marker and `...` end marker. Multiple documents, complex keys (`? `) and `%TAG` directives throw a `ParseException`. The parser does not support tag references such as `!<tag:example.com,2000:foo>`: without `PARSE_CUSTOM_TAGS` they throw, and with it they give an incorrect `TaggedValue`. Entry point: `Yaml::parse()`.
- **Lint command:** `lint:yaml` checks files, directories (`*.yml` and `*.yaml`) or STDIN (`-`). It parses with `PARSE_CONSTANT`, and `--parse-tags` adds `PARSE_CUSTOM_TAGS`. `--exclude` skips files, and the exit code is 1 when a file has errors. `--format` accepts `txt`, `json` or `github`, and the command selects `github` in GitHub Actions. The command reports an `E_USER_DEPRECATED` notice from the parse as an error. Entry point: `php bin/console lint:yaml config translations`, `vendor/bin/yaml-lint`.

## Entry points

- Static methods `Symfony\Component\Yaml\Yaml::parse()`, `Yaml::parseFile()` and `Yaml::dump()`, and the `Yaml::PARSE_*` and `Yaml::DUMP_*` flag constants.
- Classes `Symfony\Component\Yaml\Parser` (constructor arguments `$maxNestingLevel` and `$maxAliasesForCollections`) and `Symfony\Component\Yaml\Dumper` (constructor argument `$indentation`). The component registers no service, so create these objects with `new`.
- Without FrameworkBundle: call the static `Yaml` methods, or create `Parser` and `Dumper` with `new`. To lint files, run `vendor/bin/yaml-lint`, or call `addCommand(new LintCommand())` in a console application.
- Value class `Symfony\Component\Yaml\Tag\TaggedValue` for custom tags.
- Exceptions `Symfony\Component\Yaml\Exception\ParseException` and `Symfony\Component\Yaml\Exception\DumpException`, and the interface `Symfony\Component\Yaml\Exception\ExceptionInterface`.
- Console command `lint:yaml` (`Symfony\Component\Yaml\Command\LintCommand`; in an application, `Symfony\Bundle\FrameworkBundle\Command\YamlLintCommand` with the service ID `console.command.yaml_lint`). In an application, the command also accepts bundle paths such as `@AcmeDemoBundle`.
- Binary `vendor/bin/yaml-lint` for projects without a console application; it needs `symfony/console`.
- Validator constraint `#[Assert\Yaml(flags: Yaml::PARSE_CONSTANT)]` (`Symfony\Component\Validator\Constraints\Yaml`, from `symfony/validator`).
- Twig filters `yaml_encode` and `yaml_dump` (`Symfony\Bridge\Twig\Extension\YamlExtension`, from `symfony/twig-bridge`).
- Serializer formats `yaml` and `yml` (`Symfony\Component\Serializer\Encoder\YamlEncoder`, from `symfony/serializer`).
- Install the package with `composer require symfony/yaml`. The component has no attribute and no `framework` configuration key.

## Symbiotic packages

- [Console](../packages/console.md): `LintCommand` is a Console command, so `lint:yaml` and `vendor/bin/yaml-lint` need `symfony/console`.
- [FrameworkBundle](../packages/framework-bundle.md): it registers `lint:yaml` with support for `@BundleName` paths, and its `debug:config` and `config:dump-reference` commands print YAML with this component.
- [DependencyInjection](../packages/dependency-injection.md): `YamlFileLoader` parses service files with `PARSE_CONSTANT | PARSE_CUSTOM_TAGS` and turns tags such as `!tagged_iterator` into service arguments.
- [Routing](../packages/routing.md): `YamlFileLoader` parses route files with `PARSE_CONSTANT`, so `!php/const` works in route requirements.
- [Config](../packages/config.md): `YamlReferenceDumper` prints a configuration tree as a YAML reference, and the docs show custom Config loaders that call `Yaml::parse()`.
- [Serializer](../packages/serializer.md): `YamlEncoder` encodes and decodes the `yaml` and `yml` formats with `Dumper` and `Parser`; use it for objects, because `Yaml::dump()` writes most objects as `null`.
- [Validator](../packages/validator.md): `#[Assert\Yaml]` parses a string with this component and adds the parser message and line to the violation; YAML mapping files also need this component.
- [Translation](../packages/translation.md): `YamlFileLoader` and `YamlFileDumper` read and write YAML catalogs such as `messages.en.yaml`, and `lint:yaml translations` checks their syntax.
- [Twig Bridge](../packages/twig-bridge.md): the `yaml_encode` and `yaml_dump` filters dump a value with `Dumper`; `yaml_dump` adds the type, for example `%array%`.
- [TwigBundle](../packages/twig-bundle.md): it registers the `twig.extension.yaml` service, and removes it when the `Symfony\Component\Yaml\Yaml` class does not exist.
- [Symfony Language Tools](../packages/language-tools.md): `lint:yaml` checks the YAML syntax, and Symfony Language Tools checks the keys and values in `config/` against the bundle schemas.

## Changed in 8.0/8.1

- **8.0:** a duplicate mapping key always throws a `ParseException`, also when its value is `null`. Remove the second key.
- **8.0.12 and 8.1.0 (security fixes; the component CHANGELOG lists them under 5.4):** `Yaml::parse()`, `Yaml::parseFile()` and the `Parser` constructor accept `$maxNestingLevel` and `$maxAliasesForCollections` (default 128 for each). The flag `Yaml::PARSE_EXCEPTION_ON_ALIAS` rejects aliases in untrusted YAML.
- **8.0, Console:** `Application::addCommand()` replaces the removed `Application::add()`. In a standalone lint script, call `addCommand(new LintCommand())`, or run `vendor/bin/yaml-lint`. The `lint.php` example in the Yaml docs uses `add()`.
- **8.1.5:** the parser reads `0X1F` with an uppercase `X` as a string, not as a hexadecimal number. Write `0x1F`.

## Docs

- https://symfony.com/doc/current/components/yaml.html
- https://symfony.com/doc/current/reference/formats/yaml.html
- https://symfony.com/doc/current/reference/constraints/Yaml.html
- https://symfony.com/doc/current/translation.html
- https://symfony.com/doc/current/serializer/encoders.html
- https://symfony.com/doc/current/reference/twig_reference.html
- https://symfony.com/doc/current/configuration.html
- https://symfony.com/doc/current/service_container.html
