# Config (`symfony/config`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when a reusable package or a tool must validate nested configuration arrays from several files, add defaults and merge them into one result. It also finds and loads files by format, and caches generated PHP code until a source file changes. For the options array of one class, see [OptionsResolver](options-resolver.md). For plain application settings, use parameters of [DependencyInjection](dependency-injection.md).

**Details:** [../details/config.md](../details/config.md)

## Why it exists

A reusable package gets its configuration as a list of arrays, one for each configuration file, and each array can set different keys. A plain array merge does not check types, defaults or misspelled keys. The package validates, normalizes and merges these arrays against one tree definition. It also gives the file loaders and the file-based code cache that other packages use.

## When to use it

- Define, validate and document the configuration options of a reusable package.
- Merge the configuration of a package from several files and environments into one validated array.
- Give an option a default value, a required flag, a set of allowed values or a deprecation notice.
- Accept a short form of an option, for example true or a string, and normalize it to the full array.
- Show the default or the current configuration of a package in the terminal.
- Find a file in a list of directories and load it with the loader that supports its format.
- Cache generated PHP code and generate it again only when a source file changes.
- Validate and merge parsed YAML or PHP configuration files in a plain PHP tool, without the framework.
- Give IDEs and static analysis tools the array shapes of the PHP configuration files.

## Use it instead of

- `array_merge()` or `array_replace_recursive()` over the `$configs` list in `Extension::load()` -> `$this->processConfiguration(new Configuration(), $configs)`, or `AbstractBundle::configure()` plus `loadExtension()`.
- `$config['host'] ?? 'localhost'` plus `if (!in_array($config['driver'], ['mysql', 'sqlite'])) { throw ... }` -> `defaultValue('localhost')`, `enumNode()->values([...])` or `validate()->ifNotInArray([...])->thenInvalid(...)`.
- `if (is_string($config['hosts'])) { $config['hosts'] = [$config['hosts']]; }` -> `beforeNormalization()->castToArray()` or `acceptAndWrap(['string'])`.
- `foreach ($dirs as $dir) { if (file_exists($dir.'/'.$name)) ... }` -> `FileLocator::locate($name, $currentDir, $first)`.
- `switch (pathinfo($file, PATHINFO_EXTENSION))` to select a parser -> one `Loader` subclass for each format, plus `LoaderResolver` and `DelegatingLoader`.
- `foreach (glob($dir.'/*.yaml') as $file) { ... }` -> `FileLoader::import('*.yaml')` with `$ignoreErrors` and `$exclude`.
- `if (filemtime($source) > filemtime($cacheFile)) { file_put_contents($cacheFile, $code); }` -> `ConfigCache::isFresh()` plus `ConfigCache::write($code, [new FileResource($source)])`.
- A new bundle with a separate `Extension` class and a `Configuration` class -> `AbstractBundle::configure()` and `AbstractBundle::loadExtension()` in the bundle class.
- A hand-written list of bundle options in a README -> `info()` and `example()` on the nodes, then `php bin/console config:dump-reference <bundle>`.
