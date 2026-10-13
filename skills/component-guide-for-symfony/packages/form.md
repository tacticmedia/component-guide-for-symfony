# Form (`symfony/form`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when a web page must show an HTML form for an object, read the submitted values, validate them and show the errors. It also handles CSRF tokens, file uploads, lists of sub-forms and multi-step wizards. For JSON API payloads without HTML, see [HttpKernel](http-kernel.md).

**Details:** [../details/form.md](../details/form.md)

## Why it exists

HTML form code repeats the same tasks for each field. It renders the input, reads the request value, converts it, validates it and shows the errors. The package does these tasks from one PHP class for each form. It also adds a CSRF token, handles file uploads and keeps the data of multi-step forms between requests.

## When to use it

- Render an HTML form for an entity or a data object, and save the submitted values.
- Validate user input and show each error next to its field.
- Protect an HTML form against CSRF attacks.
- Let users add and remove rows of an embedded list, for example tags or addresses.
- Split a long form into steps, for example a sign-up wizard or a checkout.
- Convert a submitted value to an object or an array, for example an entity ID or a tag list.
- Upload a file through a form field, and check its size and file type.
- Render all forms with Bootstrap, Tailwind CSS or daisyUI classes.

## Use it instead of

- `$request->request->get('email')`, `trim()` and `if ('' === $email)` checks in each controller -> `$this->createForm(ContactType::class, $dto)`, `$form->handleRequest($request)` and `$form->isSubmitted() && $form->isValid()` (`AbstractType`).
- A hidden `<input name="token">` with `bin2hex(random_bytes(32))` that you store in the session and compare -> the automatic `_token` field of each form (`csrf_protection` option).
- A hard-coded `['FR' => 'France', 'DE' => 'Germany']` array, or a `foreach (Status::cases() as $case)` loop that writes `<option>` tags -> `CountryType`, `CurrencyType`, `LanguageType`, `TimezoneType` or `EnumType`.
- `$product->setPriceInCents((int) round($price * 100))` -> `MoneyType` with `'divisor' => 100` and `'input' => 'integer'`.
- `\DateTimeImmutable::createFromFormat('Y-m-d', $request->request->get('date'))` plus a check for `false` -> `DateType` with `'input' => 'datetime_immutable'`.
- Two password inputs, an `if ($password !== $confirm)` check and `$hasher->hashPassword()` in the controller -> `RepeatedType` with `'type' => PasswordType::class` and `'mapped' => false`, plus `'hash_property_path' => 'password'` in `first_options`.
- JavaScript that counts rows and writes names such as `tags[3][name]` -> `CollectionType` with `'allow_add' => true` and its `prototype` with the `__name__` placeholder.
- A `$_SESSION['wizard_step']` counter with one form for each step -> a form flow: `AbstractFlowType`, `addStep()` and `NavigatorFlowType`.
- `explode(',', $form->get('tags')->getData())` in the controller -> a `CallbackTransformer` on the field, added with `addModelTransformer()`.
- `strip_tags($request->request->get('bio'), '<p><b><a>')` on HTML from a rich-text editor -> `'sanitize_html' => true` on `TextareaType` or `TextType` (needs `symfony/html-sanitizer`). The default sanitizer keeps the safe elements and removes scripts and unsafe attributes.
