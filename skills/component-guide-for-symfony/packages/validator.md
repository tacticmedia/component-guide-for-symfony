# Validator (`symfony/validator`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when code must check input, objects, uploaded files or API payloads against rules such as required, email, length or range. It returns a list of violations, with no hand-written if checks. To check that a value is unique in a database table, see [Doctrine Bridge](doctrine-bridge.md). The uniqueness rule of this package checks only one collection.

**Details:** [../details/validator.md](../details/validator.md)

## Why it exists

Applications must reject data that breaks rules, for example an empty name, an incorrect email address or a file that is too large. The package checks values and objects against declared rules and returns a list of violations. Forms, HTTP endpoints, queue messages and command-line commands use the same rules.

## When to use it

- Validate the properties of an entity or a data object before you save it or process it.
- Reject a JSON body or a query string that does not match the rules of a data object.
- Check an uploaded file for its size, its MIME type or its image dimensions.
- Validate a single value or an array that has no class, for example in a script.
- Apply different rules to the same class for different tasks, for example registration and profile update.
- Validate rules in a fixed order that stops at the first failure.
- Write a reusable rule for a business check that no built-in rule covers.
- Add rules to a third-party class that you cannot change.
- Validate a queue message before a background worker handles it.
- Validate the input and the answers of an interactive command-line tool.

## Use it instead of

- `if (null === $name || '' === trim($name)) { $errors[] = 'Name is required.'; }` -> `#[Assert\NotBlank(normalizer: 'trim')]`; `NotNull` rejects only `null`, and `IsTrue` checks an "accept the terms" checkbox.
- `if (strlen($title) < 3 || strlen($title) > 255)`, `if ($age < 18 || $age > 120)`, `0 !== $quantity % 5`, `$birthDate > new \DateTime('-18 years')` -> `#[Assert\Length(min: 3, max: 255)]`, `#[Assert\Range(min: 18, max: 120)]`, `#[Assert\DivisibleBy(5)]`, `Positive`, `PositiveOrZero`, `Negative`, `NegativeOrZero`, `#[Assert\LessThanOrEqual('-18 years')]` on the birth date, `#[Assert\GreaterThan('today')]`, `#[Assert\GreaterThan(propertyPath: 'startDate')]`. If a DTO has a "repeat password" field, put `#[Assert\IdenticalTo(propertyPath: 'password')]` on that field. `EqualTo` compares with `==`, and `IdenticalTo` compares with `===`.
- `filter_var($email, FILTER_VALIDATE_EMAIL)` and the same call with `FILTER_VALIDATE_URL`, `FILTER_VALIDATE_IP`, `FILTER_VALIDATE_DOMAIN` or `FILTER_VALIDATE_MAC`, and `explode('/', $cidr)` with a netmask check -> `#[Assert\Email]`, `#[Assert\Url]`, `#[Assert\Ip(version: Assert\Ip::ALL)]`, `#[Assert\Hostname]`, `#[Assert\MacAddress]`, `#[Assert\Cidr]`. By default, `Ip` accepts only IPv4 addresses. By default, `Hostname` requires a top-level domain and rejects the reserved top-level domains `.example`, `.invalid`, `.localhost` and `.test`.
- `preg_match('/^[A-Z]{3}-\d{4}$/', $code)`, `in_array($status, ['draft', 'published'], true)`, a regular expression for hex colors, `str_word_count($text) < 100`, `mb_check_encoding($text, 'UTF-8')` -> `#[Assert\Regex(pattern: '/^[A-Z]{3}-\d{4}$/')]`, `#[Assert\Choice(choices: ['draft', 'published'])]`, `#[Assert\CssColor(formats: Assert\CssColor::HEX_LONG)]`, `#[Assert\WordCount(min: 100)]`, `#[Assert\Charset('UTF-8')]`. `WordCount` needs the `intl` PHP extension.
- `json_decode()` plus `json_last_error()`, `DateTime::createFromFormat('Y-m-d', $value)`, a UUID regular expression, a hard-coded list of country codes, a Luhn loop for card numbers, an ISBN checksum -> `Json`, `Yaml`, `Xml`, `Date`, `DateTime(format: ...)`, `Time`, `Week`, `Uuid`, `Ulid`, `Country`, `Currency`, `Language`, `Locale`, `Timezone`, `Luhn`, `CardScheme`, `Iban`, `Bic`, `Isbn`, `Issn`, `Isin`.
- `$file->getSize() > 2 * 1024 * 1024`, `in_array($file->getMimeType(), ['image/png', 'image/jpeg'])`, `getimagesize()` -> `#[Assert\File(maxSize: '2Mi', extensions: ['png', 'jpg', 'jpeg'])]`, `#[Assert\Image(maxWidth: 1920)]`, `#[Assert\Video]`. In `maxSize`, `M` means 1,000,000 bytes and `Mi` means 1,048,576 bytes. The `extensions` option checks the file extension and the MIME type of the file content. Use `extensions` instead of `mimeTypes`, because `mimeTypes` does not check the extension.
- Password rules with `strlen()` and `preg_match('/[0-9]/', $password)`, a manual request to the haveibeenpwned.com API, or a check of a user name with `\Spoofchecker` -> `#[Assert\PasswordStrength(minScore: Assert\PasswordStrength::STRENGTH_STRONG)]`, `#[Assert\NotCompromisedPassword]`, `#[Assert\NoSuspiciousCharacters]`. `PasswordStrength` measures the entropy of the password, not fixed rules such as "one digit". `NoSuspiciousCharacters` needs the `intl` PHP extension.
- `isset($data['email'])` and `is_string()` checks on an array, a `foreach` loop over the items, `count($tags) > 5`, `count($ids) !== count(array_unique($ids))` -> `Collection` with `Required` and `Optional`, `All`, `#[Assert\Count(max: 5)]`, `#[Assert\Unique]`.
- `if ('gift' === $order->type && '' === $order->recipient)` in a service -> `#[Assert\When(expression: 'this.type == "gift"', constraints: [new Assert\NotBlank()])]` on the property, `#[Assert\Expression]`, or `#[Assert\Callback]` on a method.
- `SELECT COUNT(*) FROM user WHERE email = ?` before an insert -> `#[UniqueEntity(fields: ['email'])]` on the entity class, from [Doctrine Bridge](doctrine-bridge.md). If you validate a DTO, put `#[UniqueEntity(fields: ['email'], entityClass: User::class)]` on the DTO class. If the DTO updates an existing entity, also set `identifierFieldNames: ['id']`. Then the DTO needs an `id` property, and the entity with that ID does not cause a violation. The `Unique` constraint of this package checks only the elements of one collection.
