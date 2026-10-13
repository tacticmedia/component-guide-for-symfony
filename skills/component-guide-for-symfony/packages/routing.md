# Routing (`symfony/routing`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when URLs must map to controller code, or the application must build links that stay correct when a URL pattern changes. It handles URL parameters, slugs, enums, locales, subdomains and redirects. To sign URLs, see [HttpFoundation](http-foundation.md). For links to static files, see [Asset](asset.md).

**Details:** [../details/routing.md](../details/routing.md)

## Why it exists

An application must send each request to the correct controller. It must also create links that stay correct when a URL pattern changes. Hand-written regular expressions and concatenated URLs spread these rules through the code. The package matches the path, the HTTP method, the host and the scheme against named routes, and it generates URLs from route names.

## When to use it

- Connect a URL path to a controller method.
- Accept only valid values in a URL placeholder, for example digits, a slug, a UUID or a backed enum case.
- Load a database record from a URL value, and answer with a 404 when no record matches.
- Generate links and redirects from route names in controllers, PHP classes, HTML templates and command-line commands.
- Build absolute URLs outside a request, for example in an email that a background worker sends.
- Give each locale its own URL, path prefix or host.
- Match a route only for specified HTTP methods, hosts, environments or request conditions.
- Redirect an old URL to a new URL without controller code.
- Send a link that the receiver cannot change, or a link that expires.
- Load routes from a custom source, for example a database or a legacy application.
- Find the route that matches a URL, or list all routes.

## Use it instead of

- `preg_match('#^/blog/(\d+)$#', $_SERVER['REQUEST_URI'], $m)` or a `switch` on the path -> `#[Route('/blog/{id}', name: 'blog_show', requirements: ['id' => Requirement::DIGITS])]`.
- `'/blog/'.$post->getSlug()` or `sprintf('/blog/%s', $slug)` in PHP or Twig -> `$urlGenerator->generate('blog_show', ['slug' => $slug])` or Twig `path('blog_show', {slug: post.slug})`.
- `'https://'.$_SERVER['HTTP_HOST'].'/reset/'.$token` in an email or a command -> `generate('reset', ['token' => $token], UrlGeneratorInterface::ABSOLUTE_URL)`, plus `framework.router.default_uri` in a command and `framework.trusted_hosts` in a request.
- `if (!ctype_digit($id)) { throw $this->createNotFoundException(); }` -> a `requirements` entry or an inline requirement such as `{id<\d+>}`.
- `Status::tryFrom($request->attributes->get('status')) ?? throw new NotFoundHttpException()` -> a `Status $status` argument and `EnumRequirement`.
- `$repository->findOneBy(['slug' => $slug]) ?? throw $this->createNotFoundException()` -> `#[Route('/blog/{slug:post}')]` with a `BlogPost $post` argument.
- `if ('POST' !== $request->getMethod()) { return new Response('', 405); }` -> `#[Route(methods: ['POST'])]`.
- `$url.'&sig='.hash_hmac('sha256', $url, $secret)` plus a manual expiry check -> `$uriSigner->sign($url, new \DateInterval('PT1H'))` and `#[IsSignatureValid]`.
- A controller action that only returns `$this->redirect('/new-path')` -> a route with `RedirectController` and the `path` or `route` default.
- `if (str_starts_with($request->getPathInfo(), '/nl/')) { $request->setLocale('nl'); }` -> a `{_locale}` placeholder or a localized `path` array.
