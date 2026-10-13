# JsonPath (`symfony/json-path`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- Crawler: `JsonCrawler` takes the JSON as a string. `find()` returns a list of all values that the expression selects. JSON objects come back as associative arrays, and no match gives `[]`. `$crawler->find('$.store.book[0].title')` returns `['Sayings of the Century']`. `JsonCrawler::find()`
- RFC 9535 selectors: root `$`, names (`.title`, `['title']`, `["book collection"]`), wildcard (`*`, `[*]`) and index (`[0]`, `[-1]`). Also slices (`[1:3]`, `[::-1]`), unions (`[0,-1]`, `['a','b']`) and the descendant segment `..` for a recursive search (`$..author`). A name that contains a hyphen, a space or a dot, or starts with a digit, needs the bracket form, for example `$.headers["content-type"]`. `JsonCrawler::find()`
- Filters: `[?@.price < 10]` keeps the items for which the expression is true. The parentheses in `[?(@.price < 10)]` are optional for simple filters. If a filter calls `match()`, `search()` or another function with two or more arguments, write the parentheses. Without them, `[?match(@.title, "M.*") && @.category == "fiction"]` returns `[]`. Filters accept `==`, `!=`, `<`, `<=`, `>`, `>=`, `&&`, `||`, `!`, existence tests (`[?@.isbn]`), nested filters and absolute queries (`$.store.bicycle.price`). `$crawler->find('$.store.book[?@.price < 10].title')`
- Built-in functions: you must compare the results of `length()`, `count()` and `value()`, for example `[?length(@.author) > 12]`. `match()` (whole string) and `search()` (substring) are regular expression tests, so do not compare them with `true`. A `/` in the pattern gives no match, because the crawler does not escape the regular expression delimiter. `[?match(@.title, "Moby.*")]`
- RFC validation: the crawler rejects invalid expressions with `JsonCrawlerException`. Examples are a path without `$`, a non-singular query in a comparison (`@.tags[*] == "json"`), a bare literal and a wrong number of function arguments. The component tests run the full JSONPath Compliance Test Suite on string and stream input. `JsonCrawlerException`
- Query builder: the immutable `JsonPath` class builds a path with `key()`, `index()`, `first()`, `last()`, `all()`, `slice()`, `deepScan()` and `filter()`. `key()` escapes quotes, backslashes and control characters, with three exceptions: U+0008, U+000B and a backslash before `b`. For such a key, `find()` searches for a different key or throws a `JsonCrawlerException`. `filter()` adds its text without changes. `find()` accepts the object, and `(string) $path` gives the expression. Caution: `slice(2)` gives the index `[2]`, not the slice `[2:]`. `new JsonPath()`
- Stream input: `new JsonCrawler(fopen('catalog.json', 'r'))` reads a stream resource. This needs `symfony/json-streamer`, or `find()` throws a `\LogicException`. If the first segment is a dot-notation name or a non-negative index, and another segment follows, the crawler decodes only a part of the stream. For `$.store.book[1].title`, it decodes only `book[1]`. If the path starts with a bracket name (the `JsonPath` builder output) or `..`, the crawler decodes the full stream. Caution: a path with only one dot-notation name, such as `$.items`, can throw `InvalidJsonStringInputException` for a valid stream larger than 8192 bytes. For such a path, use `$["items"]`. `JsonCrawler::__construct()`
- Custom functions (8.1): put `#[AsJsonPathFunction('upper')]` on an invokable class. FrameworkBundle tags the service `json_path.function`. With FrameworkBundle, an expression must pass exactly the number of required `__invoke()` parameters. A custom function with the name of a built-in function replaces it. `#[AsJsonPathFunction]`
- Function return types: if the crawler has function metadata (as with FrameworkBundle), you must compare a `FunctionReturnType::Value` result (the default). A `Logical` or `Nodes` result is a filter test, and a comparison with it causes a `JsonCrawlerException`. `#[AsJsonPathFunction('is_positive', returnType: FunctionReturnType::Logical)]`
- Crawler factory (8.1): autowire `JsonPathCrawlerInterface`. Its `crawl($json)` method returns a crawler that knows the registered custom functions. A crawler from `new JsonCrawler($json)` does not know them. `JsonPathCrawlerInterface::crawl()`
- PHPUnit assertions: `JsonPathAssertionsTrait` adds 7 static assertions. The expected value of `assertJsonPathEquals()` and `assertJsonPathSame()` is the full result list, for example `[1]` and not `1`. Equals compares with `==`, Same compares with `===`, and Contains uses a strict `in_array()` by default. The assertions create a `JsonCrawler` without custom functions. `use JsonPathAssertionsTrait;`
- Errors: `find()` throws `JsonCrawlerException` for an invalid path, an unknown function or an exception in a custom function. For invalid JSON, `find()` throws `InvalidJsonStringInputException`. The constructor throws `InvalidArgumentException` only when the input is not a string or a resource. `Symfony\Component\JsonPath\Exception\ExceptionInterface`
- Limits against hostile queries: `match()` and `search()` run with a `pcre.backtrack_limit` of 10000 (CVE-2026-45756). A regular expression that reaches this limit gives no match. A filter longer than 10000 characters causes a `JsonCrawlerException`. More than 100 levels of `&&`, `||` and `!` also cause this exception, so a flat chain of 102 conditions fails. `JsonCrawler::find()`

## Entry points

- `Symfony\Component\JsonPath\JsonCrawler`: `new JsonCrawler($json)` with a string or a stream resource, then `find(string|JsonPath $query): array`. The optional second and third arguments are a PSR-11 container of custom functions and their metadata. `Symfony\Component\JsonPath\JsonCrawlerInterface` is the type of a crawler.
- Without FrameworkBundle: `new JsonCrawler($json)`. To add custom functions, pass a PSR-11 container of callables as the second constructor argument, and their metadata as the third.
- `Symfony\Component\JsonPath\JsonPathCrawlerInterface`: autowire it for crawlers with custom functions. `crawl($json)` returns a `JsonCrawlerInterface`. The service ID is `json_path.crawler` (class `JsonPathCrawler`). FrameworkBundle registers it when the package is installed, and no config key exists.
- `Symfony\Component\JsonPath\JsonPath`: the query builder.
- `Symfony\Component\JsonPath\Attribute\AsJsonPathFunction` (arguments `name` and `returnType`) and the enum `Symfony\Component\JsonPath\FunctionReturnType` (`Value`, `Logical`, `Nodes`). Without autoconfiguration, tag the service `json_path.function` with a `name` attribute. The `arity` and `return_type` (`value`, `logical` or `nodes`) attributes are optional.
- `Symfony\Component\JsonPath\Test\JsonPathAssertionsTrait`: `assertJsonPathEquals()`, `assertJsonPathNotEquals()`, `assertJsonPathSame()`, `assertJsonPathNotSame()`, `assertJsonPathCount()`, `assertJsonPathContains()` and `assertJsonPathNotContains()`. The arguments are the expected value, the path (`JsonPath|string`) and the JSON string.
- Exceptions in `Symfony\Component\JsonPath\Exception`: `JsonCrawlerException`, `InvalidJsonStringInputException`, `InvalidArgumentException` and the common `ExceptionInterface`.
- `composer require symfony/json-path`. For stream input, also run `composer require symfony/json-streamer`.
- The package has no config keys, console commands or Twig functions. `JsonPathUtils` and the classes in the `Tokenizer` namespace are `@internal`.

## Symbiotic packages

- [FrameworkBundle](../packages/framework-bundle.md): when `symfony/json-path` is installed, FrameworkBundle registers the `json_path.crawler` service (alias `JsonPathCrawlerInterface`) and autoconfigures `#[AsJsonPathFunction]` classes.
- [JsonStreamer](../packages/json-streamer.md): `JsonCrawler` uses its `Splitter` to query a stream resource; to decode JSON into typed objects, use the JsonStreamer `StreamReaderInterface` instead.
- [Serializer](../packages/serializer.md): use Serializer to deserialize a whole JSON payload into objects, and JsonPath to select values as arrays or scalars.
- [DomCrawler](../packages/dom-crawler.md): the docs present JsonPath as the JSON equivalent of DomCrawler; use DomCrawler for HTML or XML.
- [PropertyAccess](../packages/property-access.md): use `PropertyAccessorInterface::getValue()` to read one value at a fixed path of PHP data, and JsonPath to query JSON text.
- [FrameworkBundle test tools](../packages/framework-bundle-testing.md): the FrameworkBundle test traits have no JSONPath assertions, so use `JsonPathAssertionsTrait` in a `WebTestCase` on the response content.
- [ExpressionLanguage](../packages/expression-language.md): often confused; JsonPath uses RFC 9535 JSONPath expressions and does not use ExpressionLanguage.

## Changed in 8.0/8.1

- 8.1: custom filter functions. Before 8.1, `JsonCrawler` took only the JSON, and every function name except `length`, `count`, `match`, `search` and `value` caused a `JsonCrawlerException`. Now use `#[AsJsonPathFunction]`. Without FrameworkBundle, pass a PSR-11 container of callables as the second constructor argument.
- 8.1: `JsonPathCrawlerInterface`, an autowireable factory. In a service, `new JsonCrawler($json)` -> `$crawlerFactory->crawl($json)` when the expression uses custom functions.
- 8.1.7: FrameworkBundle fixes container compilation when a JsonPath function is registered. If you use `#[AsJsonPathFunction]`, require `symfony/framework-bundle` 8.1.7 or later.
- 8.0.15 and 8.1.2: a comparison with a non-singular query in parentheses now throws `JsonCrawlerException`. Before, `[?(@.tags[*] == "json")]` compared only the first selected tag. `[?(@.tags[*] == "json")]` -> `[?@.tags[?@ == "json"]]` (an existence test with a nested filter).

## Status

Not experimental. The backward compatibility promise applies, except to the `@internal` classes.

## Docs

- https://symfony.com/doc/current/components/json_path.html
- https://symfony.com/doc/current/reference/attributes.html
- https://symfony.com/doc/current/serializer/streaming_json.html
- https://symfony.com/doc/current/components/dom_crawler.html
- https://symfony.com/doc/current/contributing/code/bc.html
- https://datatracker.ietf.org/doc/html/rfc9535
