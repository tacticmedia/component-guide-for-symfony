# OptionsResolver (`symfony/options-resolver`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Defaults and resolution**: `setDefault()` and `setDefaults()` define options that have a default value. `resolve($options)` merges the given array with the defaults and returns the result. `resolve()` works on a clone of the resolver, thus each call is independent. Entry: `OptionsResolver::resolve()`.
- **Unknown options**: If the given array has a key that is not defined, `resolve()` throws `UndefinedOptionsException`. The message lists the defined options. If you must accept unknown keys, call `setIgnoreUndefined()`. Then `resolve()` removes these keys from the result. Entry: `OptionsResolver::setIgnoreUndefined()`.
- **Required and optional options**: `setRequired()` makes an option required. If the option has no default value and the caller does not give it, `resolve()` throws `MissingOptionsException`. `setDefined()` defines an option without a default value. The result contains this option only when the caller gives it. Entry: `OptionsResolver::setRequired()`, `OptionsResolver::setDefined()`.
- **Allowed types**: `setAllowedTypes()` accepts `bool`, `int`, `float`, `numeric`, `string`, `scalar`, `array`, `iterable`, `countable`, `callable`, `object`, `resource`, `null`, and class or interface names. Write `int[]` for an array of integers, `int|null` for a union, and `(int|string)[]` for an array of integers and strings. Do not write `?int` or `mixed`: the resolver rejects every value for these types. If the type is wrong, `resolve()` throws `InvalidOptionsException`. `addAllowedTypes()` adds types to the existing types. Entry: `OptionsResolver::setAllowedTypes()`.
- **Allowed values**: `setAllowedValues()` accepts a list of values and closures. The resolver compares values with `===`, thus `'1'` does not match `1`. A closure gets the value and returns `true` for a valid value. Use a `\Closure`, for example `is_numeric(...)`. The resolver uses a callable string such as `'is_numeric'` as a literal value. `Validation::createIsValidCallable()` converts Validator constraints into such a closure. If the value is not allowed, `resolve()` throws `InvalidOptionsException`, and `setInfo()` adds a text to its message. `addAllowedValues()` adds values to the existing values. Entry: `OptionsResolver::setAllowedValues()`.
- **Normalizers**: A normalizer changes the value after the type and value checks. It gets `Options $options` and the value, and it returns the new value. `setNormalizer()` replaces all normalizers of the option. `addNormalizer()` adds a normalizer after the existing normalizers; with `true` as the third argument, it adds the normalizer before them. Entry: `OptionsResolver::setNormalizer()`, `OptionsResolver::addNormalizer()`.
- **Default values that depend on other options**: If a default value is a closure and its first parameter has the type `Options`, `resolve()` calls the closure to calculate the default. In the closure, read other options with array access, for example `$options['encryption']`. A second parameter gets the previous default value, for example the value from a parent class. The closure does not run when the caller gives the option. A closure with no parameter type or with another type, for example the `empty_data` closure with `FormInterface`, is a plain value. Before you read an option that has no default value, check it with `isset()`. Otherwise, `NoSuchOptionException` occurs. If two closures read each other, `resolve()` throws `OptionDefinitionException`. Entry: `OptionsResolver::setDefault()`.
- **Nested options**: `setOptions('spool', function (OptionsResolver $spool, Options $parent): void {...})` defines the sub-options of an array option in a nested resolver. The nested resolver supports all features, and `$parent` gives access to the options of the parent level. Error messages show the path, for example `spool[type]`. If the given value is not an array, `resolve()` throws `InvalidOptionsException`. To add sub-options in a subclass, call `setOptions()` again. In a `setOptions()` closure, read parent options only through the second parameter. Array access on the first parameter throws `AccessException`. If an option of the parent level needs a nested value, use a lazy default, for example `setDefault('profiling', fn (Options $options) => 'file' === $options['spool']['type'])`. Entry: `OptionsResolver::setOptions()`.
- **Prototype options**: In a nested resolver, `setPrototype(true)` applies the definition to each element of a list, for example a list of database connections. The list keys can have any value. Error messages show the key, for example `connections[default][database]`. On the root resolver, `setPrototype(true)` throws `AccessException`. Entry: `OptionsResolver::setPrototype()`.
- **Deprecation**: `setDeprecated($option, $package, $version, $message)` sends a deprecation with `trigger_deprecation()`. The deprecation occurs when the caller gives the option, or when a lazy default or a normalizer reads the option. In the message, `%name%` is the option name. A closure message gets `Options` and the value, and it returns `''` for no deprecation. The resolver calls a closure message only for a value that the caller gives. If your own lazy default or normalizer reads a deprecated option, use `$options->offsetGet('name', false)` to prevent the deprecation. Entry: `OptionsResolver::setDeprecated()`.
- **Fluent definition**: `define('host')` returns an `OptionConfigurator` with `required()`, `default()`, `allowedTypes()`, `allowedValues()`, `normalize()`, `deprecated()`, `info()`, `options()` and `define()` for the next option. If the option is already defined, for example by a parent form type, `define()` throws `OptionDefinitionException`. To change an inherited option, use `setDefault()` and the other `set*()` methods. `allowedTypes()`, `allowedValues()` and `normalize()` replace earlier settings. `ignoreUndefined()` changes the full resolver, not only the option. Entry: `OptionsResolver::define()`.
- **Introspection**: `OptionsResolverIntrospector` reads the configuration of one option with `getDefault()`, `getLazyClosures()`, `getAllowedTypes()`, `getAllowedValues()`, `getNormalizers()`, `getDeprecation()` and `getNestedOptions()`. If the option has no such configuration, it throws `NoConfigurationException`. The `debug:form` command uses it. The resolver itself has `isRequired()`, `isMissing()`, `isDefined()`, `hasDefault()`, `isNested()`, `isDeprecated()`, `getInfo()`, `getDefinedOptions()`, `getRequiredOptions()` and `getMissingOptions()`. Entry: `Symfony\Component\OptionsResolver\Debug\OptionsResolverIntrospector`.
- **Form type options**: A form type or a type extension defines its options in `configureOptions(OptionsResolver $resolver): void`. Symfony clones the resolver of the parent type, then calls `configureOptions()` of the type and of each type extension. Give the options as the third argument of `createForm()` or `$builder->add()`. If the resolution fails, the exception message names the form type class. Entry: `AbstractType::configureOptions()`, `AbstractTypeExtension::configureOptions()`.
- **One resolver for each class**: If a constructor creates the resolver, the configuration runs for each new instance. If the configuration cost is too high, keep one configured resolver for each class in a static array. If the defaults contain objects, clear this array at intervals in long-running processes. Entry: a static `$resolversByClass` array (docs pattern).

## Entry points

- `Symfony\Component\OptionsResolver\OptionsResolver`: create it with `new OptionsResolver()`. It is not a service. In a form type, Symfony gives it to `configureOptions()`.
- Without FrameworkBundle: create `new OptionsResolver()` in any class, define the options, then call `resolve($options)`.
- `Symfony\Component\OptionsResolver\Options`: the type of the first parameter of lazy defaults (required there), of normalizers and of closure deprecation messages.
- `Symfony\Component\OptionsResolver\OptionConfigurator`: the return value of `OptionsResolver::define()`.
- `Symfony\Component\OptionsResolver\Debug\OptionsResolverIntrospector`: reads the configuration of one option.
- `Symfony\Component\OptionsResolver\Exception\ExceptionInterface`: all exceptions of the package implement it. `UndefinedOptionsException`, `MissingOptionsException` and `InvalidOptionsException` extend the package `InvalidArgumentException`, but none of them extends another. To catch all three, catch `ExceptionInterface` or the package `InvalidArgumentException`.
- `Symfony\Component\Form\AbstractType::configureOptions()` and `Symfony\Component\Form\AbstractTypeExtension::configureOptions()` (symfony/form).
- Console command (symfony/form): `debug:form [<class>] [<option>]` shows the options of a form type, or the definition of one option.
- This package has no config key, no PHP attribute, no service ID and no Twig function.

## Symbiotic packages

- [Form](../packages/form.md): form types and type extensions define their options with this resolver in `configureOptions()`, and `debug:form` shows them with `OptionsResolverIntrospector`.
- [Validator](../packages/validator.md): `Validation::createIsValidCallable()` converts constraints into a closure for `setAllowedValues()`.
- [Doctrine Bridge](../packages/doctrine-bridge.md): `EntityType` (through `DoctrineType`) requires the `class` option and normalizes the `em` and `query_builder` options with this resolver.
- [RateLimiter](../packages/rate-limiter.md): `RateLimiterFactory` validates each limiter configuration with `define()` and a nested `rate` option.
- [Ldap](../packages/ldap.md): the Ldap adapter classes resolve their options with this resolver, for example a lazy `port` default (636 for `ssl`, else 389).
- [UX Twig Component](../packages/ux-twig-component.md): a `#[PreMount]` hook can validate component props with this resolver and `setIgnoreUndefined(true)`, then return `$resolver->resolve($data) + $data`.
- [UX Autocomplete](../packages/ux-autocomplete.md): its type extension adds the `autocomplete` option to `ChoiceType` and `TextType` fields in `configureOptions()`.
- [Symfony Contracts](../packages/contracts.md): this package requires `symfony/deprecation-contracts`, whose `trigger_deprecation()` function sends the deprecations of `setDeprecated()`.
- [Config](../packages/config.md): Config validates configuration trees from files and bundles with a `TreeBuilder`, but OptionsResolver validates one options array at runtime.

## Changed in 8.0/8.1

- Removed in 8.0: nested options with `setDefault('spool', function (OptionsResolver $spool) {...})`. Use `setOptions('spool', function (OptionsResolver $spool) {...})` or `define('spool')->options(...)`. In 8.1, the resolver gives no error and no deprecation for the old pattern. The closure becomes the default value, and the resolver does not validate the given array.

## Docs

- https://symfony.com/doc/current/components/options_resolver.html
- https://symfony.com/doc/current/forms.html
- https://symfony.com/doc/current/form/create_custom_field_type.html
- https://symfony.com/doc/current/form/create_form_type_extension.html
- https://symfony.com/doc/current/form/use_empty_data.html
- https://symfony.com/doc/current/validation.html
