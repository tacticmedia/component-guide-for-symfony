# UX Autocomplete (`symfony/ux-autocomplete`)

**Applies to:** Symfony UX 3.5

**Elevator pitch:** Use when a select box or a text field in an HTML form needs type-ahead search, search over Ajax, or tag input. It turns form fields into searchable Tom Select controls, with an Ajax endpoint that you can secure. To autocomplete answers in a terminal prompt, see [Console](console.md). For a live list of search results, see [UX Live Component](ux-live-component.md).

**Details:** [../details/ux-autocomplete.md](../details/ux-autocomplete.md)

## Why it exists

A plain HTML select box has no search. A form field that lists database records also puts all records into the page as options. The package turns these fields into Tom Select controls with type-ahead search. For many options, the control loads the matching options from an Ajax endpoint that the package generates and can secure.

## When to use it

- Add type-ahead search to a long select field, for example a list of choices, database records or enum cases.
- Search many Doctrine entities through Ajax, and put only the selected entities into the page.
- Search an API, a search index or an in-memory list from a form field or a plain HTML select box.
- Let users type new tags as items in a text field.
- Let only users with a given role query the search endpoint.
- Pass server-side values, for example IDs to exclude, to the Ajax search with a tamper-proof checksum.
- Use a searchable select in a form that renders again on the server after each change. See [UX Live Component](ux-live-component.md).

## Use it instead of

- `new TomSelect('#product_category', {...})` or another select plugin in a custom script -> the `autocomplete` form option (`'autocomplete' => true`).
- A `#[Route('/search/foods')]` action that runs `->andWhere('f.name LIKE :q')` and returns `new JsonResponse($rows)` -> a field class with `#[AsEntityAutocompleteField]` and `BaseEntityAutocompleteType`; the bundle serves the `ux_autocomplete` route.
- An `EntityType` that renders all rows of a table as `<option>` elements -> `BaseEntityAutocompleteType`, which renders only the selected entities and searches through Ajax.
- `fetch('/search?q=' + input.value)` plus `list.innerHTML = html` for a suggestion dropdown -> the `symfony/ux-autocomplete/autocomplete` Stimulus controller with a `url` value; it escapes the result text.
- A "Load more" button that requests `?page=2` -> `new AutocompleteResults($results, $hasNextPage)`; the endpoint adds `next_page`, and the dropdown loads it on scroll.
- A query parameter such as `?exclude=12` that the browser can change -> the `extra_options` option; a changed value gives HTTP 400.
- `if (!$this->isGranted('ROLE_ADMIN')) { throw $this->createAccessDeniedException(); }` in a search action -> `'security' => 'ROLE_ADMIN'`, or `isGranted(Security $security)` in an autocompleter.
- A custom script that turns a comma-separated text field into tag chips -> `TextType` with `'autocomplete' => true` and `'tom_select_options' => ['create' => true, 'createOnBlur' => true, 'delimiter' => ',']`.
- `new TomSelect(element)` in a `MutationObserver` callback after each Live Component re-render -> the autocomplete controller, which sets `data-skip-morph` and rebuilds Tom Select.
