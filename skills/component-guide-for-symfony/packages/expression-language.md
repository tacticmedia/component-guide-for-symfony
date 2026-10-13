# ExpressionLanguage (`symfony/expression-language`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when a rule must live outside PHP code, for example a business rule in a database or an access rule in a configuration file. It parses restricted one-line expressions with a syntax similar to PHP, then evaluates them or compiles them to PHP code. Route, access, workflow and validation rules also use it. For complex authorization logic, see [Security](security-bundle.md).

**Details:** [../details/expression-language.md](../details/expression-language.md)

## Why it exists

Some rules cannot be PHP code, for example access rules in configuration files, or discount rules that non-developers edit in a database. Code that runs such a string with eval can run any PHP code. The package parses one-line expressions with a syntax similar to PHP, then evaluates them or compiles them to PHP code. An expression can use only the variables and functions that you declare, so it is a restricted sandbox.

## When to use it

- Evaluate business rules that non-developers store in a database or a configuration file.
- Restrict access to a URL path with a condition on the request, the IP address or the user.
- Match a route only when a condition on the request or the route parameters is true.
- Inject a computed value, or select an implementation at runtime, with an expression in the dependency configuration.
- Validate an object with a one-line rule, or apply validation rules only when a condition is true.
- Block a workflow transition unless the user has a role or the subject is valid.
- Compute an option of a controller attribute at runtime from the request or the controller arguments.
- Check that a rule that a user enters is a valid expression before you save it.
- Filter log records in a terminal with a condition on the level, the channel or the message.

## Use it instead of

- `eval('return ' . $rule . ';')` on a rule string from the database -> `$expressionLanguage->evaluate($rule, ['order' => $order])`. It does not run the rule as PHP code, and it accepts only the variables that you give.
- A JSON rule format and a hand-written interpreter (`switch ($rule['op']) { case 'gt': ... }`) -> one rule string, for example `order.total > 100 and customer.group in ['vip']`, with `ExpressionLanguage::evaluate()`.
- `try { $expressionLanguage->evaluate($input); } catch (\Throwable) {}` to test a rule that a user enters -> `ExpressionLanguage::lint($input, ['order'])` or `#[Assert\ExpressionSyntax(allowedVariables: ['order'])]`.
- A `kernel.request` listener that checks `$request->getClientIp()` for one path and throws `AccessDeniedHttpException` -> an `access_control` entry with `allow_if: "'127.0.0.1' == request.getClientIp()"`.
- `if (!preg_match('/firefox/i', $request->headers->get('User-Agent'))) { throw $this->createNotFoundException(); }` in a controller -> `#[Route('/contact', condition: "request.headers.get('User-Agent') matches '/firefox/i'")]`.
- A factory class that only returns `$debug ? $traceableSender : $sender` -> `factory: '@=parameter("kernel.debug") ? service("traceable_newsletter") : service("newsletter")'`, or `expr()` in PHP configuration.
- A custom constraint and validator class for one cross-property rule -> `#[Assert\Expression("this.getCategory() in ['php', 'symfony'] or !this.isTechnicalPost()")]`.
- A `Callback` constraint with `if ($this->type === 'percent' && $this->value > 100)` -> `#[Assert\When(expression: 'this.getType() == "percent"', constraints: [new Assert\LessThanOrEqual(100)])]`.
- A workflow guard listener that calls `$event->setBlocked(true)` when `!$security->isGranted('ROLE_REVIEWER')` -> `guard: "is_granted('ROLE_REVIEWER')"` on the transition.
