# FrameworkBundle (`symfony/framework-bundle`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when you start a full PHP web application or API that needs one place for configuration, controller helpers and maintenance commands. It connects the installed packages and reads their settings. Its encrypted secrets vault keeps API keys out of plain-text environment files. For a command-line tool without HTTP, see [DependencyInjection](dependency-injection.md).

**Details:** [../details/framework-bundle.md](../details/framework-bundle.md)

## Why it exists

Each package works alone, but an application needs one place that reads the configuration, builds the shared objects and starts the application. Without it, each project writes this wiring code by hand. The package reads one configuration tree and sets up each installed package from it. It also adds a base controller, an encrypted secrets vault and command-line tools for cache and debug tasks.

## When to use it

- Start a web application or API with one application class and one configuration directory.
- Keep API keys and passwords in an encrypted vault that you can commit to Git.
- Return HTML, JSON, redirects and file downloads from a controller with short helper methods.
- Turn on a feature such as routing, sessions, email or background jobs with one configuration key.
- Allow only a fixed list of environment names, for example prod, dev and test.
- Clear and warm up the cache when you deploy a new release.
- Find a route, an event listener, a configuration value or an object in the dependency injection container with a command-line command.
- Run the command-line commands of the application with an environment option and a debug option.
- Redirect an old URL or show a static page from the route configuration, without a controller class.
- Cache full HTTP responses with a reverse proxy in PHP when you cannot install a separate reverse proxy server.

## Use it instead of

- `$stripeKey = 'sk_live_...';` in code, or `STRIPE_KEY=sk_live_...` in a committed `.env` file -> `php bin/console secrets:set STRIPE_KEY`, then `%env(STRIPE_KEY)%` (`framework.secrets`).
- `header('Location: /login'); exit;` -> `return $this->redirectToRoute('login');` (`AbstractController::redirectToRoute()`).
- `new Response(json_encode($data), 200, ['Content-Type' => 'application/json'])` -> `return $this->json($data);` (`AbstractController::json()`).
- `$_SESSION['flash'][] = 'Saved.';` -> `$this->addFlash('success', 'Saved.');` (`AbstractController::addFlash()`).
- `http_response_code(404); echo 'Not found'; exit;` -> `throw $this->createNotFoundException();` (`AbstractController::createNotFoundException()`).
- `if (!in_array('ROLE_ADMIN', $user->getRoles(), true)) { http_response_code(403); exit; }` -> `$this->denyAccessUnlessGranted('ROLE_ADMIN');` (`AbstractController::denyAccessUnlessGranted()`).
- A controller method that only does `return new RedirectResponse('/new-page', 301);` -> a route with `controller: Symfony\Bundle\FrameworkBundle\Controller\RedirectController` and the defaults `path: /new-page` and `permanent: true` (`RedirectController`).
- `rm -rf var/cache/*` in a deploy script -> `APP_ENV=prod APP_DEBUG=0 php bin/console cache:clear`, which also warms up the cache (`cache:clear`).
- `grep -rn "'/blog'" src/ config/` to find the controller of a URL -> `php bin/console router:match /blog` (`router:match`, `debug:router`).
- `$ip = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'];` behind a load balancer -> set `framework.trusted_proxies` and `framework.trusted_headers`, then call `$request->getClientIp()` (`framework.trusted_proxies`).
