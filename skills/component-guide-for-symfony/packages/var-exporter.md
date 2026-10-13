# VarExporter (`symfony/var-exporter`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when code must deep-copy objects, export PHP values as PHP code for OPcache, or create objects without their constructor. It keeps private state and references, and an optional PHP extension makes it faster. To display values for debugging, see [VarDumper](var-dumper.md). To write JSON or XML, see [Serializer](serializer.md).

**Details:** [../details/var-exporter.md](../details/var-exporter.md)

## Why it exists

The PHP clone keyword copies only the outer object, and a serialize and unserialize cycle allocates the strings and arrays again. The PHP export function ignores the serialization methods of a class. Loading serialized data is also slower than PHP code that OPcache keeps in memory. The package copies, exports and rebuilds object graphs with their private state, references and serialization behavior.

## When to use it

- Deep-clone an object graph so that changes to the copy do not change the original.
- Create many independent copies of one prototype object.
- Save a snapshot of mutable objects that later changes must not affect.
- Export arrays or objects to a PHP file that OPcache loads, instead of serialized data.
- Send an object graph through JSON, a cache or a queue as a plain array, and rebuild it.
- Create an object without its constructor, or set its private, protected or readonly properties.
- Generate a lazy-loading decorator for an interface, an abstract class or an internal PHP class.
- Make caches and the build of the dependency injection container faster with an optional PHP extension.

## Use it instead of

- `unserialize(serialize($order))` to deep-copy an object -> `DeepCloner::deepClone($order)`.
- A `__clone()` method that clones each nested object property by hand -> `DeepCloner::deepClone()`.
- `unserialize($serializedPrototype)` in a loop to get many copies -> `$cloner = new DeepCloner($prototype)`, then `$cloner->clone()` for each copy.
- `file_put_contents($file, serialize($data))` and `unserialize(file_get_contents($file))` for a PHP-only cache -> `file_put_contents($file, '<?php return '.VarExporter::export($data).';')` and `require $file`. In an application, use the Cache `PhpFilesAdapter` or `PhpArrayAdapter`, which do this for you.
- `var_export($config, true)` for data that holds objects with `__wakeup()`, `__serialize()` or private state -> `VarExporter::export($config)`.
- `(new \ReflectionClass(User::class))->newInstanceWithoutConstructor()` and `ReflectionProperty::setValue()` for each property -> `deepclone_hydrate(User::class, ['id' => 42, 'name' => 'Alice'])`.
- `\Closure::bind(fn () => $this->email = $email, $user, User::class)()` to write a private property -> `deepclone_hydrate($user, ['email' => $email])`.
- `json_encode($object)` for a PHP-to-PHP transfer that must keep private state, identities and references -> `json_encode((new DeepCloner($object))->toArray())`, then `DeepCloner::fromArray(json_decode($json, true))->clone()`.
- A hand-written proxy class that implements an interface and creates the real object on the first call -> `ProxyHelper::generateLazyProxy(null, [new \ReflectionClass(SomeInterface::class)])` and `createLazyProxy()`; for a service, `#[Lazy]`.
