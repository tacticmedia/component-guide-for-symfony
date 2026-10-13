# Doctrine Bridge (`symfony/doctrine-bridge`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when an application with Doctrine ORM entities must load an entity from a URL or a command argument, or reject duplicate values. It also fills entity choice lists in forms and loads login users from the database. It wraps queue message handlers in transactions and maps UUID and date columns.

**Details:** [../details/doctrine-bridge.md](../details/doctrine-bridge.md)

## Why it exists

Doctrine ORM and DBAL do not connect to the controllers, command-line commands, forms, validation, security or message queues of the framework. The bridge supplies that connection. It rejects Doctrine ORM versions before 3.4 and DBAL versions before 4.3. In a full application, a separate Doctrine integration package requires this bridge and registers most of its features.

## When to use it

- Load a Doctrine entity from a route parameter, with a 404 response for a missing entity.
- Load a Doctrine entity from a command-line argument or option.
- Reject a duplicate email, username or other unique value before the database insert.
- Show Doctrine entities as a select list, radio buttons or checkboxes in a form.
- Load the users for a login from a Doctrine entity repository.
- Run all handlers of a queue message in one database transaction.
- Keep the database connection alive and the entity manager clean in a long-running background worker.
- Use UUID or ULID primary keys in Doctrine entities, or date columns that return the date objects of [Clock](clock.md).
- Generate the migration for the tables of database sessions, locks, cache pools, message queues and remember-me tokens.

## Use it instead of

- `$product = $repository->find($id);` plus `if (!$product) { throw $this->createNotFoundException(); }` in each action -> an entity-typed controller argument with `{id}` or `{slug:product}` in the route, or `#[MapEntity]`.
- `$repository->findOneBy(['email' => $email])` plus a manual error message before `persist()` -> `#[UniqueEntity('email')]` on the entity class (on a DTO, add `entityClass`), plus a unique index.
- `ChoiceType` with `choices` built from `findAll()` plus a manual ID-to-entity data transformer -> `EntityType` with `class`, `choice_label` and `query_builder`.
- A custom `UserProviderInterface` class that calls `findOneBy(['email' => $identifier])` -> `security.providers.<name>.entity` with `class` and `property`, or `UserLoaderInterface` on the repository.
- `beginTransaction()`, `flush()`, `commit()` and `rollBack()` in each message handler -> the `doctrine_transaction` middleware on the bus.
- A manual reconnect or `$entityManager->clear()` call in a long-running worker -> the `doctrine_ping_connection` and `doctrine_close_connection` middleware and `DoctrineClearEntityManagerWorkerSubscriber`.
- Hand-written `CREATE TABLE` SQL for `sessions`, `rememberme_token`, the lock table, the cache table or `messenger_messages` -> the schema listeners, which add these tables to `make:migration`.
- A `string` column plus `Uuid::fromString()` in getters and setters -> `#[ORM\Column(type: UuidType::NAME)]`; for a generated ID, also `#[ORM\GeneratedValue(strategy: 'CUSTOM')]` and `#[ORM\CustomIdGenerator('doctrine.uuid_generator')]`.
- A custom remember-me token table and DAO class -> `remember_me.token_provider.doctrine: true`.
- A `datetime_immutable` column plus a manual conversion to `DatePoint` -> `#[ORM\Column(type: 'date_point')]`.
