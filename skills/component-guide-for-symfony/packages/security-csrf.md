# Security CSRF (`symfony/security-csrf`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when forms, delete buttons and logins that change data must block cross-site request forgery, also called CSRF. It creates and checks tokens in the session, or without a session with same-origin header checks, so you can cache the page. To add the token to forms automatically, see [Form](form.md).

**Details:** [../details/security-csrf.md](../details/security-csrf.md)

## Why it exists

A browser sends the session cookie with each request, also when a page on another site sends the request. So a malicious page can make a logged-in user change data in your application. The package gives each form a token that the other site cannot know, or it checks that the request comes from the same origin.

## When to use it

- Protect a plain HTML form, for example a delete button, against CSRF attacks.
- Check a CSRF token before a controller changes or deletes data.
- Protect the login form and the logout action against CSRF attacks.
- Add a CSRF check to custom login code.
- Cache pages that contain forms, with stateless CSRF tokens instead of session tokens.
- Read a CSRF token from a request header or from the query string.
- Create or check CSRF tokens in PHP code outside a controller or a template.
- Submit a form with a known CSRF token in a functional test.
- Protect the forms of a plain PHP application with tokens in the native PHP session.

## Use it instead of

- `bin2hex(random_bytes(32))` in `$_SESSION['csrf_token']`, a hidden field and a `hash_equals()` check in each action -> `{{ csrf_token('delete-item') }}` in the template and `#[IsCsrfTokenValid('delete-item', tokenKey: 'token')]` on the action.
- The same token check copied into each action of a controller -> one `#[IsCsrfTokenValid('the token ID')]` attribute on the controller class.
- A hidden token field added by hand to a Symfony form type -> the automatic `_token` field of each form (`csrf_protection` form option).
- A check of `$request->headers->get('Origin')` or `Referer` against `$request->getHost()` -> `framework.csrf_protection.stateless_token_ids` (`SameOriginCsrfTokenManager`).
- A hand-written double-submit cookie in JavaScript and a cookie comparison in PHP -> a stateless token ID (`framework.csrf_protection.stateless_token_ids`) with `csrf_protection_controller.js` of the StimulusBundle recipe.
- A per-item token from `hash_hmac('sha256', 'delete'.$id, $secret)` -> a token ID per item: `csrf_token('delete-item-' ~ post.id)` and `#[IsCsrfTokenValid(new Expression('"delete-item-" ~ args["post"].getId()'))]`.
- `$request->headers->get('X-CSRF-Token')` or `$request->query->get('token')` read by hand -> `#[IsCsrfTokenValid('api-call', tokenKey: 'X-CSRF-Token', tokenSource: IsCsrfTokenValid::SOURCE_HEADER)]`, or `SOURCE_QUERY` for the query string. The `tokenKey` is the header name or the query parameter name.
- A CSRF check inside `authenticate()` of a custom authenticator -> `new CsrfTokenBadge('login', $token)` in the passport (`CsrfTokenBadge`).
