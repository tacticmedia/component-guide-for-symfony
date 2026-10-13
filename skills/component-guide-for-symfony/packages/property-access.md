# PropertyAccess (`symfony/property-access`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when code must read or write a nested object or array value by a path string, for example from configuration. It calls the getters, the setters and the add and remove methods, and it can stop at null values in the path. For the types and other information about class properties, see [PropertyInfo](property-info.md).

**Details:** [../details/property-access.md](../details/property-access.md)

## Why it exists

Code often gets a field name or a path as a string, for example from a form option, a configuration value or a serialized key. Without this package, each caller must build method names, check that the methods exist, walk nested arrays and stop at null values. The package does this work with one call, and it keeps the access information in a cache.

## When to use it

- Read a nested value from an object or an array with a path of property names and array keys.
- Write a value by a path through a setter, a public property or a nested array key.
- Read or write a property that a configuration option or an option of a reusable form names.
- Return null instead of an error when a value in the middle of the path is null.
- Update a collection property through its add and remove methods, instead of a replacement of the whole array.
- Check if a path is readable or writable before you read or write it.
- Write the property paths that form, serialization, validation and security options accept.

## Use it instead of

- `$getter = 'get'.ucfirst($field); $value = $object->$getter();` -> `$propertyAccessor->getValue($object, $field)`, which also finds `is`, `has` and `can` methods and public properties.
- A loop over `explode('.', $path)` with `$data[$key] ?? null` -> `$propertyAccessor->getValue($data, '[address?][city]')`. With the `?`, a `null` at `[address]` gives `null` instead of `UnexpectedTypeException`.
- `if (method_exists($object, 'set'.ucfirst($field))) { ... } elseif (property_exists($object, $field)) { ... }` -> `isWritable()` and `setValue()`.
- `$data['a'] ??= []; $data['a']['b'] = $value;` -> `$propertyAccessor->setValue($data, '[a][b]', $value)`, which creates the missing arrays.
- A `foreach` that compares the old and new collections and calls `removeTag()` and `addTag()` -> `$propertyAccessor->setValue($task, 'tags', $newTags)`.
- A chain of `null` checks for a configured path, such as `$post->getAuthor() ? $post->getAuthor()->getName() : null` -> `getValue($post, 'author?.name')`.
- `'' === $base ? $sub : $base.'.'.$sub` to build an error path -> `PropertyPath::append($base, $sub)`, which also joins `[index]` parts without a dot.
- `try { $object->setAge($value); } catch (\TypeError $e) { ... }` to build an error message -> catch `InvalidTypeException` from `setValue()` and read `$e->expectedType`, `$e->actualType` and `$e->propertyPath`.
