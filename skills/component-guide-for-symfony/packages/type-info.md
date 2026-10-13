# TypeInfo (`symfony/type-info`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when code must read PHP and PHPDoc types, for example typed lists, array shapes and generics, or check a value against a type. It gives one object model for all types, which code can inspect. To list the properties of a class and their types, see [PropertyInfo](property-info.md).

**Details:** [../details/type-info.md](../details/type-info.md)

## Why it exists

PHP reflection gives native types only. It does not read PHPDoc types such as typed lists or array shapes. The package resolves native types and PHPDoc types to one object model that code can inspect. Other packages use this model to convert, validate and stream data.

## When to use it

- Get the type of a property, a parameter or a return value, with the PHPDoc type before the native type.
- Parse a PHPDoc type string, for example a typed array or an array shape, into an object.
- Check if a type is nullable, or if it is a given builtin type, class or interface.
- Check if a value matches a type, with the keys and values of collections and shapes.
- Describe the type of the data to stream as JSON, for example a list of objects of one class. See [JsonStreamer](json-streamer.md).
- Use one PHPDoc type alias in many classes.
- Make metadata from the types of properties or method parameters, for example a JSON Schema for the tools of an AI agent.
- Migrate code that uses the old type class of [PropertyInfo](property-info.md), which Symfony 8.0 removed.

## Use it instead of

- `$property->getType()->getName()` with `instanceof \ReflectionUnionType` and `allowsNull()` checks -> `$typeResolver->resolve($reflectionProperty)` on `TypeResolverInterface`.
- `preg_match('/@var\s+(\S+)/', $property->getDocComment(), $matches)` -> `TypeResolverInterface::resolve($reflectionProperty)` in a project with `phpstan/phpdoc-parser` (`PhpDocAwareReflectionTypeResolver`).
- A custom parser for strings such as `'array<string, list<int>>'` -> `$typeResolver->resolve('array<string, list<int>>')` (`StringTypeResolver`, needs `phpstan/phpdoc-parser`).
- `is_int($value) || is_string($value)` checks that repeat a declared type -> `$type->accepts($value)`.
- `in_array($reflectionType->getName(), ['int', 'float'], true)` or `is_a($className, Foo::class, true)` -> `$type->isIdentifiedBy(TypeIdentifier::INT, TypeIdentifier::FLOAT)` or `$type->isIdentifiedBy(Foo::class)`.
- `new \Symfony\Component\PropertyInfo\Type(Type::BUILTIN_TYPE_INT)` (removed in 8.0) -> `\Symfony\Component\TypeInfo\Type::int()`.
- `get_debug_type($value)` to describe the type of a value -> `Type::fromValue($value)`.
- An array such as `['type' => 'array', 'items' => Cat::class]` that describes a JSON payload -> `Type::list(Type::object(Cat::class))`, which JsonStreamer writes and reads.
- `token_get_all()` or a regex over the class file to find the `use` import of a short class name in PHPDoc -> `(new TypeContextFactory())->createFromClassName($class)->normalize('ShortName')`.
