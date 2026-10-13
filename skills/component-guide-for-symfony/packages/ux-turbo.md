# Symfony UX Turbo (`symfony/ux-turbo`)

**Applies to:** Symfony UX 3.5

**Elevator pitch:** Use when link clicks and form submits must update a page without a full reload, or the server must push HTML changes to open pages. It integrates Hotwire Turbo: HTML from the server replaces pages or parts of pages, with no custom JavaScript. It also broadcasts Doctrine entity changes through Mercure. For a stateful widget, see [UX Live Component](ux-live-component.md).

**Details:** [../details/ux-turbo.md](../details/ux-turbo.md)

## Why it exists

A server-rendered page reloads completely on each link click and form submit. It also does not show the changes that other users make. By hand, each partial update needs JavaScript that fetches HTML and changes the DOM. The package integrates Hotwire Turbo, so links, forms and server pushes update the page in place with HTML from Twig templates.

## When to use it

- Make link clicks and form submits update the page without a full reload.
- Replace only one part of a page, or load one part of a page lazily from its own URL.
- Answer a form submit or a delete request with a partial page update. For example, append, replace or remove one element.
- Push HTML updates to all connected browsers in real time, for example for a chat or a live task list.
- Broadcast each insert, update and delete of a Doctrine entity to every open page that shows it.
- Send a smaller response when the request asks for one part of a page only.
- Control the client-side page cache, the page preview, a forced full reload and the refresh method from a Twig template.

## Use it instead of

- `fetch('/task/new', {method: 'POST', body: new FormData(form)})` and then `list.innerHTML = html` -> a Turbo Drive form submit with a stream reply: `renderBlock()` after `setRequestFormat(TurboBundle::STREAM_FORMAT)`, or `TurboStreamResponse`.
- `$('#task_42').remove()` in a JavaScript callback after a delete request -> `return (new TurboStreamResponse())->remove('#task_42');`.
- `new Response('<turbo-stream action="append" ...>', 200, ['Content-Type' => 'text/vnd.turbo-stream.html'])` -> `return (new TurboStreamResponse())->append('#tasks', $html);` or `<twig:Turbo:Stream:Append target="#tasks">`.
- `str_contains($request->headers->get('Accept'), 'text/vnd.turbo-stream.html')` -> `TurboBundle::STREAM_FORMAT === $request->getPreferredFormat()`.
- `$request->headers->get('Turbo-Frame')` -> `$turboFrame->isFrameRequest()` and `$turboFrame->getRequestId()` (autowire `TurboFrame $turboFrame`), or `turbo_is_frame_request()` in Twig.
- `$this->render('task/new.html.twig', ['form' => $form->createView()])` (always 200) and `redirectToRoute('task_index')` (302) -> `$this->render('task/new.html.twig', ['form' => $form])` (422 when invalid) and `redirectToRoute('task_index', [], Response::HTTP_SEE_OTHER)`.
- `form.reset()` in JavaScript after a stream reply -> a `replace` stream action for `form[name=task]` that renders a copy of the form from before `handleRequest()` (`$emptyForm = clone $form;`).
- `setInterval(() => fetch('/task/list'), 5000)` to show the changes of other users -> `#[Broadcast]` on the entity and `<twig:Turbo:Stream:From topics="App\\Entity\\Task" />` (Mercure protocol 0.x only, see Status).
- A Doctrine `postPersist` or `postUpdate` listener that calls `$hub->publish(new Update($topic, $html))` -> `#[Broadcast]` and `templates/broadcast/Task.stream.html.twig`.
- `new EventSource(hubUrl + '?topic=chat')` with an `onmessage` handler that changes the DOM -> `turbo_stream_from('chat')` and `<turbo-stream>` messages that you publish with `HubInterface::publish()`.
