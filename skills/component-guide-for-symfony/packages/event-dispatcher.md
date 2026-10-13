# EventDispatcher (`symfony/event-dispatcher`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when code must react to an action in the same process without a direct call, for example hooks, observers or before and after filters. The package calls each registered listener in priority order, and a listener can stop the others. Framework events cover requests, console commands, logins and emails. For queued or background work, see [Messenger](messenger.md).

**Details:** [../details/event-dispatcher.md](../details/event-dispatcher.md)

## Why it exists

Applications often must do more work when an action occurs, for example send an email and update statistics after an order. If the order code calls each reaction directly, the order code must change for each new reaction. With the package, the code dispatches an event object, and each registered listener runs in priority order, in the same process.

## When to use it

- Run extra code after an action, for example a notification after an order, without a change to the order code.
- Run code before and after each controller, for example a token check or a change to the response.
- Change the request, the response or the error response at one stage of the HTTP request cycle.
- Run code after the server sends the HTTP response to the client.
- React to framework events, for example a login, a logout, a console command or an outgoing email.
- Let other code change the arguments or the return value of a method without a subclass.
- Make a library or a reusable package extensible with events that other code can listen to.
- Use events in a console tool or a terminal UI without the full framework.
- Find which listeners run for an event, in which order and with which priority.

## Use it instead of

- `$this->mailer->send($email); $this->stats->increment('orders');` at the end of `OrderService::placeOrder()` -> dispatch an `OrderPlacedEvent` with `EventDispatcherInterface::dispatch()`, and add one `#[AsEventListener]` class for each reaction.
- A `$this->checkToken($request);` call at the top of each action, or `preExecute()` and `postExecute()` in a base controller -> `kernel.controller` and `kernel.response` listeners (`KernelEvents::CONTROLLER`, `KernelEvents::RESPONSE`).
- A home-made observer list: `$this->callbacks[] = $callback;` and `foreach ($this->callbacks as $callback) { $callback($data); }` -> `EventDispatcher::addListener()` and `dispatch()`.
- `usort($this->callbacks, fn ($a, $b) => $b['priority'] <=> $a['priority'])` -> the `priority` argument of `#[AsEventListener]` or of `addListener()`.
- A `$handled` flag that each callback checks first -> `$event->stopPropagation()`.
- `class LoggingOrderService extends OrderService` that overrides `placeOrder()` to change its result -> events that `placeOrder()` dispatches at its start and its end, with setters on the events.
- `fastcgi_finish_request()` and slow code after it in a controller -> a `kernel.terminate` listener (`KernelEvents::TERMINATE`). For retries or a queue, dispatch a Messenger message.
- `(new \ReflectionMethod($class, $method))->getAttributes(MyAttribute::class)` in a `kernel.controller_arguments` listener -> a listener for the `KernelEvents::CONTROLLER_ARGUMENTS.'.'.MyAttribute::class` event.
- `error_log()` calls in each callback to find out which callbacks ran -> `debug:event-dispatcher` and `TraceableEventDispatcher::getCalledListeners()`.
