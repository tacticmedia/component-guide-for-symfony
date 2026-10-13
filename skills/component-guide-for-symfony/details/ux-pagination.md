# Symfony UX Pagination (`symfony/ux-pagination`): details

**Applies to:** Symfony UX 3.5

## Key features and concepts

- **One paginator service**: `PaginatorInterface::paginate($source)` returns a numbered result in one call. `query($source)` and `cursor($source)` return builders, and each builder method returns a changed copy. The supported sources are PHP arrays, Doctrine ORM and DBAL `QueryBuilder` objects, and the sources of custom adapters. Entry point: autowire `Symfony\UX\Pagination\PaginatorInterface`.
- **Page from the request**: Without a page argument, `paginate()` reads the route attribute `page`, then the query parameter `page`. If both are absent, the page is 1. A malformed, zero or negative value causes a `BadRequestHttpException` (400). `paginate(page: 3)` does not read the request, and a page below 1 then causes `InvalidArgumentException`. To change the parameter name, use `pageParameter('p')` or `ux_pagination.page_parameter`.
- **Offset strategy (default)**: The adapter fetches one page with `LIMIT` and `OFFSET`. The exact count runs only when code reads a total or checks for a next page, for example `getTotalItems()`, `hasNext()`, `getPages()` or `getInfo()`. The built-in themes call `hasNext()`, so `ux_pagination()` always needs the total. `total(int|callable)` supplies a known total, and the callable runs at most once. An offset above `max_offset` (default 100000) causes `OffsetLimitExceededException` (400) before the data query runs. By default, a page after the last page gives an empty result with status 200. `throwOnOutOfRange()` runs the count immediately and throws `OutOfRangePageException` (404). The bundle never redirects; if you need a redirect, write it in the controller.
- **Lookahead strategy**: `query($source)->lookahead()` fetches `perPage + 1` rows. The extra row shows if a next page exists, so no count query runs. `getTotalItems()` and `getTotalPages()` return `null`, and the built-in themes show only the previous and next links. `lookahead()` together with `total()` or `throwOnOutOfRange()` causes `InvalidArgumentException`.
- **Cursor strategy**: `cursor($source)->orderBy(['createdAt', 'id'], 'DESC')->paginate()` reads the `cursor` query parameter and returns a `CursorPagination`. It runs no count query and has no total, no page numbers and no direct page access. The ordered fields must be unique together. Doctrine ORM appends the missing identifier fields; with DBAL, put the primary key last. One direction applies to all fields. A Doctrine source must not have its own `ORDER BY`. An array source also needs `context()`.
- **Cursor tokens**: The links carry opaque cursor tokens. An HMAC-SHA256 signature with the cursor secret binds each token to the order and to a hash of the source context. `ux_pagination.cursor.secret` defaults to `%kernel.secret%`, and numbered pagination never reads it. The bundle does not encrypt the tokens, so clients can decode the boundary values. A malformed or invalid token, or a token longer than 4096 bytes, causes `InvalidCursorException` (400). For a tenant or user boundary that the query does not contain, add `context('tenant:'.$tenant->getId())`.
- **Navigation modes**: `sliding(size: 5)` (default) shows a moving window and adds first-page and last-page links with gaps. `fixed(10)` shows the pages in blocks. `full(500)` shows every page and throws `NavigationTooLargeException` above its maximum. The config keys are `ux_pagination.navigation.mode` and `ux_pagination.navigation.size`. `getPages()` gives entries with `page`, `url`, `isCurrent` and `isGap`.
- **Link URLs**: The links keep the current query string, so the filters stay in each link. The page 1 link has no page parameter, unless the route requires `{page}`. The links use the current route; if the route has a `{page}` placeholder, the page goes into the path. Change this with `route()`, `path()`, `fragment()`, `queryParameters()`, `discardQueryString()` and `excludeQueryParameters()`. `getAbsoluteUrl($page)` returns an absolute URL.
- **Doctrine adapters**: The ORM adapter clones the `QueryBuilder` and does not change the original. It uses Doctrine's `Paginator` only for collection-valued or unknown joins. It does not count a query with `GROUP BY`, `HAVING` or several root aliases (`UnsupportedDoctrineQueryException`); give a `total()` or use `lookahead()`. The DBAL adapter needs DBAL 4.4 or later and returns `fetchAllAssociative()` rows. The bundle registers each adapter only when the application has the matching Doctrine package.
- **Twig rendering**: `{{ ux_pagination(products) }}` renders a `<nav>` element with real links and no JavaScript. With UX Twig Component, `<twig:ux:pagination :pagination="products" />` gives the same result. Select `@UXPagination/theme/default.html.twig`, `@UXPagination/theme/bootstrap.html.twig` or `@UXPagination/theme/tailwind.html.twig` with `theme:` or `ux_pagination.theme`. Add attributes with `attributes`, `navigation_attributes` and `link_attributes` (an array or a closure); `link_attributes` cannot set `href`. When a result has no previous and no next link, the built-in themes render nothing. The labels use the `UXPaginationBundle` translation domain (10 locales). The optional `@symfony/ux-pagination/style.min.css` file has `--ux-pagination-*` CSS variables. With Tailwind, add `vendor/symfony/ux-pagination/templates` as a Tailwind source.
- **Named paginators**: `ux_pagination.paginators.<name>` overrides `items_per_page`, `max_offset`, `page_parameter`, `cursor_parameter` and `navigation` for one use case. Inject it with `#[Target('<name>')] PaginatorInterface $paginator`. The service ID is `ux_pagination.paginator.<name>`. `theme` and `cursor.secret` stay global. The bundle does not read a page size from the request.
- **Live Component integration**: `ComponentWithPaginationTrait` adds a writable `page` LiveProp that is in the URL, and the live actions `goToPage()`, `nextPage()` and `previousPage()`. Implement `createPagination(): PaginationBuilder`. When a filter changes, call `resetPage()`. Pass `this.paginationLinkAttributes` as `link_attributes`, so the links run live actions and keep their `href`. The trait supports numbered and lookahead pagination, not cursors.
- **JSON and APIs**: Both result types implement `JsonSerializable`. `$this->json($products)` returns `items`, `current_page`, `per_page`, `has_next`, `has_previous`, `total_items`, `total_pages` and `links`. A lookahead result has no `total_items` and `total_pages`. A cursor result returns `cursor`, `next_cursor` and `previous_cursor` instead of the page fields. For an application envelope, use `getMetadata()`, `getLinks()` and `map()`. Convert entity items to arrays or DTOs, or configure the Serializer for them.
- **Custom data sources**: `fromCallbacks(slice: fn (int $offset, int $limit): array => ..., count: fn (): int => ...)` paginates a one-off source with offset or lookahead pagination, not cursors. For a reusable source, implement `OffsetAdapterInterface`, `LookaheadAdapterInterface` or `CursorAdapterInterface`. Autoconfiguration adds the `ux_pagination.adapter` tag. The paginator selects the adapter with the highest priority that implements the strategy interface and whose `supports()` returns true.
- **Test helper**: `Symfony\UX\Pagination\Test\PaginatorFactory::create(request: Request::create('/products?page=2'), defaultPerPage: 10)` returns a real `Paginator` with the array adapter. It needs no kernel and no PHPUnit. Do not use it to configure a production service, because its default cursor secret is predictable.

## Entry points

- `Symfony\UX\Pagination\PaginatorInterface` (alias of the service `ux_pagination.paginator`): `paginate()`, `query()`, `cursor()`, `fromCallbacks()`.
- Named paginators: `#[Target('<name>')] PaginatorInterface $paginator`, or `#[Autowire(service: 'ux_pagination.paginator.<name>')]`.
- `Symfony\UX\Pagination\PaginationBuilder`: `perPage()`, `sliding()`, `fixed()`, `full()`, `lookahead()`, `total()`, `throwOnOutOfRange()`, `maxOffset()`, `pageParameter()`, `route()`, `path()`, `fragment()`, `queryParameters()`, `preserveQueryString()`, `discardQueryString()`, `excludeQueryParameters()`, `paginate(?int $page = null)`.
- `Symfony\UX\Pagination\CursorPaginationBuilder`: `orderBy()`, `perPage()`, `context()`, `cursor()`, `cursorParameter()`, `route()`, `path()`, `fragment()`, `queryParameters()`, `preserveQueryString()`, `discardQueryString()`, `excludeQueryParameters()`, `paginate()`.
- Results: `Symfony\UX\Pagination\PaginationInterface`, `NumberedPaginationInterface`, `CursorPaginationInterface`; the classes `Pagination` (`map()`, `getMetadata()`, `getLinks()`, `getAbsoluteUrl()`) and `CursorPagination` (`map()`, `getLinks()`).
- Adapters: `Symfony\UX\Pagination\Adapter\PaginationAdapterInterface`, `OffsetAdapterInterface`, `LookaheadAdapterInterface`, `CursorAdapterInterface` (tag `ux_pagination.adapter`); `Symfony\UX\Pagination\Cursor\CursorOrder`, `CursorBoundary`, `CursorSlice`.
- Exceptions: `Symfony\UX\Pagination\Exception\InvalidCursorException` (400), `OffsetLimitExceededException` (400), `OutOfRangePageException` (404), `NavigationTooLargeException`, `UnsupportedDoctrineQueryException`, `ExceptionInterface`.
- Live Component: `Symfony\UX\Pagination\LiveComponent\ComponentWithPaginationTrait`.
- Config: `ux_pagination.items_per_page`, `ux_pagination.max_offset`, `ux_pagination.page_parameter`, `ux_pagination.cursor_parameter`, `ux_pagination.navigation.mode`, `ux_pagination.navigation.size`, `ux_pagination.theme`, `ux_pagination.cursor.secret`, `ux_pagination.paginators.<name>`.
- Twig function: `ux_pagination(pagination, attributes, theme, show_info, navigation_attributes, link_attributes)`. Twig component: `<twig:ux:pagination>` (needs `symfony/ux-twig-component`). Themes: `@UXPagination/theme/default.html.twig`, `@UXPagination/theme/bootstrap.html.twig`, `@UXPagination/theme/tailwind.html.twig`. Translation domain: `UXPaginationBundle`.
- Assets: `@symfony/ux-pagination/style.min.css` with AssetMapper, or the npm package `@symfony/ux-pagination` with Webpack Encore.
- Console: the package has no command. Use `debug:autowiring PaginatorInterface`, `debug:config ux_pagination` and `debug:twig --filter=ux_pagination`.
- Tests: `Symfony\UX\Pagination\Test\PaginatorFactory::create()`.
- Bundle class: `Symfony\UX\Pagination\UXPaginationBundle`.

## Symbiotic packages

- [UX Twig Component](../packages/ux-twig-component.md): enables the `<twig:ux:pagination>` component syntax; the `ux_pagination()` function works without it.
- [UX Live Component](../packages/ux-live-component.md): `ComponentWithPaginationTrait` keeps the page in a URL-bound LiveProp, and its link attributes run live actions.
- [Symfony UX Turbo](../packages/ux-turbo.md): put the list and `ux_pagination()` in a `<turbo-frame>` to update only the list; Turbo Drive follows the ordinary links.
- [UX Toolkit](../packages/ux-toolkit.md): its Pagination component is static markup, and you write each `href`; use UX Pagination for data, page logic and URLs.
- [TwigBundle](../packages/twig-bundle.md): a required dependency; the bundle registers `ux_pagination()` and its renderer only when the application enables TwigBundle.
- [Routing](../packages/routing.md): generates the page links from the current route, and puts the page in the path when the route has a `{page}` placeholder.
- [HttpFoundation](../packages/http-foundation.md): the current `Request` supplies the page and the cursor, and `getInt()` converts the page value.
- [HttpKernel](../packages/http-kernel.md): turns `InvalidCursorException`, `OffsetLimitExceededException` and `OutOfRangePageException` into 400 and 404 responses.
- [DependencyInjection](../packages/dependency-injection.md): `#[Target]` injects a named paginator, and `#[AsTaggedItem]` sets the priority of a custom adapter.
- [Translation](../packages/translation.md): translates the labels and the summary in the `UXPaginationBundle` domain; without it, the English message IDs show.
- [AssetMapper](../packages/asset-mapper.md): the bundle adds its `assets/dist` folder as `@symfony/ux-pagination`, so `asset('@symfony/ux-pagination/style.min.css')` works.
- [WebpackEncoreBundle](../packages/webpack-encore-bundle.md): install the npm package `@symfony/ux-pagination` and import `style.min.css` in the entrypoint.
- [Serializer](../packages/serializer.md): `$this->json($pagination)` gives the envelope; configure the Serializer, or map to arrays or DTOs, for the entity items.
- [FrameworkBundle test tools](../packages/framework-bundle-testing.md): use `WebTestCase` to test that the page links keep the filters.
- [DomCrawler](../packages/dom-crawler.md): `$crawler->selectLink('Next')->link()->getUri()` reads a generated page link in a functional test.
- [Symfony Flex](../packages/flex.md): the recipe repositories have no recipe for this bundle, but Flex registers `UXPaginationBundle` with an auto-generated recipe.

## Changed in UX 3.5 and Symfony 8.1

- UX 3.5.0 (2026-09-18) adds this package. Older Symfony code paginates by hand with `setFirstResult()`, `setMaxResults()` and Doctrine's `Paginator`. Use `PaginatorInterface` instead.
- Symfony 8.0 removes `Request::get()`, so `$request->get('page', 1)` fails. Call `paginate()` without a page: it reads the route attribute, then the query parameter.
- Symfony 8.1: `ParameterBag::getInt()` throws `Symfony\Component\HttpFoundation\Exception\UnexpectedValueException` for a value that it cannot convert. On `$request->query`, `getInt()` throws `BadRequestException`. Both still accept 0 and negative numbers. `paginate()` turns all of these values into a 400 response.
- Symfony 8.1 deprecates the match of a named autowiring alias by the parameter name only. The docs inject `PaginatorInterface $productsPaginator` and `$blogPaginator` in constructors this way. Use `#[Target('products')] PaginatorInterface $paginator`. A controller action argument does not trigger this deprecation.
- Symfony 8.1 deprecates default priority methods of tagged services. The docs give a custom adapter a static `getDefaultPriority()` method. Put `#[AsTaggedItem(priority: 100)]` on an autoconfigured adapter class instead.

## Status

- Experimental. The README and the docs state: "This bundle is currently experimental and is likely to change, possibly significantly, before its first stable release."
- It needs PHP 8.4 or later, Symfony 7.4 or 8.x and TwigBundle.
- symfony/recipes and symfony/recipes-contrib have no recipe for this package. Flex adds `UXPaginationBundle` to `config/bundles.php` with an auto-generated recipe. Flex creates no config file, and the defaults apply.
- On Symfony 8.1, the bundle's own adapter iterator (`defaultPriorityMethod: 'getDefaultPriority'`) triggers a deprecation notice when Symfony builds the container. The application cannot remove this notice.

## Docs

- https://symfony.com/bundles/ux-pagination/current/index.html
- https://symfony.com/bundles/ux-pagination/current/installation.html
- https://symfony.com/bundles/ux-pagination/current/getting-started.html
- https://symfony.com/bundles/ux-pagination/current/strategies.html
- https://symfony.com/bundles/ux-pagination/current/cursor.html
- https://symfony.com/bundles/ux-pagination/current/rendering.html
- https://symfony.com/bundles/ux-pagination/current/configuration.html
- https://symfony.com/bundles/ux-pagination/current/doctrine.html
- https://symfony.com/bundles/ux-pagination/current/live-component.html
- https://symfony.com/bundles/ux-pagination/current/integrations.html
- https://symfony.com/bundles/ux-pagination/current/custom-adapters.html
- https://symfony.com/bundles/ux-pagination/current/testing.html
- https://symfony.com/bundles/ux-pagination/current/debugging.html
- https://symfony.com/bundles/ux-pagination/current/production.html
- https://symfony.com/bundles/ux-pagination/current/adopting.html
