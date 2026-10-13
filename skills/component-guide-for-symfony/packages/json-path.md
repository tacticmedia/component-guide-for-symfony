# JsonPath (`symfony/json-path`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when code must extract values from nested JSON, for example an API response, with queries, filters, wildcards or a recursive search. It evaluates JSONPath expressions of RFC 9535 and adds test assertions. To query HTML or XML, see [DomCrawler](dom-crawler.md). To turn JSON into objects, see [Serializer](serializer.md).

**Details:** [../details/json-path.md](../details/json-path.md)

## Why it exists

Code that reads data from a decoded JSON document often needs nested checks for missing keys, loops and filter calls. The package evaluates JSONPath expressions of RFC 9535 on a JSON string or stream, and returns a list of the matching values. It does for JSON what XPath does for HTML and XML.

## When to use it

- Extract a value at a known path of a JSON string.
- Select the JSON array items that match a condition, for example a price below 10 or a regular expression.
- Collect the values of one key at all levels of a JSON document.
- Build a JSONPath query from variables or user input, and let the builder escape the key names.
- Assert values, counts or list items of a JSON API response in a test.
- Add a project-specific function to JSONPath filter expressions, for example a function that changes text to upper case.
- Read one branch of a large JSON file from a stream.

## Use it instead of

- `json_decode($json, true)['store']['book'][0]['title'] ?? null` -> `(new JsonCrawler($json))->find('$.store.book[0].title')`
- `array_filter($data['store']['book'], fn (array $book): bool => $book['price'] < 10)` after `json_decode()` -> `$crawler->find('$.store.book[?@.price < 10]')`
- A recursive function or `array_walk_recursive()` that collects every `author` value -> `$crawler->find('$..author')`
- `"$['".$key."']"` or `'$.'.$key` string concatenation with user input -> `(new JsonPath())->key($key)`
- `preg_match()` in a `foreach` loop over decoded items -> `$crawler->find('$.items[?search(@.title, "sale")]')`, or `match()` for a whole-string match
- `$data = json_decode($json, true); $this->assertSame('Moby Dick', $data['books'][2]['title']);` -> `self::assertJsonPathSame(['Moby Dick'], '$.books[2].title', $json);` with `JsonPathAssertionsTrait`
- `json_decode(file_get_contents('catalog.json'), true)` to read one branch of a large file -> `(new JsonCrawler(fopen('catalog.json', 'r')))->find('$.store.book[0]')` with `symfony/json-streamer`
