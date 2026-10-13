# Symfony UX Notify (`symfony/ux-notify`)

**Applies to:** Symfony UX 3.5

**Elevator pitch:** Use when the server must push a native desktop notification in real time to users who have the page open in a browser. PHP code sends a message through a Mercure hub, and a script in the page shows it with the Notifications API of the browser. For flash messages in the page, see [Notifier](notifier.md).

**Details:** [../details/ux-notify.md](../details/ux-notify.md)

## Why it exists

To show a native notification for a server event, an application needs a push connection, a message format and a permission request. The package connects the Mercure chat channel of [Notifier](notifier.md) to the Notifications API of the browser. Its JavaScript subscribes to Mercure topics and shows each message as a native notification.

## When to use it

- Show a desktop notification to all users with the page open, for example to announce a flash sale.
- Send a native browser notification from a command-line script, a web request or a queue worker.
- Replace a JavaScript polling loop that asks the server for new alerts.
- Add a body, an icon or a tag to a native notification from PHP.
- Subscribe a Twig page to one or more Mercure topics that carry notifications.
- Add custom JavaScript behavior to the event sources that receive the notifications.
- Read the notifications from a Mercure hub other than the default hub.

## Use it instead of

- `new EventSource(hubUrl + '?topic=' + topic)` with `onmessage = (e) => new Notification(JSON.parse(e.data).title)` in a custom script -> `{{ stream_notifications(['/chat/flash-sales']) }}` and the `@symfony/ux-notify/notify` controller.
- `if ('Notification' in window)` and `Notification.requestPermission().then(...)` in your own JavaScript -> the controller, which checks the support and asks for permission when a message arrives.
- `$hub->publish(new Update('/alerts', json_encode(['title' => $title, 'body' => $body])))` with your own payload format -> `$chatter->send(new ChatMessage($title, new MercureOptions(['/alerts'], false, null, null, null, ['body' => $body])))`.
- `setInterval(() => fetch('/notifications/unread'), 5000)` in JavaScript -> a Mercure push with `ChatterInterface::send()` to the topics of `stream_notifications()`.
- A custom Stimulus controller that gets `mercure('https://example.com/alerts')` as a value and calls `new Notification()` -> `{{ stream_notifications('https://example.com/alerts') }}`.
