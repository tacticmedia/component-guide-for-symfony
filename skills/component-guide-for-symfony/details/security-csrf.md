# Security CSRF (`symfony/security-csrf`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Activation:** If the application has `symfony/security-csrf`, `framework.csrf_protection` is on by default when the session is on or `stateless_token_ids` has values. If you enable it without a session and without `stateless_token_ids`, Symfony throws a `LogicException` ("CSRF protection needs sessions to be enabled."). If there is no session but `stateless_token_ids` has values, all token IDs are stateless. Entry point: `framework.csrf_protection`.
- **Token manager and token IDs:** `getToken('delete-item')` returns a `CsrfToken` for the token ID `delete-item` and creates a value when there is none. `isTokenValid(new CsrfToken('delete-item', $submittedValue))` checks a submitted value. `refreshToken()` replaces the value, and `removeToken()` deletes it. Use the same token ID to create a token and to check it. Entry point: `Symfony\Component\Security\Csrf\CsrfTokenManagerInterface` (service `security.csrf.token_manager`).
- **Stateful tokens (default):** `CsrfTokenManager` keeps one random value for each token ID in the session key `_csrf/<token ID>` (`_csrf/https-<token ID>` on HTTPS). Each `getToken()` call returns a new masked form of this value against the BREACH and CRIME attacks. The first token starts the session. To cache a page with a form, use stateless tokens or an uncached ESI fragment for the form. Use a different token ID for each form or action. Entry point: `Symfony\Component\Security\Csrf\CsrfTokenManager`.
- **Twig function:** `{{ csrf_token('delete-item') }}` prints a token value for the hidden field of a plain HTML form. Entry point: `csrf_token()` (`Symfony\Bridge\Twig\Extension\CsrfExtension`).
- **Controller check:** `$this->isCsrfTokenValid('delete-item', $request->getPayload()->get('token'))` returns `true` or `false`. A controller that does not extend `AbstractController` can use the same method of `ControllerHelper`. Entry points: `AbstractController::isCsrfTokenValid()`, `ControllerHelper::isCsrfTokenValid()`.
- **Attribute check:** `#[IsCsrfTokenValid('delete-item', tokenKey: 'token')]` checks the token before the controller runs. If the token is missing or not valid, the listener throws `InvalidCsrfTokenException`. Behind a firewall, the firewall then sends the response of its entry point, for example a redirect to the login page. Without an entry point, the status code is 401. On a controller class, the attribute checks all actions. `methods: ['DELETE']` limits the check to these HTTP methods, and `GET` in `methods` also covers `HEAD`. Only SecurityBundle registers the listener of the attribute. If SecurityBundle is missing or `framework.csrf_protection` is off, the attribute checks nothing. Entry point: `Symfony\Component\Security\Http\Attribute\IsCsrfTokenValid`.
- **Token sources:** `tokenSource` selects where the attribute reads the `tokenKey` value: `IsCsrfTokenValid::SOURCE_PAYLOAD` (default, form or JSON body), `SOURCE_QUERY` or `SOURCE_HEADER`. You can combine the sources with `|`. The listener then checks only the first value that it finds, in the order payload, query, header. Entry point: the `tokenSource` argument of `IsCsrfTokenValid`.
- **Dynamic token IDs:** If the token ID depends on the request, give an `Expression`, for example `new Expression('"delete-item-" ~ args["post"].getId()')`. The expression gets the variables `args`, `request` and `this` (the controller). From 8.1, the ID can also be a closure with the arguments `(array $args, Request $request, ?object $controller)` that returns a string. A closure in an attribute declaration needs PHP 8.5 and must be a `static function`, not an arrow function. Entry point: `Symfony\Component\ExpressionLanguage\Expression` (needs `symfony/expression-language`).
- **Forms:** The Form component adds a hidden `_token` field to each root form, and a wrong token makes the submitted form not valid. Configure all forms with `framework.form.csrf_protection`. Configure one form with the options `csrf_protection`, `csrf_field_name` and `csrf_token_id`. For a read-only `GET` search form, set `csrf_protection` to `false`. Entry point: `framework.form.csrf_protection` (see [Form](../packages/form.md)).
- **Login, logout and custom authenticators:** `form_login.enable_csrf: true` checks the `_csrf_token` field with the token ID `authenticate`. `logout.enable_csrf: true` checks the token ID `logout`, and `logout_path()` adds this token to the URL. A failed logout check gives the status code 403. By default, `Security::logout()` also checks the logout token. To skip this check, call `logout(false)`. In a custom authenticator, add `new CsrfTokenBadge('login', $token)` to the passport. To make this badge necessary for all authenticators of a firewall, set `required_badges: ['CsrfTokenBadge']`. A login with an authenticator that does not add this badge then fails. Entry points: `security.firewalls.<name>.form_login.enable_csrf`, `security.firewalls.<name>.logout.enable_csrf`, `security.firewalls.<name>.required_badges`, `Symfony\Component\Security\Http\Authenticator\Passport\Badge\CsrfTokenBadge`.
- **Stateless tokens:** For the token IDs in `stateless_token_ids`, `SameOriginCsrfTokenManager` needs no session, so you can cache the full page. If the request has a `Sec-Fetch-Site` header, its value must be `same-origin`. Otherwise, the `Origin` or `Referer` header must start with the origin of the application (scheme, host and port). If the request has none of these headers, only the double-submit check can accept the token. The other token IDs use the session. If the application is behind a reverse proxy, configure the trusted proxies. Entry points: `framework.csrf_protection.stateless_token_ids`, `Symfony\Component\Security\Csrf\SameOriginCsrfTokenManager`.
- **Stateless defaults in Flex applications:** The Flex recipe of `symfony/form` adds `config/packages/csrf.yaml`. This file sets `stateless_token_ids` to `submit`, `authenticate` and `logout`, and the form token ID to `submit`. So the CSRF tokens of your own form types, the login form and the logout are stateless. Entry point: `framework.form.csrf_protection.token_id`.
- **Double-submit check (optional):** For a stateless token ID, `csrf_token()` prints the cookie name (default `csrf-token`). On submit, JavaScript replaces this value with a random token and sets a cookie with the same token in its name. The server then compares the field with the cookie. `check_header: true` accepts the token in the cookie or in a header with the cookie name. A header with a wrong value always fails. `check_header: 2` (`SameOriginCsrfTokenManager::CHECK_ONLY_HEADER`) accepts only the header. When a session exists, the manager remembers which checks passed, and a later request without them fails. Entry points: `framework.csrf_protection.check_header`, `framework.csrf_protection.cookie_name`, `Symfony\Component\Security\Csrf\SameOriginCsrfListener` (after a stateless check, it removes the cookies in the response).
- **Double-submit JavaScript:** The Flex recipe of StimulusBundle adds `assets/controllers/csrf_protection_controller.js`. It handles a hidden field with `data-controller="csrf-protection"` or with the name `_csrf_token`. It is a lazy Stimulus controller, so the page must contain an element with `data-controller="csrf-protection"`. Symfony forms add this attribute to the `_token` field. Only for Turbo form submits, the script also sends the token in a header with the cookie name. If your JavaScript submits a form, call `form.requestSubmit()`. The script does not run when you call `form.submit()`. Entry point: `framework.form.csrf_protection.field_attr` (default `['data-controller' => 'csrf-protection']`).
- **Token storage:** `SessionTokenStorage` (service `security.csrf.token_storage`) keeps the stateful values in the Symfony session. Without HttpFoundation, `NativeSessionTokenStorage` uses the native PHP session (`$_SESSION`). SecurityBundle clears the stored tokens at logout and after each login (default `session_fixation_strategy: migrate`). `RedisSessionHandler` and `MemcachedSessionHandler` do not lock the session, so parallel requests can lose a token ("Invalid CSRF token"). Entry points: `Symfony\Component\Security\Csrf\TokenStorage\TokenStorageInterface`, `Symfony\Component\Security\Csrf\TokenStorage\ClearableTokenStorageInterface`.

## Entry points

- Type to autowire: `Symfony\Component\Security\Csrf\CsrfTokenManagerInterface` (service `security.csrf.token_manager`), with the value object `Symfony\Component\Security\Csrf\CsrfToken`.
- Other services: `Symfony\Component\Security\Csrf\TokenStorage\TokenStorageInterface` (`security.csrf.token_storage`), `Symfony\Component\Security\Csrf\TokenGenerator\TokenGeneratorInterface` (`security.csrf.token_generator`), `security.csrf.same_origin_token_manager` (`SameOriginCsrfTokenManager`), `security.csrf.same_origin_listener` (`SameOriginCsrfListener`).
- Without FrameworkBundle: `Symfony\Component\Security\Csrf\CsrfTokenManager`, `Symfony\Component\Security\Csrf\TokenGenerator\UriSafeTokenGenerator`, `Symfony\Component\Security\Csrf\TokenStorage\SessionTokenStorage`, `Symfony\Component\Security\Csrf\TokenStorage\NativeSessionTokenStorage`, `Symfony\Component\Security\Csrf\Exception\TokenNotFoundException`.
- Controller helpers: `Symfony\Bundle\FrameworkBundle\Controller\AbstractController::isCsrfTokenValid(string $id, ?string $token): bool`, `Symfony\Bundle\FrameworkBundle\Controller\ControllerHelper::isCsrfTokenValid()`.
- Attribute: `Symfony\Component\Security\Http\Attribute\IsCsrfTokenValid` (package `symfony/security-http`; arguments `id`, `tokenKey` (default `_token`), `methods`, `tokenSource`; repeatable).
- Passport badge: `Symfony\Component\Security\Http\Authenticator\Passport\Badge\CsrfTokenBadge`.
- Exceptions of a failed check: `Symfony\Component\Security\Core\Exception\InvalidCsrfTokenException` (attribute and login), `Symfony\Component\Security\Core\Exception\LogoutException` (logout). A form shows a form error.
- Config keys: `framework.csrf_protection.enabled`, `framework.csrf_protection.stateless_token_ids`, `framework.csrf_protection.check_header`, `framework.csrf_protection.cookie_name`.
- Form config keys: `framework.form.csrf_protection.enabled`, `framework.form.csrf_protection.token_id`, `framework.form.csrf_protection.field_name`, `framework.form.csrf_protection.field_attr`.
- Security config keys: `security.firewalls.<name>.form_login.enable_csrf`, `.csrf_parameter`, `.csrf_token_id`; `security.firewalls.<name>.logout.enable_csrf`, `.csrf_parameter`, `.csrf_token_id`, `.csrf_token_manager`; `security.firewalls.<name>.required_badges`.
- Form options: `csrf_protection`, `csrf_field_name`, `csrf_token_id`, `csrf_message`, `csrf_token_manager`. Form theme block prefix: `csrf_token` (for example `csrf_token_widget`).
- Twig functions: `csrf_token(tokenId)`. `logout_path()` and `logout_url()` add the logout token when `logout.enable_csrf` is on.
- Console commands: none.
- Test helpers: no CSRF assertion. For a stateful token ID in a `WebTestCase`, store a known value with `$client->getSession()->set('_csrf/<token ID>', $value)` and `save()`. Then submit `$value` as the token. For a stateless token ID, first request the page with the form. Then submit this form with the crawler, so that the client sends a same-origin `Referer` header.

## Symbiotic packages

- [Form](../packages/form.md): Form adds a hidden `_token` field to each root form and checks it with the token manager of this package.
- [Twig Bridge](../packages/twig-bridge.md): The bridge gives the `csrf_token()` Twig function for plain HTML forms, and `logout_path()`, which adds the logout token.
- [FrameworkBundle](../packages/framework-bundle.md): FrameworkBundle registers the token manager, the storage and the stateless manager from `framework.csrf_protection`, and gives `isCsrfTokenValid()` to controllers.
- [Security](../packages/security-bundle.md): SecurityBundle requires this package, registers the `#[IsCsrfTokenValid]` listener and checks the login and logout tokens; the attribute and `CsrfTokenBadge` come from `symfony/security-http`.
- [HttpFoundation](../packages/http-foundation.md): The stateful tokens live in the session, and the stateless manager reads the `Sec-Fetch-Site`, `Origin` and `Referer` headers of the `Request`.
- [HttpKernel](../packages/http-kernel.md): The `#[IsCsrfTokenValid]` listener runs before the controller and uses `ControllerArgumentsEvent::evaluate()` for an `Expression` or closure ID.
- [ExpressionLanguage](../packages/expression-language.md): Install it when the token ID of `#[IsCsrfTokenValid]` is an `Expression`.
- [StimulusBundle](../packages/stimulus-bundle.md): Its Flex recipe adds `csrf_protection_controller.js`, the JavaScript part of the stateless double-submit check.
- [UX Live Component](../packages/ux-live-component.md): Live component actions use no CSRF token. They rely on request headers and the same-origin and CORS rules of the browser.
- [FrameworkBundle test tools](../packages/framework-bundle-testing.md): `$client->getSession()` stores a known token before a form submit in a functional test.

## Changed in 8.0/8.1

- Calls to `SameOriginCsrfTokenManager::onKernelResponse()`, `clearCookies()` or `persistStrategy()` (deprecated in 8.1) -> `SameOriginCsrfListener` on `kernel.response` (service `security.csrf.same_origin_listener`). It clears the cookies and stores the check strategy in the session.
- A string or an `Expression` as the `#[IsCsrfTokenValid]` ID -> 8.1 also accepts a closure, and expressions also get `this` (the controller).
- A token read by hand from the query string or a header -> the `tokenSource` argument of `#[IsCsrfTokenValid]` (7.4 and 8.0).
- Only `Origin` and `Referer` checks for stateless tokens -> `SameOriginCsrfTokenManager` checks `Sec-Fetch-Site` first (7.4 and 8.0).
- `methods: ['GET']` that did not check `HEAD` requests -> `GET` in `methods` also covers `HEAD` (security fix CVE-2026-45075 in 8.0.12 and 8.1.0).

## Docs

- https://symfony.com/doc/current/security/csrf.html
- https://symfony.com/doc/current/reference/configuration/framework.html
- https://symfony.com/doc/current/reference/configuration/security.html
- https://symfony.com/doc/current/reference/twig_reference.html
- https://symfony.com/doc/current/reference/attributes.html
- https://symfony.com/doc/current/security.html
- https://symfony.com/doc/current/security/custom_authenticator.html
- https://symfony.com/doc/current/forms.html
- https://symfony.com/doc/current/form/form_customization.html
- https://symfony.com/doc/current/controller.html
- https://symfony.com/doc/current/session.html
- https://symfony.com/doc/current/testing.html
- https://symfony.com/doc/current/deployment/proxies.html
- https://symfony.com/doc/current/http_cache/esi.html
- https://symfony.com/bundles/ux-live-component/current/index.html
