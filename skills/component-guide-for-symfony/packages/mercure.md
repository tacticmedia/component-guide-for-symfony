# Mercure (`symfony/mercure`, `symfony/mercure-bundle`)

**Applies to:** symfony/mercure 0.9, MercureBundle 0.6, Symfony UX 3.5

**Elevator pitch:** Use when the server must push live updates, such as new data, chat messages or alerts, to many browsers without polling or WebSockets. A Mercure hub holds the Server-Sent Events connections and supports private updates. For a few connections, see [HttpFoundation](http-foundation.md).

**Details:** [../details/mercure.md](../details/mercure.md)

## Why it exists

Server-Sent Events keep an HTTP connection open for each client, and each open connection uses server memory and connection capacity. The package moves these connections to a dedicated Mercure hub. The application posts each update to the hub, and the hub pushes it to the subscribers. The protocol adds authorization, automatic reconnection with the retrieval of lost updates, and discovery of the hub through an HTTP Link header.

## When to use it

- Push a change of a resource to all browsers that show this resource.
- Tell a user that an asynchronous job is complete.
- Build a chat or another page that many users change at the same time.
- Send a private update that only subscribers with a matching JWT receive.
- Let API clients find the hub URL in a Link response header.
- Update the open pages with new HTML when a database record changes, with [UX Turbo](ux-turbo.md).
- Send updates to many concurrent Server-Sent Events clients, when one open PHP connection for each client uses too many server resources.
- Publish updates from a background worker or a command-line command.

## Use it instead of

- `setInterval(() => fetch('/books/1'), 5000)` to find changes -> `$hub->publish(new Update('https://example.com/books/1', $json))` on the server and `new EventSource("{{ mercure('https://example.com/books/1')|escape('js') }}")` in the page.
- A controller loop such as `while (true) { echo "data: $json\n\n"; flush(); sleep(1); }` for many clients -> `HubInterface::publish()`; the hub holds the connections.
- A separate WebSocket server and client code only to push server events -> a Mercure hub, `Update` and the browser `EventSource`.
- A JWT signed by hand with the payload `['mercure' => ['publish' => ['*']]]`, plus `$httpClient->request('POST', $hubUrl, ['body' => ['topic' => $topic, 'data' => $json]])` -> `mercure.hubs.<name>.jwt.secret` with `jwt.claims`, and `HubInterface::publish()`.
- A hub URL built by hand, such as `'https://example.com/.well-known/mercure?topic='.urlencode($topic)` -> `{{ mercure(topic) }}` in Twig, which uses the public URL and the query parameter of the configured protocol.
- `$response->headers->setCookie(Cookie::create('mercureAuthorization', $jwt))` -> `Authorization::setCookie($request, $grants)`, or `{{ mercure(topic, {subscribe: topic}) }}` in Twig.
- A hub URL that is hard-coded in JavaScript or in an API field -> `Discovery::addLink($request)` and a client that reads the `Link` header.
- A test that sends updates to a real hub -> `MockHub` with a callable, or a `HubInterface` stub as the service `mercure.hub.default`.
- A Doctrine listener that renders a template and calls `$hub->publish()` -> `#[Broadcast]` of UX Turbo.
