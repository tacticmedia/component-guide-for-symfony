# Security (`symfony/security-bundle`, `symfony/security-core`, `symfony/security-http`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Firewalls:** A firewall authenticates the requests that match its `pattern`, `host`, `methods` or `request_matcher`. Only one firewall is active for a request, because Symfony uses the first firewall that matches. `stateless: true` does not use the session. `lazy: true` loads the user and starts the session only when the application accesses the user. `security: false` removes security from a firewall, for example for the `/_profiler` URLs. Entry point: `security.firewalls`.
- **Form login and JSON login:** `form_login` reads `_username` and `_password` from a POST request to its `check_path`. After a login, it redirects to the page that the user requested before, or to `default_target_path`. `enable_csrf: true` adds a CSRF token check. `json_login` reads the credentials from the `username_path` and `password_path` of a JSON request body. `AuthenticationUtils` gives the last error and the last user name to the login template. Entry point: `security.firewalls.<name>.form_login`.
- **Login links:** `login_link` logs a user in with a signed URL and no password (a "magic link"). `LoginLinkHandlerInterface::createLoginLink()` creates the link for a user. The link uses the host of the request. Set `framework.trusted_hosts` to block a forged `Host` header. A link expires after `lifetime` seconds (600 by default). The required `signature_properties` sign the link, so a change of one of their values, for example the email address, makes the link invalid. `max_uses` limits how many times a user can use one link. Entry point: `Symfony\Component\Security\Http\LoginLink\LoginLinkHandlerInterface`.
- **Access tokens:** `access_token` reads a bearer token from the `Authorization` header by default. With `token_extractors`, it can also read the query string or a form-encoded request body. A `token_handler` returns a `UserBadge` for the token. Write an `AccessTokenHandlerInterface` service, or use the built-in `oidc`, `oidc_user_info` or `cas` handler. SecurityBundle also has an `oauth2` handler for OAuth2 token introspection, but it is `@internal` and undocumented. It sends the token to an empty URL through the `http_client` service, so it rejects every token. For token introspection, write an `AccessTokenHandlerInterface` service. The `oidc` handler validates signed JWTs and needs the `web-token/jwt-library` package. If you use the `cas` handler, set `framework.trusted_hosts`, or the handler throws a `LogicException`. Entry point: `Symfony\Component\Security\Http\AccessToken\AccessTokenHandlerInterface`.
- **Remember me:** `remember_me` sets a cookie when the login request contains `_remember_me`, or always with `always_remember_me: true`. The cookie logs the user in again after the session ends. The authenticator must add a `RememberMeBadge`, and `form_login`, `json_login` and `login_link` do this. By default, the cookie holds a signature of the `password` property, so a password change makes the cookie invalid. `token_provider: { doctrine: true }` stores the tokens in a database table, with the `DoctrineTokenProvider` class of the Doctrine Bridge. If you need another storage, set `token_provider.service` to the ID of a `TokenProviderInterface` service. Entry point: `security.firewalls.<name>.remember_me`.
- **HTTP basic, X.509 and remote users:** `http_basic` reads the user name and the password of HTTP basic authentication. If a protected page needs a login, it sends a `401` response with a `WWW-Authenticate` header. `x509` reads the user from the client certificate (`SSL_CLIENT_S_DN_Email` by default). `remote_user` uses the `REMOTE_USER` value of a web server module that authenticates the user, for example Kerberos. Entry point: `security.firewalls.<name>.http_basic`.
- **Custom authenticators and passports:** Extend `AbstractAuthenticator`, or `AbstractLoginFormAuthenticator` for a login form. Add the class to the `custom_authenticators` option of the firewall. `authenticate()` returns a `Passport` with a `UserBadge`, credentials such as `PasswordCredentials` or `CustomCredentials`, and badges such as `CsrfTokenBadge` and `RememberMeBadge`. If there are no credentials to check, for example for an API token, return a `SelfValidatingPassport`. If a listener does not resolve a badge, the authentication fails. Entry point: `Symfony\Component\Security\Http\Authenticator\AbstractAuthenticator`.
- **Login attempt limits:** `login_throttling` limits failed logins with the RateLimiter component. By default, it allows 5 failed logins (`max_attempts`) per `1 minute` (`interval`) for each user name and IP address, and 25 for each IP address. After the limit, a login fails with `TooManyLoginAttemptsAuthenticationException`. Entry point: `security.firewalls.<name>.login_throttling`.
- **User providers:** A user provider loads a user by its identifier. On each request, it also reloads the user that the session holds. The `entity` provider loads Doctrine entities, `memory` reads users from the configuration, `ldap` reads an LDAP directory, and `chain` combines providers. The `id` key uses a custom `UserProviderInterface` service. If the provider implements `PasswordUpgraderInterface`, Symfony gives a new hash of an outdated password to `upgradePassword()` after a login. Entry point: `security.providers`.
- **Roles and role hierarchy:** `UserInterface::getRoles()` returns the roles of a user, and each role name must start with `ROLE_`. `role_hierarchy` lets a role include other roles, for example `ROLE_ADMIN: [ROLE_USER]`. `IS_AUTHENTICATED` matches every logged-in user, and `IS_AUTHENTICATED_FULLY` does not match a user that only a remember-me cookie logged in. `IS_IMPERSONATOR` matches during impersonation, and `PUBLIC_ACCESS` allows all visitors. Entry point: `security.role_hierarchy`.
- **Voters:** A voter decides a permission for one subject, for example whether the user can edit a post. A custom voter extends `Voter` and implements `supports()` and `voteOnAttribute()`. Autoconfiguration tags the voter with `security.voter`. The access decision manager combines the votes with the `affirmative` (default), `consensus`, `unanimous` or `priority` strategy. `$vote?->addReason()` adds an explanation to the logs and the exception pages. Entry point: `Symfony\Component\Security\Core\Authorization\Voter\Voter`.
- **`#[IsGranted]` and `access_control`:** `#[IsGranted('ROLE_ADMIN')]` on a controller class or method checks access before the controller runs. Its `subject` argument gives a controller argument to the voters. The `message` and `statusCode` arguments set the exception message and the HTTP status code, for example `404` instead of `403`. The `methods` argument limits the check to the listed HTTP methods, for example `POST`, and `GET` also covers `HEAD`. The attribute also accepts an `Expression` or a closure. An `access_control` rule matches a path, a host, an IP address, an HTTP method or a route, and Symfony uses only the first matching rule. With the default strategy, the rule grants access if the user has one of its `roles` or if its `allow_if` expression is true. `requires_channel: https` redirects HTTP requests to HTTPS. Entry point: `Symfony\Component\Security\Http\Attribute\IsGranted`.
- **Current user and the `Security` service:** `#[CurrentUser]` on a controller argument gives the logged-in user to the controller. If the argument is not nullable and nobody is logged in, Symfony denies access. In a service, autowire `Security`. It has `getUser()`, `isGranted()`, `login()` and `logout()`. Twig templates read `app.user` and call `is_granted()`. Entry point: `Symfony\Bundle\SecurityBundle\Security`.
- **Impersonation and logout:** With `switch_user: true`, a user with `ROLE_ALLOWED_TO_SWITCH` can add `?_switch_user=<identifier>` to a URL to act as another user. `?_switch_user=_exit` switches back. `logout` logs the user out at its `path`, invalidates the session and dispatches `LogoutEvent`. `clear_site_data` sends a `Clear-Site-Data` header, and `delete_cookies` removes cookies. Entry point: `security.firewalls.<name>.switch_user`.
- **User checkers and security events:** A `UserCheckerInterface` service rejects a user before or after the credential check, for example a disabled or expired account. Symfony calls user checkers on every authentication, also for remember-me cookies and stateless firewalls. Set the service in the `user_checker` option of the firewall. Listen to `LoginSuccessEvent`, `LoginFailureEvent` or `LogoutEvent` to run code after these actions. To react only to the events of one firewall, register the listener on `security.event_dispatcher.<firewall>`. Entry point: `Symfony\Component\Security\Core\User\UserCheckerInterface`.

## Entry points

- `Symfony\Bundle\SecurityBundle\Security` (service `security.helper`): `getUser()`, `isGranted()`, `getAccessDecision()`, `isGrantedForUser()`, `getToken()`, `getFirewallConfig()`, `login()`, `logout()`. `Symfony\Component\Security\Core\Security` does not exist. Use this class.
- `Symfony\Component\Security\Core\Authorization\AuthorizationCheckerInterface` (service `security.authorization_checker`)
- `Symfony\Component\Security\Core\Authorization\AccessDecisionManagerInterface` (service `security.access.decision_manager`; in a voter, use `decide()` and not `Security::isGranted()`)
- `Symfony\Component\Security\Core\Authentication\Token\Storage\TokenStorageInterface` (service `security.token_storage`)
- `Symfony\Component\Security\Http\Authentication\AuthenticationUtils` (service `security.authentication_utils`)
- `Symfony\Component\Security\Http\LoginLink\LoginLinkHandlerInterface`
- `Symfony\Component\Security\Core\Role\RoleHierarchyInterface` (service `security.role_hierarchy`)
- Attributes: `Symfony\Component\Security\Http\Attribute\IsGranted`, `Symfony\Component\Security\Http\Attribute\CurrentUser`
- Types to implement or extend: `Symfony\Component\Security\Core\User\UserInterface`, `Symfony\Component\Security\Core\User\PasswordAuthenticatedUserInterface`, `Symfony\Component\Security\Core\User\UserProviderInterface`, `Symfony\Component\Security\Core\User\PasswordUpgraderInterface`, `Symfony\Component\Security\Core\User\UserCheckerInterface`, `Symfony\Component\Security\Core\Authorization\Voter\Voter`, `Symfony\Component\Security\Http\Authenticator\AbstractAuthenticator`, `Symfony\Component\Security\Http\Authenticator\AbstractLoginFormAuthenticator`, `Symfony\Component\Security\Http\AccessToken\AccessTokenHandlerInterface`, `Symfony\Component\Security\Http\EntryPoint\AuthenticationEntryPointInterface`, `Symfony\Component\Security\Http\Authorization\AccessDeniedHandlerInterface`
- Passport classes in `Symfony\Component\Security\Http\Authenticator\Passport`: `Passport`, `SelfValidatingPassport`, `Badge\UserBadge`, `Badge\CsrfTokenBadge`, `Badge\RememberMeBadge`, `Credentials\PasswordCredentials`, `Credentials\CustomCredentials`
- Events in `Symfony\Component\Security\Http\Event`: `LoginSuccessEvent`, `LoginFailureEvent`, `LogoutEvent`, `CheckPassportEvent`, `SwitchUserEvent`
- Exceptions in `Symfony\Component\Security\Core\Exception`: `AccessDeniedException`, `CustomUserMessageAuthenticationException`, `CustomUserMessageAccountStatusException`, `TooManyLoginAttemptsAuthenticationException`
- Config keys: `security.firewalls.<name>` (`pattern`, `host`, `methods`, `request_matcher`, `security`, `stateless`, `lazy`, `provider`, `context`, `user_checker`, `entry_point`, `access_denied_handler`, `access_denied_url`, `required_badges`, `form_login`, `json_login`, `http_basic`, `login_link`, `access_token`, `remember_me`, `x509`, `remote_user`, `custom_authenticators`, `login_throttling`, `logout`, `switch_user`), `security.providers`, `security.password_hashers`, `security.access_control`, `security.role_hierarchy`, `security.access_decision_manager`, `security.expose_security_errors`, `security.session_fixation_strategy`
- Console commands: `debug:firewall`, `debug:security:role-hierarchy`, `security:hash-password`, `security:oidc:generate-token`; MakerBundle: `make:user`, `make:security:form-login`, `make:security:custom`, `make:voter`
- Twig functions: `is_granted()`, `is_granted_for_user()`, `access_decision()`, `access_decision_for_user()`, `logout_path()`, `logout_url()`, `impersonation_path()`, `impersonation_url()`, `impersonation_exit_path()`, `impersonation_exit_url()`; variables `app.user` and `app.token`
- Controller helpers in `Symfony\Bundle\FrameworkBundle\Controller\AbstractController`: `getUser()`, `isGranted()`, `getAccessDecision()`, `denyAccessUnlessGranted()`, `createAccessDeniedException()`
- Expression functions in `allow_if` and in an `Expression` attribute of `#[IsGranted]`: `is_granted()`, `is_authenticated()`, `is_fully_authenticated()`, `is_remember_me()`
- Service tags: `security.voter`, `security.user_checker.<firewall>` (with the `security.user_checker.chain.<firewall>` service)
- Event dispatcher of one firewall: `security.event_dispatcher.<firewall>`
- Logout routes: `_logout_<firewall>`, from the `security.route_loader.logout` route resource
- Test helper: `Symfony\Bundle\FrameworkBundle\KernelBrowser::loginUser()` (it does not work with stateless firewalls)

## Symbiotic packages

- [PasswordHasher](../packages/password-hasher.md): `security.password_hashers` selects the hasher for each user class, and `form_login` checks `PasswordCredentials` with that hasher; use PasswordHasher to hash a new password.
- [Security CSRF](../packages/security-csrf.md): `enable_csrf` on `form_login` and `logout` checks a CSRF token with the CSRF token manager; use Security CSRF directly for other forms.
- [Ldap](../packages/ldap.md): The `ldap` user provider and the `form_login_ldap`, `json_login_ldap` and `http_basic_ldap` authenticators check users against an LDAP server.
- [RateLimiter](../packages/rate-limiter.md): `login_throttling` needs `symfony/rate-limiter` and counts failed logins with two fixed-window limiters.
- [Lock](../packages/lock.md): If the application has `symfony/lock`, `login_throttling` gives the `lock.factory` service to its limiters by default (`lock_factory: auto`).
- [Doctrine Bridge](../packages/doctrine-bridge.md): The `entity` user provider loads users with Doctrine, `UserLoaderInterface` allows a custom query, and `DoctrineTokenProvider` stores remember-me tokens.
- [Twig Bridge](../packages/twig-bridge.md): Twig templates use `is_granted()`, `logout_path()`, `impersonation_exit_path()` and `app.user`.
- [FrameworkBundle](../packages/framework-bundle.md): `AbstractController` gives `getUser()`, `isGranted()` and `denyAccessUnlessGranted()` to controllers.
- [FrameworkBundle test tools](../packages/framework-bundle-testing.md): `KernelBrowser::loginUser()` logs a user in for a functional test.
- [ExpressionLanguage](../packages/expression-language.md): `allow_if` and `#[IsGranted(new Expression('...'))]` need this package, because SecurityBundle removes the expression voter without it.
- [Validator](../packages/validator.md): The `UserPassword` constraint checks that a value is the current password of the logged-in user.
- [Form](../packages/form.md): The `hash_property_path` option of `PasswordType` hashes the submitted password with the password hasher of the user.
- [Notifier](../packages/notifier.md): `LoginLinkNotification` sends a login link by email or SMS.
- [HttpClient](../packages/http-client.md): The `oidc_user_info` and `cas` token handlers and OIDC discovery call the identity server with HttpClient.
- [Cache](../packages/cache.md): OIDC discovery caches the server configuration, and `max_uses` of login links stores the used links in a cache pool.
- [PropertyAccess](../packages/property-access.md): The `signature_properties` of login links and remember-me cookies read the user properties with PropertyAccess.
- [String](../packages/string.md): The `oidc` and `oidc_user_info` token handlers need `symfony/string` to create the default `OidcUser` from the token claims, and the `oauth2` handler always needs it.
- [EventDispatcher](../packages/event-dispatcher.md): Each firewall has its own dispatcher, `security.event_dispatcher.<firewall>`, and Symfony dispatches the security events on it and on the global dispatcher.
- [HttpFoundation](../packages/http-foundation.md): A `RequestMatcherInterface` service in `request_matcher` selects the requests of a firewall or of an `access_control` rule.
- [HttpKernel](../packages/http-kernel.md): A controller value resolver gives the `#[CurrentUser]` argument to the controller, and `#[IsGranted]` checks access on the `kernel.controller_arguments` event.
- [Routing](../packages/routing.md): An `access_control` rule can match a route name, a login link needs a `check_route`, and `security.route_loader.logout` creates the `_logout_<firewall>` routes.
- [Monolog Bridge](../packages/monolog-bridge.md): `TokenProcessor` and `SwitchUserTokenProcessor` add the user and the impersonator to log records.
- [MakerBundle](../packages/maker-bundle.md): `make:user`, `make:security:form-login`, `make:security:custom` and `make:voter` generate a user class, a login form, an authenticator and a voter.
- [Workflow](../packages/workflow.md): Workflow guard expressions can call `is_granted()`.
- [WebProfilerBundle](../packages/web-profiler-bundle.md): The toolbar shows the authentication state and the firewall of a request, and the security panel shows the badges of the passport.

## Changed in 8.0/8.1

- `public function eraseCredentials(): void` on the user class -> a `__serialize()` method that does not return the property that `eraseCredentials()` emptied (8.0 removed `UserInterface::eraseCredentials()`). To keep the password hash out of the session, put `$data = (array) $this; $data["\0".self::class."\0password"] = hash('crc32c', $this->password); return $data;` in `__serialize()`. If `__serialize()` does not return the password, a password change does not invalidate the sessions of the user. Symfony 8.1 deprecates the `security.erase_credentials` option.
- `hide_user_not_found: true` -> `expose_security_errors: 'none'` (the default), and `hide_user_not_found: false` -> `expose_security_errors: 'all'` (8.0). The new value `'account_status'` shows account status errors, for example a locked account, but hides unknown user names.
- `voteOnAttribute(string $attribute, mixed $subject, TokenInterface $token): bool` -> `voteOnAttribute(string $attribute, mixed $subject, TokenInterface $token, ?Vote $vote = null): bool` (8.0). To explain the decision, call `$vote?->addReason()`.
- `checkPostAuth(UserInterface $user): void` -> `checkPostAuth(UserInterface $user, ?TokenInterface $token = null): void` (8.0).
- A callable firewall listener or `AbstractListener::__invoke()` -> a class that extends `AbstractListener` or implements `FirewallListenerInterface` (`supports()`, `authenticate()`, `getPriority()`) (8.0).
- The `algorithm` and `key` options of the `oidc` token handler -> `algorithms` (a list) and `keyset` (8.0).
- A `priority` on the `security.voter` tag in the service configuration -> `#[AsTaggedItem(priority: 10)]` on the voter class (8.1). The tag priority still works, but the docs recommend the attribute.
- A custom `RoleHierarchyInterface` class -> add the `getParentRoleNames()` method, which the interface declares with `@method` (8.1).

## Docs

- https://symfony.com/doc/current/security.html
- https://symfony.com/doc/current/reference/configuration/security.html
- https://symfony.com/doc/current/security/custom_authenticator.html
- https://symfony.com/doc/current/security/form_login.html
- https://symfony.com/doc/current/security/access_token.html
- https://symfony.com/doc/current/security/login_link.html
- https://symfony.com/doc/current/security/remember_me.html
- https://symfony.com/doc/current/security/user_providers.html
- https://symfony.com/doc/current/security/user_checkers.html
- https://symfony.com/doc/current/security/voters.html
- https://symfony.com/doc/current/security/expressions.html
- https://symfony.com/doc/current/security/access_control.html
- https://symfony.com/doc/current/security/impersonating_user.html
- https://symfony.com/doc/current/security/entry_point.html
- https://symfony.com/doc/current/security/access_denied_handler.html
- https://symfony.com/doc/current/security/firewall_restriction.html
- https://symfony.com/doc/current/security/force_https.html
- https://symfony.com/doc/current/reference/constraints/UserPassword.html
- https://symfony.com/doc/current/testing.html
