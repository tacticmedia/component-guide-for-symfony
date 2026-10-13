# Uid (`symfony/uid`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when code must create, validate or convert unique IDs for primary keys, URLs or messages, without a central counter. It supports UUID, GUID and ULID. UUIDv7 and ULID values sort by creation time. For a random code in your own alphabet, see [String](string.md).

**Details:** [../details/uid.md](../details/uid.md)

## Why it exists

Applications need IDs that are unique across servers and processes without a central counter. They must also store, validate and convert these IDs in text and binary forms. The package supplies UUID classes for versions 1 and 3 to 8, and a ULID class. These classes generate, parse, compare and convert the IDs.

## When to use it

- Generate a unique ID for an entity or a message without a database sequence.
- Use a UUID or a ULID as a database primary key that sorts by creation time.
- Create the same UUID again from the same name, for example a URL or an email address.
- Validate a UUID or a ULID in a request, a route or a form.
- Convert an ID between the RFC 4122, base32, base58, binary and hexadecimal forms.
- Get a UUID or ULID object from a route parameter, a query parameter or a command-line argument.
- Hide the creation time of UUIDv7 primary keys in public URLs and API responses.
- Make the generated UUIDs predictable in tests.
- Generate or inspect a UUID or a ULID in a terminal.

## Use it instead of

- `bin2hex(random_bytes(16))` or a UUIDv4 function with `mt_rand()` -> `Uuid::v4()`, or `Uuid::v7()` for an ID that sorts by time.
- `uniqid()`, `microtime(true)` or `time().rand()` as a unique ID -> `new Ulid()` or `Uuid::v7()`.
- `md5($name)` or `sha1($name)` in the form of a UUID -> `Uuid::v5(Uuid::fromString(Uuid::NAMESPACE_URL), $name)`.
- `preg_match('/^[0-9a-f]{8}-[0-9a-f]{4}-/i', $id)` -> `Uuid::isValid($id)`, `#[Assert\Uuid]` on a property, or `requirements: ['id' => Requirement::UUID]` on a route.
- `hex2bin(str_replace('-', '', $uuid))` for a binary column -> `$uuid->toBinary()` and `Uuid::fromBinary($bytes)`, or the Doctrine `uuid` column type.
- A `string` column of 36 characters and `Uuid::fromString()` in each getter -> `#[ORM\Column(type: UuidType::NAME)]`; for a generated ID, also `#[ORM\GeneratedValue(strategy: 'CUSTOM')]` and `#[ORM\CustomIdGenerator('doctrine.uuid_generator')]`.
- `Uuid::fromString($request->attributes->get('id'))` and a manual `NotFoundHttpException` -> a controller argument `UuidV7 $id` (`UidValueResolver`).
- A serializer callback or a getter that returns `(string) $this->id` for JSON -> `UidNormalizer` with the `uid_normalization_format` context key.
- A fake UUID generator class or a `UuidFactory` mock in tests -> `new MockUuidFactory([...])`.
- UUIDv7 primary keys in public URLs that show the creation time -> `Uuid47Transformer::encode()` for output and `Uuid47Transformer::decode()` for input.
