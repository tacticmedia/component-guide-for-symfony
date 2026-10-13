# PropertyInfo (`symfony/property-info`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when code must list the properties of a class, find the type of each property, or find how to read and write it. It reads PHP types, PHPDoc tags, getters, setters, constructor arguments and ORM mapping. To read or write the values, see [PropertyAccess](property-access.md). To resolve one type alone, see [TypeInfo](type-info.md).

**Details:** [../details/property-info.md](../details/property-info.md)

## Why it exists

Serializers, validators and other libraries must know the properties of a class and the type of each property. This information comes from PHP type declarations, PHPDoc tags, getter and setter methods, constructor arguments and ORM mapping. The package asks these sources in a fixed order and returns the first answer that is not null.

## When to use it

- Get the type of a property from its PHP type, its PHPDoc or its getter and setter methods.
- List the properties of a class, also the properties that only a getter or a setter shows.
- Check if code can read or write a property through the property, a getter, a setter or an add method.
- Find the getter, setter, add method, remove method or constructor argument that reads or writes a property.
- Check if a constructor argument can set a property of a new object.
- Get the short and long description of a property from its PHPDoc.
- Deserialize a nested list of data objects when only PHPDoc gives the item type. See [Serializer](serializer.md).
- Add not-null and type validation rules from the property types automatically. See [Validator](validator.md).

## Use it instead of

- `(new \ReflectionProperty($class, $name))->getType()` plus `preg_match('/@var\s+(\S+)/', $property->getDocComment(), $m)` -> `$propertyInfo->getType($class, $name)` (`PropertyTypeExtractorInterface`).
- `get_class_methods($object)` filtered with `str_starts_with($method, 'get')` -> `$propertyInfo->getProperties($class)` (`PropertyListExtractorInterface`).
- `method_exists($object, 'set'.ucfirst($name)) || property_exists($object, $name)` -> `$propertyInfo->isWritable($class, $name)`, or `getWriteInfo()` to get the method name (`PropertyWriteInfoExtractorInterface`).
- A loop over `(new \ReflectionMethod($class, '__construct'))->getParameters()` that matches property names -> `isInitializable()` (`PropertyInitializableExtractorInterface`) or `ConstructorExtractor`.
- A parser of `$property->getDocComment()` for help texts or API documentation -> `getShortDescription()` and `getLongDescription()` (`PropertyDescriptionExtractorInterface`).
- A static array that keeps reflection results -> the `property_info` service, which `property_info.cache` caches in the pool `cache.property_info`.
- `array_map(fn (array $row) => new UserDto(...$row), $data['users'])` after `json_decode()` -> `@param UserDto[] $users` on the constructor, plus `#[MapRequestPayload]` or the Serializer, which get the element type from `property_info`.
