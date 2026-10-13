# Symfony UX React (`symfony/ux-react`)

**Applies to:** Symfony UX 3.5

**Elevator pitch:** Use when server-rendered HTML pages must show React components, written in JSX or TSX, with initial props from PHP. It writes the component name and the props into the HTML, and its JavaScript mounts the component in the browser. It works with Vite, Rsbuild, webpack or [AssetMapper](asset-mapper.md). For interactive UI in PHP and Twig only, see [UX Live Component](ux-live-component.md).

**Details:** [../details/ux-react.md](../details/ux-react.md)

## Why it exists

A React component in a server-rendered page needs JavaScript that finds its root element, reads its props and mounts it. The package does this work. Its Twig function writes the component name and the props as data attributes, and its JavaScript mounts the component. For a front end that is completely a JavaScript application, the docs recommend the tools of that framework and Symfony as an API.

## When to use it

- Render a React component in a Twig template, with props from PHP.
- Add an interactive React widget to one part of a page that Twig renders.
- Give a React component its initial data from PHP code through the Twig template.
- Register all React components of one directory with Vite, Rsbuild, webpack or an import map.
- Use JSX components without a bundler, after a Babel step compiles them to JavaScript. See [AssetMapper](asset-mapper.md).
- Keep a React component mounted when other code moves its root element in the DOM, for example [UX Turbo](ux-turbo.md).
- Run JavaScript code when a React component mounts or unmounts.

## Use it instead of

- A custom script such as `document.querySelectorAll('[data-react]').forEach((el) => createRoot(el).render(<App {...JSON.parse(el.dataset.props)} />))` -> `react_component('App', props)` and the `@symfony/ux-react/react` Stimulus controller.
- `<div id="root" data-props="{{ props|json_encode|e('html_attr') }}"></div>` plus `JSON.parse(root.dataset.props)` -> `<div {{ react_component('App', props) }}></div>`, which JSON-encodes and escapes the props.
- `<script>window.initialProps = {{ props|json_encode|raw }};</script>` -> the `props` argument of `react_component()`, with one set of props for each root element.
- A hand-written Stimulus controller with `createRoot(this.element).render(...)` in `connect()` and `root.unmount()` in `disconnect()` -> the built-in controller, plus `{permanent: true}` if the root element moves.
- A manual registry such as `window.components = { Hello, ProductList }` -> `registerReactControllerComponents(import.meta.glob('./react/controllers/**/*.{jsx,tsx}', { eager: true }))` or `registerReactControllerComponents(require.context(...))`.
