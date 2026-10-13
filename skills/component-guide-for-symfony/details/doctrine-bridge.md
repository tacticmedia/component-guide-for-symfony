# Doctrine Bridge (`symfony/doctrine-bridge`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Entity arguments in controllers:** If a controller argument has an entity type, the resolver calls `find()` with the `{id}` route parameter. The route syntax `{slug:product}` makes the resolver call `findOneBy(['slug' => $slug])` for the `$product` argument. If no entity matches and the argument is not nullable, the resolver throws `NotFoundHttpException` (404). If `doctrine.orm.resolve_target_entities` maps an interface to an entity, an argument with that interface type also works. Entry point: `Symfony\Bridge\Doctrine\ArgumentResolver\EntityValueResolver`.
- **`#[MapEntity]` options:** The attribute sets the lookup for one argument with `class`, `id`, `mapping`, `exclude`, `stripNull`, `expr`, `objectManager`, `evictCache`, `disabled` and `message`. Do not use `id` together with `mapping` or `exclude`. The `expr` option needs `symfony/expression-language`. In a controller, the expression gets the variables `repository`, `request` and the route parameters. If you set `class`, the expression can return a list of entities for an `iterable` controller argument. In a command, the expression gets `repository`, `input` and the arguments and options, with their input names as variable names. If an input name has a hyphen, use `input.getArgument("user-id")` or `input.getOption("user-id")` in the expression. Entry point: `Symfony\Bridge\Doctrine\Attribute\MapEntity`.
- **Entity arguments in console commands (new in 8.1):** A command parameter with `#[Argument]` or `#[Option]` and an entity type receives the entity. This works in `__invoke()` and in `#[AsCommand]` methods. `#[MapEntity]` is optional here. Its `mapping` keys and `id` match the input names after a kebab-case conversion (`userId` matches `user-id`). If no entity matches and the parameter is not nullable, the resolver throws a Console `RuntimeException`. This resolver ignores `#[MapEntity(disabled: true)]`. Entry point: `Symfony\Bridge\Doctrine\ArgumentResolver\Console\EntityValueResolver`.
- **Unique values:** The class constraint `UniqueEntity` queries the repository (`findBy` by default). It adds a `UniqueEntity::NOT_UNIQUE_ERROR` violation when another entity has the same field values. The `entityClass` and `identifierFieldNames` options let it validate a DTO. Because the constraint does not prevent race conditions, keep a unique index on the column. Entry point: `Symfony\Bridge\Doctrine\Validator\Constraints\UniqueEntity`.
- **Validation from the mapping:** If `framework.validation.auto_mapping` includes the entity namespace (for example `'App\Entity\': []`), the loader adds `UniqueEntity` for `unique: true` fields. It also adds `Length(max: ...)` for `string` and `text` fields that have a length. `#[Assert\DisableAutoMapping]` and `#[Assert\EnableAutoMapping]` change this for one class or property. Entry point: `Symfony\Bridge\Doctrine\Validator\DoctrineLoader`.
- **Entity choice field:** `EntityType` is a `ChoiceType` that loads its choices from the entity class in the required `class` option. To filter or sort the choices, set `query_builder` to a `QueryBuilder` or to a closure that gets the `EntityRepository`. If you already have the entities, give them in the `choices` option. The `uid_format` option (new in 8.1) sets the format of UID choice values. Entry point: `Symfony\Bridge\Doctrine\Form\Type\EntityType`.
- **Form type guessing:** If you add a field without a type to a form with an entity `data_class`, the guesser reads the Doctrine mapping. An association becomes an `EntityType` field, and a `boolean` column becomes a `CheckboxType` field. The guesser also guesses `required` and the maximum length. Entry point: `Symfony\Bridge\Doctrine\Form\DoctrineOrmTypeGuesser`.
- **Property information:** `DoctrineExtractor` returns the property list and the TypeInfo type (`getType()`) from the ORM mapping. It also marks a generated ID as not writable. DoctrineBundle registers one extractor for each entity manager when `symfony/property-info` is installed. Entry point: `Symfony\Bridge\Doctrine\PropertyInfo\DoctrineExtractor`.
- **Messenger middleware:** `doctrine_transaction` begins a transaction, calls `flush()` and commits after the handlers, and it rolls back on an exception. `doctrine_ping_connection` reconnects a lost connection before a worker handles a message. `doctrine_close_connection` closes the connection after a worker message. `doctrine_open_transaction_logger` logs a transaction that a handler left open. Entry point: `Symfony\Bridge\Doctrine\Messenger\DoctrineTransactionMiddleware`.
- **Entity manager reset in workers:** The subscriber clears all entity managers after each handled or failed worker message. The next message then does not get old data. DoctrineBundle registers the subscriber. Entry point: `Symfony\Bridge\Doctrine\Messenger\DoctrineClearEntityManagerWorkerSubscriber`.
- **Tables in migrations:** When Doctrine generates the schema, five listeners add the tables of `DoctrineDbalAdapter`, `DoctrineDbalStore`, the Doctrine Messenger transport, `PdoSessionHandler` and `DoctrineTokenProvider`. A listener adds a table only if the store uses the same database, and it applies the DBAL schema filter. `make:migration` and `doctrine:schema:update` then include these tables. Entry point: `Symfony\Bridge\Doctrine\SchemaListener\AbstractSchemaListener`.
- **Database users for login:** The `entity` user provider loads a user with `findOneBy()` on the configured `property`. Without `property`, the repository must implement `UserLoaderInterface`. If the repository implements `PasswordUpgraderInterface`, the provider sends each new password hash to it. Entry point: `Symfony\Bridge\Doctrine\Security\User\EntityUserProvider`.
- **Persistent remember-me tokens:** `token_provider: { doctrine: true }` stores the remember-me tokens in the `rememberme_token` table. You can then make a token invalid when you change its database row. The `connection` sub-option selects a DBAL connection. Entry point: `Symfony\Bridge\Doctrine\Security\RememberMe\DoctrineTokenProvider`.
- **UID and DatePoint columns:** The `uuid` and `ulid` types store a native GUID if the platform has one, and a 16-byte binary value if not. The `date_point`, `day_point` and `time_point` types return `Symfony\Component\Clock\DatePoint` objects. `UuidGenerator` and `UlidGenerator` create primary keys only with `#[ORM\GeneratedValue(strategy: 'CUSTOM')]` and `#[ORM\CustomIdGenerator]` on the ID. To use the UUID version from `framework.uid`, give the service ID `doctrine.uuid_generator` to `#[ORM\CustomIdGenerator]`. Doctrine converts UID values in repository methods such as `findOneBy()`. In DQL or a QueryBuilder, give `UuidType::NAME` or `UlidType::NAME` as the third argument of `setParameter()`. Entry point: `Symfony\Bridge\Doctrine\Types\UuidType`.
- **Doctrine event listeners:** The bridge registers each service with the `doctrine.event_listener` tag as a lazy listener. The tag needs `event` and accepts `priority` and `connection`. Without `connection`, the bridge adds the listener to the event manager of each connection. DoctrineBundle adds this tag for the class attribute `Doctrine\Bundle\DoctrineBundle\Attribute\AsDoctrineListener`. The bridge does not register services with a `doctrine.event_subscriber` tag, so write listeners. Entry point: `Symfony\Bridge\Doctrine\ContainerAwareEventManager`.

## Entry points

- Attribute `Symfony\Bridge\Doctrine\Attribute\MapEntity`: on a controller argument, or on a command parameter with `#[Argument]` or `#[Option]`.
- Route syntax `{param:argument}` and `{param:argument.property}` in `#[Route]`, for example `#[Route('/blog/{slug:post}')]`.
- Value resolvers `Symfony\Bridge\Doctrine\ArgumentResolver\EntityValueResolver` (service `doctrine.orm.entity_value_resolver`) and `Symfony\Bridge\Doctrine\ArgumentResolver\Console\EntityValueResolver` (service `doctrine.orm.entity_value_resolver.console`). DoctrineBundle registers both.
- Constraint `Symfony\Bridge\Doctrine\Validator\Constraints\UniqueEntity` (class attribute, repeatable), error code `UniqueEntity::NOT_UNIQUE_ERROR`, validator service `doctrine.orm.validator.unique`.
- Config key `framework.validation.auto_mapping` (enables `Symfony\Bridge\Doctrine\Validator\DoctrineLoader` for the listed namespaces).
- Form type `Symfony\Bridge\Doctrine\Form\Type\EntityType` (options `class`, `em`, `query_builder`, `choices`, `uid_format`).
- Form type guesser `Symfony\Bridge\Doctrine\Form\DoctrineOrmTypeGuesser` (service `form.type_guesser.doctrine`).
- Form extension `Symfony\Bridge\Doctrine\Form\DoctrineOrmExtension` (loads `EntityType` and the type guesser). If a form type under unit test uses `EntityType`, register this extension with a mock `ManagerRegistry`.
- PropertyInfo extractor `Symfony\Bridge\Doctrine\PropertyInfo\DoctrineExtractor` (service `doctrine.orm.<manager>_entity_manager.property_info_extractor`).
- Config key `security.providers.<name>.entity` with `class` (required), `property` and `manager_name` -> `Symfony\Bridge\Doctrine\Security\User\EntityUserProvider`.
- Interface `Symfony\Bridge\Doctrine\Security\User\UserLoaderInterface` (`loadUserByIdentifier()` on the user repository).
- Config key `security.firewalls.<name>.remember_me.token_provider.doctrine` (`true`, or `connection: <name>`) -> `Symfony\Bridge\Doctrine\Security\RememberMe\DoctrineTokenProvider`.
- Config key `framework.messenger.buses.<bus>.middleware` with `doctrine_transaction` (or `doctrine_transaction: ['<entity manager>']`), `doctrine_ping_connection`, `doctrine_close_connection` and `doctrine_open_transaction_logger`.
- Doctrine column types `uuid` (`Symfony\Bridge\Doctrine\Types\UuidType::NAME`), `ulid` (`Symfony\Bridge\Doctrine\Types\UlidType::NAME`), `date_point` (`DatePointType`), `day_point` (`DayPointType`) and `time_point` (`TimePointType`).
- ID generators `Symfony\Bridge\Doctrine\IdGenerator\UuidGenerator` and `UlidGenerator`, and their services `doctrine.uuid_generator` and `doctrine.ulid_generator` (use them with `#[ORM\GeneratedValue(strategy: 'CUSTOM')]` and `#[ORM\CustomIdGenerator]`).
- Service tag `doctrine.event_listener` with the attributes `event`, `priority` and `connection` (DoctrineBundle sets it for `#[AsDoctrineListener]`).
- Console commands and Twig functions: none in this package. The `doctrine:*` commands come from DoctrineBundle.

## Symbiotic packages

- [HttpKernel](../packages/http-kernel.md): `MapEntity` extends the HttpKernel `ValueResolver` attribute, and `EntityValueResolver` implements its `ValueResolverInterface` for controller arguments.
- [Routing](../packages/routing.md): the `{slug:product}` route syntax stores the parameter mapping that the entity resolver reads.
- [Console](../packages/console.md): the Console argument resolvers (new in 8.1) use the Console `EntityValueResolver` for entity parameters of invokable commands.
- [ExpressionLanguage](../packages/expression-language.md): required for the `expr` option of `#[MapEntity]`.
- [Validator](../packages/validator.md): runs `UniqueEntity` and the auto-mapping loader; use its `Unique` constraint for duplicates inside one collection and `UniqueEntity` for duplicates in the database.
- [Form](../packages/form.md): `EntityType` extends `ChoiceType`, and the Form `UuidType` and `UlidType` are form fields, not the Doctrine column types of the same name.
- [Security](../packages/security-bundle.md): its `providers` configuration accepts the `entity` key of the bridge `EntityFactory`, and its `remember_me.token_provider.doctrine` option uses `DoctrineTokenProvider`.
- [PasswordHasher](../packages/password-hasher.md): when a password needs a new hash, `EntityUserProvider::upgradePassword()` sends the hash to a repository that implements `PasswordUpgraderInterface`.
- [Messenger](../packages/messenger.md): uses the Doctrine middleware and the worker subscriber, and the schema listener adds the table of the Doctrine transport (`symfony/doctrine-messenger`) to migrations.
- [Lock](../packages/lock.md): the schema listener adds the `DoctrineDbalStore` table to migrations.
- [Cache](../packages/cache.md): the schema listener adds the `DoctrineDbalAdapter` (`cache.adapter.doctrine_dbal`) table to migrations.
- [HttpFoundation](../packages/http-foundation.md): the schema listener adds the `PdoSessionHandler` session table to migrations.
- [PropertyInfo](../packages/property-info.md): `DoctrineExtractor` is a list, type and access extractor for entities.
- [TypeInfo](../packages/type-info.md): `DoctrineExtractor::getType()` returns a TypeInfo `Type`.
- [Uid](../packages/uid.md): supplies the `Uuid` and `Ulid` values of the `uuid` and `ulid` column types, and the `UuidFactory` that `doctrine.uuid_generator` uses.
- [Clock](../packages/clock.md): supplies `DatePoint`, which the `date_point`, `day_point` and `time_point` column types return.
- [FrameworkBundle](../packages/framework-bundle.md): supplies the `framework.validation.auto_mapping`, `framework.messenger` and `framework.uid` options that these integrations use.
- [WebProfilerBundle](../packages/web-profiler-bundle.md): shows the Doctrine queries in the toolbar and the profiler; DoctrineBundle builds this panel on the bridge `DoctrineDataCollector`.
- [MakerBundle](../packages/maker-bundle.md): `make:entity --with-uuid` and `--with-ulid` write `UuidType` or `UlidType` IDs, `make:form` makes `EntityType` fields for relations except OneToMany, and `make:registration-form` can add `#[UniqueEntity]`.
- [UX Autocomplete](../packages/ux-autocomplete.md): the `autocomplete: true` option turns an `EntityType` field into a Tom Select field, and its Ajax fields have `EntityType` as the parent type.
- [EventDispatcher](../packages/event-dispatcher.md): Doctrine listeners react to entity changes; for domain logic, the docs advise Symfony events, not Doctrine events.

## Changed in 8.0/8.1

- 8.0 removes the automatic mapping of all route parameters to entity properties (`doctrine.orm.controller_resolver.auto_mapping: true`) -> use `{slug:product}` in the route or `#[MapEntity(mapping: [...])]`.
- 8.0 removes `DoctrineExtractor::getTypes()` -> use `DoctrineExtractor::getType()`, which returns a TypeInfo `Type`.
- 8.0 stops reading an options array in constraint constructors: `new UniqueEntity(['fields' => 'email'])` -> `new UniqueEntity(fields: 'email')` or `#[UniqueEntity('email')]`.
- 8.0 makes `ProxyCacheWarmer` final and removes `AbstractDoctrineExtension` -> do not extend these classes.
- 8.1 adds the Console `EntityValueResolver`: `$repository->find($input->getArgument('id'))` in a command -> an entity parameter with `#[Argument]`.
- 8.1 adds the `EntityType` option `uid_format` (`base32`, `base58`, `binary`, `hex`, `rfc4122`) for UID choice values.
- 8.1 deprecates `$aliasMap` in `RegisterMappingsPass`, because Doctrine does not support namespace aliases -> use full class names, not `App:Category`.

## Docs

- https://symfony.com/doc/current/doctrine.html
- https://symfony.com/doc/current/reference/constraints/UniqueEntity.html
- https://symfony.com/doc/current/reference/forms/types/entity.html
- https://symfony.com/doc/current/controller/value_resolver.html
- https://symfony.com/doc/current/console/value_resolver.html
- https://symfony.com/doc/current/routing.html
- https://symfony.com/doc/current/security/user_providers.html
- https://symfony.com/doc/current/security/passwords.html
- https://symfony.com/doc/current/security/remember_me.html
- https://symfony.com/doc/current/messenger.html
- https://symfony.com/doc/current/components/property_info.html
- https://symfony.com/doc/current/components/uid.html
- https://symfony.com/doc/current/components/clock.html
- https://symfony.com/doc/current/doctrine/events.html
- https://symfony.com/doc/current/doctrine/resolve_target_entity.html
- https://symfony.com/doc/current/form/type_guesser.html
- https://symfony.com/doc/current/form/unit_testing.html
- https://symfony.com/doc/current/session.html
- https://symfony.com/doc/current/lock.html
