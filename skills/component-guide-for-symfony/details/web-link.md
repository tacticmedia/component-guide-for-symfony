# WebLink (`symfony/web-link`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Resource hint functions in Twig:** `preload()`, `prefetch()`, `preconnect()`, `dns_prefetch()` and `prerender()` add a link with that relation to the response of the current page. `link()` adds a link with any relation, for example `modulepreload` or `alternate`. Each function returns the URI unchanged, so you can use it in an `href` attribute or with `asset()`. The functions add the links to the main request. If no request exists, for example in a console command, they only return the URI. The docs mark the `prerender` hint as deprecated and superseded by the Speculation Rules API, but `prerender()` has no PHP deprecation. Entry point: `{{ preload(asset('build/app.css'), {as: 'style'}) }}`.
- **Link attributes:** the last argument of each Twig function is a map of link attributes. The docs say that browsers need the `as` attribute on a `preload` link, but WebLink does not check it. A `true` value writes only the attribute name, for example `nopush`, and a `false` value omits the attribute. Entry point: `preload('/fonts/app.woff2', {as: 'font', type: 'font/woff2', crossorigin: 'anonymous'})`.
- **Link objects:** `Link` implements the PSR-13 `EvolvableLinkInterface`. The constructor takes the relation and the URI. The `with*()` and `without*()` methods return a changed copy and do not change the original object. Entry point: `new Link(Link::REL_PRELOAD, '/app.css')->withAttribute('as', Link::AS_STYLE)`.
- **Relation and `as` constants:** `Link` has 122 `REL_*` constants: 121 relations from the IANA registry and `REL_MERCURE`. Since 8.1, 13 `AS_*` constants give the values of the `as` attribute. Comments in the class tell which `AS_*` values apply to `preload` and which apply to `modulepreload`. Entry point: `Link::REL_PRECONNECT`, `Link::AS_FONT`.
- **Link providers:** `GenericLinkProvider` is an immutable PSR-13 collection of links. `withLink()` and `withoutLink()` return a new provider, and `getLinksByRel()` filters the links by relation. The provider ignores a second `withLink()` call only for the same object, not for an equal `Link` object. Entry point: `new GenericLinkProvider([$link])`.
- **The `_links` request attribute:** the Twig functions, `addLink()`, `importmap()` and the Mercure discovery store their links in the `_links` attribute of the request. On `kernel.response`, `AddLinkHeaderListener` adds these links to the `Link` header and keeps the existing `Link` headers. The listener reads only the main request, so links that `addLink()` puts on a sub-request do not reach the response. Entry point: `$request->attributes->get('_links')`.
- **Controller shortcut:** `AbstractController::addLink()` adds one PSR-13 link to the `_links` attribute of the given request. If the WebLink component is not installed, the method throws a `\LogicException`. Entry point: `$this->addLink($request, new Link(Link::REL_PRELOAD, '/app.css')->withAttribute('as', Link::AS_STYLE))`.
- **103 Early Hints:** `sendEarlyHints()` writes the given links into the `Link` header of a `Response` and sends the headers immediately with the status code 103. The method returns the `Response`. Give this object to `render()` as the third argument. Only `sendEarlyHints()` gives `rel="preload"` to a link without a relation. With `addLink()`, such a link gets `rel=""`. With AssetMapper, use the versioned URL from the autowired `AssetMapperInterface`, for example `$assetMapper->getAsset('styles/app.css')->publicPath`. If the PHP SAPI has no `headers_send()` function, `Response::sendHeaders(103)` sends nothing. The docs name FrankenPHP and RoadRunner as SAPIs with this support. In the Symfony code, only `sendEarlyHints()` sends a 103 response. The `preload()` function adds its link only to the final response. Entry point: `$response = $this->sendEarlyHints([new Link(Link::REL_PRECONNECT, 'https://fonts.example.com')]);`.
- **Controllers without `AbstractController`:** `ControllerHelper` gives `addLink()` and `sendEarlyHints()` as public methods. Inject one method as a closure with `#[AutowireMethodOf(ControllerHelper::class)]`. Give the parameter the name of the method, for example `$sendEarlyHints`. Entry point: `Symfony\Bundle\FrameworkBundle\Controller\ControllerHelper`.
- **Header serializer:** `HttpHeaderSerializer::serialize()` turns links into one `Link` header value, for example `</app.css>; rel="preload"; as="style"`. It skips templated links (an href with `{` or `}`), repeats the attribute for each value of an array, and escapes double quotes. It returns `null` when no link remains. Entry point: autowire `Symfony\Component\WebLink\HttpHeaderSerializer`.
- **Header parser:** `HttpHeaderParser::parse()` reads a `Link` header value, or a list of values, and returns a `GenericLinkProvider`. Its declared return type is `EvolvableLinkProviderInterface`. It reads only the first `rel` parameter and splits it at white space. A repeated attribute becomes an array, and an attribute without a value becomes `true`. Entry point: autowire `Symfony\Component\WebLink\HttpHeaderParser`, then call `->parse($headerValue)->getLinksByRel('next')`.
- **Configuration:** `framework.web_link.enabled` is `true` by default when the WebLink classes exist, unless the project requires the full `symfony/symfony` package. When it is enabled, FrameworkBundle registers the serializer, the parser and `AddLinkHeaderListener`. The Twig functions, `sendEarlyHints()` and the automatic `Link` header need it. Entry point: `framework.web_link`.
- **Automatic preloads from asset tools:** if WebLink is installed, `importmap()` of AssetMapper adds `preload` links (`as="style"`) for the CSS files that the entry point imports. A CSS file of a dynamic `import()` gets no link. If you use `importmap()`, do not call `preload()` for these CSS files. JavaScript modules get `<link rel="modulepreload">` tags in the HTML instead. WebpackEncoreBundle and Reprise also add links for their rendered tags, with their own `preload` option. Entry point: `{{ importmap('app') }}`.

## Entry points

- Config key `framework.web_link` with the option `enabled`.
- Twig functions `link(uri, rel, attributes = {})`, `preload(uri, attributes = {})`, `prefetch(uri, attributes = {})`, `preconnect(uri, attributes = {})`, `dns_prefetch(uri, attributes = {})` and `prerender(uri, attributes = {})`, defined in `Symfony\Bridge\Twig\Extension\WebLinkExtension`.
- Controller methods `Symfony\Bundle\FrameworkBundle\Controller\AbstractController::addLink(Request $request, LinkInterface $link)` and `AbstractController::sendEarlyHints(iterable $links = [], ?Response $response = null)`.
- The same public methods on the `Symfony\Bundle\FrameworkBundle\Controller\ControllerHelper` service (`controller.helper`), for example with `#[Symfony\Component\DependencyInjection\Attribute\AutowireMethodOf(ControllerHelper::class)]`.
- Autowire `Symfony\Component\WebLink\HttpHeaderSerializer` (service `web_link.http_header_serializer`) and `Symfony\Component\WebLink\HttpHeaderParser` (service `web_link.http_header_parser`).
- Classes `Symfony\Component\WebLink\Link` and `Symfony\Component\WebLink\GenericLinkProvider`.
- Without FrameworkBundle: build the links with `new Link()` and `new GenericLinkProvider([$link])`. Write the header with `(new HttpHeaderSerializer())->serialize($provider->getLinks())` and the PHP `header()` function.
- Listener `Symfony\Component\WebLink\EventListener\AddLinkHeaderListener` (service `web_link.add_link_header_listener`, event `kernel.response`).
- Request attribute `_links`, which holds a `Psr\Link\LinkProviderInterface`.
- PSR-13 interfaces from `psr/link`: `Psr\Link\LinkInterface`, `Psr\Link\EvolvableLinkInterface`, `Psr\Link\LinkProviderInterface` and `Psr\Link\EvolvableLinkProviderInterface`.
- Install the package with `composer require symfony/web-link`. The FrameworkBundle error message names `symfony/weblink`, but no package has that name.
- The package has no console command, no PHP attribute and no test assertion.

## Symbiotic packages

- [Twig Bridge](../packages/twig-bridge.md): its `WebLinkExtension` defines the six Twig functions, which add links to the `_links` attribute of the main request.
- [TwigBundle](../packages/twig-bundle.md): it registers `WebLinkExtension` as `twig.extension.weblink` and enables it only when FrameworkBundle registers `AddLinkHeaderListener`.
- [FrameworkBundle](../packages/framework-bundle.md): `framework.web_link` registers the WebLink services, and `AbstractController` and `ControllerHelper` supply `addLink()` and `sendEarlyHints()`.
- [HttpKernel](../packages/http-kernel.md): `AddLinkHeaderListener` subscribes to the `kernel.response` event and writes the `Link` header for the main request only.
- [HttpFoundation](../packages/http-foundation.md): `Response::sendHeaders(103)` sends the Early Hints response, and the `_links` provider is a value in `Request::$attributes`.
- [AssetMapper](../packages/asset-mapper.md): `importmap()` renders `modulepreload` tags for the imported JavaScript and, if WebLink is installed, adds `preload` links for CSS (`as="style"`) and JSON (`as="fetch"`) imports.
- [Asset](../packages/asset.md): `preload(asset('build/app.css'), {as: 'style'})` preloads the versioned URL that the Asset component builds.
- [Mercure](../packages/mercure.md): the Mercure component requires WebLink, and `Discovery::addLink()` adds a `rel="mercure"` link with the public URL of the hub.
- [WebpackEncoreBundle](../packages/webpack-encore-bundle.md): with `webpack_encore.preload: true` (default `false`), the bundle adds `preload` links for all rendered script and link tags and throws a `\LogicException` without WebLink.
- [Symfony Reprise](../packages/reprise.md): with WebLink, `reprise.preload` (default `true`) adds `modulepreload` links for scripts and `preload` links for CSS with the `integrity`, `crossorigin` and `nonce` of each tag.
- [HttpClient](../packages/http-client.md): `$response->getHeaders()['link']` gives a list of strings, and `HttpHeaderParser::parse()` accepts this list to read API pagination links.
- [DependencyInjection](../packages/dependency-injection.md): `#[AutowireMethodOf(ControllerHelper::class)]` injects `sendEarlyHints()` or `addLink()` as a closure into a controller that does not extend `AbstractController`.
- [DomCrawler](../packages/dom-crawler.md): its `Link` class is for an `<a>`, `<area>` or `<link>` tag of a crawled HTML page, and `Symfony\Component\WebLink\Link` is for HTTP `Link` headers.

## Changed in 8.0/8.1

- **8.1:** `Link::AS_*` constants give the values of the `as` attribute for `preload` and `modulepreload` links. Use `Link::AS_STYLE` instead of the string `'style'`.
- **8.0 (also 7.4):** `HttpHeaderParser` parses `Link` header values into `Link` objects. Use it instead of a regular expression on the header. FrameworkBundle registers it as the autowirable `web_link.http_header_parser` service.
- **8.0 (also 7.4):** `ControllerHelper` gives the `AbstractController` helpers, including `addLink()` and `sendEarlyHints()`, as a standalone service.

## Docs

- https://symfony.com/doc/current/web_link.html
- https://symfony.com/doc/current/reference/twig_reference.html
- https://symfony.com/doc/current/reference/configuration/framework.html
- https://symfony.com/doc/current/controller.html
- https://symfony.com/doc/current/frontend/asset_mapper.html
- https://symfony.com/doc/current/mercure.html
- https://symfony.com/doc/current/http_client.html
- https://symfony.com/bundles/WebpackEncoreBundle/current/index.html
- https://symfony.com/bundles/reprise/current/index.html
