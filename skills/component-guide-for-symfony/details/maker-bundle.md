# MakerBundle (`symfony/maker-bundle`): details

**Applies to:** MakerBundle 1.68

## Key features and concepts

- **Generated files and class names.** A maker writes PHP classes, Twig templates and configuration changes from its own templates. It does not replace a class or template file that exists: it stops with an error. A class goes into the root namespace and the folder of its type, for example `App\Controller\BlogController`. A name that starts with `\` is an absolute class name. Entry point: `php bin/console list make`.
- **Questions or options.** A maker asks a question for each missing value. Since 1.68, many makers also accept options that replace the questions, for scripts and for terminals without input. With `--no-interaction`, give each value that has no default as an argument or an option. The maker then prints a warning that it is "not meant to be run in non-interactive mode". Arguments and options can change between minor versions. Read `make:<name> --help` before you write a script. `make:stimulus-controller` and `make:docker:database` fail with `--no-interaction`. `make:twig-component` then ignores the namespace in `twig_component.yaml` and uses the default `Twig\Components` namespace. Entry point: `--no-interaction`.
- **Doctrine entities.** `make:entity` creates or updates an entity class and its repository, with getters, setters, adders and removers. Since 1.68, `--field=title:string:100` and `--relation=author:ManyToOne:User` add fields and relations without questions. A trailing `?` makes the field or the relation nullable. `--regenerate` adds the missing methods for properties that you wrote by hand. `--with-uuid` or `--with-ulid` gives the entity a `Uuid` or `Ulid` ID. Entry point: `make:entity`.
- **Migrations, fixtures and the database service.** `make:migration` runs `doctrine:migrations:diff` and writes a migration with the SQL for the mapping changes. If `PdoSessionHandler`, a Lock `DoctrineDbalStore` or a Messenger Doctrine transport uses the Doctrine database, the migration also creates its table. `make:fixtures` creates a fixtures class with a `load()` method in `src/DataFixtures/`. `make:docker:database` adds a MySQL, MariaDB or Postgres service to `compose.yaml`, or to an existing `compose.yml`. It has no options and asks for each value. Entry points: `make:migration`, `make:fixtures`, `make:docker:database`.
- **Controllers and CRUD.** `make:controller Blog` creates `App\Controller\BlogController` with a `#[Route('/blog', name: 'app_blog')]` action and the template `templates/blog/index.html.twig`. If TwigBundle is missing, or with `--no-template`, the action returns a `JsonResponse`. `make:crud Product` creates a controller with `index`, `new`, `show`, `edit` and `delete` actions, a `ProductType` form and six Twig templates. Generated route names start with `app_`. Entry points: `make:controller`, `make:crud`.
- **Users and login.** `make:user` creates a user class as a Doctrine entity, or as a plain class with a user provider. It adds the `app_user_provider` provider to `security.yaml`. If the user has a password and `security.yaml` has no hasher for `PasswordAuthenticatedUserInterface`, it also adds a hasher with `algorithm: auto`. `make:security:form-login` creates a login controller, a template and the `form_login` configuration with CSRF. Its `--logout` option adds a logout route. `make:security:custom` creates an `AbstractAuthenticator` class and sets it as the only item of `custom_authenticators` in the `main` firewall. The generated `supports()` and `authenticate()` methods contain only comments, so each request to the `main` firewall fails with a `TypeError` until you write them. Entry points: `make:user`, `make:security:form-login`, `make:security:custom`.
- **Voters, registration and password reset.** `make:voter` creates a `Voter` class with `supports()` and `voteOnAttribute()`, including the `?Vote $vote` argument. `make:registration-form` creates a registration form type, a controller and a template, with an optional `#[UniqueEntity]` and optional email verification. `make:reset-password` creates a controller, two form types, four templates and a `ResetPasswordRequest` entity with its repository. Email verification needs `symfonycasts/verify-email-bundle`, and `make:reset-password` needs `symfonycasts/reset-password-bundle`. Entry points: `make:voter`, `make:registration-form`, `make:reset-password`.
- **Console commands.** `make:command app:send-report` creates `App\Command\SendReportCommand`, an `#[AsCommand]` class with `__invoke(SymfonyStyle $io, ...)` and no parent class. `--argument=recipient` and `--option=dry-run` add `#[Argument]` and `#[Option]` parameters. The format is `name[:type]`, and the type is `string`, `bool`, `int`, `float`, `array` or a backed enum. A `?` after an argument name makes the argument optional. Entry point: `make:command`.
- **Events, services and messages.** `make:listener` creates a class with an `#[AsEventListener]` method. In interactive mode, a class name that ends with `Subscriber` gives an `EventSubscriberInterface` class. `make:decorator` (new in 1.68) creates an `#[AsDecorator]` class that receives the inner service through `#[AutowireDecorated]`. `make:message` creates a message class and an `#[AsMessageHandler]` handler. If `messenger.yaml` defines an `async` transport, `--transport=async` adds `#[AsMessage('async')]`. `make:messenger-middleware` creates a `MiddlewareInterface` class. Entry points: `make:listener`, `make:decorator`, `make:message`, `make:messenger-middleware`.
- **Forms, validation and serialization.** `make:form ProductType Product` creates an `AbstractType` class with the fields of the bound class and its `data_class`. `make:validator` creates a `Constraint` class and its `ConstraintValidator`. `make:serializer:normalizer` creates a `NormalizerInterface` class that wraps the `serializer.normalizer.object` service. `make:serializer:encoder` creates a class that encodes and decodes one format. Entry points: `make:form`, `make:validator`, `make:serializer:normalizer`, `make:serializer:encoder`.
- **Twig and JavaScript.** `make:twig-extension` creates one class with `#[AsTwigFilter]` and `#[AsTwigFunction]` methods. `make:twig-component Alert` creates an `#[AsTwigComponent]` class and `templates/components/Alert.html.twig`. With `--live`, it creates an `#[AsLiveComponent]` class. `make:stimulus-controller hello` creates the lazy Stimulus controller `assets/controllers/hello_controller.js`, and `--typescript` creates a `.ts` file. Entry points: `make:twig-extension`, `make:twig-component`, `make:stimulus-controller`.
- **Webhooks.** `make:webhook stripe` creates `App\Webhook\StripeRequestParser` and `App\RemoteEvent\StripeWebhookConsumer` with `#[AsRemoteEventConsumer('stripe')]`. It adds `framework.webhook.routing.stripe` with the placeholder secret `your_secret_here` to `config/packages/webhook.yaml`. If `symfony/webhook` is missing, the maker runs `composer require symfony/webhook`. Entry point: `make:webhook`.
- **Tests.** `make:test WebTestCase BlogPostTest` creates a test class in `tests/`. The test types are `TestCase`, `KernelTestCase`, `WebTestCase`, `ApiTestCase` and `PantherTestCase`. The experimental `--with-tests` option of `make:controller`, `make:crud`, `make:registration-form`, `make:reset-password` and `make:security:form-login` adds a test for the generated code. Entry point: `make:test`.
- **Configuration.** `maker.root_namespace` (default `App`) sets the root namespace of all generated classes. `maker.generate_final_classes` (default `true`) adds `final` to the classes of `make:controller`, `make:crud`, `make:voter`, `make:validator`, `make:twig-extension`, `make:webhook` and `make:decorator`. `maker.generate_final_entities` (default `false`) adds `final` to generated entities. The templates of the other makers set `final` or not, whatever the configuration. Entry point: `config/packages/maker.yaml`.
- **Custom makers.** A service that implements `MakerInterface`, usually through `AbstractMaker`, becomes a `make:*` command. Autoconfiguration adds the `maker.command` tag, and the bundle wraps the service in a console command. You cannot change the templates of the core makers. If you need a different code shape, write your own maker. You can also edit the generated files. Entry points: `Symfony\Bundle\MakerBundle\Maker\AbstractMaker`, `maker.command`.

## Entry points

- Installation: `composer require --dev symfony/maker-bundle`. The docs put the configuration under `when@dev` in `config/packages/maker.yaml`.
- Discovery: `php bin/console list make` and `php bin/console make:<name> --help`.
- Makers, grouped by what they generate:
  - Console commands: `make:command` (an `#[AsCommand]` class with `__invoke()`).
  - Controllers: `make:controller` (a controller and a Twig template), `make:crud` (a CRUD controller, a form type and templates for an entity).
  - Doctrine and the database: `make:entity` (an entity and its repository), `make:migration` (a migration class), `make:fixtures` (a fixtures class), `make:docker:database` (a database service in `compose.yaml`).
  - Forms and validation: `make:form` (a form type), `make:validator` (a constraint and its validator).
  - Security, login: `make:user` (a user class and `security.yaml` changes), `make:security:form-login` (a login controller, a template and `form_login`), `make:security:custom` (a custom authenticator).
  - Security, access and accounts: `make:voter` (a voter), `make:registration-form` (a form, a controller and a template), `make:reset-password` (a controller, form types, templates and an entity).
  - Events and services: `make:listener` (an event listener or subscriber), `make:decorator` (a service decorator, new in 1.68).
  - Messenger: `make:message` (a message and its handler), `make:messenger-middleware` (a middleware).
  - Serializer: `make:serializer:normalizer` (a normalizer), `make:serializer:encoder` (an encoder and decoder).
  - Twig and JavaScript: `make:twig-extension` (a Twig extension), `make:twig-component` (a Twig or Live component and its template), `make:stimulus-controller` (a Stimulus controller in `assets/controllers/`).
  - Webhooks: `make:webhook` (a request parser, a remote event consumer and a `webhook.yaml` entry).
  - Tests: `make:test` (a PHPUnit test class).
  - From other packages: `make:autocomplete-field` (`symfony/ux-autocomplete`), `make:native-bridge-controller` (`symfony/ux-native`, experimental).
  - Deprecated, do not use (old -> new): `make:auth` -> `make:security:form-login` or `make:security:custom` (1.59); `make:schedule` -> the Scheduler Flex recipe (1.63); `make:subscriber` -> `make:listener` (1.51); `make:unit-test` and `make:functional-test` -> `make:test` (1.29).
- Config keys: `maker.root_namespace`, `maker.generate_final_classes`, `maker.generate_final_entities`.
- Shared options: `--no-interaction`, `--with-tests` (experimental), `--with-uuid`, `--with-ulid`.
- Custom makers: `Symfony\Bundle\MakerBundle\Maker\AbstractMaker`, `Symfony\Bundle\MakerBundle\MakerInterface`, service tag `maker.command`.
- Maker API: `Symfony\Bundle\MakerBundle\Generator`, `Symfony\Bundle\MakerBundle\InputConfiguration`, `Symfony\Bundle\MakerBundle\DependencyBuilder`, `Symfony\Bundle\MakerBundle\ConsoleStyle`, `Symfony\Bundle\MakerBundle\Exception\RuntimeCommandException`.

## Symbiotic packages

- [Symfony Flex](../packages/flex.md): Flex installs packages and applies their recipes, and MakerBundle generates your code. For a schedule, the Scheduler recipe replaces the deprecated `make:schedule`.
- [Console](../packages/console.md): `make:command` generates an invokable `#[AsCommand]` class, and each maker runs as a console command.
- [FrameworkBundle](../packages/framework-bundle.md): MakerBundle requires it, and generated controllers extend its `AbstractController`.
- [FrameworkBundle test tools](../packages/framework-bundle-testing.md): `make:test` and `--with-tests` generate `KernelTestCase` and `WebTestCase` classes.
- [Routing](../packages/routing.md): Generated controllers use `#[Route]`, with route names that start with `app_`.
- [TwigBundle](../packages/twig-bundle.md): `make:controller` creates a Twig template only when TwigBundle is installed, and `make:crud` requires it.
- [Doctrine Bridge](../packages/doctrine-bridge.md): `make:registration-form --unique-entity` adds its `#[UniqueEntity]` constraint to the user class.
- [Security](../packages/security-bundle.md): `make:user`, `make:security:form-login` and `make:security:custom` generate security classes and update `security.yaml`, and `make:voter` generates a voter.
- [PasswordHasher](../packages/password-hasher.md): `make:user` adds a password hasher, and the generated registration and reset controllers use `UserPasswordHasherInterface`.
- [Form](../packages/form.md): `make:form`, `make:crud`, `make:registration-form` and `make:reset-password` generate `AbstractType` classes.
- [Validator](../packages/validator.md): `make:validator` generates a constraint and its validator, and the generated form types use constraints such as `NotBlank`.
- [Mailer](../packages/mailer.md): `make:reset-password` requires it, and the email verification of `make:registration-form` sends a `TemplatedEmail`.
- [Messenger](../packages/messenger.md): `make:message` generates a message and its `#[AsMessageHandler]` handler, and `make:messenger-middleware` generates a middleware.
- [Scheduler](../packages/scheduler.md): Install it with Flex to get an initial schedule, because `make:schedule` is deprecated since 1.63.
- [Serializer](../packages/serializer.md): `make:serializer:normalizer` and `make:serializer:encoder` generate a normalizer and an encoder.
- [Webhook](../packages/webhook.md): `make:webhook` generates a request parser and the routing entry in `config/packages/webhook.yaml`.
- [RemoteEvent](../packages/remote-event.md): The consumer that `make:webhook` generates has `#[AsRemoteEventConsumer]`.
- [DependencyInjection](../packages/dependency-injection.md): `make:decorator` uses `#[AsDecorator]` and `#[AutowireDecorated]`, and autoconfiguration registers custom makers.
- [EventDispatcher](../packages/event-dispatcher.md): `make:listener` generates `#[AsEventListener]` listeners and `EventSubscriberInterface` subscribers.
- [Uid](../packages/uid.md): `--with-uuid` and `--with-ulid` give the generated entities a `Uuid` or `Ulid` ID.
- [Yaml](../packages/yaml.md): `make:user`, `make:security:form-login`, `make:webhook` and `make:docker:database` require it, because they update YAML files.
- [BrowserKit](../packages/browser-kit.md): `make:test WebTestCase` requires it.
- [CssSelector](../packages/css-selector.md): `make:test WebTestCase` requires it.
- [Panther](../packages/panther.md): `make:test PantherTestCase` generates a test that calls `createPantherClient()`.
- [StimulusBundle](../packages/stimulus-bundle.md): `make:stimulus-controller` requires it.
- [UX Twig Component](../packages/ux-twig-component.md): `make:twig-component` requires it.
- [UX Live Component](../packages/ux-live-component.md): `make:twig-component --live` requires it.
- [Symfony UX Turbo](../packages/ux-turbo.md): `make:entity --broadcast` adds its `#[Broadcast]` attribute to the entity.
- [Mercure](../packages/mercure.md): If you answer yes to the broadcast question of `make:entity` and `symfony/mercure-bundle` is missing, the maker stops with an error.
- [UX Autocomplete](../packages/ux-autocomplete.md): It adds the `make:autocomplete-field` maker.
- [Symfony UX Native](../packages/ux-native.md): It adds the experimental `make:native-bridge-controller` maker.
- [AI Mate](../packages/ai-mate.md): The MakerBundle README recommends coding agents with skills, for example Symfony Mate, for code shapes that the makers do not generate.

## Changed in 1.59 to 1.68

- `make:auth` -> `make:security:form-login` for a login form, or `make:security:custom` for another authenticator (1.59 deprecates `make:auth`).
- Generated classes without `final` -> `final` classes by default. 1.61 adds `maker.generate_final_classes` (default `true`) and makes the `make:crud` and `make:voter` classes `final`. To stop this, set `maker.generate_final_classes: false`.
- `make:schedule` -> `composer require symfony/scheduler`, whose Flex recipe creates an initial schedule (1.63 deprecates `make:schedule`).
- `eraseCredentials()` in the user class -> a `__serialize()` method that stores a `crc32c` hash of the password. `make:user` generates it since 1.64, and Symfony 8.0 removes `UserInterface::eraseCredentials()`.
- `class ... extends Command` with `configure()` and `execute()` -> an `#[AsCommand]` class with `__invoke(SymfonyStyle $io, #[Argument] ..., #[Option] ...)` from `make:command` (1.68).
- `AbstractExtension` with `getFilters()`, `getFunctions()` and a runtime class -> one class with `#[AsTwigFilter]` and `#[AsTwigFunction]` methods from `make:twig-extension` (1.68).
- Questions only -> options for `--no-interaction` (1.68): `make:entity --field/--relation`, `make:command --argument/--option`, `make:crud --controller-class`, and options of `make:registration-form`, `make:reset-password` and `make:security:form-login`. The `chosen-transport` argument of `make:message` becomes the `--transport` option.
- A php-cs-fixer step with `MAKER_PHP_CS_FIXER_BINARY_PATH` and `MAKER_PHP_CS_FIXER_CONFIG_PATH` -> no linting step, and the two variables have no effect (1.68). 1.68 also adds `make:decorator` and requires PHP 8.2 or later and Symfony `^7.4|^8.1`, so it does not support Symfony 8.0.

## Docs

- https://symfony.com/bundles/SymfonyMakerBundle/current/index.html
- https://symfony.com/doc/current/doctrine.html
- https://symfony.com/doc/current/doctrine/associations.html
- https://symfony.com/doc/current/controller.html
- https://symfony.com/doc/current/security.html
- https://symfony.com/doc/current/security/custom_authenticator.html
- https://symfony.com/doc/current/security/user_providers.html
- https://symfony.com/doc/current/security/passwords.html
- https://symfony.com/doc/current/forms.html
- https://symfony.com/doc/current/messenger.html
- https://symfony.com/doc/current/scheduler.html
- https://symfony.com/doc/current/webhook.html
- https://symfony.com/doc/current/testing.html
- https://symfony.com/doc/current/session.html
- https://symfony.com/doc/current/lock.html
- https://symfony.com/bundles/ux-twig-component/current/index.html
- https://symfony.com/bundles/ux-live-component/current/index.html
- https://symfony.com/bundles/ux-autocomplete/current/index.html
- https://symfony.com/bundles/ux-native/current/index.html
- https://symfony.com/doc/current/ai/components/mate.html
