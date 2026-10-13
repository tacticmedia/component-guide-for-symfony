# TypeInfo (`symfony/type-info`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Type factories:** static methods on `Type` create each type, for example `Type::int()`, `Type::object(User::class)`, `Type::enum(Status::class)`, `Type::nullable()`, `Type::union()`, `Type::intersection()`, `Type::generic()` and `Type::template()`. `Type::union()` merges nested unions and returns a `NullableType` when one member is `null`. `Type::enum()` finds the backing type of a backed enum. Entry point: `Symfony\Component\TypeInfo\Type` (methods of `TypeFactoryTrait`).
- **Collections:** `Type::list($value)` has `int` keys and only accepts a list. `Type::dict($value)` has `string` keys. `Type::array($value, $key)` and `Type::iterable($value, $key)` use `int|string` keys when you give no key type. The PHPDoc type `T[]` also has `int|string` keys. `Type::collection(Type::object(Collection::class), $value, $key)` describes an object collection, for example a Doctrine `Collection`. Entry point: `CollectionType::getCollectionKeyType()`, `getCollectionValueType()`, `isList()`.
- **Array shapes and object shapes:** `Type::arrayShape(['id' => Type::int(), 'name' => ['type' => Type::string(), 'optional' => true]])` describes the exact keys of an array. A shape is sealed by default. To accept extra entries, give `false` as the second argument, or give the extra key and value types. In PHPDoc, `array{id: int, ...}` and `array{id: int, ...<string, bool>}` accept extra entries. `Type::objectShape()` (8.1) describes an anonymous object, and it is always sealed. Entry point: `ArrayShapeType`, `ObjectShapeType`.
- **Type of a value:** `Type::fromValue()` returns the type of a PHP value, for example `list<int>` for `[1, 2, 3]` and `float` for `1.1`. Entry point: `Type::fromValue()`.
- **String form:** each type converts to a PHPDoc string, for example `list<int>`, `null|string` or `Collection<int>`. Entry point: `(string) $type` (`Type` implements `\Stringable`).
- **Resolvers:** one resolver accepts a `ReflectionProperty`, a `ReflectionParameter`, a `ReflectionFunctionAbstract` (for the return type), a `ReflectionType` or a string. In a Symfony application, autowire `TypeResolverInterface`. In standalone code, call `TypeResolver::create()`. Entry point: `TypeResolverInterface::resolve($subject, $typeContext)`.
- **PHPDoc before native types:** if the project has `phpstan/phpdoc-parser`, `PhpDocAwareReflectionTypeResolver` reads `@var`, `@param` and `@return` before the native type. For a promoted property, it also reads the `@param` tag of the constructor. Without that package, the resolvers read native types only, and a string subject causes an `UnsupportedException`. Entry point: `PhpDocAwareReflectionTypeResolver`.
- **PHPStan and Psalm syntax:** `StringTypeResolver` reads generics (`array<K, V>`, `list<T>`, `Collection<T>`), `T[]`, `?T`, unions, intersections, DNF types, shapes, `key-of<>`, `value-of<>`, class constants (`Foo::STATUS_*`), `$this`, `self`, `static` and `parent`. It changes refined types to their base type: `positive-int` and `int<0, 100>` become `int`, `non-empty-string` and `class-string` become `string`. A class that implements `Traversable` or `ArrayAccess` becomes a `CollectionType`. Entry point: `StringTypeResolver`.
- **Type context:** a `TypeContext` holds the namespace, the `use` imports, the `@template` types and the type aliases of a class. The reflection resolvers make it for you. To resolve a string with short class names, `self` or templates, give a context from `TypeContextFactory::createFromClassName()`. A `TypeContextFactory` without a `StringTypeResolver` collects no templates and no aliases. Entry point: `TypeContextFactory`, `TypeContext`.
- **Type aliases:** `@phpstan-type` and `@psalm-type` define an alias on a class, and `@phpstan-import-type` and `@psalm-import-type` import an alias from another class. `framework.type_info.aliases` defines global aliases, and a class alias with the same name has priority. Global aliases apply only to the services `type_info.resolver` and `type_info.type_context_factory`, which JsonStreamer also uses. `TypeResolver::create()` and the PropertyInfo extractors ignore them. In a global alias, write each class name as a fully qualified name. Entry point: `framework.type_info.aliases`.
- **Identification:** `isIdentifiedBy()` returns `true` when the type or a wrapped or composed part matches a `TypeIdentifier`, a builtin type name or a class name. An object type also matches the names of its parent classes and its interfaces. The method does not look at collection values: `list<int>` matches `array`, but not `int`. `isA()` does not exist. Use `isIdentifiedBy()`. Entry point: `Type::isIdentifiedBy()`, `TypeIdentifier`.
- **Satisfaction:** `isSatisfiedBy($callable)` returns `true` when the callable returns `true` for the type or for a part of it. The parts are the wrapped type, one member of a union, or all members of an intersection. Thus `?float` satisfies a callable that rejects nullable types, because the wrapped `float` satisfies it. `is()` does not exist. Use `isSatisfiedBy()`. Entry point: `Type::isSatisfiedBy()`.
- **Value check:** `accepts($value)` checks a value against the type, with collection keys and values, list keys and shape keys. `isNullable()` returns `true` for `null`, `mixed` and nullable types. Entry point: `Type::accepts()`, `Type::isNullable()`.
- **Wrapped and composed parts:** `WrappingTypeInterface::getWrappedType()` unwraps `NullableType`, `CollectionType`, `GenericType` and `TemplateType`. `CompositeTypeInterface::getTypes()` returns the members of `UnionType` and `IntersectionType`. `traverse()` yields the type and its direct parts. Entry point: `Type::traverse()`.
- **FrameworkBundle integration:** FrameworkBundle registers the services `type_info.resolver` and `type_info.type_context_factory`. The alias `TypeResolverInterface` points to `type_info.resolver`. FrameworkBundle adds the string resolver, the PHPDoc resolvers and the global aliases only if the project has `phpstan/phpdoc-parser`. JsonStreamer needs `framework.type_info` enabled. Entry point: `framework.type_info`.

## Entry points

- `Symfony\Component\TypeInfo\TypeResolver\TypeResolverInterface`: autowire it. The service ID is `type_info.resolver`.
- Without FrameworkBundle: `Symfony\Component\TypeInfo\TypeResolver\TypeResolver::create()`, a resolver without the `framework.type_info` aliases.
- `Symfony\Component\TypeInfo\Type`: the abstract base class, with the static factory methods of `Symfony\Component\TypeInfo\TypeFactoryTrait`.
- `Symfony\Component\TypeInfo\TypeIdentifier`: the enum of builtin type names (`INT`, `STRING`, `ARRAY`, `OBJECT`, `NULL`, `MIXED` and others).
- Type classes in `Symfony\Component\TypeInfo\Type\`: `BuiltinType`, `ObjectType`, `EnumType`, `BackedEnumType`, `CollectionType`, `GenericType`, `UnionType`, `NullableType`, `IntersectionType`, `TemplateType`, `ArrayShapeType`, `ObjectShapeType`; interfaces `WrappingTypeInterface` and `CompositeTypeInterface`.
- Resolvers in `Symfony\Component\TypeInfo\TypeResolver\`: `ReflectionTypeResolver`, `ReflectionPropertyTypeResolver`, `ReflectionParameterTypeResolver`, `ReflectionReturnTypeResolver`, `PhpDocAwareReflectionTypeResolver`, `StringTypeResolver`.
- `Symfony\Component\TypeInfo\TypeContext\TypeContextFactory` (service `type_info.type_context_factory`) and `Symfony\Component\TypeInfo\TypeContext\TypeContext`.
- Config: `framework.type_info.enabled`, `framework.type_info.aliases`.
- Exceptions in `Symfony\Component\TypeInfo\Exception\` implement `ExceptionInterface`. A resolver that cannot resolve a subject throws `UnsupportedException` (property `$subject`). An invalid type, for example `array<float, int>`, causes an `InvalidArgumentException`. If TypeInfo cannot import or resolve a type alias, or if an alias is recursive, it throws a `LogicException`. If the type context factory cannot read a class file, it throws a `RuntimeException`.
- Optional package: `phpstan/phpdoc-parser`, for PHPDoc types and string types.
- Console commands, attributes, Twig functions and test helpers: none.

## Symbiotic packages

- [PropertyInfo](../packages/property-info.md): `PropertyTypeExtractorInterface::getType()` returns a TypeInfo `Type`, and the reflection, PHPStan and PHPDoc extractors build that type with TypeInfo classes.
- [JsonStreamer](../packages/json-streamer.md): `StreamWriterInterface::write()` and `StreamReaderInterface::read()` need a TypeInfo `Type` that describes the data, and FrameworkBundle enables JsonStreamer only with TypeInfo.
- [Serializer](../packages/serializer.md): `AbstractObjectNormalizer` reads the TypeInfo type of each attribute from PropertyInfo to denormalize nested objects, collections and scalars.
- [Validator](../packages/validator.md): auto-mapping (`PropertyInfoLoader`) changes the TypeInfo type of a property into `Type`, `NotNull` and `All` constraints.
- [Doctrine Bridge](../packages/doctrine-bridge.md): `DoctrineExtractor::getType()` returns a TypeInfo type from the Doctrine mapping, for example a `Collection` of the target entity.
- [FrameworkBundle](../packages/framework-bundle.md): `framework.type_info` registers `type_info.resolver` and gives the `aliases` to the string resolver and to the type context factory.
- [UX Live Component](../packages/ux-live-component.md): `LiveComponentMetadataFactory` finds the type of each `#[LiveProp]` with PropertyInfo and `type_info.resolver`, for hydration.
- [AI Platform](../packages/ai-platform.md): `TypeInfoDescriber`, a default describer of the JSON Schema `Factory`, changes property and parameter types into JSON Schema for tools and structured output.
- [AI Agent](../packages/ai-agent.md): `ToolCallArgumentResolver` resolves the parameter types of a tool method with `TypeResolver` before it denormalizes the tool call arguments.

## Changed in 8.0/8.1

- 8.0 removes `Symfony\Component\PropertyInfo\Type`, `getTypes()` and `getTypesFromConstructor()` -> `getType()` and `getTypeFromConstructor()` return one `Symfony\Component\TypeInfo\Type` or `null`.
- Old PropertyInfo calls -> TypeInfo: `getBuiltinType()` -> `isIdentifiedBy()` or `BuiltinType::getTypeIdentifier()`; `isCollection()` -> `instanceof CollectionType`; `getCollectionValueTypes()` -> `getCollectionValueType()`. TypeInfo types have no `getBuiltinType()` method.
- Use the namespace `Symfony\Component\TypeInfo\Type\` for type classes, for example `Symfony\Component\TypeInfo\Type\CollectionType`. The UPGRADE-8.0 example imports `Symfony\Component\TypeInfo\BuiltinType` and `Symfony\Component\TypeInfo\CollectionType`, which do not exist.
- 8.0 removes the third argument `$asList` of `Type::iterable()` -> `Type::list($valueType)`. A list `CollectionType` that is not an `array` now causes an `InvalidArgumentException`.
- 8.1 adds object shapes: `object{name: string, email?: string}` in PHPDoc and `Type::objectShape()` (`ObjectShapeType`).
- 8.1: if a built-in PHP method has no return type, the return type resolver uses its tentative return type, for example `DateTimeZone|false` for `DateTime::getTimezone()`.

## Docs

- https://symfony.com/doc/current/components/type_info.html
- https://symfony.com/doc/current/components/property_info.html
- https://symfony.com/doc/current/serializer/streaming_json.html
- https://symfony.com/doc/current/reference/configuration/framework.html
