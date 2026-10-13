# JsonStreamer (`symfony/json-streamer`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when PHP must write or read very large JSON data with little memory, for example an export file or a long API response. It streams JSON in chunks to and from typed objects with public properties. For other formats, serialization groups, constructor arguments or polymorphic objects, see [Serializer](serializer.md).

**Details:** [../details/json-streamer.md](../details/json-streamer.md)

## Why it exists

The built-in JSON functions of PHP build all of the JSON as one string, or decode all of the data into memory at once. Large JSON data then uses much memory. The package writes JSON in chunks and reads JSON from a stream in parts. It also generates PHP code for each data type, which makes it fast.

## When to use it

- Return a large list of data objects as a JSON response in chunks.
- Write a large JSON export file from a generator of data objects.
- Read a large JSON file item by item without loading all of it into memory.
- Map a JSON request body or an API response to typed data objects with high performance.
- Rename a JSON key, or transform a property value, when you write or read JSON.
- Write dates, durations, time zones or your own value objects as single JSON values.
- Generate the conversion code at deploy time, before the first call needs it.
- Stream JSON in a command-line tool or a library that does not use the full framework.

## Use it instead of

- `return new JsonResponse($rows)` or `json_encode($rows)` for a large result -> `new StreamedResponse($jsonStreamWriter->write($rows, Type::list(Type::object(Row::class))), 200, ['Content-Type' => 'application/json'])` (`JsonStreamWriter::write()`).
- A loop that writes `'['`, `json_encode($item)` and `','` to a file for each item -> `foreach ($jsonStreamWriter->write($items, Type::iterable(Type::object(Item::class), Type::int())) as $chunk) { fwrite($file, $chunk); }`.
- `json_decode(file_get_contents('big.json'), true)` and a loop that copies array keys into objects -> `$jsonStreamReader->read(fopen('big.json', 'r'), Type::iterable(Type::object(Item::class), Type::int()))`.
- `$data['createdAt'] = $date->format(\DATE_RFC3339)` and `new \DateTimeImmutable($data['createdAt'])` -> a `\DateTimeImmutable` property and the built-in `DateTimeValueObjectTransformer` (option `date_time_format`).
- A `toArray()` method that renames keys, such as `'@id' => $this->id` -> `#[StreamedName('@id')]`.
- A conversion such as `strtoupper($dto->name)` before `json_encode()` -> `#[ValueTransformer(nativeToStream: 'strtoupper')]`.
- The same `Money`-to-string conversion in many DTOs -> one `ValueObjectTransformerInterface` service for the `Money` class.
- `array_filter($data, fn ($value) => null !== $value)` before `json_encode()` -> the default writer behavior, which omits `null` properties (`include_null_properties` is `false`).
