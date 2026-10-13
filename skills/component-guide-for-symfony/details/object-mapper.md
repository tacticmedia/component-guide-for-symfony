# ObjectMapper (`symfony/object-mapper`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- Create or update: `map($input, Product::class)` creates a new target. `map($input, $product)` writes into an existing object and does not call its constructor (`ObjectMapperInterface::map()`). For a new target, the mapper passes the source values to the constructor parameters with the same names.
- Implicit mapping: the mapper copies the properties that have the same name in the source and the target. It ignores source properties that the target does not have. Target properties without a source value keep their default value, or their current value in an existing object.
- Class-level `#[Map]`: on a source class, `#[Map(target: Product::class)]` sets the default target, so `map($input)` needs no second argument. On a target class, `#[Map(source: Product::class)]` declares the source class (`Symfony\Component\ObjectMapper\Attribute\Map`).
- Property-level `#[Map]`: `target` sets the target property name. `source` (on a target class) sets the source property name. `if` sets a condition, and `transform` changes the value. The attribute is repeatable. The condition option is `if`; there is no `condition` option.
- Conditions: `if: false` never maps the property. Otherwise, a callable (for example `[self::class, 'isOnline']`) or the service ID of a `ConditionCallableInterface` service returns `true` to map the value. It receives the value, the source and the target, but a string callable such as `'strlen'` receives only the value. In the class-level condition of the object that you pass to `map()`, the value and the target are `null`. In the class-level condition of a nested object, the value is the nested object, and the source and the target are the outer objects.
- Built-in conditions (`Symfony\Component\ObjectMapper\Condition\`): `new IsNotNull()` skips `null` values (8.1). `new TargetClass(AdminUserProfile::class)` and `new SourceClass(ExternalProduct::class)` (8.1) apply a mapping only when the target or the source is an instance of the class. Since 8.1, both accept an array of classes. `ClassRule` and `ClassRuleList` (8.1) combine source and target checks.
- Transforms: `transform` changes the value before the mapper writes it. Use a function name (`'intval'`), a static method (`[PriceFormatter::class, 'format']`) or the service ID of a `TransformCallableInterface` service. A transform gets the same arguments as a condition. For a `BackedEnum`, use `Status::class.'::from'`, not `[Status::class, 'from']`, which gets three arguments and fails. A callable object, for example a closure, must implement the interface. Otherwise the mapper throws `NoSuchCallableException`. If the `#[Map]` with the `transform` is on a target property, also set `source`, even for the same name.
- Class-level transform: in `#[Map(target: User::class, transform: [User::class, 'createFromLegacy'])]`, the callable returns the target object, for example from a named constructor. Then the mapper maps the properties into this object and does not call the constructor.
- Collections: `#[Map(transform: new MapCollection())]` maps each item of an array or iterable property, like `map($item)`. Since 8.1, `new MapCollection(targetClass: LineItem::class)` sets the item class, so the item class needs no `#[Map]`. The transform returns an array with the same keys. Without `MapCollection`, the mapper copies arrays unchanged (`Symfony\Component\ObjectMapper\Transform\MapCollection`).
- Several target classes: repeat the class-level `#[Map(target: ..., if: ...)]` with one condition for each target. If more than one target matches and `map()` gets no target, the mapper throws a `MappingException` ("Ambiguous mapping").
- Nested objects and cycles: if a property value has a class-level `#[Map]`, the mapper maps it too. Without a class-level transform, the nested target is a native PHP lazy object that the mapper fills on first access. In cyclic graphs, the mapper reuses the targets that it already created.
- Nested merge (8.1): a source property without `#[Map]` can hold an object that maps to the same target class as its parent. If the target has no property of that name, the mapper writes the properties of this object into the parent target. Use this to flatten nested DTOs.
- Reverse class map (8.1): in an application, FrameworkBundle collects the class-level `#[Map]` attributes of the classes that the service loader finds (for example in `src/`). Then `map($product)` finds `ProductOutput` from `#[Map(source: Product::class)]` on `ProductOutput`. Without the framework, pass `new ReverseClassObjectMapperMetadataFactory(new ReflectionObjectMapperMetadataFactory(), $classMap)` to the `ObjectMapper` constructor.
- Property access: if you install `symfony/property-access`, the `object_mapper` service reads through getters and writes through setters. Then `source` and `target` also accept property paths such as `address.city`. Without PropertyAccess, the mapper uses public properties only, and `__get()` to read.
- Decoration and custom rules: a decorator (`#[AsDecorator(decorates: ObjectMapperInterface::class)]`) calls `withObjectMapper($this)` of `ObjectMapperAwareInterface`, so nested mapping also goes through the decorator. `ObjectMapperMetadataFactoryInterface` lets you keep the mapping rules in another place, for example in a dedicated mapper class.

## Entry points

- Install: `composer require symfony/object-mapper` (PHP 8.4.1 or later). FrameworkBundle registers the services when you install the package.
- Autowire `Symfony\Component\ObjectMapper\ObjectMapperInterface` (service `object_mapper`). Call `map(object $source, object|string|null $target = null): object`.
- Without FrameworkBundle: `new Symfony\Component\ObjectMapper\ObjectMapper()`. The constructor accepts a metadata factory, a `PropertyAccessorInterface`, and PSR-11 locators for transform and condition services.
- Attribute: `Symfony\Component\ObjectMapper\Attribute\Map` with the options `target`, `source`, `if` and `transform`, on classes and properties.
- Service interfaces: `Symfony\Component\ObjectMapper\ConditionCallableInterface` and `Symfony\Component\ObjectMapper\TransformCallableInterface`. Autoconfiguration adds the tags `object_mapper.condition_callable` and `object_mapper.transform_callable`. In `if` or `transform`, refer to the service by its ID (by default, the class name).
- Built-in conditions: `Symfony\Component\ObjectMapper\Condition\IsNotNull`, `TargetClass`, `SourceClass`, `ClassRule` and `ClassRuleList` (same namespace).
- Built-in transform: `Symfony\Component\ObjectMapper\Transform\MapCollection`.
- Decoration: `Symfony\Component\ObjectMapper\ObjectMapperAwareInterface`, with `Symfony\Component\DependencyInjection\Attribute\AsDecorator`.
- Metadata: `Symfony\Component\ObjectMapper\Metadata\ObjectMapperMetadataFactoryInterface` (service `object_mapper.metadata_factory`) and `Symfony\Component\ObjectMapper\Metadata\ReverseClassObjectMapperMetadataFactory` (service `object_mapper.metadata_factory.reverse_class`). The docs also use two `@internal` classes (same namespace): the default factory `ReflectionObjectMapperMetadataFactory`, and `Mapping`, which `create()` returns in a list.
- Config: there is no `framework.object_mapper` key. The `framework.property_access` options apply. For example, `throw_exception_on_invalid_property_path: false` makes a missing source property read as `null` instead of an exception.
- Exceptions: `Symfony\Component\ObjectMapper\Exception\MappingException` and its subclasses `NoSuchPropertyException` and `NoSuchCallableException`, and `MappingTransformException`. All implement `Symfony\Component\ObjectMapper\Exception\ExceptionInterface`.
- The package has no console commands, Twig functions or test helpers.

## Symbiotic packages

- [Serializer](../packages/serializer.md): Often confused: the Serializer converts objects to and from formats or arrays, for example JSON to a DTO; the ObjectMapper copies one object into another. `TargetClass` conditions are an alternative to serialization groups for several views of one class.
- [Form](../packages/form.md): Often confused: a form reads submitted HTML form fields from the request, writes them into its `data_class` object through data mappers, and validates them. The ObjectMapper maps two PHP objects and does not read the request or validate.
- [HttpKernel](../packages/http-kernel.md): In a controller, `#[MapRequestPayload]` creates and validates the input DTO from the request; then `map()` copies the DTO into the entity.
- [PropertyAccess](../packages/property-access.md): If you install the package, the `object_mapper` service uses the `property_accessor` service for getters, setters and property paths in `source` and `target`.
- [FrameworkBundle](../packages/framework-bundle.md): FrameworkBundle registers the `object_mapper` service and its autowiring alias, autoconfigures condition and transform services, and builds the reverse class map from `#[Map]` attributes (8.1).
- [DependencyInjection](../packages/dependency-injection.md): `#[AsDecorator]` decorates the mapper. The `object_mapper.map` resource tag and `ReverseMappingPass` collect the `#[Map]` classes and do not make them services.
- [Doctrine Bridge](../packages/doctrine-bridge.md): Doctrine entities are the usual targets. Load the entity, for example with `#[MapEntity]` or a repository, then call `map($dto, $entity)` to update it.

## Changed in 8.0/8.1

- 8.1, new: `ReverseClassObjectMapperMetadataFactory` and, in an application, an automatic class map. `#[Map(source: Product::class)]` on `ProductOutput` lets `$objectMapper->map($product)` find the target. Old: `$objectMapper->map($product, ProductOutput::class)`.
- 8.1, new: `#[Map(if: new IsNotNull())]` skips `null` values. Old: a custom `ConditionCallableInterface` class that returns `null !== $value`.
- 8.1, new: the `SourceClass`, `ClassRule` and `ClassRuleList` conditions. `TargetClass` and `SourceClass` accept an array of classes.
- 8.1, new: `new MapCollection(targetClass: LineItem::class)` maps the items to a class without a `#[Map]` attribute on the item class.
- 8.1, new: if a nested object maps to the same target class as its parent, the mapper merges it into the parent target.
- 8.1, new: an unknown `transform` or `if` callable, or a callable object or a service without the required interface, causes a `NoSuchCallableException`. Old (8.0): the mapper ignored unknown callables and accepted any callable object or service.
- 8.1 (also 8.0.9), new: a transform that implements `ObjectMapperAwareInterface` gets the current (outermost) mapper through `withObjectMapper()`.
- 8.0 (also 7.4), new: the `MapCollection` transform and `ObjectMapperAwareInterface`.

## Status

Stable, not experimental. The backward compatibility promise excludes `@internal` classes, for example `Mapping` and `ReflectionObjectMapperMetadataFactory`.

## Docs

- https://symfony.com/doc/current/object_mapper.html (main page)
- https://symfony.com/doc/current/reference/attributes.html (`#[Map]` in the attribute list)
