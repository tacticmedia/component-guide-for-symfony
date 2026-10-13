# PropertyAccess (`symfony/property-access`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Property path syntax.** Dots separate object properties, and brackets mark array or `ArrayAccess` indexes, for example `children[0].firstName`. An index ends at the first `]`, so a path cannot address an array key that contains `]`. A path with a syntax error, such as `[a]b]`, throws `InvalidPropertyPathException`. Entry point: `Symfony\Component\PropertyAccess\PropertyPath`.
- **Brackets for arrays.** Write `[first_name]` for an array key. A property element on an array throws `NoSuchPropertyException`, and the message suggests the bracket form. A write to an array path creates the missing nested arrays. Entry points: `getValue()`, `setValue()`.
- **Read discovery.** For `first_name`, the accessor tries `getFirstName()`, `firstName()`, `isFirstName()`, `hasFirstName()`, `canFirstName()`, `__get()`, the public property, then `__call()` if enabled. A read method must be public, have no required parameter and not return `void` or `never`. Entry point: `getValue()`.
- **Write discovery.** If no adder and remover pair applies, the accessor tries `setFirstName()`, `firstName($value)`, a public property that is not `readonly`, `__set()`, then `__call()` if enabled. A setter must be public and accept one argument. If a `private(set)` or `protected(set)` property has no setter, `setValue()` throws an `\Error`, and `isWritable()` returns `false`. Entry point: `setValue(&$objectOrArray, $propertyPath, $value)`.
- **Adders and removers.** If the new value is iterable and both `addChild()` and `removeChild()` exist, they have priority over `setChildren()`. The accessor compares the items with `===`. It calls the remover for each removed item and the adder for each added item. If a Form field holds a collection object, set `by_reference` to `false` so that the form calls `addChild()` and `removeChild()`. Entry point: `setValue()`.
- **Singular names.** By default, the accessor finds the singular of the property name with `EnglishInflector`, so only English names work. If only one method of the pair exists and no other write access exists, `setValue()` throws `NoSuchPropertyException` that names the missing method. Entry point: `Symfony\Component\String\Inflector\EnglishInflector`.
- **Custom discovery rules.** Create a PropertyInfo `ReflectionExtractor` with other adder and remover prefixes or another inflector. Give it to the accessor as the write extractor. Examples: `new ReflectionExtractor(null, null, ['join', 'leave'])`, `new ReflectionExtractor(inflector: new FrenchInflector())`. Entry point: `PropertyAccessorBuilder::setWriteInfoExtractor()`.
- **Null-safe elements.** Add `?` after an element (`person?.firstName`, `[age?]`). If that value is `null` or missing, `getValue()` returns `null` and does not throw. Use `?` in read paths only. If the value of an element with `?` is `null`, `setValue()` throws `NoSuchPropertyException` or `NoSuchIndexException`. Entry point: `PropertyPath::isNullSafe()`.
- **Exception options.** By default, a missing index returns `null` and a missing property throws `NoSuchPropertyException`. `enableExceptionOnInvalidIndex()` makes a read of a missing index throw `NoSuchIndexException`; `setValue()` still creates the index. `disableExceptionOnInvalidPropertyPath()` makes a read of a missing property return `null`, and a write to it does nothing. Entry point: `PropertyAccessorBuilder`.
- **Null values in the middle of a path.** The exception options do not apply to a `null` value in the middle of a property path. Such a value causes `UnexpectedTypeException` unless the element has `?`. Entry point: `Symfony\Component\PropertyAccess\Exception\UnexpectedTypeException`.
- **Magic methods.** `__get()` and `__set()` are enabled by default, and `__call()` is disabled. If you implement `__get()`, also implement `__isset()`. Entry points: `enableMagicCall()`, `enableMagicGet()`, `enableMagicSet()`, `enableMagicMethods()`, `disableMagicMethods()` and the `PropertyAccessor::MAGIC_*` constants.
- **Type errors.** If a setter or a typed property rejects the value, `setValue()` throws `InvalidTypeException` with the expected type, the given type and the property path. If a setter rejects `DateTime` or `DateTimeImmutable`, the accessor converts the value to the other class and tries again. Entry point: `Symfony\Component\PropertyAccess\Exception\InvalidTypeException`.
- **Uninitialized properties.** A read of an uninitialized typed property, or a getter that returns `null` for a non-nullable return type, throws `UninitializedPropertyException`. Entry point: `Symfony\Component\PropertyAccess\Exception\UninitializedPropertyException`.
- **Checks without exceptions.** If the accessor cannot read or write the path, `isReadable()` and `isWritable()` return `false` instead of an exception. A path with a syntax error still throws `InvalidPropertyPathException`. Entry points: `isReadable()`, `isWritable()`.
- **Property path tools and cache.** `PropertyPathBuilder` edits a property path, and `PropertyPath::append()` joins two parts. With `setCacheItemPool()`, the accessor stores the access information in a PSR-6 pool. Entry points: `PropertyPathBuilder`, `PropertyAccessor::createCache()`.

## Entry points

- `Symfony\Component\PropertyAccess\PropertyAccessorInterface`: autowire it in a Symfony application (service `property_accessor`).
- Without FrameworkBundle: `Symfony\Component\PropertyAccess\PropertyAccess::createPropertyAccessor()` and `PropertyAccess::createPropertyAccessorBuilder()`.
- `Symfony\Component\PropertyAccess\PropertyAccessorBuilder`: magic method, exception, cache and extractor options.
- `Symfony\Component\PropertyAccess\PropertyAccessor`: constants `MAGIC_GET`, `MAGIC_SET`, `MAGIC_CALL`, `DISALLOW_MAGIC_METHODS`, `DO_NOT_THROW`, `THROW_ON_INVALID_INDEX`, `THROW_ON_INVALID_PROPERTY_PATH`; static `createCache()`. In application code, use the builder instead of `new PropertyAccessor(...)`.
- `Symfony\Component\PropertyAccess\PropertyPath`, `PropertyPathInterface`, `PropertyPathBuilder`.
- `Symfony\Component\PropertyAccess\Exception\ExceptionInterface`, `AccessException`, `NoSuchPropertyException`, `NoSuchIndexException`, `UninitializedPropertyException`, `UnexpectedTypeException`, `InvalidTypeException`, `InvalidPropertyPathException`.
- Config `framework.property_access`: `enabled`, `magic_call` (default `false`), `magic_get` (`true`), `magic_set` (`true`), `throw_exception_on_invalid_index` (`false`), `throw_exception_on_invalid_property_path` (`true`).
- Cache pool service `cache.property_access`: APCu through `PropertyAccessor::createCache()` when debug is off (a `NullAdapter` if APCu is not enabled), `ArrayAdapter` when debug is on.
- Form options that take a property path: `property_path`, `choice_label`, `choice_value`, `group_by`, `preferred_choices`, `hash_property_path`, `step_property_path`.
- Serializer: the `#[SerializedPath]` attribute and the `unwrap_path` context key take a property path.
- Validator options that take a property path: `propertyPath`, `minPropertyPath`, `maxPropertyPath`, `ibanPropertyPath`.
- Security options that take property paths: `signature_properties`, `username_path`, `password_path`.

## Symbiotic packages

- [Form](../packages/form.md): Form requires PropertyAccess; the default data mapper reads and writes each mapped field through its `property_path`, and a string `choice_label` is a property path.
- [Serializer](../packages/serializer.md): `ObjectNormalizer` reads and writes attributes with PropertyAccess and throws `LogicException` without it, and `#[SerializedPath]` and `unwrap_path` take property paths.
- [Validator](../packages/validator.md): the comparison constraints, `Range` and `Bic` read the other value through `propertyPath`, `minPropertyPath`, `maxPropertyPath` or `ibanPropertyPath`, which need PropertyAccess.
- [PropertyInfo](../packages/property-info.md): PropertyAccess requires its `ReflectionExtractor` to find accessors; use PropertyInfo for the types of a class, and PropertyAccess for the values of an object.
- [FrameworkBundle](../packages/framework-bundle.md): FrameworkBundle registers the `property_accessor` service, its autowiring alias, the `framework.property_access` configuration and the `cache.property_access` pool.
- [Security](../packages/security-bundle.md): the login link and remember-me `signature_properties` and the `json_login` `username_path` and `password_path` options are property paths that the `property_accessor` service reads.
- [ObjectMapper](../packages/object-mapper.md): `ObjectMapper` accepts an optional `PropertyAccessorInterface` to read source values and write target values.
- [String](../packages/string.md): its `EnglishInflector` gives the singular of a property name, so the accessor finds `addTag()` and `removeTag()` for `tags`; another inflector needs a custom extractor.
- [Cache](../packages/cache.md): `PropertyAccessor::createCache()` builds an APCu adapter (a `NullAdapter` if APCu is not enabled), and `setCacheItemPool()` accepts any PSR-6 pool for the access information.
- [Doctrine Bridge](../packages/doctrine-bridge.md): a string `choice_label` on `EntityType` is a property path that the choice list factory of Form reads with PropertyAccess.
- [UX Live Component](../packages/ux-live-component.md): the hydrator reads and writes `LiveProp` values and writable paths such as `post.title` with PropertyAccess.
- [UX Twig Component](../packages/ux-twig-component.md): the component factory sets the props that `mount()` does not use on writable component properties with `isWritable()` and `setValue()`.
- [UX Autocomplete](../packages/ux-autocomplete.md): the autocompleter reads string `choice_label`, `choice_value` and `group_by` options as property paths with PropertyAccess.
- [JsonPath](../packages/json-path.md): use JsonPath to query JSON text, and `PropertyAccessorInterface::getValue()` to read one value at a fixed path of PHP data.

## Changed in 8.0/8.1

- 8.1 adds `PropertyPath::append($basePath, $subPath)`. Use it instead of hand-rolled path concatenation. It ignores an empty part, joins an `[index]` part without a dot and joins other parts with a dot. `Symfony\Component\Validator\Util\PropertyPath::append()` has the same behavior. Serializer 8.1 uses the new method and conflicts with property-access lower than 8.1.

## Docs

- https://symfony.com/doc/current/components/property_access.html
- https://symfony.com/doc/current/reference/configuration/framework.html
- https://symfony.com/doc/current/components/property_info.html
- https://symfony.com/doc/current/forms.html
- https://symfony.com/doc/current/reference/forms/types/form.html
- https://symfony.com/doc/current/reference/forms/types/choice.html
- https://symfony.com/doc/current/form/form_collections.html
- https://symfony.com/doc/current/form/data_mappers.html
- https://symfony.com/doc/current/form/create_form_type_extension.html
- https://symfony.com/doc/current/form/form_flow.html
- https://symfony.com/doc/current/serializer.html
- https://symfony.com/doc/current/reference/constraints/GreaterThan.html
- https://symfony.com/doc/current/reference/constraints/Range.html
- https://symfony.com/doc/current/object_mapper.html
- https://symfony.com/doc/current/security/login_link.html
- https://symfony.com/doc/current/security/remember_me.html
- https://symfony.com/doc/current/reference/configuration/security.html
- https://symfony.com/bundles/ux-live-component/current/index.html
