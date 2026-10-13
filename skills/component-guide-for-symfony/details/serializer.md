# Serializer (`symfony/serializer`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- Serialize and deserialize: `serialize()` converts data to a string, and `deserialize()` converts a string to an object of the given type (`SerializerInterface`).
- Normalizers and encoders: normalizers convert objects to and from arrays, and encoders convert arrays to and from a format. To use one step only, call `NormalizerInterface::normalize()`, `DenormalizerInterface::denormalize()`, `EncoderInterface::encode()` or `DecoderInterface::decode()`.
- Built-in formats: the `json`, `xml`, `csv` and `yaml` formats are available (`JsonEncoder`, `XmlEncoder`, `CsvEncoder`, `YamlEncoder`). The `yaml` format needs `symfony/yaml`. Each encoder reads its options from the context, for example `CsvEncoder::DELIMITER_KEY`, `CsvEncoder::HEADERS_KEY`, `CsvEncoder::OUTPUT_UTF8_BOM_KEY` and `XmlEncoder::ROOT_NODE_NAME`. In JSON, an empty object or an empty collection object, for example an `\ArrayObject`, becomes `[]` by default. To write `{}` instead, set `AbstractObjectNormalizer::PRESERVE_EMPTY_OBJECTS` to `true`. `Serializer::EMPTY_ARRAY_AS_OBJECT` writes each empty array as `{}`, also when the array is a list.
- Built-in normalizers: they convert objects (`ObjectNormalizer`), dates (`DateTimeNormalizer`, RFC 3339 by default), backed enums (`BackedEnumNormalizer`), UIDs (`UidNormalizer`) and typed lists (`ArrayDenormalizer`, denormalization only). Other normalizers cover `DateInterval` (`DateIntervalNormalizer`), `DateTimeZone` (`DateTimeZoneNormalizer`), files as data URIs (`DataUriNormalizer`), `JsonSerializable` objects (`JsonSerializableNormalizer`) and `BcMath\Number` or GMP values (`NumberNormalizer`).
- Context: the context is an array of options for one operation. Set it globally in `framework.serializer.default_context`, for one call in the `$context` argument, or for one class or property with `#[Context]`. The most specific level wins. Context builders give typed methods, for example `(new ObjectNormalizerContextBuilder())->withGroups(['read'])->toArray()`.
- Property selection: serialization groups select the properties for each use case (`#[Groups]` and the `AbstractNormalizer::GROUPS` context key). `#[Ignore]` and `AbstractNormalizer::IGNORED_ATTRIBUTES` remove properties, and `AbstractObjectNormalizer::SKIP_NULL_VALUES` removes null values. To select properties at runtime, set `AbstractNormalizer::ATTRIBUTES`, for example to `['name', 'company' => ['name']]`.
- Name mapping: `#[SerializedName]` renames one property, and `#[SerializedPath('[profile][name]')]` maps a property to a nested path. Do not put both attributes on one property. A name converter renames all properties (`framework.serializer.name_converter`).
- Typed denormalization: for a list, append `[]` to the type (`Person::class.'[]'`). Typed properties, nested objects and PHPDoc types such as `list<Person>` resolve through PropertyInfo. A value of the wrong type causes a `NotNormalizableValueException`. To denormalize only one part of the payload, set `UnwrappingDenormalizer::UNWRAP_PATH`, for example to `'[data][person]'`.
- Error collection: `DenormalizerInterface::COLLECT_DENORMALIZATION_ERRORS` and `DenormalizerInterface::COLLECT_EXTRA_ATTRIBUTES_ERRORS` collect all errors in one `PartialDenormalizationException`. By default, the Serializer ignores unknown fields. To reject them, set `AbstractNormalizer::ALLOW_EXTRA_ATTRIBUTES` to `false`.
- Existing objects: `AbstractNormalizer::OBJECT_TO_POPULATE` writes the payload into a given object instead of a new object. `AbstractObjectNormalizer::DEEP_OBJECT_TO_POPULATE` also updates the nested objects, but it creates new objects for the items of a list or a collection object.
- Object graphs: `AbstractNormalizer::CIRCULAR_REFERENCE_HANDLER` replaces a repeated object, for example with its ID. `#[MaxDepth]` together with `AbstractObjectNormalizer::ENABLE_MAX_DEPTH` limits the depth.
- Polymorphism: `#[DiscriminatorMap(typeProperty: 'type', mapping: [...])]` selects the concrete class from a type field during denormalization.
- Problem output: `ConstraintViolationListNormalizer` converts validation violations, and `ProblemNormalizer` converts a `FlattenException`, to RFC 7807 arrays. To convert an exception, serialize `FlattenException::createFromThrowable($exception)` (`Symfony\Component\ErrorHandler\Exception\FlattenException`). `FormErrorNormalizer` converts the errors of a submitted, invalid form to an array.
- Named serializers: each named serializer is a separate service with its own context, name converter, normalizers and encoders (`framework.serializer.named_serializers`).
- Extension: a custom normalizer implements `NormalizerInterface` or `DenormalizerInterface`, including `getSupportedTypes()`. Autoconfiguration adds the `serializer.normalizer` tag. `#[ExtendsSerializationFor]` adds mapping to a class that you cannot edit. To change the value of one property only, give a callable for that property in `AbstractNormalizer::CALLBACKS`.

## Entry points

- Install: `composer require symfony/serializer-pack`. The pack also installs `symfony/property-access`, `symfony/property-info`, `phpstan/phpdoc-parser` and `phpdocumentor/reflection-docblock`.
- Autowire `Symfony\Component\Serializer\SerializerInterface` (service `serializer`).
- Autowire `Symfony\Component\Serializer\Normalizer\NormalizerInterface` or `Symfony\Component\Serializer\Normalizer\DenormalizerInterface` for the array step only.
- Autowire `Symfony\Component\Serializer\Encoder\EncoderInterface` or `Symfony\Component\Serializer\Encoder\DecoderInterface` for the format step only.
- Mapping attributes: `Symfony\Component\Serializer\Attribute\Groups`, `Ignore`, `SerializedName`, `SerializedPath`, `MaxDepth`, `Context`, `DiscriminatorMap` and `ExtendsSerializationFor` (same namespace).
- Controller attributes (HttpKernel): `Symfony\Component\HttpKernel\Attribute\MapRequestPayload`, `Symfony\Component\HttpKernel\Attribute\MapQueryString` and `Symfony\Component\HttpKernel\Attribute\Serialize` (8.1).
- Controller helper: `Symfony\Bundle\FrameworkBundle\Controller\AbstractController::json()`.
- Context builders: `Symfony\Component\Serializer\Context\SerializerContextBuilder` and the classes in `Symfony\Component\Serializer\Context\Normalizer\` and `Symfony\Component\Serializer\Context\Encoder\`.
- Context keys: use the class constants, for example `AbstractNormalizer::GROUPS`, `DateTimeNormalizer::FORMAT_KEY` and `JsonEncode::OPTIONS`.
- Config: `framework.serializer` with `enabled`, `enable_attributes`, `name_converter`, `circular_reference_handler`, `max_depth_handler`, `mapping.paths`, `default_context` and `named_serializers`.
- Mapping files: `config/serializer/*.yaml` and `config/serializer/*.xml`.
- Service IDs: `serializer.name_converter.camel_case_to_snake_case` and `serializer.name_converter.snake_case_to_camel_case`. To wrap the object normalizer in a custom normalizer, inject it with `#[Autowire(service: 'serializer.normalizer.object')]`.
- Service tags: `serializer.normalizer` and `serializer.encoder`, with the `priority` and `serializer` tag attributes. Autoconfiguration adds these tags.
- Console command: `php bin/console debug:serializer 'App\Entity\Book'` shows the mapping metadata of a class.
- Twig filter: `{{ object|serialize(format = 'json', context = {}) }}`.
- Profiler: when the profiler is enabled, the Serializer panel shows each call with its data, context, normalizers, encoders and time.

## Symbiotic packages

- [JsonStreamer](../packages/json-streamer.md): Often confused: JsonStreamer streams large JSON for DTOs with public properties and no constructor; the Serializer supports more formats and complex objects.
- [ObjectMapper](../packages/object-mapper.md): Often confused: ObjectMapper copies data from one object to another (DTO to entity), and the Serializer converts objects to and from text formats.
- [PropertyAccess](../packages/property-access.md): `ObjectNormalizer` reads and writes properties through PropertyAccess, and `#[SerializedPath]` and `UnwrappingDenormalizer` use its property paths.
- [PropertyInfo](../packages/property-info.md): The normalizers get property types from PropertyInfo to denormalize nested objects and typed lists, and its `SerializerExtractor` lists properties by serialization group.
- [TypeInfo](../packages/type-info.md): PropertyInfo returns TypeInfo `Type` objects, and the normalizers use them to check and cast values during denormalization.
- [HttpKernel](../packages/http-kernel.md): `#[MapRequestPayload]` and `#[MapQueryString]` deserialize request data into typed controller arguments, and `#[Serialize]` (8.1) serializes the controller return value.
- [Validator](../packages/validator.md): `#[MapRequestPayload]` validates the deserialized DTO, and `ConstraintViolationListNormalizer` converts the violations to RFC 7807 JSON.
- [FrameworkBundle](../packages/framework-bundle.md): FrameworkBundle registers the `serializer` service, the `framework.serializer` options, the `debug:serializer` command and `AbstractController::json()`.
- [Messenger](../packages/messenger.md): The `messenger.transport.symfony_serializer` service encodes messages with this component; Messenger's own `Transport\Serialization\SerializerInterface` is a different interface.
- [ErrorHandler](../packages/error-handler.md): When the serializer is enabled, `SerializerErrorRenderer` renders exceptions in the preferred request format (for example JSON) through `ProblemNormalizer`.
- [Twig Bridge](../packages/twig-bridge.md): The `serialize` Twig filter calls `SerializerInterface::serialize()`, for example to pass an object to JavaScript in a `data-*` attribute.
- [Yaml](../packages/yaml.md): The `yaml` format and the YAML mapping files need the Yaml component.
- [Uid](../packages/uid.md): `UidNormalizer` converts `Uuid` and `Ulid` objects to strings and back, in the canonical, base58, base32 or RFC 4122 format.
- [Form](../packages/form.md): `FormErrorNormalizer` converts the errors of a submitted, invalid form to an array for an API response.
- [Translation](../packages/translation.md): `TranslatableNormalizer` translates `TranslatableInterface` values during normalization; FrameworkBundle registers it only when the translator is enabled.
- [Mime](../packages/mime.md): `MimeMessageNormalizer` normalizes email messages and headers, and `DataUriNormalizer` guesses the MIME type of a file with the Mime component.
- [Lock](../packages/lock.md): With `LockKeyNormalizer` from the Lock component, the Serializer can send a lock `Key` to another process.
- [Semaphore](../packages/semaphore.md): Since 8.1, `SemaphoreKeyNormalizer` lets the Serializer send a semaphore `Key` to another process.
- [Webhook](../packages/webhook.md): If the serializer is enabled, FrameworkBundle encodes the payload of a sent webhook with `SerializerPayloadSerializer` instead of `json_encode()`.
- [WebProfilerBundle](../packages/web-profiler-bundle.md): The Serializer panel of the profiler shows each serializer call with its context, normalizers, encoders and time.
- [DependencyInjection](../packages/dependency-injection.md): `#[Target]` selects a named serializer, and `#[Autowire(service: 'serializer.normalizer.object')]` injects the object normalizer into a custom normalizer.
- [JsonPath](../packages/json-path.md): to select some values of a JSON document as arrays or scalars, use JsonPath and do not deserialize the whole payload.
- [MakerBundle](../packages/maker-bundle.md): `make:serializer:normalizer` and `make:serializer:encoder` generate a normalizer class and an encoder class.
- [VarExporter](../packages/var-exporter.md): when only PHP reads the data back, use VarExporter; use the Serializer for JSON, XML or CSV.

## Changed in 8.0/8.1

- 8.1, new: `#[Serialize]` on a controller method serializes the returned value in the request format (JSON by default). Old: `return $this->json($data, 201);` -> new: `#[Serialize(code: 201)]` and `return $data;` (`Symfony\Component\HttpKernel\Attribute\Serialize`).
- 8.1: `PartialDenormalizationException::getErrors()` -> `getNotNormalizableValueErrors()`. If `AbstractNormalizer::ALLOW_EXTRA_ATTRIBUTES` is `false`, the new `DenormalizerInterface::COLLECT_EXTRA_ATTRIBUTES_ERRORS` option reports all unknown fields, with their full paths, in `getExtraAttributesError()`.
- 8.1, new: `AbstractObjectNormalizer::ENABLE_TYPE_CONVERSION` casts string values to `int`, `float` or `bool`. The option is on by default for the `xml` and `csv` formats.
- 8.1, deprecated: if a date string does not match the default format (RFC 3339), the date class constructor parses it loosely and triggers a deprecation. Version 9.0 throws `NotNormalizableValueException`. Set `DateTimeNormalizer::FORMAT_KEY` to the real format, or to `null` to parse the date loosely.
- 8.1, deprecated (DependencyInjection): if you inject a named serializer by the parameter name only, for example `SerializerInterface $apiClient1Serializer`, add `#[Target]` to the argument.
- 8.0, removed: `Symfony\Component\Serializer\Annotation\*` -> `Symfony\Component\Serializer\Attribute\*`. Attribute getters -> public properties, for example `$groups->groups`.
- 8.0, changed: `NameConverterInterface::normalize(string $propertyName)` -> `normalize(string $propertyName, ?string $class = null, ?string $format = null, array $context = [])`, and the same for `denormalize()`. `AdvancedNameConverterInterface` -> `NameConverterInterface`.
- 8.0, removed: `CsvEncoder::ESCAPE_CHAR_KEY` and `CsvEncoderContextBuilder::withEscapeChar()`, with no replacement. `AbstractNormalizerContextBuilder::withDefaultContructorArguments()` -> `withDefaultConstructorArguments()`.

## Docs

- https://symfony.com/doc/current/serializer.html (main guide)
- https://symfony.com/doc/current/serializer/encoders.html
- https://symfony.com/doc/current/serializer/custom_normalizer.html
- https://symfony.com/doc/current/serializer/custom_name_converter.html
- https://symfony.com/doc/current/serializer/custom_context_builders.html
- https://symfony.com/doc/current/serializer/streaming_json.html (JsonStreamer)
- https://symfony.com/doc/current/reference/configuration/framework.html (`framework.serializer` options)
- https://symfony.com/doc/current/controller.html (`#[MapRequestPayload]`, `#[MapQueryString]`, `#[Serialize]`, `json()`)
- https://symfony.com/doc/current/controller/error_pages.html (non-HTML error output)
- https://symfony.com/doc/current/reference/attributes.html
- https://symfony.com/doc/current/reference/dic_tags.html (`serializer.normalizer`, `serializer.encoder`)
- https://symfony.com/doc/current/reference/twig_reference.html (`serialize` filter)
- https://symfony.com/doc/current/messenger.html (`messenger.transport.symfony_serializer`)
