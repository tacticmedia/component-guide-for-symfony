# UX Live Component (`symfony/ux-live-component`)

**Applies to:** Symfony UX 3.5

**Elevator pitch:** Use when one page region must render again on the server after each user input, such as live search, field validation, dependent fields or polling. It keeps the state in PHP properties and sends the new HTML over Ajax, with no custom JavaScript. For page navigation, page parts from other URLs and server push, see [UX Turbo](ux-turbo.md).

**Details:** [../details/ux-live-component.md](../details/ux-live-component.md)

## Why it exists

A page often must update one region after each user input, for example a list of search results. By hand, you write an Ajax endpoint and JavaScript that sends the input and replaces the HTML. The package keeps the state of the region in PHP properties and renders its Twig template again on the server. The browser then merges the new HTML into the page.

## When to use it

- Render a list of search results again on the server while the user types.
- Validate form fields on the server while the user edits the form.
- Update a dependent form field when the user changes another field, for example the state list of a country.
- Add and remove the rows of a form collection without custom JavaScript.
- Refresh a region of the page at a fixed interval with polling.
- Render a slow region of the page after the page loads, or when the user scrolls to it.
- Keep the search text, the filters and the page number of a page region in the URL.
- Start a file download from a button click, while the page region keeps its state.

## Use it instead of

- `fetch('/search?q=' + input.value)` in an `input` listener, then `list.innerHTML = html` -> a writable LiveProp bound with `data-model` (`#[LiveProp(writable: true)]`).
- `setTimeout()` and `clearTimeout()` around an `input` listener to limit the requests -> the debounce of `data-model` (150 ms by default, `data-model="debounce(300)|query"`).
- `setInterval(() => fetch(url).then(...), 2000)` to refresh a widget -> `data-poll` (`data-poll="delay(5000)|$render"`).
- A `change` listener that posts the form with `fetch()`, parses the HTML with `DOMParser` and copies `stateSelect.innerHTML` -> a form in a live component (`ComponentWithFormTrait`).
- An Ajax endpoint that returns form errors as JSON, plus JavaScript that shows them next to the fields -> `ComponentWithFormTrait`, or `ValidatableComponentTrait` with `_errors`.
- JavaScript that clones `data-prototype` and replaces `__name__` to add collection rows -> `LiveCollectionType` with `LiveCollectionTrait`.
- `history.replaceState()` with `URLSearchParams` to keep filters in the URL -> `#[LiveProp(writable: true, url: true)]` and `UrlMapping`.
- `render_hinclude()` with hinclude.js (a legacy technique in the Symfony docs), or an `IntersectionObserver` that fetches a widget -> `{{ component('Name', {loading: 'lazy'}) }}` or `loading: 'defer'`.
- A temporary file plus a redirect to a download route, or `URL.createObjectURL(blob)` in JavaScript -> `LiveResponse::downloadFile()` or `LiveResponse::downloadUrl()`.
- `fetch(url, {method: 'POST'})` followed by `element.remove()` to dismiss a notification -> `LiveResponse::remove()`.
