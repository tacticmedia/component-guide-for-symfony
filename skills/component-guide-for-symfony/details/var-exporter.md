# VarExporter (`symfony/var-exporter`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Export as PHP code:** `VarExporter::export()` returns PHP code that rebuilds any serializable value, with its private properties, object identities and `&` references. The code keeps the semantics of `__sleep()`, `__wakeup()`, `__serialize()`, `__unserialize()` and `Serializable`. Write the code to a `.php` file. Load the file with `require`, so that OPcache serves it. Entry point: `Symfony\Component\VarExporter\VarExporter::export($value, $isStaticValue, $foundClasses)`.
- **Exported code format:** since 8.1, the code for an object graph is a call to `\deepclone_from_array([...], null, true)`. Scalars, enums and arrays of scalars or enums export as plain PHP literals, and `$isStaticValue` becomes `true`. `$foundClasses` collects the class names of the value, for example for preloading. Initialize it to `[]` before the call; an undefined variable causes a `TypeError`. Entry point: the by-reference arguments of `VarExporter::export()`.
- **Export errors:** resources, anonymous closures, anonymous classes without `__wakeup()` or `__unserialize()`, `Reflection*` objects and other values that PHP cannot serialize cause a `NotInstantiableTypeException`. Code for an anonymous class with one of these methods loads only in the same PHP process. Closures over named callables, such as `strlen(...)` or `$object->method(...)`, export without errors. If exported code names a class that does not exist, loading it throws `\DeepClone\ClassNotFoundException` instead of creating an incomplete object. Entry point: `Symfony\Component\VarExporter\Exception\NotInstantiableTypeException`.
- **Deep clone:** `DeepCloner::deepClone()` returns a copy that shares no object with the original. Strings and scalar-only arrays keep the PHP copy-on-write behavior, so the copy uses less memory than `unserialize(serialize())`. To make many copies, create `new DeepCloner($prototype)` once. Then call `clone()` for each copy. Later changes to the prototype do not change the next clones. `isStaticValue()` returns `true` for scalars, `null`, enums and scalar-only arrays, which need no clone. Entry point: `Symfony\Component\VarExporter\DeepCloner::deepClone($value)`, `new DeepCloner($value)`, `DeepCloner::clone()`.
- **Clone as another class:** `cloneAs()` deep-clones the root object into a compatible class, usually a class of the same hierarchy. If the root value is not an object, it throws `LogicException`. DependencyInjection uses it to change a `Definition` into a `ChildDefinition`. Entry point: `DeepCloner::cloneAs(Puppy::class)`.
- **Portable payload:** `toArray()` returns the cloner state as scalars and nested arrays only, so `json_encode()`, `var_export()` or a cache can store it. `DeepCloner::fromArray()` restores the cloner without a new analysis of the object graph. `serialize($cloner)` also works. The serialized cloner stores each class and property name once, but it is not always smaller than `serialize($value)`. Entry point: `DeepCloner::toArray()`, `DeepCloner::fromArray($data)`.
- **Untrusted payloads:** `$allowedClasses` works like the `allowed_classes` option of `unserialize()`: `null` allows all classes, and `[]` allows no class. A class outside the list causes a `\ValueError`, not a component exception. If a payload comes from outside the application, pass an explicit list to `clone()`, `cloneAs()` or `deepClone()`. Closures over named callables need `$allowNamedClosure = true` on both sides, because such a payload can create a closure over any function, `system()` included. Entry point: the `$allowedClasses` and `$allowNamedClosure` arguments of the `DeepCloner` methods.
- **Create and hydrate objects:** `deepclone_hydrate(Foo::class, $vars)` creates an object without its constructor and sets its properties. `deepclone_hydrate($object, $vars)` sets the properties of an existing object. It writes private, protected and readonly properties. Entry point: the global function `deepclone_hydrate()`, from the `deepclone` extension or from `symfony/polyfill-deepclone`.
- **Hydration keys and flags:** the keys of `$vars` use the format of `(array) $object`. `'name'` sets the property with that name, also a private property of a parent class. If several classes of the hierarchy declare a private property with that name, `'name'` sets the one nearest to the class of the object. `"\0*\0name"` sets a protected property, and `"\0Parent\0name"` sets a private property that the class `Parent` declares. By default, set hooks do not run. `DEEPCLONE_HYDRATE_CALL_HOOKS` runs them, and `DEEPCLONE_HYDRATE_NO_LAZY_INIT` writes without the initialization of a lazy object. Do not combine these two flags, because that causes a `\ValueError`. `DEEPCLONE_HYDRATE_PRESERVE_REFS` keeps the `&` references of `$vars`. In a user class, a `null` value leaves a non-nullable typed property uninitialized, and a scalar becomes the matching case of a backed enum property. For `ArrayObject` or `SplObjectStorage`, call `__unserialize()` after `deepclone_hydrate()`. Entry point: the `$flags` argument of `deepclone_hydrate()`.
- **Deprecated `Instantiator` and `Hydrator`:** since 8.1, loading these classes triggers a deprecation. `Instantiator::instantiate()` and `Hydrator::hydrate()` call `deepclone_hydrate()` with `DEEPCLONE_HYDRATE_PRESERVE_REFS`. They still accept the per-class `$scopedVars` array and the `"\0"` key for the internal state of SPL classes. Entry point: `Symfony\Component\VarExporter\Instantiator`, `Symfony\Component\VarExporter\Hydrator` (deprecated).
- **Lazy decorators:** `ProxyHelper::generateLazyProxy()` returns the code of a decorator class without the class name. Add a class name and evaluate the code, or write it to a file for production. Then call the static `createLazyProxy()` with an initializer that returns the real object. The initializer runs when code first calls a method or reads a property. The decorator implements `LazyObjectInterface` with `isLazyObjectInitialized()`, `initializeLazyObject()` and `resetLazyObject()`. Entry point: `Symfony\Component\VarExporter\ProxyHelper::generateLazyProxy()`.
- **What `generateLazyProxy()` accepts:** an abstract class, an internal PHP class or a class that extends one, or `null` and a list of interfaces. For an interface, call `generateLazyProxy(null, [new \ReflectionClass(SomeInterface::class)])`. A concrete user class, an interface as the first argument, a final class or a final method causes a `LogicException`. Entry point: the `$class` and `$interfaces` arguments of `generateLazyProxy()`.
- **Native lazy objects:** for a concrete user class, use the PHP 8.4 methods `ReflectionClass::newLazyGhost()` and `ReflectionClass::newLazyProxy()`. In a Symfony application, mark the service lazy with `#[Lazy]` or `lazy: true`. The container then uses native lazy objects for concrete user classes, and `ProxyHelper` decorators for interfaces, abstract classes and internal classes. Entry point: `\ReflectionClass::newLazyGhost()`, `Symfony\Component\DependencyInjection\Attribute\Lazy`.
- **The `deepclone` extension:** it implements `deepclone_to_array()`, `deepclone_from_array()` and `deepclone_hydrate()` in C. When PHP loads it, `DeepCloner`, `VarExporter::export()`, exported code and `deepclone_hydrate()` use it with no code change. The `DeepCloner` source states a 4-5x speedup over the polyfill. On PHP 8.4 and later, the extension returns objects that hold closures as lazy ghosts, so some errors occur only on first use. Entry point: `pie install symfony/deepclone`.
- **Low-level payload functions:** `deepclone_to_array()` changes a value into an array of scalars and nested arrays, and `deepclone_from_array()` rebuilds the value. You can store this array with `var_export()` in a `.php` file or send it as JSON. `DeepCloner` wraps the same functions and changes their errors into component exceptions. Entry point: `deepclone_to_array($value, $allowed_classes, $allow_named_closures)`, `deepclone_from_array($data, $allowed_classes, $allow_named_closures)`.

## Entry points

- Static method `Symfony\Component\VarExporter\VarExporter::export()`.
- Class `Symfony\Component\VarExporter\DeepCloner` with the methods `deepClone()`, `clone()`, `cloneAs()`, `isStaticValue()`, `toArray()` and `fromArray()`.
- Global functions `deepclone_hydrate()`, `deepclone_to_array()` and `deepclone_from_array()`, and the constants `DEEPCLONE_HYDRATE_CALL_HOOKS`, `DEEPCLONE_HYDRATE_NO_LAZY_INIT` and `DEEPCLONE_HYDRATE_PRESERVE_REFS`. The `deepclone` extension or `symfony/polyfill-deepclone` defines them.
- Static method `Symfony\Component\VarExporter\ProxyHelper::generateLazyProxy()`, the static method `createLazyProxy()` of the generated class, and the interface `Symfony\Component\VarExporter\LazyObjectInterface`.
- Exceptions `Symfony\Component\VarExporter\Exception\ExceptionInterface`, `ClassNotFoundException`, `NotInstantiableTypeException` and `LogicException`. The functions throw `\DeepClone\ClassNotFoundException` and `\DeepClone\NotInstantiableException`, and `\ValueError` for a class outside the allow-list or a malformed payload.
- Deprecated since 8.1: `Symfony\Component\VarExporter\Instantiator::instantiate()` and `Symfony\Component\VarExporter\Hydrator::hydrate()`.
- Install the component with `composer require symfony/var-exporter`. FrameworkBundle, Cache, DependencyInjection and Form already require it.
- Install the extension with `pie install symfony/deepclone`. If PIE does not enable it, add `extension=deepclone` to `php.ini`. `extension_loaded('deepclone')` returns `true` when PHP loads it.
- Without FrameworkBundle: use `VarExporter::export()`, the `DeepCloner` class and the `deepclone_*()` functions directly. They need no service or configuration.
- The component has no service, `framework` configuration key, console command, Twig function or attribute.

## Symbiotic packages

- [Cache](../packages/cache.md): `PhpFilesAdapter` and `PhpArrayAdapter` store arrays and objects as `VarExporter::export()` code that OPcache serves, and `ArrayAdapter` stores `DeepCloner` snapshots and returns deep clones by default.
- [DependencyInjection](../packages/dependency-injection.md): the container builds lazy services as native lazy objects or, for interfaces, abstract and internal classes, as `ProxyHelper` decorators, and copies definitions with `DeepCloner`.
- [FrameworkBundle](../packages/framework-bundle.md): its PHP-file cache warmers write `PhpArrayAdapter` files from `DeepCloner` values, and the secrets vault writes `list.php` with `VarExporter::export()`.
- [Form](../packages/form.md): the `SessionDataStorage` of the multi-step form flow saves the flow data in the session as a `DeepCloner` snapshot.
- [Doctrine Bridge](../packages/doctrine-bridge.md): `ManagerRegistry` resets a lazy entity manager with `resetLazyObject()` when the manager is a `LazyObjectInterface` decorator.
- [Security](../packages/security-bundle.md): before the `ContextListener` serializes the token into the session, it initializes a lazy user object, `LazyObjectInterface` decorators included.
- [ObjectMapper](../packages/object-mapper.md): the object mapper initializes a lazy source object, native or `LazyObjectInterface`, before it examines each property of the source.
- [Serializer](../packages/serializer.md): use the Serializer for JSON, XML or CSV, and VarExporter when PHP reads the data back.
- [VarDumper](../packages/var-dumper.md): use `dump()` to display a value, and VarExporter to write PHP code that rebuilds it; VarDumper also has a caster for VarExporter decorators.
- [Symfony Polyfill](../packages/polyfill.md): `symfony/polyfill-deepclone`, which the component requires, defines the `deepclone_*()` functions in plain PHP only when PHP does not load the extension.

## Changed in 8.0/8.1

- **8.1, exported code:** `VarExporter::export()` now returns a call to `\deepclone_from_array()`. Code that older versions exported for objects throws `LogicException` when PHP loads it, so regenerate the stored files. The exception lets cache pools treat old files as a miss.
- **8.1, new `DeepCloner`:** replace `unserialize(serialize($value))` with `DeepCloner::deepClone($value)`.
- **8.1, deprecated `Instantiator`:** `Instantiator::instantiate(Foo::class, [], [Bar::class => ['secret' => $value]])` -> `deepclone_hydrate(Foo::class, ["\0Bar\0secret" => $value])`. If the values hold `&` references, add `DEEPCLONE_HYDRATE_PRESERVE_REFS`.
- **8.1, deprecated `Hydrator`:** `Hydrator::hydrate($object, $vars)` -> `deepclone_hydrate($object, $vars)`. For the `"\0"` key of `ArrayObject`, `ArrayIterator` or `SplObjectStorage`, call `__unserialize()` after `deepclone_hydrate()`.
- **8.0, removed lazy traits:** `LazyGhostTrait` and `LazyProxyTrait` do not exist anymore. Use `(new \ReflectionClass(Foo::class))->newLazyGhost($initializer)` or `newLazyProxy($factory)`.
- **8.0, removed `ProxyHelper::generateLazyGhost()`:** use `ReflectionClass::newLazyGhost()`.
- **8.0, restricted `ProxyHelper::generateLazyProxy()`:** a concrete user class causes a `LogicException`. Use `ReflectionClass::newLazyProxy()` for such a class.

## Status

- The `deepclone` extension is optional and has a 0.x version. Its CHANGELOG lists breaking changes in 0.3.0, 0.4.0, 0.5.0 and 0.8.0, and a removal in 0.6.0. During the 0.x phase, only the latest minor release gets security updates. If you call the `deepclone_*()` functions directly, read the extension CHANGELOG before an upgrade.
- Without the extension, `symfony/polyfill-deepclone` supplies the same functions in plain PHP, which the docs call several times slower.
- The extension builds for PHP 8.2 or later, NTS or ZTS, 32-bit or 64-bit. Its release job attaches Windows DLLs, which PIE downloads. The component itself requires PHP 8.4.1 or later.

## Docs

- https://symfony.com/doc/current/components/var_exporter.html (the exported-code sample, the `ProxyHelper` interface example and the "deprecation notice" sentence on this page do not match the 8.1 source)
- https://symfony.com/doc/current/performance.html
- https://symfony.com/doc/current/service_container/lazy_services.html
- https://github.com/symfony/php-ext-deepclone
- https://github.com/symfony/polyfill-deepclone
- https://www.php.net/manual/en/language.oop5.lazy-objects.php
