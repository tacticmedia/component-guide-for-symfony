# WebLink (`symfony/web-link`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when the browser must fetch fonts, stylesheets or scripts early, or connect early to other origins. It sends HTTP Link headers for preload, prefetch, preconnect and DNS prefetch, and 103 Early Hints. It also parses Link headers, for example the pagination links of an API.

**Details:** [../details/web-link.md](../details/web-link.md)

## Why it exists

A browser finds a font, a stylesheet or a script only when it parses the HTML or the CSS that refers to the file. The HTTP Link header and the 103 Early Hints response tell the browser about these files and origins earlier. The package builds these headers from PSR-13 link objects, so you do not write the header syntax by hand.

## When to use it

- Preload a font, a stylesheet or a script that the page needs early.
- Open an early connection or an early DNS lookup to a CDN or another origin.
- Prefetch a resource that the next page can need.
- Send 103 Early Hints before a slow controller renders the full page.
- Add a Link response header, for example an alternate link, from an HTML template, a controller or PHP code.
- Read the pagination URLs from the Link header of an API response.
- Build a Link header value in a PHP script without the full framework.

## Use it instead of

- `$response->headers->set('Link', '</app.css>; rel="preload"; as="style"')` with a hand-written string -> `{{ preload(asset('app.css'), {as: 'style'}) }}` in Twig, or `$this->addLink($request, new Link(Link::REL_PRELOAD, '/app.css')->withAttribute('as', Link::AS_STYLE))`.
- `header('Link: </app.css>; rel=preload', false)` in a plain PHP script -> `header('Link: '.(new HttpHeaderSerializer())->serialize($linkProvider->getLinks()))` with a `GenericLinkProvider`.
- `header('HTTP/1.1 103 Early Hints')` or a direct `headers_send(103)` call -> `$response = $this->sendEarlyHints([...])`, then `$this->render('home/index.html.twig', [], $response)`.
- `preg_match('/<([^>]+)>;\s*rel="next"/', $response->getHeaders()['link'][0], $matches)` -> `$parser->parse($response->getHeaders()['link'] ?? [])->getLinksByRel(Link::REL_NEXT)`.
- A custom `kernel.response` listener that adds a `Link` header -> `addLink()` or a Twig function puts the link in `_links`, and `AddLinkHeaderListener` writes the header.
- The strings `'preload'`, `'dns-prefetch'` or `'style'` in link code -> `Link::REL_PRELOAD`, `Link::REL_DNS_PREFETCH`, `Link::AS_STYLE`.
- `<link rel="preload">` tags or `preload()` calls for the CSS files of `importmap()` -> no code: `importmap()` adds these `Link` headers when WebLink is installed.
