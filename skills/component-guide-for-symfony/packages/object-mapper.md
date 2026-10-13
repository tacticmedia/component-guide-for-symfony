# ObjectMapper (`symfony/object-mapper`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when code must copy data between PHP objects, for example from an input object to a database entity, or for a partial update. It copies the matching properties, with optional rules for names, conditions and values. To convert objects to JSON or arrays, see [Serializer](serializer.md). To read HTML form submissions, see [Form](form.md).

**Details:** [../details/object-mapper.md](../details/object-mapper.md)

## Why it exists

Applications often keep input objects, database entities and output objects apart. Then hand-written code copies the same properties between these objects, one line for each property. The package copies the properties of a source object into a new or an existing target object. Optional rules on the classes rename properties, skip values or change them.

## When to use it

- Copy the properties of a validated request object into a new database entity.
- Update an existing entity with only the input properties that are not null, for a partial update such as an HTTP PATCH request.
- Build a response object, or separate public and admin views, from one entity.
- Map a list of input objects to a list of entities or other objects.
- Map an object with different property names to your own class, for example snake_case API data or a decoded JSON object.
- Select one of several target classes from the state of the source object.
- Flatten nested input objects into one target object.

## Use it instead of

- `$product->setName($input->name); $product->setSku($input->sku);` for each property -> `$objectMapper->map($input, $product)` (`ObjectMapperInterface::map()`; setters need `symfony/property-access`).
- A static `ProductMapper::toEntity(ProductInput $input)` or `ProductOutput::fromEntity(Product $product)` method for each class pair -> `#[Map(target: Product::class)]` on the input DTO, or `#[Map(source: Product::class)]` on the output DTO.
- `$serializer->denormalize($serializer->normalize($dto), Product::class)` to copy a DTO into an entity -> `$objectMapper->map($dto, Product::class)`, with no array step.
- `if (null !== $input->email) { $user->setEmail($input->email); }` for each field of a PATCH request -> `#[Map(if: new IsNotNull())]` on the DTO properties and `$objectMapper->map($input, $user)`.
- `array_map(fn (ItemInput $item) => new Item($item->name), $input->items)` -> `#[Map(transform: new MapCollection(targetClass: Item::class))]` on the `items` property.
- `match ($input->type) { 'online' => new OnlineEvent(), 'physical' => new PhysicalEvent() }` before you copy the properties -> one class-level `#[Map(target: ..., if: ...)]` for each target class.
- Two hand-built view objects that differ by one field (public and admin) -> `#[Map(target: 'ipAddress', if: new TargetClass(AdminUserProfile::class))]` on the entity property.
- `$product->name = $payload->product_name;` for snake_case API objects -> `#[Map(source: 'product_name')]` on the target property.
- An `SplObjectStorage` or a `$visited` array that stops endless loops on cyclic relations -> the built-in recursion handling of `map()`.
