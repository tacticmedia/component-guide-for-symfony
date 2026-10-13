# Symfony Contracts (`symfony/contracts`): details

**Applies to:** Symfony Contracts 3.7, Symfony 8.1

## Key features and concepts

- **Cache, get or compute (`symfony/cache-contracts`):** `get()` returns the cached value. On a miss, it calls your callback and saves the return value. The contract has no `set()` method. The callback receives the cache item (`ItemInterface` in Symfony pools, with `expiresAfter()` and `tag()`) and `bool &$save`. Set `$save = false` to skip the save. Entry point: `Symfony\Contracts\Cache\CacheInterface::get()` and `delete()`.
- **Cache stampede protection:** The third argument of `get()`, `$beta`, controls the probabilistic early expiration. The default is `1.0`, `0` disables it, `INF` forces a recompute, and a negative value throws an exception. It works only for items with an expiration and only through the contract, not through the PSR-6 `getItem()` and `save()` methods. Symfony pools also lock the key, so that one process per host computes it. By default, the lock is off in CLI processes (`cli`, `phpdbg` and `embed` SAPIs) and on Windows. Entry point: `CacheInterface::get($key, $callback, $beta)`.
- **Cache tags and sub-namespaces:** In the callback, `ItemInterface::tag()` adds tags. If the pool is not tag-aware, `tag()` throws a `CacheException`. `TagAwareCacheInterface::invalidateTags()` then invalidates all items that have one of these tags, in all sub-namespaces. `NamespacedPoolInterface::withSubNamespace()` returns a new pool that prefixes the keys. `clear()` on that pool deletes only the items of its sub-namespace, for example with the filesystem, Redis and PDO adapters. Memcached and Couchbase pools use namespace versioning, so there `clear()` invalidates the whole pool. Entry points: `Symfony\Contracts\Cache\TagAwareCacheInterface`, `Symfony\Contracts\Cache\NamespacedPoolInterface`.
- **Cache callbacks as services:** A service that implements `CallbackInterface` computes the value, and you pass it to `get()` instead of a closure. If the pool sets `early_expiration_message_bus`, a Messenger worker recomputes the early-expired items. An anonymous closure cannot go to the worker, so the request computes it. `CacheTrait` adds `get()` and `delete()` to your own PSR-6 pool class. Entry points: `Symfony\Contracts\Cache\CallbackInterface`, `Symfony\Contracts\Cache\CacheTrait`.
- **Deprecation notices (`symfony/deprecation-contracts`):** The global function triggers a silenced `E_USER_DEPRECATED` error. The message starts with `Since <package> <version>: `, and the extra arguments fill the `printf()` placeholders. An error handler collects the notices, for example the ErrorHandler component, or the PHPUnit Bridge with PHPUnit 9 and older. PHPUnit 10.2 and later report these silenced notices only if `<source>` has `ignoreSuppressionOfDeprecations="true"`. Entry point: `trigger_deprecation(string $package, string $version, string $message, mixed ...$args)`.
- **Events (`symfony/event-dispatcher-contracts`):** `dispatch(object $event, ?string $eventName = null)` returns the same event object. The event name defaults to the class of the event. The interface extends the PSR-14 dispatcher interface. The `Event` base class adds `stopPropagation()` and `isPropagationStopped()`. Entry points: `Symfony\Contracts\EventDispatcher\EventDispatcherInterface`, `Symfony\Contracts\EventDispatcher\Event`.
- **HTTP client (`symfony/http-client-contracts`):** The interface has `request()`, `stream()` and `withOptions()`. The `OPTIONS_DEFAULTS` constant defines each option, for example `timeout`, `max_duration`, `max_connect_duration`, `json`, `auth_bearer` and `buffer`. An implementation must throw a `TransportExceptionInterface` for an option that it does not support. Entry point: `Symfony\Contracts\HttpClient\HttpClientInterface`.
- **Lazy responses and HTTP errors:** `request()` returns a lazy response, and the client follows up to 20 redirects (`max_redirects`). For a 4xx or 5xx status, or a 3xx status that the client does not follow, `getHeaders()`, `getContent()` and `toArray()` throw an `HttpExceptionInterface`. To handle the status yourself, pass `false` to these methods. If the code calls none of these methods and not `getStatusCode()`, the destructor throws the exception. The exceptions are `TransportExceptionInterface` (network errors, with `TimeoutExceptionInterface`), `ClientExceptionInterface` (4xx), `ServerExceptionInterface` (5xx), `RedirectionExceptionInterface` (3xx) and `DecodingExceptionInterface` (`toArray()`). Do not confuse them with the HttpKernel `HttpExceptionInterface`, which holds the status code and headers of your own error response. Entry points: `Symfony\Contracts\HttpClient\ResponseInterface`, `Symfony\Contracts\HttpClient\Exception\ExceptionInterface` and its child interfaces.
- **Concurrent streams:** `stream($responses, $timeout)` yields each response with a chunk, as the chunks arrive. `isFirst()`, `isLast()`, `isTimeout()` and `getContent()` describe the chunk. Entry points: `HttpClientInterface::stream()`, `Symfony\Contracts\HttpClient\ChunkInterface`.
- **Service subscribers (`symfony/service-contracts`):** A class lists its dependencies in the static `getSubscribedServices()` method. The container injects a lazy PSR-11 locator that contains only these services. A `?` prefix makes a service optional. Type-hint the locator with `ServiceProviderInterface` to get `getProvidedServices()`, or with `ServiceCollectionInterface` to count and iterate the services. Entry point: `Symfony\Contracts\Service\ServiceSubscriberInterface`.
- **Subscriber trait:** Add `#[SubscribedService]` to a method that has a return type and no parameters. On PHP 8.4, you can also add it to a property with a `get` hook. The trait builds `getSubscribedServices()` and adds a `#[Required]` `setContainer()` method. In the method, return `$this->container->get(__METHOD__)`. Entry points: `Symfony\Contracts\Service\ServiceMethodsSubscriberTrait`, `Symfony\Contracts\Service\Attribute\SubscribedService`.
- **Fake locators:** `ServiceLocatorTrait` implements the methods of `ServiceProviderInterface` from an array of factory closures. It does not keep the created services, and it detects circular references. Use it for a fake locator in a unit test. Entry point: `Symfony\Contracts\Service\ServiceLocatorTrait`.
- **Resettable services:** `reset()` puts an object back to its initial state. Autoconfiguration tags each implementation with `kernel.reset`. The `services_resetter` service then calls `reset()` between main requests and between Messenger messages. If possible, make the service stateless instead. Entry point: `Symfony\Contracts\Service\ResetInterface`.
- **Required dependencies:** With autowiring, the container calls each `#[Required]` method after it creates the service. It also sets each `#[Required]` public typed property. If the method returns `static`, the container uses the returned clone (a wither). Without autowiring, the container ignores the attribute. DependencyInjection 8.1 ignores the `priority` argument that service-contracts v3.7.3 adds. Entry point: `Symfony\Contracts\Service\Attribute\Required`.
- **Translation (`symfony/translation-contracts`):** `trans($id, $parameters, $domain, $locale)` translates a message, and a numeric `%count%` parameter selects the plural form. `TranslatableInterface::trans(TranslatorInterface $translator, ?string $locale = null)` lets an enum or a value object translate itself later. A `LocaleAwareInterface` service gets the request locale through the `kernel.locale_aware` tag. `TranslatorTrait` implements `trans()` and the locale methods without catalogs. Entry points: `Symfony\Contracts\Translation\TranslatorInterface`, `Symfony\Contracts\Translation\TranslatableInterface`, `Symfony\Contracts\Translation\LocaleAwareInterface`, `Symfony\Contracts\Translation\TranslatorTrait`.

## Entry points

- Composer: require only the contract packages that you use: `symfony/cache-contracts`, `symfony/deprecation-contracts`, `symfony/event-dispatcher-contracts`, `symfony/http-client-contracts`, `symfony/service-contracts`, `symfony/translation-contracts`. The `symfony/contracts` package contains all six. An implementation package declares `"provide": {"symfony/cache-implementation": "3.0"}` (pattern `symfony/*-implementation`).
- Without FrameworkBundle: type-hint the contract interfaces and give the code an implementation, for example from Cache, HttpClient or Translation. `trigger_deprecation()`, `ServiceLocatorTrait`, `CacheTrait` and `TranslatorTrait` need no container.
- Autowire `Symfony\Contracts\Cache\CacheInterface` or `Symfony\Contracts\Cache\NamespacedPoolInterface` (service `cache.app`). For another pool, add `#[Target('<pool name>')]`.
- Autowire `Symfony\Contracts\Cache\TagAwareCacheInterface` (service `cache.app.taggable`, a tag-aware pool on top of `cache.app`).
- Autowire `Symfony\Contracts\HttpClient\HttpClientInterface` (service `http_client`). For a scoped client, add `#[Target('<client name>')]`.
- Autowire `Symfony\Contracts\Translation\TranslatorInterface` (service `translator`). If the translator is disabled but Form or Validator is enabled, the service is an `IdentityTranslator`.
- If the translator is enabled, autowire `Symfony\Contracts\Translation\LocaleAwareInterface` (service `translation.locale_switcher`, a `LocaleSwitcher`).
- Autowire `Symfony\Contracts\EventDispatcher\EventDispatcherInterface` (service `event_dispatcher`).
- Autowire a locator of tagged or listed services: a `Symfony\Contracts\Service\ServiceCollectionInterface` argument with the DependencyInjection `#[AutowireLocator('<tag>')]` attribute.
- Implement for autoconfiguration: `Symfony\Contracts\Service\ResetInterface` (tag `kernel.reset`), `Symfony\Contracts\Service\ServiceSubscriberInterface` (tag `container.service_subscriber`), `Symfony\Contracts\Translation\LocaleAwareInterface` (tag `kernel.locale_aware`).
- Attributes: `Symfony\Contracts\Service\Attribute\Required`, `Symfony\Contracts\Service\Attribute\SubscribedService`.
- Traits: `Symfony\Contracts\Service\ServiceMethodsSubscriberTrait`, `Symfony\Contracts\Service\ServiceLocatorTrait`, `Symfony\Contracts\Cache\CacheTrait`, `Symfony\Contracts\Translation\TranslatorTrait`.
- Function: `trigger_deprecation()` (global function of `symfony/deprecation-contracts`).
- Config keys (FrameworkBundle): `framework.cache.pools.<name>.tags`, `framework.cache.pools.<name>.early_expiration_message_bus`, `framework.http_client`, `framework.translator.enabled`.
- Twig (Twig Bridge): the `trans` filter accepts a `TranslatableInterface` object, for example `{{ message|trans }}`.
- Reference test suites for your own implementation: `Symfony\Contracts\HttpClient\Test\HttpClientTestCase` with `Symfony\Contracts\HttpClient\Test\TestHttpServer` (needs `symfony/process`), `Symfony\Contracts\Service\Test\ServiceLocatorTestCase`, `Symfony\Contracts\Translation\Test\TranslatorTest`.

## Symbiotic packages

- [Cache](../packages/cache.md): The Cache component supplies the pools that implement `CacheInterface`, `TagAwareCacheInterface` and `NamespacedPoolInterface`, with the adapters, PSR-6, PSR-16 and the stampede locks.
- [HttpClient](../packages/http-client.md): `CurlHttpClient`, `NativeHttpClient`, `AmpHttpClient`, `MockHttpClient` and the decorators implement `HttpClientInterface`, and HttpClient 8.1 requires `symfony/http-client-contracts` 3.7.
- [Translation](../packages/translation.md): `Translator`, `IdentityTranslator`, `LocaleSwitcher`, `TranslatableMessage` and `StaticMessage` implement the translation contracts, and the `t()` function creates a `TranslatableMessage`.
- [EventDispatcher](../packages/event-dispatcher.md): `EventDispatcher` implements the contract; if you must add, remove or inspect listeners, type-hint the component `EventDispatcherInterface` instead.
- [DependencyInjection](../packages/dependency-injection.md): The container autoconfigures `ResetInterface` and `ServiceSubscriberInterface`, applies `#[Required]` and `#[SubscribedService]`, and its `ServiceLocator` uses `ServiceLocatorTrait`.
- [FrameworkBundle](../packages/framework-bundle.md): FrameworkBundle registers the autowiring aliases for the contract interfaces and autoconfigures `LocaleAwareInterface`, and its `AbstractController` is a service subscriber.
- [HttpKernel](../packages/http-kernel.md): `Kernel::boot()` resets the `kernel.reset` services between main requests, and `LocaleAwareListener` gives the request locale to the `kernel.locale_aware` services.
- [Messenger](../packages/messenger.md): The worker resets the `ResetInterface` services between messages (`--no-reset` disables it), and a cache pool with `early_expiration_message_bus` recomputes items in a worker.
- [Runtime](../packages/runtime.md): In FrankenPHP worker mode, the kernel stays in memory, so a stateful service must implement `ResetInterface`; `FRANKENPHP_RESET_KERNEL=1` is a slower alternative.
- [PHPUnit Bridge](../packages/phpunit-bridge.md): With PHPUnit 9 and older, the bridge reports the notices of `trigger_deprecation()`, and `ExpectDeprecationTrait::expectDeprecation()` asserts them with the `Since <package> <version>: ` prefix.
- [ErrorHandler](../packages/error-handler.md): The ErrorHandler error handler catches and logs the silenced notices of `trigger_deprecation()`.
- [Twig Bridge](../packages/twig-bridge.md): The `trans` filter translates `TranslatableInterface` objects, and `TranslationExtension` uses a `TranslatorTrait` translator when no translator is set.
- [Serializer](../packages/serializer.md): `TranslatableNormalizer` normalizes a `TranslatableInterface` object to a translated string.
- [Form](../packages/form.md): `EnumType` labels and the `help` option accept `TranslatableInterface` objects.
- [String](../packages/string.md): `AsciiSlugger` implements `LocaleAwareInterface`, so the `slugger` service follows the request locale.
- [Mailer](../packages/mailer.md): Mailer throws its own `Symfony\Component\Mailer\Exception\TransportExceptionInterface`; catch that interface around `MailerInterface::send()`, not the HttpClient contract.
- [Console](../packages/console.md): The console `Application` implements `ResetInterface` and sends `reset()` to the `services_resetter` service.

## Changed in 3.5 to 3.7 (and Symfony 8.0/8.1)

- 3.5: `ServiceSubscriberTrait` is deprecated, and loading it triggers a deprecation. Use `ServiceMethodsSubscriberTrait` with `#[SubscribedService]`.
- 3.5: `ServiceCollectionInterface` is new. Type-hint a locator with it to `count()` and iterate the services.
- 3.6: `NamespacedPoolInterface::withSubNamespace()` is new. Use it instead of key prefixes that you build by hand.
- 3.7: `#[SubscribedService]` also works on a PHP 8.4 property with a `get` hook.
- 3.7 (Symfony 8.1): `ContainerProviderInterface::getContainer()` is new. `Symfony\Contracts\Service\ContainerAwareInterface` (added in 8.1.0, renamed in 8.1.1) is deprecated and extends it. DependencyInjection 7.0 removed its own `ContainerAwareInterface` and `ContainerAwareTrait`. Inject the services instead.
- 3.7 (Symfony 8.1): The `max_connect_duration` request option limits the time for DNS, TCP and TLS.
- Symfony 8.1: To select a named cache pool or a scoped HTTP client, use `#[Target('name')]`. Selection by argument name (`CacheInterface $customThingCache`) is deprecated.
- Symfony 8.0: `TranslatableMessage::__toString()` is removed. Call `$message->trans($translator)` or use the Twig `trans` filter.

## Docs

- https://symfony.com/doc/current/components/contracts.html
- https://symfony.com/doc/current/service_container/subscribers_locators.html
- https://symfony.com/doc/current/cache.html
- https://symfony.com/doc/current/http_client.html
- https://symfony.com/doc/current/translation.html
- https://symfony.com/doc/current/event_dispatcher.html
- https://symfony.com/doc/current/service_container/autowiring.html
- https://symfony.com/doc/current/service_container/injection_types.html
- https://symfony.com/doc/current/reference/dic_tags.html
- https://symfony.com/doc/current/reference/attributes.html
- https://symfony.com/doc/current/components/phpunit_bridge.html
- https://symfony.com/doc/current/contributing/code/conventions.html
- https://symfony.com/doc/current/components/http_kernel.html
- https://symfony.com/doc/current/messenger.html
- https://symfony.com/doc/current/testing.html
