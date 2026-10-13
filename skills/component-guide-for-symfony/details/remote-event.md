# RemoteEvent (`symfony/remote-event`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Split with Webhook.** `symfony/webhook` owns the HTTP side: the controller of the `/webhook/{type}` route, the request parsers, the signature check and outgoing webhooks. `symfony/remote-event` owns the event side: the `RemoteEvent` object, the payload converter interface, the consumers and their Messenger delivery. Webhook requires RemoteEvent. RemoteEvent requires Messenger, but not Webhook. Entry points: `Symfony\Component\Webhook\Client\RequestParserInterface` (Webhook) and `Symfony\Component\RemoteEvent\Consumer\ConsumerInterface` (RemoteEvent).
- **Event object.** A `RemoteEvent` holds a name, an ID and a payload array. Create it with `new RemoteEvent($name, $id, $payload)`. Read it with `getName()`, `getId()` and `getPayload()`. The class is not final, and the mailer and SMS events extend it. Entry point: `Symfony\Component\RemoteEvent\RemoteEvent`.
- **Consumer.** A consumer implements `consume(RemoteEvent $event): void`. Keep the parameter type `RemoteEvent`. Select the event class with `instanceof`. A narrower type, such as `AbstractMailerEvent` in the Mailomat bridge README, causes a PHP fatal error. Entry point: `Symfony\Component\RemoteEvent\Consumer\ConsumerInterface`.
- **Consumer attribute.** `#[AsRemoteEventConsumer('<routing name>')]` makes the class the consumer of one routing name under `framework.webhook.routing`. FrameworkBundle converts the attribute into the service tag `remote_event.consumer` with the tag attribute `consumer`. The class needs the attribute and the interface. If the attribute is missing, the handler throws a `LogicException` ("Unable to find a consumer") when an event arrives. If the interface is missing, the handler also throws a `LogicException`. Entry point: `Symfony\Component\RemoteEvent\Attribute\AsRemoteEventConsumer`.
- **One consumer for each routing name.** If two classes use the same name, only one of them receives the events, and no error occurs. The attribute is not repeatable. To use one class for two routing names, tag its service two times with `remote_event.consumer` and two different `consumer` values. Entry point: the service tag `remote_event.consumer`.
- **Messenger delivery.** For each parsed event, the webhook controller dispatches a `ConsumeRemoteEventMessage` with the routing name and the event. It uses the bus in `framework.webhook.message_bus` (default `messenger.default_bus`). The handler service `remote_event.messenger.handler` finds the consumer by the routing name and calls `consume()` directly. Thus, EventDispatcher listeners do not receive the event. Entry points: `Symfony\Component\RemoteEvent\Messenger\ConsumeRemoteEventMessage`, `Symfony\Component\RemoteEvent\Messenger\ConsumeRemoteEventHandler`.
- **Synchronous or asynchronous.** Without Messenger routing, the consumer runs during the webhook request. To run the consumer in a worker, route `ConsumeRemoteEventMessage` to an async transport. Then the controller sends its response (202 for parsers that extend `AbstractRequestParser`) before the consumer runs. Entry point: `framework.messenger.routing`.
- **Mailer events.** Twelve Mailer bridges convert provider callbacks into two final classes. The bridges are AhaSend, Brevo, Mandrill, MailerSend, Mailgun, Mailjet, Mailomat, Mailtrap, Postmark, Resend, SendGrid and Sweego. `MailerDeliveryEvent` has the names `received`, `dropped`, `delivered`, `deferred` and `bounce`, and the method `getReason()`. `MailerEngagementEvent` has the names `open`, `click`, `spam` and `unsubscribe`. Each provider uses a subset of these names. Both classes extend `AbstractMailerEvent`, which gives `getDate()`, `getRecipientEmail()`, `getMetadata()` and `getTags()`. Compare `getName()` with the class constants, for example `MailerDeliveryEvent::BOUNCE`. A bounce is a delivery event, not an engagement event. Entry points: `Symfony\Component\RemoteEvent\Event\Mailer\MailerDeliveryEvent`, `Symfony\Component\RemoteEvent\Event\Mailer\MailerEngagementEvent`.
- **Mailer events from your own converter.** If your code creates a mailer event, call `setDate()`. `getDate()` throws an `Error` if the event has no date. The other getters return an empty string or an empty array. Entry point: `Symfony\Component\RemoteEvent\Event\Mailer\AbstractMailerEvent::setDate()`.
- **SMS events.** Five Notifier bridges (LOX24, Smsbox, Sweego, Twilio, Vonage) return an `SmsEvent` with the name `delivered` or `failed`. `getRecipientPhone()` gives the phone number; it is empty for LOX24. For intermediate statuses, such as the Twilio statuses `queued` or `sent`, the Twilio, Vonage and LOX24 parsers return no event, and no consumer runs. For LOX24 event types other than `sms.delivery` and `sms.delivery.dryrun`, the parser returns a plain `RemoteEvent`. For Twilio, `TwilioOptions::webhookUrl()` sets the callback URL of one message. Entry point: `Symfony\Component\RemoteEvent\Event\Sms\SmsEvent`.
- **Several events in one request.** The Mandrill, Mailtrap and SendGrid parsers return a list of events. The consumer receives one `consume()` call for each event. Entry point: `RequestParserInterface::parse()` (Webhook), which returns `RemoteEvent|RemoteEvent[]|null`.
- **Payload converter.** `PayloadConverterInterface::convert(array $payload): RemoteEvent` maps a decoded payload to an event. If the payload is not valid, throw `ParseException`. In the request parser, convert it into a `RejectWebhookException` with the status 406, as the Mailer bridge parsers do. Type the converter argument of the parser with the concrete converter class, as `MailgunRequestParser` does. Entry points: `Symfony\Component\RemoteEvent\PayloadConverterInterface`, `Symfony\Component\RemoteEvent\Exception\ParseException`, the services `mailer.payload_converter.<provider>`.
- **Outgoing webhooks.** `SendWebhookMessage` (Webhook) takes a `Subscriber` and a `RemoteEvent`. By default, the event name goes into the `Webhook-Event` header, the ID into `Webhook-Id` and the JSON payload into the body. On the receiving Symfony application, the built-in `RequestParser` creates the same `RemoteEvent` again. Entry point: `Symfony\Component\Webhook\Messenger\SendWebhookMessage`.
- **Delivery without Webhook.** `ConsumeRemoteEventMessage` and its handler do not need `symfony/webhook`. Code can dispatch `new ConsumeRemoteEventMessage('<name>', $event)` on the bus to call the consumer `<name>`. The source allows this; the docs do not show it. Entry point: `Symfony\Component\Messenger\MessageBusInterface::dispatch()`.
- **Configuration and generator.** FrameworkBundle enables `framework.remote_event` by default if Composer installs `symfony/remote-event`, for example as a dependency of `symfony/webhook`. `php bin/console make:webhook <name>` (MakerBundle) creates a request parser and a consumer `App\RemoteEvent\<Name>WebhookConsumer` with the attribute. It also adds the routing name to `config/packages/webhook.yaml` with the placeholder secret `your_secret_here`. Replace that secret. Entry points: `framework.remote_event.enabled`, `make:webhook`.

## Entry points

- `Symfony\Component\RemoteEvent\RemoteEvent`: the event object (`getName()`, `getId()`, `getPayload()`).
- `Symfony\Component\RemoteEvent\Consumer\ConsumerInterface`: implement `consume(RemoteEvent $event): void`.
- `#[Symfony\Component\RemoteEvent\Attribute\AsRemoteEventConsumer('<routing name>')]`: on the consumer class (one name, not repeatable).
- `Symfony\Component\RemoteEvent\PayloadConverterInterface`: `convert(array $payload): RemoteEvent`.
- Event classes: `Symfony\Component\RemoteEvent\Event\Mailer\AbstractMailerEvent`, `Symfony\Component\RemoteEvent\Event\Mailer\MailerDeliveryEvent`, `Symfony\Component\RemoteEvent\Event\Mailer\MailerEngagementEvent`, `Symfony\Component\RemoteEvent\Event\Sms\SmsEvent`.
- Messenger: `Symfony\Component\RemoteEvent\Messenger\ConsumeRemoteEventMessage` (route it in `framework.messenger.routing`), `Symfony\Component\RemoteEvent\Messenger\ConsumeRemoteEventHandler`.
- Config: `framework.remote_event.enabled`. Related Webhook keys: `framework.webhook.routing.<routing name>.service`, `framework.webhook.routing.<routing name>.secret`, `framework.webhook.message_bus`.
- Service IDs and tag: `remote_event.messenger.handler`; the tag `remote_event.consumer` with the attribute `consumer`; `mailer.webhook.request_parser.<provider>`, `mailer.payload_converter.<provider>`, `notifier.webhook.request_parser.<provider>`.
- Exceptions (namespace `Symfony\Component\RemoteEvent\Exception`): `ExceptionInterface`, `ParseException`, `InvalidArgumentException`, `LogicException`, `RuntimeException`.
- Console: `make:webhook` (MakerBundle). The package has no console commands, no Twig functions and no test helpers.
- Tests: to test a consumer, create the event with its constructor and call `consume()`. To test a request parser, extend `Symfony\Component\Webhook\Test\AbstractRequestParserTestCase` (Webhook).

## Symbiotic packages

- [Webhook](../packages/webhook.md): Webhook owns the HTTP side (route, parsers, signatures, outgoing webhooks), and RemoteEvent owns the event object and its consumers.
- [Messenger](../packages/messenger.md): RemoteEvent requires Messenger. Each event reaches its consumer as a `ConsumeRemoteEventMessage`, which you can route to an async transport.
- [Mailer](../packages/mailer.md): Twelve Mailer bridges parse provider callbacks into `MailerDeliveryEvent` and `MailerEngagementEvent` objects with the parser services `mailer.webhook.request_parser.<provider>`.
- [Notifier](../packages/notifier.md): Five Notifier bridges parse SMS status callbacks into `SmsEvent` objects with the parser services `notifier.webhook.request_parser.<provider>`.
- [FrameworkBundle](../packages/framework-bundle.md): FrameworkBundle registers the handler service, converts `#[AsRemoteEventConsumer]` into the `remote_event.consumer` tag and supplies the webhook route file.
- [MakerBundle](../packages/maker-bundle.md): `make:webhook` generates a request parser, a consumer class with `#[AsRemoteEventConsumer]` and the routing configuration.
- [EventDispatcher](../packages/event-dispatcher.md): Use EventDispatcher for events inside your application and RemoteEvent for events that another system sends by webhook.

## Changed in 8.0/8.1

- 8.1.7 fixes the `framework.remote_event` node. Before 8.1.7, FrameworkBundle rejected any value for this node with an "Unrecognized option" error. Write `framework.remote_event.enabled`. The configuration reference page shows `remote-event`, and FrameworkBundle accepts that spelling as `remote_event`.
- 8.0 removes the fluent PHP configuration format. Thus, the `static function (FrameworkConfig $config)` examples on the Webhook page fail. Write YAML, or a PHP file in the namespace `Symfony\Component\DependencyInjection\Loader\Configurator` that returns `App::config(['framework' => ['messenger' => ['routing' => [ConsumeRemoteEventMessage::class => 'async']]]])`.
- 8.0 removes the `webhook.xml` route file. Import `@FrameworkBundle/Resources/config/routing/webhook.php`.
- 7.4/8.0: the LOX24 parser returns an `SmsEvent` for delivery reports and a plain `RemoteEvent` for other LOX24 event types. If you consume LOX24 events, handle both classes.

## Docs

- https://symfony.com/doc/current/webhook.html
- https://symfony.com/doc/current/reference/attributes.html
- https://symfony.com/doc/current/reference/configuration/framework.html
- https://symfony.com/doc/current/messenger.html
- https://symfony.com/doc/current/mailer.html
- https://symfony.com/doc/current/notifier.html
