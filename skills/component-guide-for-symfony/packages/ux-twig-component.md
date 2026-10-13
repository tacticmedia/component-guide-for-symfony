# UX Twig Component (`symfony/ux-twig-component`)

**Applies to:** Symfony UX 3.5

**Elevator pitch:** Use when a reusable UI fragment, such as an alert, a button, a modal or a card, needs its own props, markup and data. It joins a PHP class, or only a template, to one HTML-like Twig tag. It replaces most template includes and sub-requests. For a fragment that renders again over Ajax on user input, see [UX Live Component](ux-live-component.md).

**Details:** [../details/ux-twig-component.md](../details/ux-twig-component.md)

## Why it exists

A shared template fragment gets its variables from each page that includes it. So each page must repeat the database query and pass the right variables. The package joins a PHP object to a template, so the fragment keeps its props, its logic and its markup together. The Symfony docs recommend this package to render and reuse small template fragments.

## When to use it

- Create a reusable alert, button, modal or card that has its own Twig template.
- Replace an included template fragment that needs required props, default values or validation.
- Render a sidebar widget that loads its own data, without a sub-request to a controller.
- Pass HTML content and named blocks into a shared layout fragment.
- Merge default CSS classes and HTML attributes with the attributes that the caller passes.
- Map the color and size variants of a component to CSS classes.
- Share a value from a parent component with all its descendant components.
- Test the props and the rendered HTML of a template fragment in an automated test.

## Use it instead of

- `{{ include('_alert.html.twig', {type: 'danger', message: text}) }}` plus `{% set type = type|default('success') %}` in the partial -> an anonymous component with `{% props message, type = 'success' %}`, rendered as `<twig:Alert type="danger" :message="text" />`.
- `{{ render(controller('App\\Controller\\BlogController::recentArticles', {max: 3})) }}` -> an `#[AsTwigComponent]` class that injects the repository, rendered as `<twig:RecentArticles :max="3" />`. Keep `render(controller())` when you need a sub-request, for example to cache the fragment with ESI.
- `{% embed 'card.html.twig' %}{% block footer %}...{% endblock %}{% endembed %}` -> `<twig:Card>` with the content inside the tags and `<twig:block name="footer">`.
- `class="btn {{ extra_class|default('') }}"` plus a loop that prints `{{ key }}="{{ value|e('html_attr') }}"` -> `{{ attributes.defaults({class: 'btn'}) }}`. It merges the classes, escapes the values and omits `null` and `false` values. Only `aria-*` renders `false` as `"false"`.
- `{% set classes = {primary: 'btn-primary', danger: 'btn-danger'}[color] %}` -> `html_cva()` with `variants` and `default_variant`.
- `{% if message is not defined %}` checks in a partial, or `isset($data['type'])` checks in PHP -> `{% props message %}` (a missing required prop throws an error) or a `#[PreMount]` hook with `OptionsResolver`.
- A variable that each nested partial passes to the next partial -> nested components with `provide()` in the parent component and `inject()` in the descendant.
- `$twig->createTemplate('...')->render()` plus `str_contains()` in a test -> `renderTwigComponent()` and `$rendered->crawler()`.
