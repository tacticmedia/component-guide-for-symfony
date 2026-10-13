# Validator (`symfony/validator`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Constraint attributes:** Put constraints on properties, on getters with the prefix `get`, `is` or `has`, and on classes. The attributes are in `Symfony\Component\Validator\Constraints`, which code imports as `Assert` (`#[Assert\NotBlank]`). YAML or XML files in `config/validator/` and a static `loadValidatorMetadata(ClassMetadata $metadata)` method are alternatives. The validator also applies the constraints of parent classes.
- **Validator service:** `ValidatorInterface::validate($value, $constraints = null, $groups = null)` returns a `ConstraintViolationListInterface`. An empty list means that the value is valid. Each `ConstraintViolation` gives `getPropertyPath()`, `getMessage()`, `getCode()` and `getConstraint()`. `findByCodes()` returns a new list with only the violations that have the given error codes.
- **Empty values:** Most constraints accept `null` and the empty string as valid values, so that a field can be optional. If a value is mandatory, add `NotBlank` or `NotNull` to it.
- **Nested data:** `Valid` validates the object, or the array of objects, in a property. `Valid` applies in each group unless you set its `groups` option. `Cascade` on a class validates all the objects in its properties. `All` applies constraints to each element, and `Collection` validates array keys with `Required` and `Optional`.
- **Conditional and cross-field rules:** `When` applies its `constraints` only when its expression or Closure returns true, and applies `otherwise` when it returns false. A string expression needs ExpressionLanguage, and a Closure in a `#[Assert\When]` attribute needs PHP 8.5. `Expression` checks a condition on `this` and `value`. `#[Assert\Callback]` on a method runs custom code with an `ExecutionContextInterface`. `Sequentially` stops at the first violation, and `AtLeastOneOf` needs one satisfied constraint.
- **Reusable sets:** A `Compound` subclass with `#[\Attribute]` returns a list of constraints from `getConstraints(array $options): array`. Code then uses the subclass as one attribute. For example, the docs show the application class `App\Validator\PasswordRequirements`, which code uses as `#[PasswordRequirements]`.
- **Validation groups:** The `groups` option puts a constraint into named groups. Constraints without a group are in the `Default` group and in the group with the class name. Pass the groups as the third argument: `$validator->validate($user, null, ['registration'])`.
- **Group sequences:** `#[Assert\GroupSequence(['User', 'Strict'])]` validates the `Strict` group only when the `User` group has no violations. In a sequence, use the class name, not `Default`, because `Default` causes infinite recursion. If the sequence depends on the object state, implement `GroupSequenceProviderInterface` in the class. Then add `#[Assert\GroupSequenceProvider]` to the class. If a service must give the groups, implement `GroupProviderInterface` in the service. Then add `#[Assert\GroupSequenceProvider(provider: MyGroupProvider::class)]` to the class.
- **Custom constraints:** A custom constraint extends `Constraint`, has `#[\Attribute]` and declares its options as constructor arguments. Its validator has the same class name plus `Validator` (`validatedBy()`), extends `ConstraintValidator` and calls `$this->context->buildViolation($constraint->message)->addViolation()`. In the validator, return early for `null` and `''`. Throw `UnexpectedValueException` for a value type that the validator cannot check. Autoconfiguration adds the `validator.constraint_validator` tag, so the validator can get services through its constructor. A constructor argument without a default value makes an option mandatory. The docs put `#[HasNamedArguments]` on the constructor. No Symfony code reads this attribute. For a check on the whole object, return `self::CLASS_CONSTRAINT` from `getTargets()`. To attach a violation to a property, call `atPath('email')` on the violation builder.
- **Extension of third-party classes:** `#[ExtendsValidationFor(Product::class)]` on an abstract class adds the constraints of that class to `Product`. The original constraints of `Product` stay active. Each property and method of the extension class must also exist on `Product`, or the container compilation throws a `MappingException`.
- **Metadata sources and cache:** If `kernel.debug` is false, autoconfiguration finds the classes with constraint attributes at compile time (tag `validator.attribute_metadata`). `AttributeMetadataPass` gives these classes to `ValidatorBuilder::addAttributeMappings()`. Tag a class that is not a service with `validator.attribute_metadata` and `container.excluded`. If `kernel.debug` is false, Symfony also caches the metadata in `%kernel.build_dir%/validation.php`.
- **Without FrameworkBundle:** `Validation::createValidator()` returns a validator. `Validation::createValidatorBuilder()` returns a builder with methods such as `enableAttributeMapping()` and `addYamlMapping()`. `Validation::createCallable()` returns a closure that throws `ValidationFailedException`. `Validation::createIsValidCallable()` returns a closure that returns `false` on violations.
- **Property checks:** `validateProperty($object, 'name')` validates one property. `validatePropertyValue($object, 'name', $value)` validates a value before you set it. In 8.1, `framework.validation.property_metadata_existence_check: true` makes both methods throw `ValidatorException` for a property without metadata.
- **Messages and severity:** The translator translates violation messages with the `validators` domain. `framework.validation.translation_domain` changes the domain, and `framework.validation.disable_translation` stops the translation. The `payload` option of each constraint carries custom data, for example a severity level.
- **Automatic constraints:** For the namespaces in `framework.validation.auto_mapping`, Symfony adds `NotNull`, `Type`, `Length` and `UniqueEntity` from Doctrine and PropertyInfo metadata. `#[Assert\EnableAutoMapping]` and `#[Assert\DisableAutoMapping]` change this for one class or one property.

## Entry points

- `Symfony\Component\Validator\Validator\ValidatorInterface`: autowire it (service ID `validator`).
- `Symfony\Component\Validator\Constraints\*`: the constraint attributes, imported as `Assert`, including `#[Assert\GroupSequence]` and `#[Assert\GroupSequenceProvider]`. The next lines list all built-in constraints by purpose.
- Constraints for empty values and types: `NotBlank`, `Blank`, `NotNull`, `IsNull`, `IsTrue`, `IsFalse`, `Type`.
- Constraints for strings: `Length`, `Regex`, `Email`, `Charset`, `WordCount`, `NoSuspiciousCharacters`, `CssColor`, `Json`, `Yaml`, `Xml`, `ExpressionSyntax`, `Uuid`, `Ulid`, `PasswordStrength`, `NotCompromisedPassword`.
- Constraints for numbers and comparisons: `Positive`, `PositiveOrZero`, `Negative`, `NegativeOrZero`, `Range`, `DivisibleBy`, `EqualTo`, `NotEqualTo`, `IdenticalTo`, `NotIdenticalTo`, `LessThan`, `LessThanOrEqual`, `GreaterThan`, `GreaterThanOrEqual`.
- Constraints for dates: `Date`, `DateTime`, `Time`, `Timezone`, `Week`.
- Constraints for choices and collections: `Choice`, `Country`, `Currency`, `Language`, `Locale`, `Count`, `Unique`, `All`, `Collection` (with `Required` and `Optional`).
- Constraints for files: `File`, `Image`, `Video`.
- Constraints for financial and other numbers: `Iban`, `Bic`, `CardScheme`, `Luhn`, `Isbn`, `Isin`, `Issn`.
- Constraints for network values: `Url`, `Hostname`, `Ip`, `Cidr`, `MacAddress`.
- Other constraints (nested objects, conditions, reusable sets, auto-mapping): `Valid`, `Cascade`, `Traverse`, `Callback`, `Expression`, `When`, `Sequentially`, `AtLeastOneOf`, `Compound` (abstract base class), `EnableAutoMapping`, `DisableAutoMapping`.
- Constraints in other packages: `UniqueEntity` (Doctrine Bridge), `UserPassword` (Security Core), `Twig` (Twig Bridge).
- `#[Symfony\Component\Validator\Attribute\ExtendsValidationFor]`.
- `Symfony\Component\Validator\Constraint`, `Symfony\Component\Validator\ConstraintValidator` and `Symfony\Component\Validator\Constraints\Compound`: the base classes for custom constraints.
- `Symfony\Component\Validator\GroupSequenceProviderInterface` and `Symfony\Component\Validator\GroupProviderInterface`.
- Without FrameworkBundle: `Symfony\Component\Validator\Validation` with `createValidator()`, `createValidatorBuilder()`, `createCallable()` and `createIsValidCallable()`.
- `Symfony\Component\Validator\Exception\ValidationFailedException`, `Symfony\Component\Validator\Exception\UnexpectedTypeException`, `Symfony\Component\Validator\Exception\UnexpectedValueException`.
- Config: `framework.validation` with `enabled`, `enable_attributes`, `static_method`, `translation_domain`, `disable_translation`, `email_validation_mode` (`html5`, `html5-allow-no-tld`, `strict`; `strict` needs `egulias/email-validator`), `mapping.paths`, `not_compromised_password.enabled`, `not_compromised_password.endpoint`, `property_metadata_existence_check`, `auto_mapping`.
- Constraint files: Symfony loads `config/validator/*.yaml` and `config/validator/*.xml` automatically.
- Service tags (autoconfigured): `validator.constraint_validator`, `validator.group_provider`, `validator.initializer`, `validator.attribute_metadata`.
- Console command: `debug:validator <class or directory>` (option `--show-all`).
- Twig: the package has no Twig function. Loop over the violations in a template: `{% for error in errors %}{{ error.message }}{% endfor %}`.
- Test helpers: `Symfony\Component\Validator\Test\ConstraintValidatorTestCase` (`createValidator()`, `validate()`, `assertNoViolation()`, `buildViolation()->setParameter()->assertRaised()`) and `Symfony\Component\Validator\Test\CompoundConstraintTestCase` (`createCompound()`, `validateValue()`, `assertViolationsRaisedByCompound()`).

## Symbiotic packages

- [Form](../packages/form.md): `$form->isValid()` validates the mapped object with its constraints, the `constraints` option adds constraints to unmapped fields, and `validation_groups` selects the groups.
- [Doctrine Bridge](../packages/doctrine-bridge.md): It provides `#[UniqueEntity]` for unique database values and the `auto_mapping` loader that reads Doctrine metadata.
- [HttpKernel](../packages/http-kernel.md): `#[MapRequestPayload]` (HTTP 422) and `#[MapQueryString]` (HTTP 404) validate the DTO, and `#[MapUploadedFile]` (HTTP 422) checks an uploaded file with its `constraints` option. On violations, they throw an HTTP exception with that default status.
- [Serializer](../packages/serializer.md): The serializer builds the `#[MapRequestPayload]` DTO before the validation, and `ConstraintViolationListNormalizer` turns violations into an RFC 7807 list.
- [Messenger](../packages/messenger.md): The `validation` middleware validates each message before the handlers, and `ValidationStamp` selects the groups.
- [Console](../packages/console.md): In 8.1, `#[MapInput]` validates the input object, and `#[Ask(constraints: [...])]` and `Question::setConstraints()` validate the answers.
- [OptionsResolver](../packages/options-resolver.md): Pass `Validation::createIsValidCallable(new Assert\Length(min: 10))` to `setAllowedValues()` to check an option with constraints.
- [Translation](../packages/translation.md): The translator translates the violation messages with the `validators` domain.
- [Security](../packages/security-bundle.md): Security Core provides `#[UserPassword]`, which checks the password of the current user, for example in a "change password" form.
- [ExpressionLanguage](../packages/expression-language.md): The `Expression` and `ExpressionSyntax` constraints and a `When` constraint with a string expression need it.
- [Intl](../packages/intl.md): The `Country`, `Currency`, `Language`, `Locale` and `Bic` constraints need it.
- [HttpClient](../packages/http-client.md): `NotCompromisedPassword` uses the HTTP client to query the haveibeenpwned.com API.
- [PropertyAccess](../packages/property-access.md): The `propertyPath` option of comparison constraints and the `minPropertyPath` and `maxPropertyPath` options of `Range` need it.
- [PropertyInfo](../packages/property-info.md): With `auto_mapping`, `PropertyInfoLoader` adds `NotNull` and `Type` from the property types.
- [Clock](../packages/clock.md): Comparison validators and `RangeValidator` accept an optional `clock` argument for relative dates such as `today`, so a test can pass a `MockClock`. FrameworkBundle does not inject the `clock` service into them.
- [Mime](../packages/mime.md): `File` and `Image` need it to check the `extensions` and `mimeTypes` options.
- [Yaml](../packages/yaml.md): YAML constraint files and the `Yaml` constraint need it.
- [Process](../packages/process.md): The `Video` constraint runs the `ffprobe` binary through it.
- [Twig Bridge](../packages/twig-bridge.md): It provides the `Twig` constraint, which checks that a string contains valid Twig syntax.
- [Workflow](../packages/workflow.md): The `is_valid(subject)` function in a guard expression validates the subject before a transition.
- [UX Live Component](../packages/ux-live-component.md): `ValidatableComponentTrait` validates live properties with constraints and gives the violations to the template as `_errors`.
- [FrameworkBundle](../packages/framework-bundle.md): It registers the `validator` service, the `framework.validation` configuration and the `debug:validator` command.
- [MakerBundle](../packages/maker-bundle.md): `make:validator` generates a constraint class and its validator class.
- [HttpFoundation](../packages/http-foundation.md): give `File` and `Image` the `UploadedFile` object, not its temporary path, so that they report upload errors and check the original file extension.
- [Uid](../packages/uid.md): `#[Assert\Uuid]` and `#[Assert\Ulid]` check the string form of an ID and do not need Uid. In plain PHP code without a validator, use `Uuid::isValid()` of Uid.

## Changed in 8.0/8.1

- 8.0: Constraint constructors do not accept an options array. `new Assert\Length(['min' => 3])` -> `new Assert\Length(min: 3)`, and `new Assert\Choice(['a', 'b'])` -> `new Assert\Choice(choices: ['a', 'b'])`.
- 8.0: The base `Constraint` class does not read options, and `getRequiredOptions()`, `getDefaultOption()` and `normalizeOptions()` are removed. Declare the options of a custom constraint as constructor arguments. Call `parent::__construct(null, $groups, $payload)`.
- 8.0: YAML and XML constraint files do not accept a list of values without an option name: `- Choice: [a, b]` -> `- Choice: { choices: [a, b] }`. A single scalar value, such as `- GreaterThan: 18`, goes to the first constructor argument.
- 8.0: The `requireTld` option of `Url` is `true` by default. If a host has no top-level domain, such as `https://intranet`, set `requireTld: false`.
- 8.0: FrameworkBundle removes the `framework.validation.cache` option. Symfony caches the metadata when `kernel.debug` is false.
- 8.1: `ConstraintValidatorInterface::initialize()` and `validate()` are deprecated; the new contract is `validateInContext()`. A class that extends `ConstraintValidator` needs no change, but an override of `initialize()` is deprecated. In tests, call `$this->validate($value, $constraint)` instead of `$this->validator->validate()`.
- 8.1: `ConstraintViolationListInterface` declares `findByCodes()`, which `ConstraintViolationList` already had before 8.1. `ValidatorBuilder::enablePropertyMetadataExistenceCheck()` (config `property_metadata_existence_check`) makes `validateProperty()` and `validatePropertyValue()` throw for an unknown property.
- 8.1: The new `Xml` constraint checks XML syntax and, with `schemaPath`, an XSD schema. The docs page shows `schema:` and `message:`. The constructor accepts `schemaPath:` and `formatMessage:`. Comparison validators and `RangeValidator` accept a `clock` argument for relative dates. The docs say that the framework injects the `clock` service. FrameworkBundle does not inject it.

## Docs

- https://symfony.com/doc/current/validation.html
- https://symfony.com/doc/current/reference/constraints.html
- https://symfony.com/doc/current/validation/custom_constraint.html
- https://symfony.com/doc/current/validation/groups.html
- https://symfony.com/doc/current/validation/sequence_provider.html
- https://symfony.com/doc/current/validation/raw_values.html
- https://symfony.com/doc/current/validation/translations.html
- https://symfony.com/doc/current/validation/severity.html
- https://symfony.com/doc/current/form/validation_groups.html
- https://symfony.com/doc/current/reference/constraints/Compound.html
- https://symfony.com/doc/current/reference/constraints/When.html
- https://symfony.com/doc/current/reference/constraints/Callback.html
- https://symfony.com/doc/current/reference/constraints/Xml.html
- https://symfony.com/doc/current/reference/constraints/UniqueEntity.html
- https://symfony.com/doc/current/reference/configuration/framework.html
