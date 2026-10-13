# Symfony Contracts (`symfony/contracts`)

**Applies to:** Symfony Contracts 3.7, Symfony 8.1

**Elevator pitch:** Use when code must depend on an interface, not on a class, for a cache, an HTTP client, a translator or an event dispatcher. It also gives a function for deprecation notices, lazy access to a fixed list of dependencies, and a reset hook for long-running processes. The implementations come from [Cache](cache.md), [HttpClient](http-client.md), [Translation](translation.md), [EventDispatcher](event-dispatcher.md) and [DependencyInjection](dependency-injection.md).

**Details:** [../details/contracts.md](../details/contracts.md)

## Why it exists

A type declaration on a concrete class ties the code to one implementation. A test double also cannot extend a final class, for example the cURL HTTP client. The package gives small sets of interfaces, traits, normative docblocks and reference test suites, taken from the Symfony components. Code that declares a contract type works with any matching implementation, from Symfony or from another PHP package.

## When to use it

- Inject a cache, an HTTP client, a translator or an event dispatcher through its interface, not through its class.
- Write a library or a reusable package that accepts any compatible cache, HTTP client or translator implementation.
- Deprecate a class, a method or an argument and tell the user which replacement to use.
- Give a class lazy access to a fixed list of other dependencies, without access to all objects of the application.
- Build a fake dependency locator in a unit test.
- Clean the state of an object between requests or messages in a long-running process, for example a queue worker.
- Make an enum or a value object translatable later, without a translator in its constructor.
- Make an object follow the locale of the current request.
- Get a dependency automatically through a setter, a wither or a public property.
- Test your own HTTP client, translator or dependency locator against a reference test suite.

## Use it instead of

- `$item = $pool->getItem($key); if (!$item->isHit()) { $item->set(compute()); $pool->save($item); }` -> `$cache->get($key, fn (ItemInterface $item) => compute())` with `CacheInterface::get()`, which adds the stampede protection.
- Key prefixes that you build by hand, such as `'user-'.$id.'-dashboard'`, or a stored list of keys that you delete one by one -> `NamespacedPoolInterface::withSubNamespace()`, or `ItemInterface::tag()` with `TagAwareCacheInterface::invalidateTags()`.
- `@trigger_error(sprintf('Since acme/lib 2.1: Method "%s()" is deprecated.', __METHOD__), E_USER_DEPRECATED)` -> `trigger_deprecation('acme/lib', '2.1', 'Method "%s()" is deprecated.', __METHOD__)`.
- An injected `service_container` service and calls such as `$container->get('app.mailer')` -> `ServiceSubscriberInterface` with `ServiceMethodsSubscriberTrait` and `#[SubscribedService]`.
- A hand-written PSR-11 fake container class in a unit test -> `new class(['foo' => fn () => $foo]) implements ServiceProviderInterface { use ServiceLocatorTrait; }`.
- A `kernel.terminate` listener or a worker loop that clears service properties by hand -> `ResetInterface::reset()`, autoconfigured with the `kernel.reset` tag.
- `new CurlHttpClient()` in a constructor, or a `CurlHttpClient` type-hint -> `HttpClientInterface` (the autowired `http_client` service, and `MockHttpClient` in tests).
- `$this->createMock(TranslatorInterface::class)` with a stubbed `trans()` -> `new IdentityTranslator()` from `symfony/translation`, which uses `TranslatorTrait`.
- An enum method that returns a translation key, plus a translator call in each controller -> `enum TextAlign: string implements TranslatableInterface` with a `trans()` method, rendered with `{{ value|trans }}`. If `translation:extract` must find the keys, return a `TranslatableMessage` from an enum method instead.
- A `$handled` flag on an event that each listener must check -> `Event::stopPropagation()` on an event class that extends `Symfony\Contracts\EventDispatcher\Event`.
