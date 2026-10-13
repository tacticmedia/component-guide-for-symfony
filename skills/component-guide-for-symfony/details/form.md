# Form (`symfony/form`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Form types**: A form type class adds fields in `buildForm()` and declares options in `configureOptions()`. A type reuses another type through `getParent()`, not through PHP class inheritance. Entry: `Symfony\Component\Form\AbstractType`.
- **Submit cycle**: `handleRequest()` submits the form only when the request method matches the `method` option (default `POST`) and the request contains data for the form. Call `isSubmitted()` before `isValid()`, because `isValid()` throws a `LogicException` for a form that is not submitted. `getData()` then returns the updated data object. The `trim` option (default `true`) removes white space around text input. A `PATCH` request keeps the values of the fields that it does not contain. Entry: `Symfony\Component\Form\FormInterface::handleRequest()`.
- **Text and number types**: The text types are `TextType`, `TextareaType`, `EmailType`, `PasswordType`, `SearchType`, `UrlType`, `TelType`, `ColorType` and `RangeType`. `RangeType` renders a slider, but its value is a string. The number types are `IntegerType`, `NumberType`, `MoneyType` and `PercentType`. With `'divisor' => 100`, `MoneyType` shows an amount in cents as a decimal value. `PercentType` shows the fraction `0.95` as `95`. `EmailType` and `TelType` do not validate the value on the server. Add a validator constraint, for example `Email`. Entry: the namespace `Symfony\Component\Form\Extension\Core\Type`.
- **Choice types**: `ChoiceType` renders a select box, radio buttons or checkboxes, as set by the `expanded` and `multiple` options. `EnumType` lists the cases of a PHP enum. `EntityType` (Doctrine Bridge) lists Doctrine entities. `CountryType`, `LanguageType`, `LocaleType` and `CurrencyType` list names from `symfony/intl` in the current locale. `TimezoneType` lists the time zones. For a large list, use a `choice_loader` with `'choice_lazy' => true`, which loads only the preset and submitted choices. The page then needs a JavaScript widget that loads the other choices. In a reusable custom choice type, create the `choice_loader` with `ChoiceList::lazy()` from a callable, or with `ChoiceList::loader()` from a loader. This makes the choice list cacheable. Entry: `ChoiceType`, `EnumType`, `Symfony\Component\Form\ChoiceList\ChoiceList`.
- **Date and time types**: `DateType`, `DateTimeType`, `TimeType`, `BirthdayType` and `WeekType` render one HTML5 input by default (`'widget' => 'single_text'`). `DateIntervalType` edits a `DateInterval`. The `input` option sets the PHP type of the data, for example `datetime_immutable`, `date_point` or `string`. Entry: `Symfony\Component\Form\Extension\Core\Type\DateType`.
- **Other field types**: `CheckboxType` maps a boolean. `FileType` returns an `UploadedFile`, and `form_start()` then adds `enctype="multipart/form-data"`. To check the size and the type of the file, add an `Assert\File` constraint in the `constraints` option. `RepeatedType` renders two fields and adds an error when the values differ. `UuidType` and `UlidType` return `Uuid` and `Ulid` objects. `HiddenType` renders a hidden input field. `SubmitType` adds a button, and `isClicked()` tells which button the user clicked. Entry: `FileType`, `RepeatedType`, `SubmitType`.
- **Data mapping options**: `data_class` binds the form to a class, and `property_path` maps a field to another property. `'mapped' => false` keeps a field out of the data object. `empty_data` creates the data object when the form has no data, for example with constructor arguments. `inherit_data` lets an embedded form use the data of its parent. `getter` and `setter` replace the property access with callables. Entry: the options of `Symfony\Component\Form\Extension\Core\Type\FormType`.
- **Data transformers**: A data transformer converts one field value between two formats, for example between an issue number and an `Issue` entity. If the input is not valid, throw a `TransformationFailedException`. The field then shows its `invalid_message`. Entry: `Symfony\Component\Form\CallbackTransformer`, `Symfony\Component\Form\DataTransformerInterface`, `addModelTransformer()`, `addViewTransformer()`.
- **Data mappers**: A data mapper maps many fields to one object and back. Use a data mapper for an immutable object that gets its values through the constructor. Entry: `Symfony\Component\Form\DataMapperInterface`, `setDataMapper()`.
- **Collections**: `CollectionType` edits a list of embedded forms of one `entry_type`. With `'allow_add' => true`, the view contains a `prototype` with the `__name__` placeholder, which JavaScript copies for each new row. `'allow_delete' => true` removes the rows that the request does not contain. Set `'by_reference' => false`, so that the form calls the adder and remover methods, for example `addTag()` and `removeTag()`. Entry: `Symfony\Component\Form\Extension\Core\Type\CollectionType`.
- **Validation**: When `handleRequest()` submits the form, the form validates the data object with its Validator constraints. Each violation goes to the matching field, and `isValid()` returns `false`. Use the `constraints` option for unmapped fields and for forms without a data class. To validate an embedded object, add `#[Assert\Valid]` to its property. `validation_groups` accepts an array, a callable or a `GroupSequence`. The `required` option only adds the HTML `required` attribute; it does not validate on the server. Entry: the `constraints`, `validation_groups` and `error_mapping` options.
- **CSRF protection**: Each root form gets a hidden `_token` field, and `isValid()` returns `false` when the token is not valid. The token ID comes from the `csrf_token_id` option, then from `framework.form.csrf_protection.token_id` (autoconfigured types only), then from the form name. For a read-only `GET` search form, set `'csrf_protection' => false`. For stateless CSRF, use the token ID `submit` in `framework.form.csrf_protection.token_id` and in `framework.csrf_protection.stateless_token_ids`. Entry: the `csrf_protection`, `csrf_token_id` and `csrf_field_name` options.
- **Form themes**: `{{ form(form) }}`, `form_row()` and the other Twig form functions render fields with the blocks of a form theme. Built-in themes: `form_div_layout.html.twig` (default), `form_table_layout.html.twig`, `bootstrap_3_layout.html.twig`, `bootstrap_4_layout.html.twig`, `bootstrap_5_layout.html.twig` (each with a horizontal variant, for example `bootstrap_5_horizontal_layout.html.twig`), `foundation_5_layout.html.twig`, `foundation_6_layout.html.twig`, `tailwind_2_layout.html.twig` and `daisyui_5_layout.html.twig`. To change one field, override its block, for example `_product_name_widget`. Entry: `twig.form_themes`, `{% form_theme form 'form/theme.html.twig' %}`.
- **Events, type extensions and guessers**: Form events change a form at run time, for example a state field that depends on a country field. Add the listeners in `buildForm()` with `addEventListener()`. A type extension changes every field of a type, for example with a new option for all `FileType` fields. When `add()` has no type and the form has a data class, type guessers use Validator constraints, enum properties and Doctrine mapping. Entry: `Symfony\Component\Form\FormEvents`, `Symfony\Component\Form\AbstractTypeExtension`, `Symfony\Component\Form\FormTypeGuesserInterface`.
- **Multi-step form flow**: A flow type extends `AbstractFlowType` and adds steps with `addStep()` in `buildFormFlow()`. `NavigatorFlowType` adds the previous, next and finish buttons. Set the `step_property_path` option to the property that stores the current step, for example `currentStep`. Each step validates the groups `Default` and the step name. In a full-stack application, the session keeps the data between requests. After the user clicks the finish button, `isFinished()` returns `true`, and `getData()` contains the data of all steps. If the flow is not finished, pass the result of `getStepForm()` to the template, not the flow object. When the submitted step is valid, `getStepForm()` runs the handler of the clicked button, for example `moveNext()`. It then returns the form of the new step. Entry: `Symfony\Component\Form\Flow\AbstractFlowType`.

## Entry points

- Service to autowire: `Symfony\Component\Form\FormFactoryInterface` (service `form.factory`): `create()`, `createNamed()`, `createBuilder()`.
- Controller helpers in `Symfony\Bundle\FrameworkBundle\Controller\AbstractController` (also in the `Symfony\Bundle\FrameworkBundle\Controller\ControllerHelper` service): `createForm()`, `createFormBuilder()`, `createFormFlowBuilder()`, and `render()`. Pass the form object to `render()`, not the result of `createView()`. Then `render()` returns the status code 422 for a submitted invalid form.
- Form object: `Symfony\Component\Form\FormInterface`: `handleRequest()`, `isSubmitted()`, `isValid()`, `getData()`, `getErrors(true)`, `submit()`, `createView()`.
- Classes to extend or implement: `Symfony\Component\Form\AbstractType`, `Symfony\Component\Form\AbstractTypeExtension`, `Symfony\Component\Form\FormTypeGuesserInterface`, `Symfony\Component\Form\DataTransformerInterface`, `Symfony\Component\Form\CallbackTransformer`, `Symfony\Component\Form\DataMapperInterface`, `Symfony\Component\Form\Flow\AbstractFlowType`.
- Built-in types: `Symfony\Component\Form\Extension\Core\Type\*`, for example `TextType`, `ChoiceType`, `EnumType`, `DateType`, `MoneyType`, `FileType`, `CollectionType`, `RepeatedType`. Doctrine entities: `Symfony\Bridge\Doctrine\Form\Type\EntityType`.
- Form flow types: `Symfony\Component\Form\Flow\Type\NavigatorFlowType`, `NextFlowType`, `PreviousFlowType`, `FinishFlowType`, `ResetFlowType`. Data storages: `Symfony\Component\Form\Flow\DataStorage\SessionDataStorage`, `InMemoryDataStorage`, `NullDataStorage`.
- Form events: `Symfony\Component\Form\FormEvents::PRE_SET_DATA`, `POST_SET_DATA`, `PRE_SUBMIT`, `SUBMIT`, `POST_SUBMIT`.
- Attributes: none. The component has no attributes for application code; define the fields in `buildForm()`.
- Service tags (autoconfigured): `form.type`, `form.type_extension`, `form.type_guesser`. Service to decorate: `form.violation_mapper` (`Symfony\Component\Form\Extension\Validator\ViolationMapper\ViolationMapperInterface`).
- Config keys: `framework.form.enabled`, `framework.form.csrf_protection.enabled`, `framework.form.csrf_protection.token_id`, `framework.form.csrf_protection.field_name`, `framework.form.csrf_protection.field_attr`, `framework.csrf_protection` (must be enabled for form CSRF), `twig.form_themes`.
- Console commands: `debug:form`, `debug:form BirthdayType`, `debug:form BirthdayType label_attr`. MakerBundle: `make:form`, `make:registration-form`.
- Twig functions: `form()`, `form_start()`, `form_end()`, `form_row()`, `form_label()`, `form_widget()`, `form_errors()`, `form_help()`, `form_rest()`, `form_parent()`, `field_name()`, `field_id()`, `field_value()`, `field_label()`, `field_help()`, `field_errors()`, `field_choices()`, `csrf_token()`. Form flow functions: `form_flow_*()`, for example `form_flow_current_step()` and `form_flow_total_steps()`. Twig tag: `{% form_theme %}`. Twig tests: `selectedchoice`, `rootform`.
- Test helpers: `Symfony\Component\Form\Test\TypeTestCase`, `Symfony\Component\Form\Test\Traits\ValidatorExtensionTrait`, `Symfony\Component\Form\PreloadedExtension`, `Symfony\Bridge\Twig\Test\FormLayoutTestCase`.
- Without FrameworkBundle: `Symfony\Component\Form\Forms::createFormFactoryBuilder()` with `Symfony\Component\Form\Extension\HttpFoundation\HttpFoundationExtension`, `Symfony\Component\Form\Extension\Csrf\CsrfExtension` and `Symfony\Component\Form\Extension\Validator\ValidatorExtension`.

## Symbiotic packages

- [Validator](../packages/validator.md): The form validates the submitted data object with its constraints and attaches each violation to the matching field.
- [Twig Bridge](../packages/twig-bridge.md): The bridge contains the Twig form functions, the `form_theme` tag and the built-in form themes.
- [TwigBundle](../packages/twig-bundle.md): The `twig.form_themes` option sets the form themes for all forms of the application.
- [FrameworkBundle](../packages/framework-bundle.md): FrameworkBundle registers `form.factory` and autoconfigures form types; its `AbstractController` adds `createForm()` and returns the status code 422 from `render()` for a submitted invalid form.
- [Security CSRF](../packages/security-csrf.md): Forms use its token manager for `_token`; for a plain HTML form, use `csrf_token()` with `isCsrfTokenValid()` or `#[IsCsrfTokenValid]` (needs SecurityBundle).
- [HttpFoundation](../packages/http-foundation.md): `HttpFoundationRequestHandler` reads the fields and the `UploadedFile` objects of the `Request` for `handleRequest()`.
- [HttpKernel](../packages/http-kernel.md): For a JSON API payload without an HTML form, use `#[MapRequestPayload]`, which maps the payload to a DTO.
- [Serializer](../packages/serializer.md): `FormErrorNormalizer` converts the errors of a submitted form into an RFC 7807 array for an API response.
- [Doctrine Bridge](../packages/doctrine-bridge.md): `EntityType` lists entities as choices, `DoctrineOrmTypeGuesser` guesses field types from the Doctrine mapping, and `UniqueEntity` validates unique values.
- [Intl](../packages/intl.md): `CountryType`, `LanguageType`, `LocaleType` and `CurrencyType` need this package for their choice lists, and `TimezoneType` needs it with `'intl' => true`.
- [Uid](../packages/uid.md): `UuidType` and `UlidType` need this package and return `Uuid` and `Ulid` objects.
- [Clock](../packages/clock.md): The date and time types need this package for `'input' => 'date_point'`, which returns `DatePoint` objects.
- [HtmlSanitizer](../packages/html-sanitizer.md): The `sanitize_html` option of `TextType` and its child types cleans HTML input with a configured sanitizer.
- [PasswordHasher](../packages/password-hasher.md): The `hash_property_path` option of `PasswordType` hashes the submitted password with this package and writes the hash to the user object.
- [Security](../packages/security-bundle.md): SecurityBundle registers the form extension for `hash_property_path`, which needs a `PasswordAuthenticatedUserInterface` object and `'mapped' => false`.
- [Translation](../packages/translation.md): The form translates labels, help texts and choice labels with the `translation_domain` and `choice_translation_domain` options.
- [PropertyAccess](../packages/property-access.md): The form reads and writes the data object through property paths, for example `'property_path' => 'category.name'`.
- [OptionsResolver](../packages/options-resolver.md): `configureOptions()` receives an `OptionsResolver` that declares the options, defaults and allowed types of a form type.
- [EventDispatcher](../packages/event-dispatcher.md): The form events use a dispatcher in each form, not the kernel dispatcher; add their listeners in `buildForm()`.
- [UX Live Component](../packages/ux-live-component.md): `ComponentWithFormTrait` renders a form in a live component that validates fields and updates dependent fields while the user types.
- [Symfony UX Turbo](../packages/ux-turbo.md): Turbo Drive needs the status code 422 for an invalid form and a 303 redirect after success; `render()` sets the 422.
- [UX Autocomplete](../packages/ux-autocomplete.md): `'autocomplete' => true` on `ChoiceType` or `EntityType` adds a search box, and `#[AsEntityAutocompleteField]` loads the options with AJAX.
- [Symfony UX Dropzone](../packages/ux-dropzone.md): `DropzoneType` replaces `FileType` and adds a drag-and-drop zone.
- [Symfony UX Cropper.js](../packages/ux-cropperjs.md): `CropperType` adds an image crop field to a form, with a `Crop` object from `CropperInterface`.
- [MakerBundle](../packages/maker-bundle.md): `make:form` creates a form type class, and `make:registration-form` creates a registration form system.
- [DomCrawler](../packages/dom-crawler.md): the DomCrawler `Form` fills in and submits the rendered HTML form in tests; `Symfony\Component\Form\Form` builds and validates forms on the server.
- [ExpressionLanguage](../packages/expression-language.md): in the `constraints` option of a field, `Assert\When` with `this.getParent()` reads the value of another field.
- [FrameworkBundle test tools](../packages/framework-bundle-testing.md): use `TypeTestCase` to unit test a form type; if you cannot mock its dependencies, use `KernelTestCase` and the `form.factory` service.
- [ObjectMapper](../packages/object-mapper.md): often confused; ObjectMapper maps one PHP object to another and does not read the request or validate. Use Form for submitted HTML forms.
- [Symfony Polyfill](../packages/polyfill.md): Form requires `symfony/polyfill-intl-icu`, so the localized number and date transformers work without the intl extension, but only for the `en` locale.
- [StimulusBundle](../packages/stimulus-bundle.md): give `stimulus_controller(...).toArray()` to the `attr` option of `form_start()` or `form_row()`, or build the attributes in a form type with `StimulusHelper`.
- [Workflow](../packages/workflow.md): for a multi-step form wizard, use the Form flow (`AbstractFlowType`); for the status of a domain object, use Workflow.

## Changed in 8.0/8.1

- 8.0: `UrlType` does not add `http://` to a URL without a protocol, because `default_protocol` is `null`. To keep the old behavior, set `'default_protocol' => 'http'`.
- 8.1: `AbstractController::createFormFlowBuilder()`, the `with_reset` option of `NavigatorFlowType` (`ResetFlowType`) and the `form_flow_*()` Twig functions are new. The form flow itself is new in 7.4.
- 8.1: A required collapsed `ChoiceType` renders its placeholder with the `hidden` attribute. To show it again, set `'placeholder_attr' => []` or `'required' => false`.
- 8.1: A boolean second argument of `ValidatorExtension` and `FormTypeValidatorExtension` is deprecated. Pass a `ViolationMapperInterface`, or decorate the `form.violation_mapper` service.
- 8.1: `DateType` has a `labels` option for its year, month and day fields. `BirthdayType` with `single_text` adds `min` and `max` attributes.
- 8.1: `EntityType` has a `uid_format` option, which sets the format of a UID identifier in the choice values.
- 8.1: The new `daisyui_5_layout.html.twig` form theme renders forms with daisyUI 5 classes.

## Docs

- https://symfony.com/doc/current/forms.html
- https://symfony.com/doc/current/form/form_flow.html
- https://symfony.com/doc/current/reference/forms/types.html
- https://symfony.com/doc/current/form/data_transformers.html
- https://symfony.com/doc/current/form/data_mappers.html
- https://symfony.com/doc/current/form/form_collections.html
- https://symfony.com/doc/current/form/embedded.html
- https://symfony.com/doc/current/form/form_themes.html
- https://symfony.com/doc/current/form/form_customization.html
- https://symfony.com/doc/current/form/events.html
- https://symfony.com/doc/current/form/dynamic_form_modification.html
- https://symfony.com/doc/current/form/create_custom_field_type.html
- https://symfony.com/doc/current/form/create_form_type_extension.html
- https://symfony.com/doc/current/form/type_guesser.html
- https://symfony.com/doc/current/form/validation_groups.html
- https://symfony.com/doc/current/form/unit_testing.html
- https://symfony.com/doc/current/security/csrf.html
- https://symfony.com/doc/current/controller/upload_file.html
- https://symfony.com/doc/current/reference/forms/types/choice.html
- https://symfony.com/doc/current/reference/forms/types/enum.html
- https://symfony.com/doc/current/reference/forms/types/money.html
- https://symfony.com/doc/current/reference/forms/types/date.html
- https://symfony.com/doc/current/reference/forms/types/file.html
- https://symfony.com/doc/current/reference/forms/types/collection.html
- https://symfony.com/doc/current/reference/forms/types/repeated.html
- https://symfony.com/doc/current/reference/forms/types/password.html
