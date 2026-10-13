# DependencyInjection (`symfony/dependency-injection`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Autowiring:** The container reads the type declarations of constructor arguments and injects the matching services. Services are private by default. `App::config()` turns on `autowire` and `autoconfigure` by default. Entry point: `_defaults: { autowire: true, autoconfigure: true }`.
- **Resource discovery:** One `resource` entry registers each class in a directory as a service. Use `exclude` or `#[Exclude]` to skip classes. Entry point: `resource`, `exclude`, `#[Exclude]`.
- **Autoconfiguration:** The container adds tags and method calls from the parent types and the attributes of a class. Entry point: `#[AutoconfigureTag]`, `#[Autoconfigure]`, `_instanceof`, `ContainerBuilder::registerForAutoconfiguration()`, `ContainerBuilder::registerAttributeForAutoconfiguration()`.
- **Explicit argument values:** `#[Autowire]` injects a service, a parameter, an env var or an expression into one argument. Entry point: `#[Autowire(service: ...)]`, `#[Autowire(param: ...)]`, `#[Autowire(env: ...)]`, `#[Autowire(expression: ...)]`.
- **Aliases and targets:** `#[AsAlias]` sets the default implementation of an interface. A named autowiring alias plus `#[Target]` selects another implementation for one argument. Entry point: `#[AsAlias]`, `#[AsAlias(target: ...)]` (8.1), `#[Target]`, `ContainerBuilder::registerAliasForArgument()`.
- **Tagged services and resource tags:** `#[AutowireIterator('tag')]` injects all services that have the tag. `#[AsTaggedItem]` sets the key and the priority of each service. Resource tags mark classes that the container must not create, for example entities or value objects. A compiler pass finds these classes with `ContainerBuilder::findTaggedResourceIds()`. Entry point: `#[AutowireIterator]`, `#[AsTaggedItem]`, `!tagged_iterator`, `tagged_iterator()`, `#[AutoconfigureResourceTag]`, `resource_tags`.
- **Service locators:** A service locator is a small container that creates each service only when your code gets it. Entry point: `#[AutowireLocator]`, `ServiceSubscriberInterface`, `ServiceMethodsSubscriberTrait`, `#[SubscribedService]`, `ServiceCollectionInterface`.
- **Decoration:** `#[AsDecorator('id')]` puts your class in place of a service, and `#[AutowireDecorated]` injects the original service. In 8.1, `#[AsTagDecorator('tag')]` decorates all services that have the tag. Entry point: `#[AsDecorator]`, `#[AutowireDecorated]`, `#[AsTagDecorator]`, `decorates`, `decorates_tag`, `stack`.
- **Lazy services:** The container injects a proxy and creates the real service when the code first uses the proxy. The proxies are native PHP 8.4 lazy objects, so `final` classes work. Entry point: `#[Lazy]`, `#[Autowire(lazy: true)]`, `#[Autoconfigure(lazy: true)]`, `lazy: true`.
- **Closures and inline services:** `#[AutowireServiceClosure]` injects a closure that returns a service. `#[AutowireCallable]` and `#[AutowireMethodOf]` inject one method as a closure or as a functional interface. `#[AutowireInline]` creates a new service for one argument. Entry point: these attributes, `!service_closure`, `!closure`.
- **Conditional registration:** `#[When(env: 'dev')]` and `#[WhenNot(env: 'dev')]` register a class only in some environments. The environment is the only supported condition. If you use YAML, put the services in a `when@dev` block, with its own `_defaults`. Entry point: `#[When]`, `#[WhenNot]`, `when@<env>`, `ContainerConfigurator::env()`.
- **Parameters and env var processors:** `%name%` injects a parameter. `%env(NAME)%` injects an env var that the container reads at runtime. 21 built-in processors cast the env string, for example `int:`, `bool:`, `json:`, `csv:`, `file:`, `default:` and `enum:`. Entry point: `%env(int:NAME)%`, `ContainerBagInterface`, `EnvVarProcessorInterface`, `EnvVarLoaderInterface`.
- **Refreshable env vars (8.1):** If the argument type is `\Closure` or `\Stringable`, `#[Autowire(env: ...)]` injects a wrapper that reads the current value on each call. The env cache clears when the container resets its services. Entry point: `#[Autowire(env: ...)]`, `!env_closure`, `EnvClosureArgument`.
- **Compiler passes and extensions:** A compiler pass changes the service definitions before Symfony dumps the container. An extension loads the service definitions and the configuration of a bundle. A kernel or a bundle class that implements `CompilerPassInterface` runs as a compiler pass (bundle classes since 8.1). Entry point: `CompilerPassInterface`, `PassConfig::TYPE_BEFORE_OPTIMIZATION`, `ContainerBuilder::findTaggedServiceIds()`, `AbstractExtension`, `PrependExtensionInterface`.
- **HTTP-less kernel (8.1):** `Kernel\AbstractKernel` plus `Kernel\KernelTrait` build, compile and cache the container without HttpKernel. They use the `config/` conventions of `MicroKernelTrait`. `Kernel\ServicesBundle` gives the core services, and `#[RequiredBundle]` registers the bundles that a bundle needs. Define a `getAllowedEnvs()` method in the kernel that returns the valid `APP_ENV` values. The kernel then throws an `InvalidArgumentException` at boot time for each other environment name. Entry point: `Kernel\AbstractKernel`, `Kernel\KernelTrait`, `Kernel\AbstractBundle`, `Kernel\RequiredBundle`, `getAllowedEnvs()`.

## Entry points

- Types to autowire: `Symfony\Component\DependencyInjection\ParameterBag\ContainerBagInterface` (all parameters), `Symfony\Contracts\Service\ServiceCollectionInterface` or `Psr\Container\ContainerInterface` (with `#[AutowireLocator]`), `Symfony\Component\DependencyInjection\ServicesResetterInterface` (service `services_resetter`).
- Attributes in `Symfony\Component\DependencyInjection\Attribute\`: `AsAlias`, `AsDecorator`, `AsTagDecorator`, `AsTaggedItem`, `Autoconfigure`, `AutoconfigureResourceTag`, `AutoconfigureTag`, `Autowire`, `AutowireCallable`, `AutowireDecorated`, `AutowireInline`, `AutowireIterator`, `AutowireLocator`, `AutowireMethodOf`, `AutowireServiceClosure`, `Exclude`, `Lazy`, `Target`, `When`, `WhenNot`.
- Other attributes: `Symfony\Component\DependencyInjection\Kernel\RequiredBundle`, `Symfony\Contracts\Service\Attribute\Required` (setter injection), `Symfony\Contracts\Service\Attribute\SubscribedService`.
- Interfaces and traits to implement: `Symfony\Component\DependencyInjection\Compiler\CompilerPassInterface`, `Symfony\Component\DependencyInjection\EnvVarProcessorInterface` (tag `container.env_var_processor`), `Symfony\Component\DependencyInjection\EnvVarLoaderInterface` (tag `container.env_var_loader`), `Symfony\Component\DependencyInjection\Extension\AbstractExtension`, `Symfony\Component\DependencyInjection\Extension\PrependExtensionInterface`, `Symfony\Contracts\Service\ServiceSubscriberInterface`, `Symfony\Contracts\Service\ServiceMethodsSubscriberTrait`, `Symfony\Contracts\Service\ResetInterface` (tag `kernel.reset`).
- HTTP-less kernel (8.1): `Symfony\Component\DependencyInjection\Kernel\AbstractKernel`, `Symfony\Component\DependencyInjection\Kernel\KernelTrait`, `Symfony\Component\DependencyInjection\Kernel\AbstractBundle`, `Symfony\Component\DependencyInjection\Kernel\ServicesBundle`, `Symfony\Component\Console\ConsoleBundle`.
- Without FrameworkBundle: `Symfony\Component\DependencyInjection\ContainerBuilder` (`register()`, `autowire()`, `compile()`, `findTaggedServiceIds()`, `findTaggedResourceIds()`, `registerAliasForArgument()`), `Symfony\Component\DependencyInjection\Dumper\PhpDumper`, or the HTTP-less kernel classes above. Compiler passes use the same `ContainerBuilder` methods at build time.
- Configuration files: `config/services.yaml`, or `config/services.php` with `App::config([...])` in the namespace `Symfony\Component\DependencyInjection\Loader\Configurator`. Service keys: `_defaults`, `_instanceof`, `resource`, `namespace`, `exclude`, `arguments`, `bind`, `tags`, `resource_tags`, `decorates`, `decorates_tag`, `decoration_priority`, `decoration_on_invalid`, `stack`, `lazy`, `factory`, `constructor`, `from_callable`, `shared`, `public`. Environment blocks: `when@<env>`.
- PHP configuration functions (namespace `Symfony\Component\DependencyInjection\Loader\Configurator`): `service()`, `param()`, `env()`, `expr()`, `tagged_iterator()`, `tagged_locator()`, `service_locator()`, `service_closure()`, `closure()`, `inline_service()`, `abstract_arg()`, and `ContainerConfigurator::import()` (argument `exclude` in 8.1; YAML and array imports ignore an `exclude` key).
- YAML tags and prefixes: `!tagged_iterator`, `!tagged_locator`, `!service_locator`, `!service_closure`, `!closure`, `!env_closure`, `!service`, `!abstract`, `!returns_clone`, `@id`, `@?id` (optional), `@>id` (closure), `@=` (expression).
- Placeholders: `%parameter_name%`, `%env(NAME)%`, `%env(PROCESSOR:NAME)%`.
- Service tags of the component: `container.env_var_processor`, `container.env_var_loader`, `kernel.reset`, `proxy`, `auto_alias`, `container.hot_path`, `container.preload`, `container.no_preload`.
- Console commands (FrameworkBundle): `debug:container` (`--show-hidden`, `--tag`, `--tags`, `--parameters`, `--env-vars`, `--env-var`, `--deprecations`), `debug:autowiring`, `lint:container` (`--resolve-env-vars`).
- Test helper (FrameworkBundle): `static::getContainer()` in `KernelTestCase` returns a test container that also gives the private services that the compiler did not remove.

## Symbiotic packages

- [FrameworkBundle](../packages/framework-bundle.md): In a full application, `MicroKernelTrait` builds the container, FrameworkBundle requires `ServicesBundle` with `#[RequiredBundle]`, and FrameworkBundle adds `debug:container`, `debug:autowiring` and `lint:container`.
- [HttpKernel](../packages/http-kernel.md): The HttpKernel `Kernel` extends `Kernel\AbstractKernel` and uses `Kernel\KernelTrait`; HTTP applications use it, and HTTP-less applications use the DependencyInjection kernel.
- [Console](../packages/console.md): `ConsoleBundle` (8.1) runs on the DependencyInjection kernel and autoconfigures commands, and `Application` accepts a PSR-11 container as its third argument.
- [Config](../packages/config.md): The file loaders, `ConfigCache` and `Kernel\KernelTrait` need Config, which DependencyInjection does not require; Config validates bundle options, not service definitions.
- [Symfony Contracts](../packages/contracts.md): DependencyInjection requires symfony/service-contracts, which gives `ServiceSubscriberInterface`, `ServiceMethodsSubscriberTrait`, `#[Required]`, `#[SubscribedService]` and `ResetInterface`.
- [ExpressionLanguage](../packages/expression-language.md): `#[Autowire(expression: ...)]`, `expr()` and the `@=` prefix use ExpressionLanguage; without it, `#[Autowire]` and `@=` throw a `LogicException`.
- [Yaml](../packages/yaml.md): `YamlFileLoader` needs the Yaml component to read `config/services.yaml`.
- [VarExporter](../packages/var-exporter.md): DependencyInjection requires VarExporter, and uses its `ProxyHelper` for lazy proxies and its `DeepCloner` for tag decorators.
- [Dotenv](../packages/dotenv.md): `.env` files give the values that `%env()%` reads, and DependencyInjection only reads and casts these values.
- [EventDispatcher](../packages/event-dispatcher.md): If EventDispatcher is installed, `ServicesBundle` registers the `event_dispatcher` service and the autoconfiguration of `#[AsEventListener]`.
- [Messenger](../packages/messenger.md): The Messenger worker resets services between messages through `ServicesResetterInterface`, and refreshable env vars (8.1) target such long-running workers.
- [FrameworkBundle test tools](../packages/framework-bundle-testing.md): `static::getContainer()` in `KernelTestCase` gives the test container, which also contains the private services that the compiler did not remove.
- [Runtime](../packages/runtime.md): The docs boot the DependencyInjection kernel in a console executable through `autoload_runtime.php`.
- [Filesystem](../packages/filesystem.md): `Kernel\KernelTrait` writes the compiled container with `Filesystem`, and `ServicesBundle` registers the `filesystem` service.
- [Clock](../packages/clock.md): If Clock is installed, `ServicesBundle` registers the `clock` service and the `ClockInterface` aliases.
- [MakerBundle](../packages/maker-bundle.md): `make:decorator` generates a decorator class for a service, with `#[AsDecorator]` and `#[AutowireDecorated]`.

## Changed in 8.0/8.1

- XML service files (`services.xml`) -> YAML, PHP (`App::config([...])`) or attributes. Version 8.0 removes the XML format.
- `#[TaggedIterator]`, `#[TaggedLocator]` and the YAML `!tagged` tag -> `#[AutowireIterator]`, `#[AutowireLocator]` and `!tagged_iterator` (removed in 8.0).
- Config builder classes (`use Symfony\Config\FrameworkConfig;`, `static function (FrameworkConfig $framework)`, `$config->color('red')`) -> return `App::config(['acme' => ['color' => 'red']])` or a plain array from the PHP config file (removed in 8.0). Some 8.1 docs examples still show `Symfony\Config\` classes, but Symfony 8.1 does not generate them. If the closure that the PHP config file returns has an argument of a `Symfony\Config\` type, the PHP loader throws an `InvalidArgumentException`. UPGRADE-8.0.md shows `return new AcmeConfig([...])`, but the PHP loader of 8.1 ignores an object that is not callable.
- A named autowiring alias that matches only the argument name -> add `#[Target]` to the argument (deprecated in 8.1).
- `getDefaultPriority()`, `getDefault<Name>Name()`, `defaultIndexMethod` and `defaultPriorityMethod` -> `#[AsTaggedItem(index: ..., priority: ...)]` (deprecated in 8.1).
- HttpKernel `DependencyInjection\Extension`, `Bundle\BundleInterface`, `Config\FileLocator`, `MergeExtensionConfigurationPass` and `ServicesResetter` -> the DependencyInjection classes `Extension\Extension`, `Kernel\BundleInterface`, `Kernel\FileLocator`, `Compiler\MergeExtensionConfigurationPass` and `ServicesResetter` (deprecated in 8.1).
- A hand-made `ContainerBuilder` setup for an HTTP-less application -> `Kernel\AbstractKernel` plus `Kernel\KernelTrait`, and `#[RequiredBundle]` for bundle dependencies (new in 8.1).
- A compiler pass that decorates each tagged service -> `#[AsTagDecorator]` or `decorates_tag` (new in 8.1).

## Docs

- https://symfony.com/doc/current/service_container.html
- https://symfony.com/doc/current/service_container/autowiring.html
- https://symfony.com/doc/current/service_container/injection_types.html
- https://symfony.com/doc/current/service_container/tags.html
- https://symfony.com/doc/current/service_container/subscribers_locators.html
- https://symfony.com/doc/current/service_container/decoration.html
- https://symfony.com/doc/current/service_container/factories.html
- https://symfony.com/doc/current/service_container/lazy_services.html
- https://symfony.com/doc/current/service_container/compiler_passes.html
- https://symfony.com/doc/current/service_container/extensions.html
- https://symfony.com/doc/current/service_container/advanced_definitions.html
- https://symfony.com/doc/current/configuration/env_var_processors.html
- https://symfony.com/doc/current/configuration.html
- https://symfony.com/doc/current/configuration/front_controllers_and_kernel.html
- https://symfony.com/doc/current/bundles.html
- https://symfony.com/doc/current/bundles/extension.html
- https://symfony.com/doc/current/bundles/prepend_extension.html
- https://symfony.com/doc/current/console.html
- https://symfony.com/doc/current/reference/dic_tags.html
- https://symfony.com/doc/current/reference/attributes.html
