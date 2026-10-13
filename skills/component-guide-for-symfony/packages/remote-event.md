# RemoteEvent (`symfony/remote-event`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when the application must react to webhook events, such as email bounces, opens and clicks, SMS delivery status or custom callbacks. It gives each event one shape and delivers it to your consumer class, at once or in a background worker. To receive and verify the HTTP request, see [Webhook](webhook.md).

**Details:** [../details/remote-event.md](../details/remote-event.md)

## Why it exists

A webhook from another system arrives as an HTTP request in a format that the provider defines. The package gives each event one shape: a name, an ID and a payload. It delivers each event to one consumer class for each webhook endpoint, during the request or in a background worker. Its email and SMS event classes give the same status names to all supported providers.

## When to use it

- Run code when an email provider reports a delivery, bounce, open, click, spam complaint or unsubscribe.
- Update the status of a sent SMS when Twilio, Vonage, LOX24, Smsbox or Sweego sends a status callback.
- Handle the webhooks of a payment service, a Git host or your own API in a dedicated consumer class.
- Process incoming webhook events in a background worker, not during the HTTP request.
- Convert a raw webhook payload into a named event with an ID in one reusable class.
- Receive the signed webhooks that another application sends with [Webhook](webhook.md).
- Describe the name, the ID and the payload of an outgoing webhook event.
- Send an event to its consumer from your own code, without an HTTP webhook.

## Use it instead of

- A controller that runs `json_decode($request->getContent(), true)` on a provider callback and updates the database in the same action -> a `ConsumerInterface` class with `#[AsRemoteEventConsumer('<routing name>')]`. A Webhook parser creates the `RemoteEvent` that it receives.
- Status strings for each provider, such as `'failed' === $payload['event-data']['event']` plus a `severity` check for Mailgun -> the constants `MailerDeliveryEvent::BOUNCE`, `::DEFERRED` and `::DROPPED`, compared with `$event->getName()`.
- `$request->request->get('MessageStatus')` checks in a Twilio status callback -> `SmsEvent::DELIVERED` and `SmsEvent::FAILED`, plus `$event->getRecipientPhone()`.
- A table of raw callbacks plus a cron command that processes them later -> `ConsumeRemoteEventMessage` routed to an async Messenger transport.
- A `switch ($provider)` in one controller that calls a different service for each provider -> one consumer class for each routing name, selected by `#[AsRemoteEventConsumer('<routing name>')]`.
- A mapping function in the controller that turns an external payload into your own event array -> a `PayloadConverterInterface` class that returns a `RemoteEvent`.
- `$dispatcher->dispatch(new PaymentWebhookEvent($payload))` with an EventDispatcher listener for incoming webhooks -> a RemoteEvent consumer, which Messenger can run in a worker.
