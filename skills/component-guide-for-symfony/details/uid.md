# Uid (`symfony/uid`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **UUID versions:** `Uuid::v1()`, `v3()`, `v4()`, `v5()`, `v6()`, `v7()` and `v8()` return `UuidV1` to `UuidV8` objects. The component does not implement UUIDv2. UUIDv4 is random and contains no time. UUIDv1 can contain the MAC address of the host, and UUIDv6 uses a random node instead. The docs recommend UUIDv7 instead of UUIDv1 and UUIDv6. `v8()` takes a UUID string that you make yourself. This string must have the version digit `8` and the RFC variant, or `v8()` throws `Invalid UUIDv8.` Entry point: `Symfony\Component\Uid\Uuid`.
- **Time-ordered UUIDv7:** `UuidV7` contains a Unix timestamp with microsecond precision. In one PHP process, each new `UuidV7` is greater than the previous one, so the values sort by creation time. `getDateTime()` returns the timestamp as a `\DateTimeImmutable`. `UuidV1`, `UuidV6` and `Ulid` also implement `TimeBasedUidInterface`. Entry point: `Uuid::v7()`, `Symfony\Component\Uid\TimeBasedUidInterface`.
- **Name-based UUIDs:** `Uuid::v5($namespace, $name)` (SHA-1) and `Uuid::v3($namespace, $name)` (MD5) return the same UUID for the same namespace and name. The namespace is a `Uuid` object, for example `Uuid::fromString(Uuid::NAMESPACE_URL)`. The constants `NAMESPACE_DNS`, `NAMESPACE_URL`, `NAMESPACE_OID` and `NAMESPACE_X500` contain the standard namespaces. The Messenger docs warn that a UUID made at dispatch time is not an idempotency key, because each dispatch makes a new UUID. Entry point: `Uuid::v5()`.
- **ULID:** `new Ulid()` creates a 128-bit ID with a 48-bit timestamp in milliseconds and 80 random bits. Its canonical form is a base32 string of 26 characters. In the same millisecond, the next ULID of a process gets the random part of the previous ULID plus 1. Thus, the order stays correct. Entry point: `Symfony\Component\Uid\Ulid`.
- **Parsers:** `fromString()` accepts the RFC 4122, base32, base58 and binary forms. `Uuid::fromString()` returns the class of the version, for example `UuidV7`, or `NilUuid` and `MaxUuid` for the all-zero and all-one values. A version class also checks the version, so `UuidV4::fromString()` rejects a UUIDv1. `fromRfc4122()`, `fromBase32()`, `fromBase58()` and `fromBinary()` first check the length of one form. Invalid input causes a `Symfony\Component\Uid\Exception\InvalidArgumentException`. Since 8.1, its `$invalidValue` property contains the input. Entry point: `Uuid::fromString()`, `Ulid::fromString()`.
- **Conversion and comparison:** `toRfc4122()`, `toBase32()`, `toBase58()`, `toBinary()` and `toHex()` return other forms of the same 128 bits. A string cast, `toString()` and `json_encode()` give the canonical form: RFC 4122 for a UUID and base32 for a ULID. `toBase58()` gives the shortest text form, with 22 characters. `UuidV1::toV6()`, `UuidV1::toV7()` and `UuidV6::toV7()` convert a time-based UUID to a newer version. `equals()` compares two values, and `compare()` returns a negative number, zero or a positive number. Entry point: `Symfony\Component\Uid\AbstractUid`.
- **Validation without exceptions:** `Uuid::isValid($value, $format)` and `Ulid::isValid($value, $format)` return a boolean. By default, `Uuid::isValid()` accepts only the RFC 4122 form, and `Ulid::isValid()` accepts only base32. To accept other forms, combine the `FORMAT_*` flags or use `FORMAT_ALL`. On a version class, `isValid()` also checks the version, for example `UuidV7::isValid()`. Entry point: `Uuid::isValid($value, Uuid::FORMAT_ALL)`.
- **Factories:** the `UuidFactory` service creates UUIDs with `create()` or with the sub-factories `timeBased()`, `randomBased()` and `nameBased($namespace)`. By default, `create()` and `timeBased()` give UUIDv7, `randomBased()` gives UUIDv4 and `nameBased()` gives UUIDv5. The `framework.uid` options change these versions and set a default namespace and node. `nameBased()` accepts a UUID or one of the keywords `dns`, `url`, `oid` and `x500`. Without a namespace, it throws a `LogicException`. Give the node as a full UUID. The factory copies the last 12 hexadecimal digits of the node into UUIDv1 and UUIDv6 values; UUIDv7 ignores the node. A node of 12 digits, as in the docs example `121212121212`, causes the error `Invalid UUID.` Entry point: `Symfony\Component\Uid\Factory\UuidFactory`, `Symfony\Component\Uid\Factory\UlidFactory`.
- **Hidden creation time (8.1):** `Uuid47Transformer::encode()` converts a `UuidV7` into a `UuidV4` that hides the timestamp, and `decode()` gives back the `UuidV7`. Use it to keep UUIDv7 keys in the database and show UUIDv4 values in public URLs. FrameworkBundle registers the `uuid47_transformer` service. Its key is `framework.uid.uuid47_secret` or, if you do not set that option, `kernel.secret`. The key must have at least 16 bytes and must not be one repeated byte. If you decode with a different key, you get a different UUIDv7 and no error. Thus, keep the key stable. `decode()` accepts any UUIDv4 and does not prove that the value is authentic. Thus, check that the record exists and that the user has access. The class needs the `sodium` PHP extension. Entry point: `Symfony\Component\Uid\Uuid47Transformer`.
- **UUIDs in tests:** `MockUuidFactory` extends `UuidFactory` and returns the UUIDs of a list in order. Its `randomBased()`, `timeBased()` and `nameBased()` factories check that the next UUID has the expected version, time, node or name. When no UUID is left, `create()` throws a `LogicException`. A mismatch throws an `InvalidArgumentException`. Entry point: `new MockUuidFactory([UuidV4::fromString('11111111-1111-4111-8111-111111111111')])`.
- **Console commands:** `uuid:generate` and `ulid:generate` create IDs. `uuid:inspect` and `ulid:inspect` show the RFC 4122, base58, base32 and hexadecimal forms of an ID and, for a time-based ID, its time. FrameworkBundle does not register these commands. To use them, register the four command classes as services. `uuid:generate` has the options `--time-based`, `--node`, `--name-based`, `--namespace`, `--random-based`, `--count` and `--format`. Entry point: `Symfony\Component\Uid\Command\GenerateUuidCommand`.
- **Doctrine columns and IDs:** the Doctrine Bridge column types `uuid` and `ulid` store a native GUID if the database has one. If not, they store a fixed 16-byte binary value. DoctrineBundle registers both types. For a generated primary key, use `#[ORM\GeneratedValue(strategy: 'CUSTOM')]` with `#[ORM\CustomIdGenerator('doctrine.uuid_generator')]`. This service uses the `framework.uid` versions, but `class: UuidGenerator::class` ignores them. In DQL or a `QueryBuilder`, give `UuidType::NAME` or `UlidType::NAME` as the third argument of `setParameter()`. The docs warn that UID primary keys make larger and slower indexes than integer keys. UUIDv6, UUIDv7 and ULID values do not fragment the index. Entry point: `Symfony\Bridge\Doctrine\Types\UuidType::NAME`.
- **Validation constraints:** `#[Assert\Uuid]` and `#[Assert\Ulid]` check the string form of a value, and they do not need this package. By default, `Uuid` accepts all versions in the strict RFC 4122 form. The option `versions: [Assert\Uuid::V7_MONOTONIC]` limits the versions, and `strict: false` accepts other hyphen positions and wrapping characters. `Ulid` checks base32 by default. Its `format` option also accepts `Assert\Ulid::FORMAT_BASE_58` and `Assert\Ulid::FORMAT_RFC_4122`. Entry point: `Symfony\Component\Validator\Constraints\Uuid`, `Symfony\Component\Validator\Constraints\Ulid`.
- **Routes, controllers and commands:** `Requirement::UUID`, `Requirement::UUID_V7`, `Requirement::ULID` and the `UID_*` constants limit a route placeholder to one form. A controller argument with a UID type, for example `UuidV7 $id`, gets the object from the route parameter in any form. If the value is not valid for that type, the response is 404. `#[MapQueryParameter]` also converts a query value, but an invalid UID causes an `InvalidArgumentException` and not a 404 response. Since 8.1, the `#[Argument]` and `#[Option]` parameters of an invokable command accept UID types. If you give a UID to `generateUrl()` as an extra parameter, cast it to a string. Entry point: `Symfony\Component\Routing\Requirement\Requirement`.
- **Serializer:** `UidNormalizer` converts UID objects to strings in the canonical form by default. The context key `uid_normalization_format` selects `canonical`, `base58`, `base32` or `rfc4122`. Denormalization accepts all forms, and an invalid string causes a `NotNormalizableValueException`. Entry point: `Symfony\Component\Serializer\Normalizer\UidNormalizer`, `UidNormalizerContextBuilder::withNormalizationFormat()`.

## Entry points

- Classes `Symfony\Component\Uid\Uuid`, `UuidV1`, `UuidV3`, `UuidV4`, `UuidV5`, `UuidV6`, `UuidV7`, `UuidV8`, `NilUuid`, `MaxUuid`, `Ulid`, `NilUlid` and `MaxUlid`, with the base class `Symfony\Component\Uid\AbstractUid` and the interface `Symfony\Component\Uid\TimeBasedUidInterface`.
- Without FrameworkBundle: `Uuid::v7()` and the other static methods of the classes above, or `new Ulid()`. `new UuidFactory()` creates a factory that makes `UuidV7` objects by default.
- Autowire `Symfony\Component\Uid\Factory\UuidFactory` (service `uuid.factory`) or `Symfony\Component\Uid\Factory\UlidFactory` (service `ulid.factory`).
- Autowire `Symfony\Component\Uid\Factory\TimeBasedUuidFactory` (`time_based_uuid.factory`), `RandomBasedUuidFactory` (`random_based_uuid.factory`) or `NameBasedUuidFactory` (`name_based_uuid.factory`, needs `framework.uid.name_based_uuid_namespace`).
- Autowire `Symfony\Component\Uid\Uuid47Transformer` (service `uuid47_transformer`, 8.1).
- Config key `framework.uid`: `enabled` (on when `symfony/uid` is installed), `default_uuid_version` (7, 6, 4 or 1; default 7), `time_based_uuid_version` (7, 6 or 1; default 7), `time_based_uuid_node` (a UUID), `name_based_uuid_version` (5 or 3; default 5), `name_based_uuid_namespace` (a UUID or `dns`, `url`, `oid`, `x500`), `uuid47_secret` (default `kernel.secret`).
- Console commands, after you register them as services: `uuid:generate` (`Symfony\Component\Uid\Command\GenerateUuidCommand`), `uuid:inspect` (`InspectUuidCommand`), `ulid:generate` (`GenerateUlidCommand`), `ulid:inspect` (`InspectUlidCommand`).
- Test helper `Symfony\Component\Uid\Factory\MockUuidFactory`.
- Doctrine column types `uuid` (`Symfony\Bridge\Doctrine\Types\UuidType::NAME`) and `ulid` (`Symfony\Bridge\Doctrine\Types\UlidType::NAME`), and the DoctrineBundle ID generator services `doctrine.uuid_generator` and `doctrine.ulid_generator`.
- Constraints `#[Assert\Uuid]` (options `versions`, `strict`, `normalizer`) and `#[Assert\Ulid]` (option `format`) in `Symfony\Component\Validator\Constraints`.
- Route requirements `Symfony\Component\Routing\Requirement\Requirement::UUID`, `UUID_V1`, `UUID_V3` to `UUID_V8`, `ULID`, `UID_BASE32`, `UID_BASE58`, `UID_RFC4122` and `UID_RFC9562`.
- Controller arguments with a UID type (`Symfony\Component\HttpKernel\Controller\ArgumentResolver\UidValueResolver`) and `#[Symfony\Component\HttpKernel\Attribute\MapQueryParameter]`.
- Command parameters with `#[Argument]` or `#[Option]` and a UID type (`Symfony\Component\Console\ArgumentResolver\ValueResolver\UidValueResolver`, 8.1).
- Serializer `Symfony\Component\Serializer\Normalizer\UidNormalizer` with the context key `uid_normalization_format`, and `Symfony\Component\Serializer\Context\Normalizer\UidNormalizerContextBuilder::withNormalizationFormat()`.
- Form types `Symfony\Component\Form\Extension\Core\Type\UuidType` and `UlidType`, and the `EntityType` option `uid_format` (8.1).
- Install the package with `composer require symfony/uid`.

## Symbiotic packages

- [FrameworkBundle](../packages/framework-bundle.md): the `framework.uid` options configure the `uuid.factory` service, and the bundle registers the factories, the `uuid47_transformer` service and the controller UID resolver.
- [Doctrine Bridge](../packages/doctrine-bridge.md): the `uuid` and `ulid` column types and the ID generators store and create UID values, and the `EntityType` option `uid_format` formats UID choices.
- [MakerBundle](../packages/maker-bundle.md): with `--with-uuid` or `--with-ulid`, `make:entity`, `make:user` and `make:reset-password` write a UID primary key with the `doctrine.uuid_generator` or `doctrine.ulid_generator` service.
- [Validator](../packages/validator.md): `#[Assert\Uuid]` and `#[Assert\Ulid]` check the string form of an ID without this package; in plain PHP code, use `Uuid::isValid()`.
- [Routing](../packages/routing.md): `Requirement::UUID`, `Requirement::UUID_V7` and `Requirement::ULID` limit a route placeholder to one UID form.
- [HttpKernel](../packages/http-kernel.md): `UidValueResolver` converts a route parameter into the UID type of a controller argument and returns a 404 response for an invalid value.
- [Console](../packages/console.md): since 8.1, `UidValueResolver` converts an `#[Argument]` or `#[Option]` value of an invokable command into a UID object.
- [Serializer](../packages/serializer.md): `UidNormalizer` converts UID objects to strings in the canonical, base58, base32 or RFC 4122 form, and back from all forms.
- [Form](../packages/form.md): `UuidType` and `UlidType` map a text field to a `Uuid` or `Ulid` object.
- [Symfony Polyfill](../packages/polyfill.md): this package requires `symfony/polyfill-uuid`, which supplies the `uuid_*()` functions when the `uuid` extension is missing.
- [UX Live Component](../packages/ux-live-component.md): a LiveProp can hold a UID object, and the bundle sends it to the browser as a string.
- [Symfony UX Calendar Link](../packages/ux-calendar-link.md): Calendar Link requires this package, and a stored `Uuid` in the `uid` argument of `CalendarEvent` keeps the `.ics` UID stable when the event changes.
- [UX Autocomplete](../packages/ux-autocomplete.md): the entity search compares a `uuid`, `guid` or `ulid` property with the search text when the text is a valid UUID or ULID.
- [VarDumper](../packages/var-dumper.md): `dump()` shows a `Uuid` or `Ulid` object with two other text forms and, for a time-based ID, its time.
- [Messenger](../packages/messenger.md): a custom transport can use `Uuid::v4()` as the message ID, but a UUID made at dispatch time is not an idempotency key.
- [String](../packages/string.md): for a random code in your own alphabet, use `ByteString::fromRandom()`; for UUID and ULID identifiers, use this package.

## Changed in 8.0/8.1

- **8.1, `Uuid47Transformer`:** the new class and the `uuid47_transformer` service hide the creation time of UUIDv7 IDs. The option `framework.uid.uuid47_secret` sets the key.
- **8.1, `Ulid::isValid()`:** the method takes a second argument for the format, for example `Ulid::isValid($value, Ulid::FORMAT_RFC_4122)`. Without it, the method accepts only base32.
- **8.1, exceptions:** `Symfony\Component\Uid\Exception\InvalidArgumentException::$invalidValue` contains the rejected input. The value is untrusted, so shorten or remove it before a logger writes it.
- **8.1, Console:** an invokable command can take a `Uuid` or `Ulid` parameter with `#[Argument]` or `#[Option]`.
- **8.1, Doctrine Bridge:** the `EntityType` option `uid_format` sets the form of UID choice values: `base32`, `base58`, `binary`, `hex` or `rfc4122`.
- **8.0, `Uuid::isValid()`:** the method declares the argument `int $format = Uuid::FORMAT_RFC_9562`. If a class extends `Uuid` and overrides `isValid()`, add this argument.
- **8.0 (also 7.4):** `new UuidFactory()` creates `UuidV7` objects by default, UUIDv7 has microsecond precision, and `MockUuidFactory` replaces hand-written fake factories in tests.
- **8.0, Validator:** `new Assert\Uuid(['versions' => [7]])` throws an exception. Use named arguments, for example `new Assert\Uuid(versions: [Assert\Uuid::V7_MONOTONIC])`.

## Status

The `Uuid47Transformer` class needs the `sodium` PHP extension. Without it, the constructor throws a `LogicException`. The other classes need no extension, because `symfony/polyfill-uuid` supplies the `uuid_*()` functions when the `uuid` extension is missing.

## Docs

- https://symfony.com/doc/current/components/uid.html
- https://symfony.com/doc/current/reference/configuration/framework.html
- https://symfony.com/doc/current/doctrine.html
- https://symfony.com/doc/current/reference/constraints/Uuid.html
- https://symfony.com/doc/current/reference/constraints/Ulid.html
- https://symfony.com/doc/current/routing.html
- https://symfony.com/doc/current/controller.html
- https://symfony.com/doc/current/controller/value_resolver.html
- https://symfony.com/doc/current/console/value_resolver.html
- https://symfony.com/doc/current/serializer.html
- https://symfony.com/doc/current/reference/forms/types/uuid.html
- https://symfony.com/doc/current/reference/forms/types/ulid.html
- https://symfony.com/doc/current/reference/forms/types/entity.html
