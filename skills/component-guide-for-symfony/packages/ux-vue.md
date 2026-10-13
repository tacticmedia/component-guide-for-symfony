# Symfony UX Vue.js (`symfony/ux-vue`)

**Applies to:** Symfony UX 3.5

**Elevator pitch:** Use when server-rendered HTML pages must show Vue 3 components with initial props from PHP. It writes the component name and the props into the HTML, and its JavaScript mounts one Vue app on each element. It works with Vite, Rsbuild, webpack or [AssetMapper](asset-mapper.md). For React, see [UX React](ux-react.md). For interactive UI in PHP and Twig only, see [UX Live Component](ux-live-component.md).

**Details:** [../details/ux-vue.md](../details/ux-vue.md)

## Why it exists

A Vue component in a server-rendered page needs JavaScript that finds its element, reads its props and mounts a Vue app. The package writes the component name and the props as data attributes, and its JavaScript mounts the component. For a front end that is completely a Vue application, the Symfony docs recommend the Vue tools and Symfony as an API.

## When to use it

- Render a Vue 3 component in a Twig template, with props from PHP.
- Add an interactive Vue widget to one part of a page that Twig renders.
- Register all Vue components of one directory with one function call.
- Compile Vue single-file components with Vite, Rsbuild or webpack, and render them from Twig.
- Use Vue components with no build step, as plain JavaScript files. See [AssetMapper](asset-mapper.md).
- Add a Vue plugin, a global directive or Vue Router to each Vue app before it mounts.
- Load the code of a Vue component only when a page shows the component.

## Use it instead of

- A page script such as `createApp(App, JSON.parse(el.dataset.props)).mount(el)` for each root element -> `vue_component('App', props)` and the `@symfony/ux-vue/vue` Stimulus controller.
- `<div id="app" data-props="{{ props|json_encode|e('html_attr') }}"></div>` plus `JSON.parse()` -> `<div {{ vue_component('App', props) }}></div>`, which JSON-encodes and escapes the props.
- A hand-written Stimulus controller with `createApp(...).mount(this.element)` in `connect()` and `app.unmount()` in `disconnect()` -> the built-in controller that `vue_component()` adds.
- A manual registry such as `import Hello from './vue/controllers/Hello.vue'` plus `window.components = { Hello }` -> `registerVueControllerComponents(import.meta.glob('./vue/controllers/**/*.vue', { eager: true }))`, or `require.context()` with Encore.
- A Vue template inside a Twig template, with the Vue `delimiters` option set to `['${', '}$']` -> a component file in `assets/vue/controllers/` that `vue_component()` renders.
- `app.use(router)` in a custom mount script -> a `vue:before-mount` listener that calls `event.detail.app.use(router)`.
