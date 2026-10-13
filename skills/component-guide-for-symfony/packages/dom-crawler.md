# DomCrawler (`symfony/dom-crawler`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when PHP code must parse HTML or XML, for example to scrape a page or to check a response in a test. It selects nodes with CSS selectors or XPath, and reads text, attributes, links and forms. For JSON, see [JsonPath](json-path.md).

**Details:** [../details/dom-crawler.md](../details/dom-crawler.md)

## Why it exists

Code that uses the PHP DOM classes directly must load the document, write XPath queries, make relative URLs absolute and collect form values. The package does these tasks with chainable methods, and it parses HTML with the HTML5 parser of PHP 8.4. Test clients and browser clients return the parsed page for each response, and the test assertions check it.

## When to use it

- Extract text, attributes or links from an HTML page with CSS selectors or XPath.
- Read values from an XML document or feed, also when the document uses namespaces.
- Check the HTML of a response in a functional test, for example the text of the h1 element.
- Click a link or submit a form in a functional test or in a scraper.
- Fill in form fields in a test: text inputs, checkboxes, select lists and file uploads.
- Make the relative URL of a link, an image or a form action absolute.
- Scrape an external website together with [BrowserKit](browser-kit.md) and [HttpClient](http-client.md).

## Use it instead of

- `preg_match('#<h1>(.*?)</h1>#s', $html, $matches)` -> `(new Crawler($html))->filter('h1')->text()`
- `$document = new \DOMDocument(); @$document->loadHTML($html);` and a `new \DOMXPath($document)` query -> `new Crawler($html, $pageUrl)` with `filter()` or `filterXPath()`. The crawler parses with the HTML5 parser of PHP 8.4.
- An XPath string with user input, such as `"//a[text()='".$name."']"` -> `Crawler::xpathLiteral($name)` in the expression, or `selectLink($name)`
- `parse_url()` and string concatenation to make an `href` absolute -> `$crawler->selectLink('Next')->link()->getUri()`, or `UriResolver::resolve($href, $pageUrl)`
- `strip_tags($html)` and `preg_replace('/\s+/', ' ', $text)` -> `$crawler->filter('article')->text()`, which normalizes whitespace by default
- `$this->assertStringContainsString('Hello World', $client->getResponse()->getContent())` -> `$this->assertSelectorTextContains('h1', 'Hello World')`
- `$client->request('POST', '/post/1/comment', ['comment_form' => [...]])` with a CSRF token that you copy by hand -> `$client->submitForm('Add comment', ['comment_form[content]' => '...'])`, which also sends the hidden fields of the form
- A cURL loop or a Goutte client that follows links and posts forms -> `HttpBrowser` with `clickLink()` and `submitForm()`, which return a `Crawler`
