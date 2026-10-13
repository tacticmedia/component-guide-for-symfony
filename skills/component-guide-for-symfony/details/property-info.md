# PropertyInfo (`symfony/property-info`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Extractor chain:** `PropertyInfoExtractor` takes five lists of extractors: list, type, description, access and initializable. Each method asks the extractors of its list in order and returns the first result that is not `null`. Thus the order of the extractors decides the result. Entry point: `Symfony\Component\PropertyInfo\PropertyInfoExtractor`.
- **Type objects:** `getType()` returns one TypeInfo `Type` or `null`. For a `?string` property, the result is a `NullableType` that casts to `'null|string'`. Check the result with `isIdentifiedBy(TypeIdentifier::STRING)`, `isNullable()` or `instanceof CollectionType`. If the result is a `NullableType`, call `getWrappedType()` before the `instanceof` check. Entry point: `Symfony\Component\PropertyInfo\PropertyTypeExtractorInterface::getType()`.
- **Reflection extractor:** it reads native PHP types and the names of accessor and mutator methods. Its `getType()` first reads the setter, adder or remover parameter, then a `get` accessor, then the constructor argument. After that, it reads the `set` hook parameter, the declared type, an `is`, `has` or `can` accessor, and the default value. If the mutator is an adder or a remover, the type is a list of the parameter type. Entry point: `Symfony\Component\PropertyInfo\Extractor\ReflectionExtractor`.
- **Reflection extractor options:** the constructor arguments set the method prefixes (default `add`/`remove`/`set` and `get`/`is`/`has`/`can`), the visibility flags (default `ALLOW_PUBLIC`) and the magic method flags (default `ALLOW_MAGIC_GET | ALLOW_MAGIC_SET`). The inflector (default `EnglishInflector`) changes `$tags` to `tag` to find `addTag()` and `removeTag()`. Entry point: `new ReflectionExtractor(accessFlags: ReflectionExtractor::ALLOW_PUBLIC | ReflectionExtractor::ALLOW_PRIVATE)`.
- **PHPDoc extractor:** it reads `@var` on a property, `@return` on an accessor and `@param` on a mutator or a promoted constructor argument. If `phpdocumentor/reflection-docblock` is not installed, its constructor throws a `LogicException`. It also returns descriptions, and its `getDocBlock()` returns a phpDocumentor `DocBlock` object, not a string. Entry point: `Symfony\Component\PropertyInfo\Extractor\PhpDocExtractor`.
- **PHPStan extractor:** it reads the same PHPDoc tags with the PHPStan parser, for example `list<Foo>`, `array<string, Foo>` and `Foo[]`. It needs `phpstan/phpdoc-parser` and `phpdocumentor/type-resolver`. It returns types, constructor argument types and descriptions, but it does not implement `PropertyDocBlockExtractorInterface`. If `$allowPrivateAccess` is `false`, it reads only public properties and methods. Entry point: `Symfony\Component\PropertyInfo\Extractor\PhpStanExtractor`.
- **Serializer extractor:** it lists the properties of the Serializer groups in the context key `serializer_groups`. Without that key, it returns `null`, and the next list extractor answers. The value `['*']` or `null` selects all attributes. It always skips attributes with `#[Ignore]`. Entry point: `$serializerExtractor->getProperties(Foo::class, ['serializer_groups' => ['read']])`.
- **Constructor extractor:** this type extractor asks constructor argument extractors for the type of the constructor argument with the property name. Put it before the other type extractors, because a constructor `@param` can differ from the property `@var`. Entry point: `new ConstructorExtractor([$phpStanExtractor, $reflectionExtractor])`.
- **Access and initialization:** `isReadable()` and `isWritable()` return `true` for a property that the access flags allow, or for a matching accessor or mutator. With the default `ALLOW_PUBLIC` flag, a `readonly`, `private(set)` or `protected(set)` property is not writable through the property. A virtual property without a `set` hook is also not writable through the property. `isInitializable()` returns `true` when a constructor parameter has the property name. Entry point: `PropertyAccessExtractorInterface`, `PropertyInitializableExtractorInterface`.
- **Read and write info:** `getReadInfo()` and `getWriteInfo()` return the property or the method that reads or writes a value. The write type is `PropertyWriteInfo::TYPE_METHOD`, `TYPE_PROPERTY`, `TYPE_ADDER_AND_REMOVER`, `TYPE_CONSTRUCTOR` or `TYPE_NONE`. For `TYPE_NONE`, `getErrors()` tells why. Entry point: `PropertyReadInfoExtractorInterface`, `PropertyWriteInfoExtractorInterface` (implemented by `ReflectionExtractor`).
- **Descriptions:** `getShortDescription()` returns the PHPDoc summary. If there is no summary, the PHPDoc extractor returns the description of the `@var` or `@param` tag. `getLongDescription()` returns the PHPDoc description text. Entry point: `PropertyDescriptionExtractorInterface`.
- **Cache:** `PropertyInfoCacheExtractor` puts a PSR-6 pool and an in-memory array in front of a `PropertyInfoExtractorInterface` object, for example a `PropertyInfoExtractor`. It does not cache a call with arguments that PHP cannot serialize. In an application, `property_info.cache` decorates `property_info` with the pool `cache.property_info`, and FrameworkBundle removes it when `kernel.debug` is `true`. Entry point: `new PropertyInfoCacheExtractor($propertyInfoExtractor, $cachePool)`.
- **FrameworkBundle services:** if `symfony/property-info` is installed, `framework.property_info` is enabled, and `property_info` gets the reflection and constructor extractors. The PHPStan extractor needs `phpstan/phpdoc-parser` and `phpdocumentor/type-resolver`, and the PHPDoc extractor needs `phpdocumentor/reflection-docblock`. If you install these packages with `composer require --dev`, FrameworkBundle does not register the extractors. The type order is constructor (-999), PHPStan (-1000), PHPDoc (-1001), reflection (-1002). When the Serializer is enabled, `property_info.serializer_extractor` is a list extractor with priority -999. DoctrineBundle adds a Doctrine extractor for each entity manager. Entry point: service `property_info`.
- **Custom extractors:** implement one or more extractor interfaces. Autoconfiguration adds the matching `property_info.*` tag with priority 0, so a custom extractor runs before the built-in extractors. A single `#[AsTaggedItem]` attribute does not change this priority. If the built-in extractors must answer first, tag the service yourself with a `priority` below -1002. Entry point: `property_info.type_extractor` and the other `property_info.*` tags.

## Entry points

- `Symfony\Component\PropertyInfo\PropertyInfoExtractorInterface`: autowire it for the list, type, description and access methods (service `property_info`).
- `Symfony\Component\PropertyInfo\PropertyTypeExtractorInterface`, `PropertyListExtractorInterface`, `PropertyAccessExtractorInterface`, `PropertyDescriptionExtractorInterface` and `PropertyInitializableExtractorInterface`: narrow aliases of `property_info`. For `isInitializable()`, autowire `PropertyInitializableExtractorInterface`.
- `Symfony\Component\PropertyInfo\PropertyReadInfoExtractorInterface` and `PropertyWriteInfoExtractorInterface`: aliases of `property_info.reflection_extractor`.
- `Symfony\Component\PropertyInfo\PropertyDocBlockExtractorInterface` and `Symfony\Component\PropertyInfo\Extractor\ConstructorArgumentTypeExtractorInterface` have no alias. To get a `DocBlock`, create a `PhpDocExtractor`, or inject the service with `#[Autowire(service: 'property_info.php_doc_extractor')]` (`Symfony\Component\DependencyInjection\Attribute\Autowire`).
- Without FrameworkBundle: `PropertyInfoExtractor`, `PropertyInfoCacheExtractor`, and in `Symfony\Component\PropertyInfo\Extractor\`: `ReflectionExtractor`, `PhpDocExtractor`, `PhpStanExtractor`, `SerializerExtractor`, `ConstructorExtractor`.
- Config: `framework.property_info.enabled`, `framework.property_info.with_constructor_extractor` (default `true`).
- Service IDs: `property_info`, `property_info.cache`, `property_info.reflection_extractor`, `property_info.constructor_extractor`, `property_info.php_doc_extractor`, `property_info.phpstan_extractor`, `property_info.serializer_extractor`; cache pool `cache.property_info`.
- DI tags: `property_info.list_extractor`, `property_info.type_extractor`, `property_info.description_extractor`, `property_info.access_extractor`, `property_info.initializable_extractor`, `property_info.constructor_extractor`. Compiler passes: `PropertyInfoPass`, `PropertyInfoConstructorPass`.
- Context keys: `serializer_groups`, `enable_constructor_extraction`, `enable_getter_setter_extraction`, `enable_magic_methods_extraction`, `enable_adder_remover_extraction`.
- Console commands, attributes, Twig functions and test helpers: none.

## Symbiotic packages

- [TypeInfo](../packages/type-info.md): each type extractor returns a TypeInfo `Type`; to resolve one reflection object or one type string, use TypeInfo alone.
- [PropertyAccess](../packages/property-access.md): `PropertyAccessor` reads and writes values through the getters, setters, adders and removers that `ReflectionExtractor` finds.
- [Serializer](../packages/serializer.md): `ObjectNormalizer` gets the types from `property_info` to denormalize nested objects and typed arrays, and `SerializerExtractor` lists properties by group.
- [Validator](../packages/validator.md): with `framework.validation.auto_mapping`, `PropertyInfoLoader` adds `NotNull`, `Type` and `All` constraints from the property types.
- [Doctrine Bridge](../packages/doctrine-bridge.md): `DoctrineExtractor` gives list, type and access information from the ORM mapping, and DoctrineBundle registers it for each entity manager.
- [FrameworkBundle](../packages/framework-bundle.md): `framework.property_info` registers the `property_info` service, the extractors, the cache and the autoconfiguration tags.
- [HttpKernel](../packages/http-kernel.md): `#[MapRequestPayload]` denormalizes a nested array of DTOs (`@param UserDto[]`) when `phpstan/phpdoc-parser` and `phpdocumentor/type-resolver` are installed.
- [Cache](../packages/cache.md): `PropertyInfoCacheExtractor` keeps extractor results in a PSR-6 pool, and FrameworkBundle uses the pool `cache.property_info`, a child of `cache.system`.
- [String](../packages/string.md): `ReflectionExtractor` uses `EnglishInflector`, or another `InflectorInterface`, to find the adder and the remover of a plural property name.
- [UX Live Component](../packages/ux-live-component.md): `LiveComponentMetadataFactory` takes the type of a `#[LiveProp]` from `property_info` when that type is a collection, for example a typed array.

## Changed in 8.0/8.1

- `$extractor->getTypes($class, $property)` (an array of `Symfony\Component\PropertyInfo\Type`, removed in 8.0) -> `$extractor->getType($class, $property)`, which returns one `Symfony\Component\TypeInfo\Type` or `null`. `DoctrineExtractor::getTypes()` is also removed.
- `getTypesFromConstructor()` (removed in 8.0) -> `getTypeFromConstructor()`.
- `new Type(Type::BUILTIN_TYPE_INT)` of `Symfony\Component\PropertyInfo\Type` (removed in 8.0) -> `Symfony\Component\TypeInfo\Type::int()`, `Type::nullable(Type::string())`, `Type::object(Foo::class)`, `Type::list(Type::bool())`, `Type::union()`.
- `$type->getBuiltinType()` -> `$type->isIdentifiedBy(TypeIdentifier::INT)`, or `BuiltinType::getTypeIdentifier()->value` on the parts that `traverse()` returns. TypeInfo has no `getBuiltinType()`. The PropertyInfo docs page calls it.
- `$type->getClassName()` checks -> `$type->isIdentifiedBy(Foo::class)`. `isCollection()` and `getCollectionValueTypes()` -> `instanceof CollectionType` and `getCollectionValueType()`. Import `BuiltinType` and `CollectionType` from `Symfony\Component\TypeInfo\Type\`, not from `Symfony\Component\TypeInfo\` as UPGRADE-8.0.md shows.
- 8.0: `framework.property_info.with_constructor_extractor` is `true` by default. Thus the type of a constructor argument now has priority over the type of the property with the same name.
- 8.1: `ReflectionExtractor::getType()` reads the parameter type of a `set` property hook before the declared property type.

## Docs

- https://symfony.com/doc/current/components/property_info.html
- https://symfony.com/doc/current/components/type_info.html
- https://symfony.com/doc/current/serializer.html
- https://symfony.com/doc/current/reference/configuration/framework.html
- https://symfony.com/doc/current/doctrine.html
- https://symfony.com/doc/current/components/property_access.html
- https://symfony.com/doc/current/controller.html
- https://github.com/symfony/symfony/blob/v8.1.8/UPGRADE-8.0.md
