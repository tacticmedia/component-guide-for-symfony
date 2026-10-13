# PasswordHasher (`symfony/password-hasher`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when PHP must hash and verify passwords, and replace old MD5 or SHA hashes with stronger hashes at the next login. It uses bcrypt or Argon2, selects a hasher for each user class, and hashes passwords on the command line. To log users in, see [Security](security-bundle.md).

**Details:** [../details/password-hasher.md](../details/password-hasher.md)

## Why it exists

An application must not store plain passwords. Hand-written MD5 hashes and direct calls to the PHP password functions do not move old hashes to a stronger algorithm. The package hashes and verifies passwords with the algorithm that the configuration sets for each user class. It also detects outdated hashes, so the application can replace them at the next login.

## When to use it

- Hash a new password before you save the user, for example in a registration or password-reset form.
- Check a plain password against the stored hash, for example before you delete an account.
- Replace old MD5, SHA-1, SHA-256 or low-cost bcrypt hashes with new hashes at the next login.
- Use a stronger hasher for administrators, or a separate hasher for recovery codes and API tokens.
- Hash the password field of a form without code in the controller.
- Create a password hash on the command line for a user list in the configuration or for a database row.
- Hash and verify passwords in a PHP application without the Symfony framework.
- Make the hashers fast in the test environment.

## Use it instead of

- `password_hash($plainPassword, PASSWORD_DEFAULT)` and `password_verify($plainPassword, $user->getPassword())` in a controller -> `UserPasswordHasherInterface::hashPassword()` and `isPasswordValid()`, with the algorithm from `security.password_hashers`.
- `hash('sha256', $salt.$plainPassword)` plus a `salt` column -> `algorithm: auto`; bcrypt keeps the salt in the hash.
- A login check that tries `password_verify()` and then `md5($plainPassword) === $hash` -> a named hasher `legacy` (`algorithm: md5`, `encode_as_base64: false`, `iterations: 1`) in the `migrate_from` list of the new hasher.
- `if (password_needs_rehash($hash, PASSWORD_DEFAULT)) { $user->setPassword(...); $entityManager->flush(); }` after a login -> `PasswordUpgraderInterface::upgradePassword()` in `UserRepository`; Symfony calls it after a login when the hash is outdated.
- `$user->setPassword($passwordHasher->hashPassword($user, $form->get('plainPassword')->getData()))` after `$form->isValid()` -> the `hash_property_path` option on an unmapped `PasswordType` field.
- `php -r "echo password_hash('secret', PASSWORD_BCRYPT);"` for a hash in `security.yaml` -> `php bin/console security:hash-password`, which uses the configured hasher.
- `password_verify($currentPassword, $user->getPassword())` in a password-change action -> the `UserPassword` constraint on the current password field.
- A recovery code that the database stores as plain text -> a named hasher (`recovery_code: auto`) and `#[Target('recovery_code')] PasswordHasherInterface`.
- `UserPasswordEncoderInterface::encodePassword()`, `security.encoders` and `security:encode-password` from Symfony 5 -> `UserPasswordHasherInterface::hashPassword()`, `security.password_hashers` and `security:hash-password` (Symfony 5.3 deprecated the encoders, and Symfony 6.0 removed them).
