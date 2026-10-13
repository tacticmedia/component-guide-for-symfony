# ExpressionLanguage (`symfony/expression-language`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- Evaluation: the engine parses the expression, then evaluates its nodes with the values that you give. A variable name that is not a key of the values causes a `SyntaxError`, except directly before `??`. Entry point: `ExpressionLanguage::evaluate(Expression|string $expression, array $values = [])`.
- Compilation: the engine returns PHP source code for the expression. Symfony writes this code into the compiled URL matcher and the dumped container, so these expressions run as plain PHP. To use another variable name in the compiled code, add `'php_name' => 'expression_name'` to `$names`. Entry point: `ExpressionLanguage::compile(Expression|string $expression, array $names = [])`.
- Parser cache: the engine keeps each parsed expression in a PSR-6 pool. The default pool is an in-memory `ArrayAdapter`. If many requests use the same expressions, give a persistent pool. `parse()` returns a `ParsedExpression` that `evaluate()` and `compile()` use without a new parse. `SerializedParsedExpression` calls `unserialize()`, so use it only with trusted data. Entry point: `new ExpressionLanguage(?CacheItemPoolInterface $cache = null, iterable $providers = [])`.
- Linting: the engine checks the syntax and the names, and throws a `SyntaxError` with the position and a "Did you mean" hint. The flags `Parser::IGNORE_UNKNOWN_VARIABLES` and `Parser::IGNORE_UNKNOWN_FUNCTIONS` turn off the name checks. Entry point: `ExpressionLanguage::lint(Expression|string $expression, array $names, int $flags = 0)`.
- Literals and access: strings, numbers (`1_000`, `.5`, `1e3`), arrays `[1, 2]`, hashes `{ key: 'value' }`, `true`, `false`, `null` and `/* comments */`. Use `.` for public properties and methods, and `[]` for array keys. Use `?.` and `?.[]` for null-safe access, and `??` for a default value. Entry point: `Symfony\Component\ExpressionLanguage\Parser`.
- Operators: arithmetic (`+ - * / % **`), bitwise (`& | ^ ~ << >>`) and comparison (`== === != !== < > <= >=`). Other binary operators are `matches` (regular expression), `contains`, `starts with`, `ends with`, `in` and `not in` (strict comparison), `..` (range) and `~` (concatenation). The logical operators are `not ! and && or || xor`. The ternaries are `a ? b : c`, `a ?: b` and `a ? b`, which gives `null` when `a` is false. Entry point: the operator tables and `parseConditionalExpression()` in `Parser`.
- Built-in functions: `constant()`, `enum()`, `min()` and `max()`. `constant()` can read every PHP constant. If your constants contain secrets, do not let untrusted users write expressions. Entry point: `ExpressionLanguage::registerFunctions()`.
- Custom functions: a function has a compiler callable and an evaluator callable. The evaluator gets the values array as its first argument. `ExpressionFunction::fromPhp('strtoupper')` wraps a PHP function. Register all functions before the first `lint()`, `parse()`, `evaluate()` or `compile()` call. A later registration can throw a `\LogicException`. Entry points: `ExpressionLanguage::register()`, `ExpressionLanguage::addFunction()`.
- Function providers: a provider groups functions for reuse. Give providers to the constructor (any iterable) or to `registerProvider()`. In a Symfony application, tag the provider service with `security.expression_language_provider` or `routing.expression_language_provider`. No autoconfiguration adds these tags. The security tag adds the functions only to the expression voter, not to workflow guards or controller attribute options. Entry point: `ExpressionFunctionProviderInterface::getFunctions()`.
- Security rules: `allow_if` in `access_control`, and `new Expression(...)` in `isGranted()` or `#[IsGranted]`, go to the expression voter. Variables: `user`, `role_names`, `object` and `subject` (the same value), `token`, `trust_resolver`, and `request` in `allow_if`. Functions: `is_authenticated()`, `is_fully_authenticated()`, `is_remember_me()`, `is_granted()`. If an `access_control` entry has both `roles` and `allow_if`, the default strategy grants access when one of them is true. Entry point: `Symfony\Component\Security\Core\Authorization\Voter\ExpressionVoter`.
- Controller attributes: some attribute options accept an `Expression`, which gets the variables `request`, `args` (the controller arguments by name) and `this` (the controller). These options are the `#[IsGranted]` subject, the `#[IsCsrfTokenValid]` token ID and the `#[RateLimit]` key. Other options are `lastModified`, `etag` and `if` of `#[Cache]`, and `validationGroups` of `#[MapRequestPayload]` and `#[MapQueryString]`. Only `#[Cache]` reads a plain string as an expression, and it also gives the request attributes as variables. By default, the engines for these options know only the built-in functions, so `is_granted()` and custom functions are not available. If the rule is fixed PHP code and you use PHP 8.5 or higher, give a `static` closure instead. The closure gets the arguments array, the request and the controller, in this order. Entry point: `ControllerEvent::evaluate()`.
- Entity lookup: `#[MapEntity(expr: 'repository.find(product_id)')]` fetches a controller argument with an expression. The variables are `repository`, the request attributes (route parameters) and `request`. In a console command argument (8.1), the variables are `repository`, the input arguments and options by input name, and `input`. If an input name has a hyphen, use `input.getArgument("user-id")` or `input.getOption("user-id")`. Entry point: `Symfony\Bridge\Doctrine\Attribute\MapEntity`.
- Service container: in YAML, a string that starts with `@=` is an expression. In PHP configuration, use `expr()`. In a class, use `#[Autowire(expression: '...')]`. The functions are `service()`, `parameter()`, `env()` and, in factory expressions, `arg()`. The variable `container` gives the container. Parameters cannot contain expressions. Entry point: `Symfony\Component\DependencyInjection\Attribute\Autowire`.
- Route conditions: the `condition` option holds an expression with the variables `context`, `request` and `params`, and the functions `env()` and `service()`. To call your service with `service('alias')`, add `#[AsRoutingConditionService(alias: 'alias')]` to its class. URL generation ignores conditions. Entry point: `Symfony\Component\Routing\Attribute\Route::$condition`.
- Validation and workflow guards: `Assert\Expression` adds a violation when the expression is false (`negate: false` reverses it). `Assert\When` applies `constraints` when the expression is true, else `otherwise`. Both get the variables `this`, `value`, `context` and your `values`. In a Symfony application, both can also call `is_valid()`. `Assert\ExpressionSyntax` checks that a string property is a valid expression. By default, its validator knows only the built-in functions, so a call to a custom function fails the check. The `service` option selects another validator. A workflow `guard` blocks a transition when its expression is false. Entry points: `Symfony\Component\Validator\Constraints\Expression`, `framework.workflows.<name>.transitions[].guard`.

## Entry points

- `Symfony\Component\ExpressionLanguage\ExpressionLanguage`: the engine. No bundle registers an autowiring alias for it, so create it with `new ExpressionLanguage($cachePool, $providers)` or define your own service.
- Without FrameworkBundle: create `new ExpressionLanguage($cachePool, $providers)`, then call `evaluate()`, `compile()`, `parse()` or `lint()`.
- `Symfony\Component\ExpressionLanguage\Expression`: wraps a string to mark it as an expression in attributes and in `isGranted()`.
- `Symfony\Component\ExpressionLanguage\ExpressionFunction` and `ExpressionFunction::fromPhp()`: one custom function.
- `Symfony\Component\ExpressionLanguage\ExpressionFunctionProviderInterface`: a group of custom functions.
- `Symfony\Component\ExpressionLanguage\Parser::IGNORE_UNKNOWN_VARIABLES`, `Parser::IGNORE_UNKNOWN_FUNCTIONS`: flags for `lint()` and `parse()`.
- `Symfony\Component\ExpressionLanguage\SyntaxError`: the exception for an invalid expression (a `\LogicException`).
- `Symfony\Component\ExpressionLanguage\ParsedExpression`, `SerializedParsedExpression`: parsed expressions for reuse.
- Config key `security.access_control[].allow_if` (SecurityBundle).
- Config key `framework.workflows.<name>.transitions[].guard` (FrameworkBundle).
- Route option `condition`: `#[Route(condition: '...')]`, or `condition` in YAML or PHP route configuration.
- Service configuration: the `@=` prefix in YAML, `expr()` in PHP configuration, `factory: '@=...'`.
- `#[Symfony\Component\DependencyInjection\Attribute\Autowire(expression: '...')]`
- `#[Symfony\Component\Security\Http\Attribute\IsGranted]` (attribute and subject accept `Expression`)
- `#[Symfony\Component\Security\Http\Attribute\IsCsrfTokenValid]` (the token ID accepts `Expression`)
- `#[Symfony\Component\HttpKernel\Attribute\Cache]` (`lastModified`, `etag`, `if`)
- `#[Symfony\Component\HttpKernel\Attribute\RateLimit]` (`key`)
- `#[Symfony\Component\HttpKernel\Attribute\MapRequestPayload]`, `#[Symfony\Component\HttpKernel\Attribute\MapQueryString]` (`validationGroups`)
- `#[Symfony\Bridge\Doctrine\Attribute\MapEntity(expr: '...')]`
- `#[Symfony\Bundle\FrameworkBundle\Routing\Attribute\AsRoutingConditionService]` (tag `routing.condition_service`)
- Constraints `Symfony\Component\Validator\Constraints\Expression`, `When`, `ExpressionSyntax`
- Service tags `security.expression_language_provider`, `routing.expression_language_provider`
- `Symfony\Component\HttpKernel\Event\ControllerEvent::evaluate($value, $expressionLanguage)` and `ControllerArgumentsEvent::evaluate()`: evaluate an `Expression` or `\Closure` of a custom controller attribute.
- `Symfony\Component\HttpKernel\Event\ControllerAttributeEvent::evaluate($value)`: in a listener for one attribute class, evaluates with the `controller.expression_language` service when you give no engine.
- `Symfony\Component\HttpFoundation\RequestMatcher\ExpressionRequestMatcher`: matches a request with an expression.
- Twig function `expression('...')`: creates an `Expression` object (no evaluation), for example for `is_granted(expression('...'))`.
- Console command `router:match /path`: shows which route matches, and evaluates route conditions with the routing providers.
- Console command `server:log --filter="level > 200 or channel in ['app']"` (Monolog Bridge, registered by DebugBundle): receives the logs of a `server_log` Monolog handler and shows only the records that match. The variables are the keys of a log record, for example `level`, `channel` and `message`.

## Symbiotic packages

- [Security](../packages/security-bundle.md): `allow_if`, `isGranted(new Expression(...))` and `#[IsGranted(new Expression(...))]` evaluate expressions with `is_granted()` and the other security functions; for complex rules, write a voter.
- [Routing](../packages/routing.md): the `condition` option of a route is an expression that the compiled URL matcher runs as plain PHP.
- [DependencyInjection](../packages/dependency-injection.md): `@=`, `expr()` and `#[Autowire(expression: ...)]` compute service arguments and factories, and the dumped container holds the compiled PHP.
- [Validator](../packages/validator.md): `Assert\Expression`, `Assert\When` and `Assert\ExpressionSyntax` use expressions for cross-property rules, conditional constraints and syntax checks.
- [Workflow](../packages/workflow.md): the `guard` option of a transition is an expression that blocks the transition when it is false.
- [HttpKernel](../packages/http-kernel.md): `#[Cache]`, `#[RateLimit]` and `#[MapRequestPayload]` evaluate expressions, and your own controller attributes can use `ControllerEvent::evaluate()` as `#[RateLimit]` does.
- [FrameworkBundle](../packages/framework-bundle.md): registers the `controller.expression_language` and `validator.expression_language` services, each with a `cache.system` pool. It also registers the engine for workflow guards (with the default in-memory pool) and the function provider for route conditions.
- [Cache](../packages/cache.md): a required dependency; `ArrayAdapter` is the default pool for parsed expressions, and any PSR-6 pool can replace it.
- [Doctrine Bridge](../packages/doctrine-bridge.md): `#[MapEntity(expr: ...)]` fetches an entity with an expression that uses the `repository` variable.
- [Twig Bridge](../packages/twig-bridge.md): the `expression()` Twig function creates an `Expression` for `is_granted()` in a template.
- [Security CSRF](../packages/security-csrf.md): `#[IsCsrfTokenValid(new Expression('"delete-item-" ~ args["post"].getId()'))]` computes one token ID for each object.
- [RateLimiter](../packages/rate-limiter.md): `#[RateLimit('limiter', key: new Expression('request.request.get("email")'))]` builds the limiter key from the request.
- [HttpFoundation](../packages/http-foundation.md): `ExpressionRequestMatcher` matches a request with the variables `request`, `method`, `path`, `host`, `ip` and `attributes`.
- [Form](../packages/form.md): in the `constraints` option of a form field, `Assert\When` with `this.getParent()` reads the value of another field.
- [Monolog Bridge](../packages/monolog-bridge.md): the `server:log --filter` option shows only the log records that match an expression.
- [JsonPath](../packages/json-path.md): often confused; JsonPath queries JSON documents with RFC 9535 JSONPath expressions and does not use ExpressionLanguage.

## Changed in 8.0/8.1

- 8.0: `$expressionLanguage->lint($expression, null)` -> `$expressionLanguage->lint($expression, [], Parser::IGNORE_UNKNOWN_VARIABLES)`. The constant is on `Parser`, not on `ExpressionLanguage`.
- 8.0: `new Assert\Expression(['expression' => '...'])` (an options array) -> named arguments `new Assert\Expression(expression: '...')`. The same applies to `Assert\When`.
- 8.0: XML service configuration (`<argument type="expression">`) -> the `@=` prefix in YAML or `expr()` in PHP configuration.
- 8.1: `foo.getItems() ? foo.getItems()[0] : null` -> null-safe array access `foo.getItems()?.[0]`.
- 8.1: `#[Cache]` expressions get the `request` and `args` variables, and the new `if` option applies the attribute only when an expression is true.
- 8.1: a custom attribute listener that evaluates `Expression` values with its own code -> `$event->evaluate($value, $expressionLanguage)` on `ControllerEvent` or `ControllerArgumentsEvent`.
- 8.1: validation groups that the controller computes -> `#[MapRequestPayload(validationGroups: new Expression('args["user"].getType()'))]`. Do not put the `Expression` in an array.
- 8.1: a hand-written limiter call in the controller -> `#[RateLimit('per_account', key: new Expression('request.request.get("email")'))]`.

## Docs

- https://symfony.com/doc/current/expression_language.html
- https://symfony.com/doc/current/reference/formats/expression_language.html
- https://symfony.com/doc/current/security/expressions.html
- https://symfony.com/doc/current/security/access_control.html
- https://symfony.com/doc/current/routing.html
- https://symfony.com/doc/current/service_container.html
- https://symfony.com/doc/current/service_container/factories.html
- https://symfony.com/doc/current/service_container/autowiring.html
- https://symfony.com/doc/current/reference/constraints/Expression.html
- https://symfony.com/doc/current/reference/constraints/When.html
- https://symfony.com/doc/current/reference/constraints/ExpressionSyntax.html
- https://symfony.com/doc/current/workflow.html
- https://symfony.com/doc/current/controller.html
- https://symfony.com/doc/current/reference/events.html
- https://symfony.com/doc/current/http_cache/validation.html
- https://symfony.com/doc/current/http_cache/expiration.html
- https://symfony.com/doc/current/rate_limiter.html
- https://symfony.com/doc/current/security/csrf.html
- https://symfony.com/doc/current/doctrine.html
- https://symfony.com/doc/current/forms.html
- https://symfony.com/doc/current/components/http_foundation.html
- https://symfony.com/doc/current/reference/twig_reference.html
- https://symfony.com/doc/current/reference/dic_tags.html
- https://symfony.com/doc/current/reference/attributes.html
