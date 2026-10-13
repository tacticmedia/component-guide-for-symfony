# PasswordHasher (`symfony/password-hasher`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **User password hasher:** `hashPassword($user, $plainPassword)` hashes the plain password with the hasher that the configuration selects for the user. `isPasswordValid($user, $plainPassword)` compares a plain password with the hash that `getPassword()` returns. `needsRehash($user)` returns `true` if the stored hash is outdated. The user class must implement `PasswordAuthenticatedUserInterface`. Entry point: `Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface`.
- **One hasher for each user class:** `security.password_hashers` maps a user class or interface to a hasher configuration. The factory uses the first class or interface in the list that matches the user object. The SecurityBundle recipe of Symfony Flex sets `PasswordAuthenticatedUserInterface: 'auto'`. Entry point: `security.password_hashers`.
- **The "auto" algorithm:** `auto` hashes with bcrypt, with a cost of 13 by default. A future PHP or Symfony version can select a different algorithm, and the hash length can change. Store the hashes in a `varchar(255)` column. `auto` also verifies Argon2 hashes, and PBKDF2 hashes that use the same options, and `needsRehash()` returns `true` for them. Entry point: `algorithm: auto`.
- **Other algorithms:** `bcrypt` uses a `cost` from 4 to 31 (13 by default) and makes 60-character hashes. Before bcrypt, the hasher hashes a password longer than 72 bytes with SHA-512, so bcrypt does not cut it. `sodium` uses Argon2 and needs the `sodium` PHP extension with libsodium 1.0.14 or later. Other values are `native`, `argon2i`, `argon2id`, `pbkdf2` (not recommended) and `plaintext` (no hash, only for tests). A `hash()` algorithm name, for example `sha256`, makes a message digest hasher for old hashes. Entry point: `security.password_hashers.<class>.algorithm`.
- **Migration from old hashers:** `migrate_from` lists the names of old hashers or algorithms. Symfony hashes new passwords with the new hasher and verifies old hashes with the old hashers. A user class does not need `PasswordHasherAwareInterface` for this. Entry point: `security.password_hashers.<class>.migrate_from`.
- **Rehash at login:** After a successful login with `PasswordCredentials` (`form_login`, `json_login`, `http_basic` or a custom authenticator), Symfony calls `needsRehash()`. If it returns `true`, Symfony hashes the plain password again and gives the new hash to `upgradePassword()` of the user provider. For the Doctrine `entity` provider, implement `PasswordUpgraderInterface` in `UserRepository`. If the repository does not implement it, the `entity` provider does not store the new hash. Entry point: `Symfony\Component\Security\Core\User\PasswordUpgraderInterface`.
- **Named hashers:** A `password_hashers` key that is not a class name, for example `harsh` or `recovery_code`, defines a named hasher. If a user class implements `PasswordHasherAwareInterface`, `getPasswordHasherName()` returns the name of a named hasher, or `null` for the default hasher. To hash a string that does not belong to a user, inject `#[Target('recovery_code')] PasswordHasherInterface $hasher`. Then call `hash()` and `verify()`, not `hashPassword()`. Entry point: `Symfony\Component\PasswordHasher\Hasher\PasswordHasherAwareInterface`.
- **Hasher factory:** `getPasswordHasher()` returns the hasher for a user object, a user class name or a hasher name. If no configuration matches, it throws a `RuntimeException`. Entry point: `Symfony\Component\PasswordHasher\Hasher\PasswordHasherFactoryInterface`.
- **Console command:** `security:hash-password` hashes a password with the hasher of a user class and prints the hash. In interactive mode, it asks for a missing password with a hidden prompt. The optional `user-class` argument selects the hasher. For a legacy hasher with a separate salt, the command generates a salt (in interactive mode, after a confirmation), unless you add `--empty-salt`. Entry point: `php bin/console security:hash-password`.
- **Form option:** The `hash_property_path` option of `PasswordType` hashes the submitted password and writes the hash to a user property, for example `password`. The field must have `'mapped' => false`, and the form data must be a `PasswordAuthenticatedUserInterface` object. The form hashes the password only if the whole form is valid. With `RepeatedType`, put `hash_property_path` in `first_options` and `'mapped' => false` on the repeated field. Entry point: `hash_property_path` of `Symfony\Component\Form\Extension\Core\Type\PasswordType`.
- **Current password check:** The `UserPassword` constraint checks that a value is the current password of the logged-in user, with the hasher of that user. Use it on the "current password" field of a password-change form. Entry point: `Symfony\Component\Security\Core\Validator\Constraints\UserPassword`.
- **Standalone use:** `new PasswordHasherFactory([...])` maps user classes or hasher names to an options array or to a `PasswordHasherInterface` object. The options are the keys of `security.password_hashers`, except `id`. `new UserPasswordHasher($factory)` adds `hashPassword()` and `isPasswordValid()` for user objects. For these user objects, install `symfony/security-core`, because the user interfaces are in that package. Without SecurityBundle, call `needsRehash()` and `hash()` yourself after a login. Entry point: `Symfony\Component\PasswordHasher\Hasher\PasswordHasherFactory`.
- **Custom hasher:** Implement `PasswordHasherInterface`, or `LegacyPasswordHasherInterface` if the algorithm uses a separate salt. Like the built-in hashers, use `CheckPasswordLengthTrait` to find plain passwords that are longer than 4096 bytes. For such a password, `hash()` must throw `InvalidPasswordException`, and `verify()` must return `false`. Set the service ID in the `id` key. If `needsRehash()` returns `true`, Symfony rehashes the password at the next login. Entry point: `Symfony\Component\PasswordHasher\PasswordHasherInterface`.
- **Fast tests:** The SecurityBundle recipe of Symfony Flex adds a `when@test` block that sets `cost: 4`, `time_cost: 3` and `memory_cost: 10` on the `PasswordAuthenticatedUserInterface` hasher. These are the lowest values for bcrypt and Argon2. If your `security.yaml` has no such block, or if you configure another hasher, set the same values in `when@test`. Entry point: `when@test` in `config/packages/security.yaml`.

## Entry points

- `Symfony\Component\PasswordHasher\Hasher\UserPasswordHasherInterface` (service `security.user_password_hasher`, alias `security.password_hasher`): `hashPassword()`, `isPasswordValid()`, `needsRehash()`
- `Symfony\Component\PasswordHasher\Hasher\PasswordHasherFactoryInterface` (service `security.password_hasher_factory`): `getPasswordHasher()`
- `Symfony\Component\PasswordHasher\PasswordHasherInterface` with `#[Symfony\Component\DependencyInjection\Attribute\Target('<name>')]` for a named hasher (service `security.password_hasher.<name>`): `hash()`, `verify()`, `needsRehash()`
- User class interfaces: `Symfony\Component\Security\Core\User\PasswordAuthenticatedUserInterface`, `Symfony\Component\Security\Core\User\LegacyPasswordAuthenticatedUserInterface` (separate salt), `Symfony\Component\PasswordHasher\Hasher\PasswordHasherAwareInterface`
- Hash upgrade at login: `Symfony\Component\Security\Core\User\PasswordUpgraderInterface::upgradePassword()`
- Custom hasher: `Symfony\Component\PasswordHasher\PasswordHasherInterface`, `Symfony\Component\PasswordHasher\LegacyPasswordHasherInterface`, `Symfony\Component\PasswordHasher\Hasher\CheckPasswordLengthTrait`, `Symfony\Component\PasswordHasher\Exception\InvalidPasswordException`
- Built-in hashers in `Symfony\Component\PasswordHasher\Hasher`: `NativePasswordHasher`, `SodiumPasswordHasher`, `MigratingPasswordHasher`, `Pbkdf2PasswordHasher`, `MessageDigestPasswordHasher`, `PlaintextPasswordHasher`
- Config keys: `security.password_hashers.<class or name>` with `algorithm`, `cost`, `time_cost`, `memory_cost`, `migrate_from`, `id`, `hash_algorithm`, `key_length`, `iterations`, `encode_as_base64`, `ignore_case`
- Console command: `security:hash-password [password] [user-class] [--empty-salt]` (`-` as the password reads it from the standard input)
- Form option: `hash_property_path` of `Symfony\Component\Form\Extension\Core\Type\PasswordType`
- Constraint: `Symfony\Component\Security\Core\Validator\Constraints\UserPassword`
- Custom authenticators: `Symfony\Component\Security\Http\Authenticator\Passport\Credentials\PasswordCredentials`, and `Symfony\Component\Security\Http\Authenticator\Passport\Badge\PasswordUpgradeBadge` to give a `PasswordUpgraderInterface` object
- Without FrameworkBundle: `Symfony\Component\PasswordHasher\Hasher\PasswordHasherFactory`, `Symfony\Component\PasswordHasher\Hasher\UserPasswordHasher`

## Symbiotic packages

- [Security](../packages/security-bundle.md): SecurityBundle reads `security.password_hashers`, registers the hasher services and `security:hash-password`, checks `PasswordCredentials` at login and rehashes outdated hashes.
- [Doctrine Bridge](../packages/doctrine-bridge.md): The `entity` user provider gives a new hash to `UserRepository::upgradePassword()` only if the repository implements `PasswordUpgraderInterface`.
- [Form](../packages/form.md): The `hash_property_path` option of `PasswordType` hashes the submitted password with `UserPasswordHasherInterface` and writes the hash to the user object.
- [Validator](../packages/validator.md): The Validator runs the `UserPassword` constraint of Security Core with the configured hasher; `PasswordStrength` and `NotCompromisedPassword` check a new plain password before you hash it.
- [Console](../packages/console.md): SecurityBundle registers `security:hash-password` only if the application has `symfony/console`.
- [DependencyInjection](../packages/dependency-injection.md): `#[Target('<name>')]` selects the autowiring alias that SecurityBundle registers for each named hasher.
- [MakerBundle](../packages/maker-bundle.md): `make:user` adds an `auto` hasher (if `PasswordAuthenticatedUserInterface` has none) and a repository or user provider with `upgradePassword()`; `make:registration-form` and `make:reset-password` generate controllers that call `hashPassword()`.
- [Ldap](../packages/ldap.md): `form_login_ldap`, `json_login_ldap` and `http_basic_ldap` check the password with an LDAP bind, not with a password hasher.
- [FrameworkBundle](../packages/framework-bundle.md): If the application must read a secret again (an API key), use the secrets vault (`secrets:set`), not a hasher.

## Changed in 8.0/8.1

- `php bin/console security:hash-password 'my-password'` -> `echo "$PASSWORD" | php bin/console security:hash-password --no-interaction -` (8.1). A password argument goes into the shell history and the process list. In interactive mode, the command now shows a warning for it.
- `$passwordHasherFactory->getPasswordHasher('recovery_code')` -> `#[Target('recovery_code')] PasswordHasherInterface $passwordHasher` (7.4 and 8.0). SecurityBundle registers this autowiring alias for each `password_hashers` key that is not a class name. Symfony 8.1 deprecates autowiring that uses only the argument name, for example `PasswordHasherInterface $recoveryCode` without `#[Target]`.
- `public function eraseCredentials(): void { $this->plainPassword = null; }` -> an unmapped form field, for example with `hash_property_path`, so that the user never holds the plain password. If a sensitive property must stay in the user, leave it out of `__serialize()`. Symfony 8.0 removed `UserInterface::eraseCredentials()` and does not call it. Symfony 8.1 deprecates the `security.erase_credentials` option.

## Docs

- https://symfony.com/doc/current/security/passwords.html
- https://symfony.com/doc/current/security.html
- https://symfony.com/doc/current/reference/configuration/security.html
- https://symfony.com/doc/current/security/user_providers.html
- https://symfony.com/doc/current/security/custom_authenticator.html
- https://symfony.com/doc/current/reference/forms/types/password.html
- https://symfony.com/doc/current/reference/constraints/UserPassword.html
