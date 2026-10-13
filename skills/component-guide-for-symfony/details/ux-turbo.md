# Symfony UX Turbo (`symfony/ux-turbo`): details

**Applies to:** Symfony UX 3.5

## Key features and concepts

- **Turbo Drive**: The `turbo-core` Stimulus controller imports `@hotwired/turbo`. Turbo then does link visits and form submits in the background and updates the page without a full reload. The package enables this controller by default (`turbo-core` in `assets/controllers.json`). A project from `symfony new --webapp` includes UX Turbo through `symfony/webapp-pack`, so Turbo Drive is active from the start. If page scripts must run after each visit, write them as Stimulus controllers. For other scripts, put the initialization code in a `turbo:load` event listener.
- **Form responses for Turbo Drive**: Turbo Drive needs status 422 for an invalid form and a 303 redirect after a successful submit. `AbstractController::render()` and `renderBlock()` set 422 when a submitted form in the parameters is invalid. Pass the form object, not `createView()`. Use `redirectToRoute($route, [], Response::HTTP_SEE_OTHER)`, because the default status of `redirectToRoute()` is 302. If a form has several submit buttons, give each button a `value` attribute. Turbo Drive does not send a button with an empty value.
- **Reload when assets change**: With AssetMapper, the bundle adds `data-turbo-track="reload"` to the importmap `<script>` tags (`framework.asset_mapper.importmap_script_attributes`). Turbo then does a full reload when a JavaScript file changes. With Webpack Encore or Reprise, set `data-turbo-track: reload` in `script_attributes` and `link_attributes`.
- **Turbo Drive meta tags**: Twig functions write the `<meta>` tags for the Turbo cache, the preview, a forced reload and the refresh behavior. The functions are `turbo_exempts_page_from_cache()`, `turbo_exempts_page_from_preview()`, `turbo_page_requires_reload()`, `turbo_refreshes_with(method, scroll)`, `turbo_refresh_method()` and `turbo_refresh_scroll()`. `method` accepts `replace` or `morph`, and `scroll` accepts `reset` or `preserve`. Other values cause an `InvalidArgumentException`.
- **Turbo Frames**: A frame is a part of the page that updates alone. When the user clicks a link inside a frame, Turbo replaces the frame with the frame of the same `id` from the new page. With a `src` attribute, a frame starts empty and gets its content from that URL. Add `loading="lazy"` to lazy-load it. Entry point: `<twig:Turbo:Frame id="..." src="..." loading="lazy" target="_top">` or a plain `<turbo-frame>` tag.
- **Frame request detection**: The `TurboFrame` service methods `isFrameRequest()` and `getRequestId()` read the `Turbo-Frame` request header. In Twig, use `turbo_is_frame_request()` and `turbo_frame_request_id()`. Entry point: autowire `Symfony\UX\Turbo\TurboFrame`.
- **Minimal frame layout**: Extend `@Turbo/layouts/frame.html.twig` in a template that answers a frame request. The layout has only the `head` and `body` blocks, so the response stays small and can still contain page meta tags.
- **Turbo Stream format**: On each request, the bundle maps the request format `turbo_stream` (`TurboBundle::STREAM_FORMAT`) to `text/vnd.turbo-stream.html`. To detect a stream request, compare `TurboBundle::STREAM_FORMAT === $request->getPreferredFormat()`. Then call `$request->setRequestFormat(TurboBundle::STREAM_FORMAT)` before `renderBlock()`, so the response gets the stream content type. If one URL can return HTML or a stream, send `Vary: Accept` (`$response->setVary('Accept')`).
- **`TurboStreamResponse`**: This response builds stream actions in a controller without a template. Its methods are `append()`, `prepend()`, `replace()`, `update()`, `remove()`, `before()`, `after()`, `refresh()`, and `action()` for a custom action. It sets the `text/vnd.turbo-stream.html` content type. `replace()` and `update()` accept `$morph`. The methods do not escape the `$html` argument. Escape user data, or render the HTML with Twig. `Symfony\UX\Turbo\Helper\TurboStream` has the same methods as static methods that return strings.
- **Stream Twig components**: `<twig:Turbo:Stream:Append>`, `Prepend`, `Replace`, `Update`, `Remove`, `Before`, `After` and `Refresh` render `<turbo-stream>` elements. The `target` attribute is a CSS selector. `Replace` and `Update` accept `morph`, `Refresh` accepts `requestId`, and `<twig:Turbo:Stream action="...">` renders a custom action. All `<twig:Turbo:*>` components need `symfony/ux-twig-component`, which `symfony/ux-turbo` does not require.
- **Broadcast Doctrine entity changes**: Put `#[Broadcast]` on a Doctrine entity. The bundle collects inserts, updates and deletions on `onFlush` and publishes them on `postFlush`. For each change, it renders the `create`, `update` or `remove` block of `templates/broadcast/<ClassName>.stream.html.twig`. The template must contain all three blocks, but a block can be empty. The template gets `entity`, `id` (a string), `action` and each attribute option as a separate variable. The docs name an `options` variable, but the source does not pass it.
- **Broadcast options**: `topics` replaces the default topic, which the bundle builds from the class name and the id. A topic that starts with `@=` is an ExpressionLanguage expression with the variable `entity`. `template` sets the template path, and `transports` limits the hubs. The Mercure options are `private`, `sse_id`, `sse_type` and `sse_retry`. To render several templates for different topics, repeat the attribute.
- **Subscribe a page to a stream**: `turbo_stream_from(topics, private, transport)` and `<twig:Turbo:Stream:From topics="..." private transport="...">` render a `<turbo-mercure-stream-source>` element. This element connects to the Mercure hub and gives each incoming Turbo Stream message to Turbo. A topic is a string, an entity object, a class name for all entities of that class, or an array. Double the backslashes in a class name (`'App\\Entity\\Task'`). Twig 3 turns `'App\Entity\Task'` into the topic `AppEntityTask`, and the page then gets no updates. With `private`, the bundle sets the Mercure authorization cookie, and the element sends cookies to the hub.
- **Transports**: Each Mercure hub is a transport with the name of the hub. `turbo_stream_from()` uses `turbo.default_transport` (default `default`) when you do not give `transport`. If no hub has the name `default`, set `turbo.default_transport` to the name of a hub. If the default transport does not exist, `turbo_stream_from()` without `transport` throws an `InvalidArgumentException`. For another protocol, implement `BroadcasterInterface::broadcast(object $entity, string $action, array $options)` and `StreamSourceRendererInterface::render()` (the custom-transport docs example omits `$options`). Autoconfiguration adds the tags `turbo.broadcaster` and `turbo.stream_source_renderer`. `#[AsTaggedItem(index: 'my-transport')]` sets the transport name.
- **Configuration and side effects**: `turbo.broadcast.entity_template_prefixes` maps namespaces to template folders (default `App\Entity\: broadcast/`). `turbo.broadcast.doctrine_orm.enabled` defaults to true when the application has DoctrineBundle and Doctrine ORM. If you set `turbo.broadcast.enabled: false`, the bundle also removes its Twig extension, and all `turbo_*` Twig functions disappear. Without a Mercure hub or a custom transport, the bundle removes its Doctrine listener, and `#[Broadcast]` does nothing. The Flex recipe writes `config/packages/ux_turbo.yaml` with `framework.csrf_protection.check_header: true`, so stateless CSRF protection also checks the token in an HTTP header.

## Entry points

- `Symfony\UX\Turbo\TurboBundle`: constants `STREAM_FORMAT` (`'turbo_stream'`) and `STREAM_MEDIA_TYPE` (`'text/vnd.turbo-stream.html'`).
- `Symfony\UX\Turbo\TurboStreamResponse` and `Symfony\UX\Turbo\Helper\TurboStream`.
- `Symfony\UX\Turbo\TurboFrame` (service `turbo.frame`, autowirable): `isFrameRequest()`, `getRequestId()`.
- `Symfony\UX\Turbo\Attribute\Broadcast` (repeatable class attribute; constants `ACTION_CREATE`, `ACTION_UPDATE`, `ACTION_REMOVE`).
- `Symfony\UX\Turbo\Broadcaster\BroadcasterInterface` (tag `turbo.broadcaster`) and `Symfony\UX\Turbo\StreamSourceRendererInterface` (tag `turbo.stream_source_renderer`).
- Config: `turbo.broadcast.enabled`, `turbo.broadcast.entity_template_prefixes`, `turbo.broadcast.doctrine_orm.enabled`, `turbo.default_transport`.
- Twig functions: `turbo_stream_from()`, `turbo_is_frame_request()`, `turbo_frame_request_id()`, `turbo_exempts_page_from_cache()`, `turbo_exempts_page_from_preview()`, `turbo_page_requires_reload()`, `turbo_refreshes_with()`, `turbo_refresh_method()`, `turbo_refresh_scroll()`. Deprecated: `turbo_stream_listen()`.
- Twig components (need `symfony/ux-twig-component`): `<twig:Turbo:Frame>`, `<twig:Turbo:Stream>`, `<twig:Turbo:Stream:Append>`, `:Prepend`, `:Replace`, `:Update`, `:Remove`, `:Before`, `:After`, `:Refresh`, `:From`.
- Twig layout: `@Turbo/layouts/frame.html.twig`.
- Front end: npm package `@symfony/ux-turbo` with the Stimulus controllers `turbo-core` (enabled) and `mercure-turbo-stream` (disabled, deprecated), and the custom element `<turbo-mercure-stream-source>`. Importmap packages: `@hotwired/turbo` `^7.1.0 || ^8.0`, `@hotwired/stimulus` `^3.0.0`.
- Mercure side (`symfony/mercure`, `symfony/mercure-bundle`): `Symfony\Component\Mercure\HubInterface`, `Symfony\Component\Mercure\Update`, config `mercure.hubs`.
- Controller helpers (FrameworkBundle): `AbstractController::render()`, `renderBlock()`, `redirectToRoute()`; `Response::HTTP_SEE_OTHER`.
- Tests: the package has no test helper. Use Panther: `Symfony\Component\Panther\PantherTestCase`, `createPantherClient()`, `assertSelectorWillContain()`.

## Symbiotic packages

- [StimulusBundle](../packages/stimulus-bundle.md): the only required dependency; it loads the `turbo-core` controller from `assets/controllers.json`, and this controller starts Turbo Drive.
- [Mercure](../packages/mercure.md): supplies the hubs (`mercure.hubs`), `HubInterface`, `Update` and the `mercure()` Twig function; UX Turbo registers a broadcaster and a stream source renderer for each hub.
- [UX Twig Component](../packages/ux-twig-component.md): resolves `<twig:Turbo:*>` names to `@Turbo/components/*.html.twig`; install it to use the Frame and Stream components.
- [UX Live Component](../packages/ux-live-component.md): Live Component is for stateful widgets that render again on user input or `data-poll`; Turbo Streams with Mercure push changes to all users. A live action redirect uses `Turbo.visit()` when Turbo is on the page, unless the component element or a parent has `data-turbo="false"`.
- [Form](../packages/form.md): `render()` returns 422 for an invalid submitted form, which Turbo Drive needs; the multi-step form docs list the 200, 422 and 303 codes for Turbo.
- [FrameworkBundle](../packages/framework-bundle.md): `AbstractController::render()`, `renderBlock()` and `redirectToRoute()` make the 422, 303 and stream responses.
- [HttpFoundation](../packages/http-foundation.md): `Request::getPreferredFormat()` reads the `Accept` header and detects the `turbo_stream` format; `Response::setVary('Accept')` keeps HTTP caches correct.
- [Doctrine Bridge](../packages/doctrine-bridge.md): `#[Broadcast]` needs Doctrine ORM and DoctrineBundle; DoctrineBundle registers the broadcast listener through the `RegisterEventListenersAndSubscribersPass` of the bridge.
- [AssetMapper](../packages/asset-mapper.md): the bundle adds its JavaScript path and `data-turbo-track="reload"` to the AssetMapper configuration.
- [WebpackEncoreBundle](../packages/webpack-encore-bundle.md): set `script_attributes` and `link_attributes` with `data-turbo-track: reload`, and enable versioning.
- [Symfony Reprise](../packages/reprise.md): reads `assets/controllers.json`; set `data-turbo-track: reload` in `reprise.script_attributes` and `reprise.link_attributes`.
- [ExpressionLanguage](../packages/expression-language.md): `#[Broadcast]` needs it for `@=` topics.
- [PropertyAccess](../packages/property-access.md): reads the `id` of an object that Doctrine does not manage, for `turbo_stream_from($object)` and broadcasts.
- [Panther](../packages/panther.md): tests Turbo pages in a real browser, because Turbo updates the page with JavaScript.
- [Abandoned Symfony UX packages](../packages/ux-abandoned.md): this package contains the Mercure bridge of the abandoned `symfony/ux-turbo-mercure`; replace that package with `symfony/mercure-bundle`.
- [MakerBundle](../packages/maker-bundle.md): `make:entity --broadcast` adds the `#[Broadcast]` attribute to the entity.

## Changed in UX 2.21 to 3.5 and Symfony 8.1

- UX 3.1: `<div {{ turbo_stream_listen(topic, 'hub2', {withCredentials: true}) }}>` -> `{{ turbo_stream_from(topic, private: true, transport: 'hub2') }}` or `<twig:Turbo:Stream:From>`. The old function returns the attributes of a Stimulus controller. The new function returns a separate `<turbo-mercure-stream-source>` element. UX 3.1 deprecates the old function, and UX 4.0 will remove it.
- UX 3.1: Do not enable the `mercure-turbo-stream` controller in `assets/controllers.json`. `turbo-core` loads the `<turbo-mercure-stream-source>` element automatically.
- UX 3.1: `TurboStreamListenRendererInterface` -> `StreamSourceRendererInterface` (tag `turbo.stream_source_renderer`); `TurboStreamListenRenderer` -> `MercureStreamSourceRenderer`. Do not use the deprecated `TopicSet` class.
- UX 3.1: `$request->headers->get('Turbo-Frame')` -> the `TurboFrame` service and `turbo_is_frame_request()`; the new `@Turbo/layouts/frame.html.twig` layout keeps `<head>` content in frame responses.
- UX 3.0: requires PHP 8.4 and Symfony 7.4. It removes the compatibility layer for the `StimulusTwigExtension` of WebpackEncoreBundle 1.x. Use StimulusBundle.
- UX 2.21: `TurboStreamResponse` exists again with `append()`, `remove()` and other methods (UX 2.1 removed it). Do not build `<turbo-stream>` strings by hand.
- Symfony 8.1: In a service constructor, inject a named hub with `#[Target('hub1')] HubInterface $hub`. The autowiring of `HubInterface $hub1` by the parameter name alone triggers a deprecation there. A controller action argument `HubInterface $hub1` (as on the multiple-transports page) does not trigger this deprecation.
- UX 3.5: Twig 4 keeps single backslashes in class-name strings. Keep `'App\\Entity\\Task'`, so the template works on Twig 3 and Twig 4.

## Status

- The Mercure transport (broadcasts and `turbo_stream_from()`) depends on 0.x packages: `symfony/mercure-bundle` and `symfony/mercure`. `symfony/mercure` marks `Symfony\Component\Mercure\Update` and `HubInterface` as `@experimental`.
- UX Turbo 3.5 targets the Mercure protocol 0.x. Its tests expect `topic=` URLs, and its end-to-end app uses a 0.x hub. MercureBundle 0.6.0 and later set `protocol_version: '1.0'` by default.
- With protocol 1.0, a `jwt.secret` hub needs `jwt.claims` with `iss`, `sub` and `client_id`, or the container does not compile. The Flex recipe of MercureBundle and the Mercure example in the UX Turbo docs have no claims.
- In UX Turbo 3.5, a subscription to all entities of a class uses a URI Template (`{id}`). Protocol 1.0 dropped URI Templates. With `protocol_version: '1.0'`, `mercure()` sends each topic as an exact `match` parameter, so this subscription gets no updates. `turbo_stream_listen()` always sends 0.x `topic` parameters.
- UX 3.6 adds support for the Mercure protocol 1.0. The docs show this support, but UX 3.6 has no release. With UX Turbo 3.5 and a 0.x hub, set `protocol_version: '0.x'` on the hub.

## Docs

- https://symfony.com/bundles/ux-turbo/current/index.html (it shows the unreleased 3.6 note about Mercure protocol 1.0)
- https://symfony.com/bundles/ux-turbo/current/resetting-form.html
- https://symfony.com/bundles/ux-turbo/current/multiple-submit-buttons.html
- https://symfony.com/bundles/ux-turbo/current/multiple-transports.html
- https://symfony.com/bundles/ux-turbo/current/custom-transport.html
- https://symfony.com/bundles/ux-turbo/current/webpack-encore.html
- https://symfony.com/bundles/ux-turbo/current/reprise.html
- https://symfony.com/bundles/ux-turbo/current/testing.html
- https://symfony.com/doc/current/mercure.html
- https://symfony.com/doc/current/forms.html
- https://symfony.com/doc/current/form/form_flow.html
- https://symfony.com/bundles/ux-live-component/current/index.html
- https://symfony.com/bundles/ux-twig-component/current/index.html
- https://symfony.com/bundles/StimulusBundle/current/index.html
