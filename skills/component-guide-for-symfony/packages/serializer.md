# Serializer (`symfony/serializer`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when PHP objects must become JSON, XML, CSV or YAML, or when an incoming payload must become typed objects. It converts in both directions, selects and renames fields, and reports type errors. To stream very large JSON, see [JsonStreamer](json-streamer.md). To copy data from one object to another, see [ObjectMapper](object-mapper.md).

**Details:** [../details/serializer.md](../details/serializer.md)

## Why it exists

APIs, integrations and import scripts must convert PHP objects to JSON, XML, CSV or YAML, and convert incoming data back to typed objects. Hand-written conversion code for each class is long and hard to keep correct. The package first converts objects to and from plain arrays, and then converts the arrays to and from the text format. It reads and writes any object through reflection, so you do not write conversion code for each class.

## When to use it

- Return an entity or a data object as a JSON response from a controller.
- Map a JSON, XML or form request body to a typed data object in a controller.
- Show different properties of the same class to different API clients.
- Rename fields in the output, for example from camelCase to snake_case.
- Import or export CSV, XML or YAML data as PHP objects.
- Report all type errors and unknown fields of an invalid payload in one response.
- Create the correct subclass of an interface or an abstract class from a type field.
- Return validation errors and exceptions as RFC 7807 problem JSON.
- Encode the messages that background workers read from a queue.

## Use it instead of

- `json_encode($entity)` or a hand-written `toArray()` method in each class -> `$serializer->serialize($entity, 'json', ['groups' => ['list']])` with `#[Groups]` (`SerializerInterface`).
- `json_decode($request->getContent(), true)` with `isset()` checks and `new Dto(...)` -> a `#[MapRequestPayload] Dto $dto` controller argument, or `$serializer->deserialize($json, Dto::class, 'json')`.
- A loop that renames keys, such as `'first_name' => $user->getFirstName()` -> `#[SerializedName('first_name')]`, or the `serializer.name_converter.camel_case_to_snake_case` name converter.
- `fputcsv()` and `str_getcsv()` loops with a manual header row -> `$serializer->serialize($rows, 'csv')` and `$serializer->deserialize($csv, Row::class.'[]', 'csv')` (`CsvEncoder`).
- `SimpleXMLElement` or `DOMDocument` code that builds or reads XML -> the `xml` format (`XmlEncoder`).
- `$date->format(DATE_ATOM)`, `$date->setTimezone(new \DateTimeZone('UTC'))`, `$date->getTimestamp()` and `new \DateTimeImmutable($data['date'])` -> `DateTimeNormalizer` with `DateTimeNormalizer::FORMAT_KEY` and `DateTimeNormalizer::TIMEZONE_KEY` in the context. To also convert the dates of the payload to that time zone, set `DateTimeNormalizer::FORCE_TIMEZONE_KEY` to `true`. For a Unix timestamp, set `DateTimeNormalizer::FORMAT_KEY` to `'U'` and `DateTimeNormalizer::CAST_KEY` to `'int'`.
- A `switch ($data['type'])` that selects a subclass before hydration -> `#[DiscriminatorMap]`.
- A hand-built error array from a `ConstraintViolationList` -> `$serializer->serialize($violations, 'json')` (`ConstraintViolationListNormalizer`, RFC 7807 output).
- `new Response(json_encode($data), 200, ['Content-Type' => 'application/json'])` in a controller -> `$this->json($data)` (`AbstractController::json()`) or `#[Serialize]` (8.1).
- A `$visited` array that stops endless recursion on Doctrine relations -> `AbstractNormalizer::CIRCULAR_REFERENCE_HANDLER` or `#[MaxDepth]`.
