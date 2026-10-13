# DependencyInjection (`symfony/dependency-injection`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when the classes of an application, a CLI tool or a worker must receive their dependencies and settings, and must not create them. The package creates the objects and connects them by the types of their constructor arguments. It also injects environment variables, collects all implementations of one kind, and delays heavy objects until first use.

**Details:** [../details/dependency-injection.md](../details/dependency-injection.md)

## Why it exists

A class that creates its own dependencies is coupled to them, and it is difficult to reuse and test. The package gives a PSR-11 container that creates the objects of an application and connects them. It checks and optimizes the object definitions at build time, and caches the result as PHP code.

## When to use it

- Give a class its dependencies through constructor arguments, not with the new operator or a global registry.
- Inject a configuration value, an environment variable or an expression into a constructor argument.
- Cast environment variable strings to integers, booleans, JSON arrays or enums.
- Collect all handlers of one kind, then loop over them or pick one by a key, such as a payment method.
- Select one of several implementations of the same interface.
- Change the behavior of an existing object, also one from a vendor package, with a decorator.
- Delay the creation of a heavy object until the code first uses it.
- Register a class only in one environment, for example development or test.
- Build a console tool or a background worker that gets its dependencies the same way, but has no HTTP layer.
- Reset the state of objects between requests or messages in a long-running worker.
- Read the current value of an environment variable at each call in a long-running process.

## Use it instead of

- `new Mailer(new SmtpTransport($host))` in each class, or a static `Registry::get('mailer')` -> constructor injection with autowiring (`_defaults: { autowire: true }` or `App::config([...])`).
- `$this->container->get('app.mailer')` in application code -> a constructor argument with the type of the service. Services are private by default, and `debug:autowiring` lists the types.
- `(int) getenv('MAX_ITEMS')` or `json_decode($_ENV['FLAGS'], true)` -> `#[Autowire(env: 'int:MAX_ITEMS')]` or `%env(json:FLAGS)%`.
- A hard-coded array of handler objects -> `#[AutoconfigureTag('app.handler')]` on the handler interface plus `#[AutowireIterator('app.handler')]`.
- `match ($method) { 'paypal' => new PaypalPayment(), ... }` -> `#[AutowireLocator('app.payment_handler')]` plus `#[AsTaggedItem(index: 'paypal')]` on each handler.
- A subclass of a vendor service that you register again under the vendor service ID -> `#[AsDecorator('vendor.service.id')]` plus `#[AutowireDecorated]`.
- `if (null === $this->client) { $this->client = new HeavyClient(); }` -> `#[Lazy]`, `#[Autowire(lazy: true)]` or `#[AutowireServiceClosure]`.
- `if ('dev' === $_SERVER['APP_ENV']) { ... }` around service setup -> `#[When(env: 'dev')]` or a `when@dev` block.
- A console script that builds a `ContainerBuilder` by hand and adds each command -> `Kernel\AbstractKernel` plus `Kernel\KernelTrait` and `ConsoleBundle`.
- Manual `$service->clear()` calls in a worker loop -> implement `Symfony\Contracts\Service\ResetInterface`. The `kernel.reset` tag resets the service between requests and between messages.
