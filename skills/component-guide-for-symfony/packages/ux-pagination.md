# Symfony UX Pagination (`symfony/ux-pagination`)

**Applies to:** Symfony UX 3.5

**Elevator pitch:** Use when a database query, an array, an API result or a feed must show one page at a time, with page links or cursors. It reads the page from the request, fetches one page and counts only when necessary. The package is experimental and has no infinite-scroll script. For static pagination markup only, see [UX Toolkit](ux-toolkit.md).

**Details:** [../details/ux-pagination.md](../details/ux-pagination.md)

## Why it exists

By hand, a controller reads the page number from the URL, calculates the limit and the offset, and runs a count query. A template then builds the page links. The package does this work in one call: it validates the page or the signed cursor, fetches one page and counts only when necessary. Its Twig themes render plain links that keep the current filters, so the list works without JavaScript.

## When to use it

- Show a database list or a search result in pages, with page numbers and an exact total.
- Show only "Previous" and "Next" links for a feed when a count query is too slow or not necessary.
- Use keyset pagination with a stable cursor for a large table that changes often, for example an audit log.
- Keep the current filters and sort parameters in every page link.
- Return a paginated JSON response with the items, the totals and the previous and next links.
- Paginate a search engine or a remote API through callbacks or a custom adapter.
- Render a paginated list again on the server when a filter changes. See [UX Live Component](ux-live-component.md).
- Render Bootstrap, Tailwind or design-system pagination markup from one Twig function.

## Use it instead of

- `$page = max(1, $request->query->getInt('page', 1))` and `$qb->setFirstResult(($page - 1) * $limit)->setMaxResults($limit)` -> `$paginator->paginate($qb)` (`PaginatorInterface`).
- `new \Doctrine\ORM\Tools\Pagination\Paginator($query)` (deprecated in Doctrine ORM 3.7) and `ceil(count($paginator) / $limit)` -> `$paginator->paginate($qb)` with `getTotalItems()` and `getTotalPages()`.
- A DBAL `SELECT COUNT(*)` query and `LIMIT :limit OFFSET :offset` -> `$paginator->paginate($connection->createQueryBuilder()->select(...)->from(...))`.
- `{% for p in 1..totalPages %}<a href="?page={{ p }}">` or `http_build_query(array_merge($request->query->all(), ['page' => $p]))` -> `{{ ux_pagination(products) }}`, which keeps the query string.
- `WHERE e.id < :lastId ORDER BY e.id DESC` with `base64_encode($lastId)` in the URL -> `$paginator->cursor($qb)->orderBy(['createdAt', 'id'], 'DESC')->paginate()` (signed tokens).
- A `COUNT(*)` query only to show a "Next" link -> `$paginator->query($qb)->lookahead()->paginate()`.
- `count($pagination)` as the total number of rows -> `$pagination->getTotalItems()`. `count()` returns only the number of items on the current page.
- `Showing {{ (page - 1) * limit + 1 }}-{{ min(page * limit, total) }} of {{ total }}` in Twig -> `{{ products.info }}` (`getInfo()`), a translated summary, or `getFirstItemNumber()` and `getLastItemNumber()`.
- `if ($page > $lastPage) { throw $this->createNotFoundException(); }` -> `->throwOnOutOfRange()` (`OutOfRangePageException`, 404).
- A hand-built `['data' => ..., 'meta' => ['page' => ...], 'links' => [...]]` array -> `$this->json($pagination)`, or `getMetadata()` and `getLinks()`.
