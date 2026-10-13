# Symfony UX Notify (`symfony/ux-notify`): details

**Applies to:** Symfony UX 3.5

## Key features and concepts

- **Send side (Notifier chat transport)**: The `symfony/mercure-notifier` bridge is a dependency of the bundle. It publishes each `ChatMessage` to a Mercure hub. Configure a chatter transport with the DSN `mercure://HUB_ID?topic=TOPIC` under `framework.notifier.chatter_transports`. `HUB_ID` is the name of a hub in `mercure.hubs`, for example `default`. The Flex recipe of the bridge adds `MERCURE_DSN=mercure://default` and a transport with the name `mercure`. Without a chatter transport, FrameworkBundle removes the `ChatterInterface` service. Entry point: `Symfony\Component\Notifier\ChatterInterface`.
- **Two ways to send**: Autowire `ChatterInterface` and send `new ChatMessage($subject, new MercureOptions($topics))`. If several chatter transports exist, call `->transport('mercure')` on the message. Without `transport()`, the first configured transport that supports the message sends it. As an alternative, send a `Notification` with the channel `chat/mercure` through `NotifierInterface`. In that case, the message has no `MercureOptions`, so the DSN topics apply and the browser shows only the subject. The `content()` of the notification does not reach the browser. To set `MercureOptions` in that case, implement `ChatNotificationInterface::asChatMessage()` on the notification class. If the application uses Messenger and `framework.notifier.message_bus` is `false`, this channel throws a `LogicException`.
- **Message payload and title**: `MercureTransport` publishes a JSON update with `summary` (the message subject) and `content` (the `MercureOptions` content). The controller uses `summary` as the notification title. If the subject is empty, the controller shows nothing.
- **Topics**: The first argument of `MercureOptions` sets the topics of one message (a string or a list). Without `MercureOptions`, or if its first argument is `null`, the transport uses the topics of the DSN. If the DSN has no topic, the transport uses `https://symfony.com/notifier`. `stream_notifications()` without arguments subscribes to the same default topic. Entry point: `Symfony\Component\Notifier\Bridge\Mercure\MercureOptions`.
- **Notification options**: The sixth constructor argument of `MercureOptions` holds the browser notification options. Its PHPDoc lists `badge`, `body`, `data`, `dir`, `icon`, `image`, `lang`, `renotify`, `requireInteraction`, `silent`, `tag`, `timestamp` and `vibrate`. The controller gives this array to the browser `Notification` constructor. The second to the fifth arguments set `private`, `id`, `type` and `retry` of the Mercure update. The UX Notify docs do not show this argument; the bridge README shows it.
- **`stream_notifications()` Twig function**: `stream_notifications(topics = [], options = {})` renders an empty `<div>` with the Stimulus controller `symfony--ux-notify--notify`. The `<div>` carries the topics and the public URL of the hub as Stimulus values. `topics` is a string or a list of strings. Call the function anywhere on each page that must show notifications. Entry point: `Symfony\UX\Notify\Twig\NotifyRuntime::renderStreamNotifications()`.
- **Public URL of the hub**: The browser connects to `HubInterface::getPublicUrl()` of the configured hub. This is the hub `public_url` (`MERCURE_PUBLIC_URL`), or the hub `url` if you do not set a public URL. If the application publishes to an internal URL, set `MERCURE_PUBLIC_URL` to a URL that browsers can reach.
- **Stimulus controller `@symfony/ux-notify/notify`**: For each topic, the controller opens one `EventSource` to the hub with a `topic` query parameter. On disconnect, it closes all its event sources. So, users get notifications only while the page is open. If the browser has no Notifications API, the controller logs a warning and shows nothing.
- **Permission request**: If the notification permission is `granted`, the controller shows the notification. If the permission is not `granted` and not `denied`, the controller asks for permission when a message arrives. If the permission is `denied`, the controller shows nothing.
- **Extension event `notify:connect`**: After it connects, the controller dispatches `notify:connect` on its element with `event.detail.eventSources`. The controller does not dispatch it if the browser has no Notifications API. To add behavior, write a Stimulus controller that listens to this event. Attach it with `stream_notifications(options = {'data-controller': 'mynotify'})`. The runtime reads only the `data-controller` key of `options`.
- **Bundle configuration**: `notify.mercure_hub` is the only option of the bundle. It holds the service ID of the hub that gives the public URL; the default is `mercure.hub.default`. MercureBundle registers each hub as the service `mercure.hub.<name>`. If your hub has another name, point `notify.mercure_hub` and the DSN `HUB_ID` to the same hub.
- **Assets**: With AssetMapper, the bundle adds its `assets/dist` directory to `framework.asset_mapper.paths` as `@symfony/ux-notify`. Flex adds the `notify` controller to `assets/controllers.json` (`enabled: true`, `fetch: eager`). With Webpack Encore, run `npm install --force` and restart Encore. Configure StimulusBundle in the application before you install the bundle.
- **Messenger**: If the application uses Messenger, the chatter and the `chat` channel dispatch each `ChatMessage` on the message bus. The bus handles the message synchronously, unless `framework.messenger.routing` sends `ChatMessage` to an async transport. If you route `ChatMessage` to an async transport, run a message consumer. If no message consumer runs, the browser shows no notification. If the application uses Messenger, do not set `framework.notifier.message_bus: false`. With this value, `ChatterInterface` sends directly, but the `chat` channel of `NotifierInterface` throws a `LogicException`. Entry point: `framework.notifier.message_bus`.
- **Public updates by default**: `MercureOptions` publishes a public update unless its second argument is `true`. For a private update, the subscriber must give the hub a JWT in a cookie or an `Authorization` header. `stream_notifications()` sets no JWT cookie. The controller creates each `EventSource` without options, so it does not set `withCredentials`.

## Entry points

- Twig function: `stream_notifications(topics = [], options = {})` (`Symfony\UX\Notify\Twig\NotifyExtension`, runtime `Symfony\UX\Notify\Twig\NotifyRuntime`).
- Config key: `notify.mercure_hub` (default `mercure.hub.default`), in `config/packages/notify.yaml`.
- Bundle class: `Symfony\UX\Notify\NotifyBundle` (Flex registers it).
- Stimulus controller: `@symfony/ux-notify/notify` from the npm package `@symfony/ux-notify`, with the values `hub` and `topics` and the event `notify:connect` (`detail.eventSources`).
- Send messages: autowire `Symfony\Component\Notifier\ChatterInterface`; use `Symfony\Component\Notifier\Message\ChatMessage` (`transport()`, `options()`) and `Symfony\Component\Notifier\Bridge\Mercure\MercureOptions`.
- Send notifications: `Symfony\Component\Notifier\NotifierInterface` with `Symfony\Component\Notifier\Notification\Notification` and the channel `chat/<transport name>`.
- Notifier config: `framework.notifier.chatter_transports` (DSN `mercure://HUB_ID?topic=TOPIC`, env `MERCURE_DSN`) and `framework.notifier.message_bus`.
- Mercure config: `mercure.hubs.<name>.url`, `public_url` and `jwt`; env `MERCURE_URL`, `MERCURE_PUBLIC_URL` and `MERCURE_JWT_SECRET`; hub service `mercure.hub.<name>` (`Symfony\Component\Mercure\HubInterface`).
- Tests: UX Notify has no test helper. `Symfony\Bundle\FrameworkBundle\Test\NotificationAssertionsTrait` (for example `assertNotificationCount()`, `assertNotificationSubjectContains()`) also sees chat messages. In the `test` environment, set the `mercure` chatter DSN to `null://null` to publish nothing to the hub. `NotificationAssertionsTrait` still sees the message. `Symfony\Component\Mercure\MockHub` replaces the hub in unit tests.

## Symbiotic packages

- [Notifier](../packages/notifier.md): Its Mercure chat transport (`symfony/mercure-notifier`, a dependency) publishes the `ChatMessage` that UX Notify shows. Do not confuse UX Notify with the Notifier `browser` channel (flash messages) or `desktop` channel (notifications on the server host).
- [Mercure](../packages/mercure.md): MercureBundle gives the hub service (`mercure.hub.default`) and its public URL, and the hub delivers each update to the browser over Server-Sent Events. UX Notify requires MercureBundle `^0.3.4|^0.4.1`.
- [StimulusBundle](../packages/stimulus-bundle.md): A required package; its `stimulus.helper` service renders the controller attributes, and it loads the `notify` controller from `assets/controllers.json`.
- [TwigBundle](../packages/twig-bundle.md): A required package; it registers the `stream_notifications()` function through the `twig.extension` and `twig.runtime` tags.
- [AssetMapper](../packages/asset-mapper.md): With AssetMapper, the bundle maps its controller files as `@symfony/ux-notify`, so the application needs no npm step.
- [WebpackEncoreBundle](../packages/webpack-encore-bundle.md): With Webpack Encore, run `npm install --force` and restart Encore after you install UX Notify.
- [Messenger](../packages/messenger.md): If the application uses Messenger, the chatter and the `chat` channel dispatch each `ChatMessage` on the bus. If you route `ChatMessage` to an async transport, run a message consumer. If the application uses Messenger, do not set `framework.notifier.message_bus: false`, because the `chat` channel then throws a `LogicException`.
- [Symfony UX Turbo](../packages/ux-turbo.md): Turbo also uses Mercure, but it broadcasts HTML updates into the page. Use Turbo to change page content; use UX Notify for a native notification outside the page.
- [Symfony UX Native](../packages/ux-native.md): UX Native wraps the web application in iOS and Android apps (Hotwire Native); it does not show browser notifications.
- [FrameworkBundle test tools](../packages/framework-bundle-testing.md): `NotificationAssertionsTrait` checks in a test that the application sent the chat message.

## Changed in 2.24 to 3.0

- 2.24: The controller gives the message `content` to the browser `Notification` as options. With the `content` argument of `MercureOptions` (Symfony 7.3 and later), a notification can have a body, an icon and other options.
- 3.0: PHP 8.4 and Symfony 7.4 are the minimum versions.
- 3.0: The bundle no longer supports the `StimulusTwigExtension` of WebpackEncoreBundle 1.x. Use StimulusBundle.

## Status

- UX Notify requires `symfony/mercure-bundle` `^0.3.4|^0.4.1`, a 0.x package. It does not install together with MercureBundle 0.5.0 or later.
- `Symfony\Component\Mercure\HubInterface`, which the Twig runtime uses, has the `@experimental` tag in `symfony/mercure`.
- Requirements: PHP 8.4 or later, Symfony 7.4 or 8.x, `symfony/stimulus-bundle`, `symfony/twig-bundle` and `symfony/mercure-notifier`.

## Docs

- https://symfony.com/bundles/ux-notify/current/index.html
- https://github.com/symfony/symfony/blob/8.1/src/Symfony/Component/Notifier/Bridge/Mercure/README.md
- https://symfony.com/doc/current/notifier.html
- https://symfony.com/doc/current/mercure.html
- https://symfony.com/bundles/StimulusBundle/current/index.html
