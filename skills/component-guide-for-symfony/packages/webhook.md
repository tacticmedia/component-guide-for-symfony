# Webhook (`symfony/webhook`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when the application must receive webhook callbacks, such as email bounces, SMS delivery status or payment events, or send signed webhooks. It checks the signature, token or IP address of each request and turns it into an event object for your code. For the event objects and their consumers, see [RemoteEvent](remote-event.md).

**Details:** [../details/webhook.md](../details/webhook.md)

## Why it exists

Each webhook provider signs and formats its HTTP callbacks in a different way. Without this package, each provider needs its own controller, signature check and payload parser. The package gives one endpoint for all providers and built-in parsers for 12 email and 5 SMS providers. It also sends signed webhooks to subscriber URLs.

## When to use it

- Receive delivery, bounce, open and click events from Mailgun, SendGrid, Postmark, Brevo or another email provider.
- Receive SMS delivery status from Twilio, Vonage, Sweego, Smsbox or LOX24.
- Accept webhooks from a third-party API, such as a payment service, and verify their signature.
- Process incoming webhook events in a background worker instead of in the HTTP request.
- Send signed webhook notifications to subscriber URLs when an event occurs in the application.
- Retry a failed outgoing webhook from a background worker.
- Receive signed webhooks from another application that uses this package, and verify the signature header.
- Test a webhook parser with JSON fixture files.

## Use it instead of

- A controller with `#[Route('/payment-webhook', methods: ['POST'])]` that calls `json_decode($request->getContent(), true)` and compares `hash_hmac('sha256', $request->getContent(), $secret) == $signature` -> a class that extends `AbstractRequestParser`, compares with `hash_equals()` and has an entry in `framework.webhook.routing` (`Symfony\Component\Webhook\Client\AbstractRequestParser`).
- `if ('failed' === $payload['event-data']['event']) { ... }` in a Mailgun callback controller -> `service: mailer.webhook.request_parser.mailgun` and a consumer that checks `$event instanceof MailerDeliveryEvent` and `$event->getName()`. The Mailgun converter maps `failed` to `bounce`, `deferred` (temporary failure) or `dropped` (delivery codes 605, 606, 607 and 625).
- A Twilio status callback controller that rebuilds the `X-Twilio-Signature` HMAC-SHA1 check -> `service: notifier.webhook.request_parser.twilio` and a consumer for `Symfony\Component\RemoteEvent\Event\Sms\SmsEvent`.
- An `incoming_webhook` database table and a cron script that processes its rows -> `ConsumeRemoteEventMessage` routed to an async transport, and a `messenger:consume` worker.
- `$httpClient->request('POST', $url, ['json' => $payload, 'headers' => ['X-Signature' => hash_hmac('sha256', json_encode($payload), $secret)]])` -> `$bus->dispatch(new SendWebhookMessage(new Subscriber($url, $secret), new RemoteEvent($name, $id, $payload)))`.
- A `for` loop with `sleep()` that repeats a failed webhook request -> `SendWebhookMessage` routed to an async transport. Messenger retries a failed message 3 times by default.
- A hand-written HMAC check for webhooks from another Symfony application -> `service: Symfony\Component\Webhook\Client\RequestParser` with the same secret as the sender.
- A test that builds one `Request::create()` for each sample payload and asserts each field -> `AbstractRequestParserTestCase` with `Fixtures/*.json` files and `.php` expectation files.
