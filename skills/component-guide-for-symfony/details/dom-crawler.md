# DomCrawler (`symfony/dom-crawler`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- Crawler: a `Crawler` holds a list of DOM nodes from one document. It is countable, and a `foreach` loop gives `\DOMNode` objects. Filter and traversal methods return a new `Crawler`, and only `closest()` can return `null`. A filter without a match returns an empty `Crawler`, not an exception. `Symfony\Component\DomCrawler\Crawler`
- Content: pass HTML or XML to the constructor or to an add method. All nodes of a crawler must come from one document. Nodes from a second document cause an `\InvalidArgumentException`. Without a `$type`, `addContent()` parses content that starts with `<?xml` as XML and other content as HTML. It ignores other types, for example `text/plain`. BrowserKit passes the `Content-Type` header of each response as `$type`, so a JSON response gives an empty `Crawler`. `__construct()`, `add()`, `addHtmlContent()`, `addXmlContent()`, `addContent()`
- Charset: `addContent()` takes the charset from the first `<meta>` tag with a charset, not from the `$type` argument. Without a `<meta>` charset, it uses UTF-8 for valid UTF-8 input and ISO-8859-1 for other input. `addHtmlContent()` and `addXmlContent()` use UTF-8 unless you pass a charset. If only the `Content-Type` header names the charset, pass that charset to `addHtmlContent()`. `addContent()`, `addHtmlContent()`
- HTML5 parser: the HTML methods parse with `\Dom\HTMLDocument::createFromString()` of PHP 8.4 and the flag `\Dom\HTML_NO_DEFAULT_NS`. Then they copy the tree into a `\DOMDocument`, so the nodes are `\DOMNode` objects, not `\Dom\Node` objects. HTML nodes have no namespace, so XPath expressions need no prefix. The parser repairs markup: a `<p>` inside a `<p>` becomes a sibling. A fragment such as `<tr>` without its `<table>` can lose its tags. `addHtmlContent()`
- CSS selectors: `filter('body > p')` converts the selector to XPath with `symfony/css-selector`. `matches()`, `closest()`, `children($selector)` and the crawler assertions also use it. Without the package, these methods throw a `\LogicException`. `filter()`
- XPath: `filterXPath()` evaluates an expression relative to the crawler nodes, as if a fake parent holds them. `evaluate()` returns an array of scalar results, or a `Crawler` for node results. `Crawler::xpathLiteral($value)` quotes a string for XPath, also when it contains both quote characters. `filterXPath()`, `evaluate()`, `xpathLiteral()`
- XML: the crawler discovers namespace prefixes, and the default namespace has the prefix `default`. If the default namespace is the only namespace, `addXmlContent()` removes it. `addXmlContent()` always adds `LIBXML_NONET`. With the default options, it does not expand external entities. With `LIBXML_NOENT`, it expands external entities from local files. If the XML is not trusted, do not pass `LIBXML_NOENT`. `addXmlContent()`, `registerNamespace()`, `setDefaultNamespacePrefix()`
- Traversal: `eq()`, `first()`, `last()` and `slice()` select nodes from the current list. `siblings()`, `nextAll()`, `previousAll()`, `ancestors()` and `children()` without a selector move through the tree from the first node. `children($selector)` returns the matching children of all nodes. `closest()` checks the first node, then its ancestors, and returns `null` without a match. On an empty crawler, `siblings()`, `nextAll()`, `previousAll()`, `ancestors()`, `children()` and `closest()` throw an `\InvalidArgumentException`. `reduce()` removes each node for which the closure returns `false`. `each()` calls the closure with a `Crawler` for each node and returns the values that the closure returns. `reduce()`, `each()`, `closest()`
- Values: `text()` returns the text of the first node with normalized whitespace. To keep the original text, pass `false` as the second argument. `innerText()` returns only the first non-empty text node that is a direct child. `extract(['_text', '_name', 'href'])` reads values from all nodes. On an empty crawler, `text()`, `html()`, `attr()` and `nodeName()` throw an `\InvalidArgumentException`, unless you pass a default to the first three. `text()`, `innerText()`, `attr()`, `nodeName()`, `html()`, `outerHtml()`, `extract()`
- Links and images: `selectLink('Log in')` finds `<a>` elements by their text or by the `alt` text of a child `<img>`. `link()` and `image()` return objects with `getUri()`, which returns an absolute URI. If an `href` is relative and the crawler has no absolute page URI or `<base href>`, `link()` throws an `\InvalidArgumentException`. `Link`, `Image`, `selectLink()`, `selectImage()`, `link()`, `links()`, `image()`, `images()`
- Forms: `selectButton('Save')` finds a button by its text, `value`, `id` or `name`, or an image input by its `alt` text. `form()` returns a `Form` for the form of that button. It uses the `formaction` and `formmethod` attributes of the button and the HTML5 `form` attribute. If the form `action` is empty or relative, `form()` needs an absolute page URI. `selectButton()`, `form()`, `Form`
- Form data: `getValues()` returns the flat values without disabled fields, unchecked boxes and file fields. It includes hidden fields, for example the `_token` field of a Symfony form. `getPhpValues()` returns nested PHP arrays. For a GET form, `getUri()` adds the values to the query string. `getFiles()` returns files only for POST, PUT, DELETE and PATCH forms. `getValues()`, `getPhpValues()`, `getFiles()`, `getPhpFiles()`, `getUri()`, `getMethod()`, `getName()`
- Form fields: `$form['user[email]']` returns a field object, and `$form['user[email]'] = 'a@example.com'` sets its value. The form throws an `\InvalidArgumentException` for an unknown field name. `$form->all()` returns all field objects. `ChoiceFormField` has `select()`, `tick()`, `untick()` and `addChoice()`. `FileFormField` has `upload()` and `setErrorCode()`. A choice field throws an `\InvalidArgumentException` for a value that is not an option. To allow such values, call `$form->disableValidation()`. `ChoiceFormField`, `FileFormField`, `InputFormField`, `TextareaFormField`, `Form::all()`, `Form::disableValidation()`
- URI resolution: `UriResolver::resolve($uri, $baseUri)` resolves a relative path, a path that starts with `/`, a query, a fragment or a scheme-relative URI against a base URI. It returns an absolute URI without a change. `Symfony\Component\DomCrawler\UriResolver`
- Test assertions: `WebTestCase` has 17 assertions for the crawler of the last request, for example `assertSelectorTextContains('h1', 'Hello')`. The text assertions without `Any` in the name check only the first matching node. `assertAnySelectorTextContains()` and `assertAnySelectorTextSame()` pass if at least one matching node has the text. `assertAnySelectorTextNotContains()` passes if no matching node contains the text. All text assertions fail if no node matches the selector. `assertInputValueSame()` reads only the `value` attribute of an `<input>`. For a `<textarea>` or a `<select>`, use `assertFormValue()`, which reads `Form::getValues()`. 15 of the 17 assertions use seven PHPUnit constraints. To check another `Crawler`, use these constraints with `assertThat()`. `DomCrawlerAssertionsTrait`, `Symfony\Component\DomCrawler\Test\Constraint`

## Entry points

- `Symfony\Component\DomCrawler\Crawler`: create it with `new Crawler($html, $pageUri)`. It is not a service. BrowserKit clients return it from `request()`, `click()`, `clickLink()`, `submit()`, `submitForm()` and `getCrawler()`.
- Without FrameworkBundle: `new Crawler($html, $pageUri)` and `UriResolver::resolve()` work in any PHP code, for example a scraper. To check a `Crawler` in a PHPUnit test, use the constraints in `Symfony\Component\DomCrawler\Test\Constraint` with `assertThat()`.
- `Symfony\Component\DomCrawler\Link`, `Symfony\Component\DomCrawler\Image` and `Symfony\Component\DomCrawler\Form`: the objects that `link()`, `image()` and `form()` return.
- `Symfony\Component\DomCrawler\Field\ChoiceFormField`, `FileFormField`, `InputFormField` and `TextareaFormField`: the field objects of a `Form`. Their base class is `Symfony\Component\DomCrawler\Field\FormField`.
- `Symfony\Component\DomCrawler\UriResolver::resolve()`: a static method that makes a URI absolute.
- The PHPUnit constraints in `Symfony\Component\DomCrawler\Test\Constraint`: `CrawlerSelectorExists`, `CrawlerSelectorCount`, `CrawlerSelectorTextContains`, `CrawlerSelectorTextSame`, `CrawlerAnySelectorTextContains`, `CrawlerAnySelectorTextSame` and `CrawlerSelectorAttributeValueSame`.
- `Symfony\Bundle\FrameworkBundle\Test\DomCrawlerAssertionsTrait`: `WebTestCase` uses it through `WebTestAssertionsTrait`. Its assertions are `assertSelectorExists()`, `assertSelectorNotExists()`, `assertSelectorCount()`, `assertSelectorTextContains()`, `assertSelectorTextNotContains()`, `assertAnySelectorTextContains()`, `assertAnySelectorTextNotContains()`, `assertSelectorTextSame()`, `assertAnySelectorTextSame()`, `assertPageTitleSame()`, `assertPageTitleContains()`, `assertInputValueSame()`, `assertInputValueNotSame()`, `assertCheckboxChecked()`, `assertCheckboxNotChecked()`, `assertFormValue()` and `assertNoFormValue()`.
- Installation: `composer require symfony/dom-crawler`, and `composer require symfony/css-selector` for CSS selectors. In a Symfony application, `composer require --dev symfony/test-pack` installs `symfony/css-selector` and `symfony/browser-kit`. BrowserKit requires DomCrawler.
- The component has no config key, attribute, console command, Twig function or service ID.

## Symbiotic packages

- [CssSelector](../packages/css-selector.md): `filter()`, `matches()`, `closest()`, `children($selector)` and the crawler assertions need it to convert CSS selectors, but `filterXPath()` works without it.
- [BrowserKit](../packages/browser-kit.md): BrowserKit clients return a `Crawler` for each response, and `click()` and `submit()` take the `Link` and `Form` objects of the crawler.
- [FrameworkBundle test tools](../packages/framework-bundle-testing.md): `WebTestCase::createClient()` returns a `KernelBrowser` that returns a `Crawler` for each request, and `WebTestCase` adds the crawler assertions of `DomCrawlerAssertionsTrait`.
- [HttpClient](../packages/http-client.md): `new HttpBrowser(HttpClient::create())` sends real HTTP requests and returns a `Crawler` for each response, so you can scrape external websites.
- [Panther](../packages/panther.md): the Panther crawler, `Symfony\Component\Panther\DomCrawler\Crawler`, extends the DomCrawler `Crawler` and reads the page from a real browser, which also runs JavaScript.
- [UX Twig Component](../packages/ux-twig-component.md): in a `KernelTestCase` with `InteractsWithTwigComponents`, `renderTwigComponent()` returns a `RenderedComponent` whose `crawler()` method needs DomCrawler and returns a `Crawler`.
- [UX Live Component](../packages/ux-live-component.md): `TestLiveComponent` needs DomCrawler and CssSelector to read the component props, and its `render()` method returns a `RenderedComponent` with a `crawler()` method.
- [Form](../packages/form.md): `Symfony\Component\Form\Form` builds and validates forms on the server, and the DomCrawler `Form` fills in and submits the rendered HTML form in tests.
- [JsonPath](../packages/json-path.md): its `JsonCrawler` queries JSON documents with JSONPath expressions, as DomCrawler queries HTML and XML with CSS selectors and XPath.
- [HtmlSanitizer](../packages/html-sanitizer.md): to remove unsafe content from user HTML, use HtmlSanitizer, because DomCrawler is not designed to change the DOM.
- [WebLink](../packages/web-link.md): `Symfony\Component\WebLink\Link` is for HTTP `Link` headers; the DomCrawler `Link` is for an `<a>`, `<area>` or `<link>` tag of a crawled page.

## Changed in 8.0/8.1

- 8.0: `new Crawler($html, $uri, null, false)` -> `new Crawler($html, $uri)`. The constructor no longer has the fourth argument, `$useHtml5Parser`, and the crawler always uses the native HTML5 parser of PHP 8.4. DomCrawler no longer requires `masterminds/html5`.
- 8.0: `$client->useHtml5Parser(false)` on a BrowserKit client -> `$client->wrapContent('<table>%s</table>')` for a fragment such as `<tr>` that loses its tags. BrowserKit 8.0 removes `useHtml5Parser()`.
- 8.1: `ChoiceFormField::addChoice()` was `@internal` and accepted only radio buttons and multiple selects -> public API that also accepts an `<option>` for a single select. Pass a `\DOMElement`, for example `$form['country']->addChoice($optionElement)`. The docs example with a string argument does not match the source.
- 8.1: `addXmlContent($xml, 'UTF-8', \LIBXML_PARSEHUGE)` lost `LIBXML_NONET` -> `addXmlContent()` now always adds `LIBXML_NONET`, so external entities cannot make network requests. Since 8.0.12 and 8.1.0, it does not enable `validateOnParse`. With the default options, it does not expand external entities (CVE-2026-45071).
- CssSelector 8.1: a `reduce()` closure with a nested `filter()` call -> `$crawler->filter('li:has(a.active)')`, because `filter()` now supports `:has()`.

## Status

DomCrawler needs PHP 8.4.1 or later and the PHP `dom` extension. `composer.json` does not list `ext-dom`, but `Crawler` uses `\DOMDocument` and `\Dom\HTMLDocument`. The CSS selector methods need `symfony/css-selector`, which DomCrawler lists only as a dev requirement.

## Docs

- https://symfony.com/doc/current/components/dom_crawler.html
- https://symfony.com/doc/current/testing/dom_crawler.html
- https://symfony.com/doc/current/testing.html
- https://symfony.com/doc/current/components/css_selector.html
- https://symfony.com/doc/current/components/browser_kit.html
- https://symfony.com/doc/current/testing/end_to_end.html
- https://symfony.com/doc/current/components/json_path.html
