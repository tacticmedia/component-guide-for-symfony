# Security (`symfony/security-bundle`, `symfony/security-core`, `symfony/security-http`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when users must log in, and roles or permissions must control what each user can do. It covers authentication with login forms, API tokens with OIDC or JWT, magic login links and remember-me cookies, and authorization per role or per object. To hash passwords, see [PasswordHasher](password-hasher.md). To protect forms with CSRF tokens, see [Security CSRF](security-csrf.md).

**Details:** [../details/security-bundle.md](../details/security-bundle.md)

## Why it exists

An application must know which user sends a request, and it must allow or deny each action of that user. Hand-written login code and role checks repeat the same logic in many controllers and templates. The package authenticates each request with the login methods that you configure, and loads the user. It then decides access with roles, a role hierarchy and permission rules for each object.

## When to use it

- Log users in and out with a login form, a JSON request, HTTP basic authentication or a login link.
- Authenticate API requests with an access token, for example a JWT from an OpenID Connect server.
- Keep users logged in with a remember-me cookie after the session ends.
- Limit the failed login attempts for each user name and IP address.
- Allow or deny access to URLs, controllers and single objects, with roles or custom permission rules.
- Get the logged-in user in a controller, in other PHP code or in a template.
- Let an administrator act as another user, for example for support.
- Reject disabled, locked or expired user accounts during authentication.

## Use it instead of

- `password_verify($_POST['password'], $user->getPassword())` and `$_SESSION['user_id'] = $user->getId()` in a login controller -> a firewall with `form_login` or `json_login` and a user provider, and a `#[CurrentUser] User $user` controller argument.
- `$tokenStorage->setToken(new UsernamePasswordToken($user, 'main', $user->getRoles()))` after a sign-up -> `$security->login($user)`, which also calls `checkPreAuth()` of the user checker and dispatches `LoginSuccessEvent`.
- `if (!in_array('ROLE_ADMIN', $user->getRoles(), true)) { throw new AccessDeniedHttpException(); }` -> `#[IsGranted('ROLE_ADMIN')]` or `$this->denyAccessUnlessGranted('ROLE_ADMIN')`, which also apply the `role_hierarchy`.
- `if ($post->getAuthor() !== $this->getUser()) { throw $this->createAccessDeniedException(); }` in many controllers and templates -> a `Voter`, `#[IsGranted('POST_EDIT', subject: 'post')]` and `is_granted('POST_EDIT', post)` in Twig.
- `substr($request->headers->get('Authorization'), 7)` plus a manual JWT decode -> `access_token` with an `AccessTokenHandlerInterface` service or the `oidc` token handler.
- A database column or a cache key that counts failed logins -> `login_throttling`.
- A custom "remember me" cookie and a token table -> `remember_me`, with a signed cookie or a `token_provider`.
- A table of one-time login tokens and a controller that checks them -> `login_link` and `LoginLinkHandlerInterface::createLoginLink()`.
- `if (!$user->isActive()) { throw ... }` in a login controller -> a `UserCheckerInterface` service in the `user_checker` option of the firewall.
- Code that puts the ID of another user into the session for support staff -> `switch_user`, `IS_IMPERSONATOR` and `impersonation_exit_path()`.
