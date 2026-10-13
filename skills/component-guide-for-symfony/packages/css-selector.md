# CssSelector (`symfony/css-selector`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when code must find nodes in an HTML or XML document with a CSS selector instead of a long XPath expression. It converts the selector to an XPath string and does not load the document. [DomCrawler](dom-crawler.md) and the HTML assertions of [FrameworkBundle test tools](framework-bundle-testing.md) need it for CSS selectors.

**Details:** [../details/css-selector.md](../details/css-selector.md)

## Why it exists

XPath finds nodes in HTML and XML documents, but XPath expressions for common tasks are long and complex. For example, an XPath match on one class name must normalize the spaces in the class attribute first. The package converts a CSS selector to the equivalent XPath expression, so code and tests can use the shorter CSS syntax.

## When to use it

- Convert a CSS selector to an XPath expression for the PHP DOM extension or SimpleXML.
- Select the nodes of a parsed page with a CSS selector in [DomCrawler](dom-crawler.md), also the matching children or the closest ancestor.
- Check the HTML of a response in a functional test with CSS selector assertions.
- Scrape an external website with CSS selectors and a browser client from [BrowserKit](browser-kit.md).
- Query an XML document that has namespaces, such as an Atom feed, with CSS selectors.
- Test the HTML of a rendered UI component with CSS selectors, for example of [UX Twig Component](ux-twig-component.md) or [UX Live Component](ux-live-component.md).
- Fix the error "install the CssSelector component" that a CSS selector query throws.

## Use it instead of

- `$xpath->query("//a[contains(@class, 'btn')]")`, which also matches `btn-primary` -> `$xpath->query((new CssSelectorConverter())->toXPath('a.btn'))`, which matches only the class `btn`.
- `preg_match('#<h1[^>]*>(.*?)</h1>#s', $html, $m)` on a response body -> `$crawler->filter('h1')->text()`, or `$this->assertSelectorTextContains('h1', 'Hello World')` in a test.
- A `foreach` loop over `$dom->getElementsByTagName('a')` with `getAttribute()` checks -> `$crawler->filter('a[href^="https"]')`.
- A `while ($node = $node->parentNode)` loop that looks for the nearest `form` -> `$crawler->closest('form')`.
- `str_contains($html, 'checked')` to test a checkbox -> `$this->assertCheckboxChecked('terms')`.
- A hand-written XPath such as `//div[img]`, or a `reduce()` closure with a nested `filter()` -> `$crawler->filter('div:has(> img)')`.
- A `DOMXPath` query with a hand-written prefix for each namespace of an Atom feed -> `$crawler->addXmlContent($xml)` and `$crawler->filter('default|entry media|group yt|aspectRatio')`.
