# UX Twig Component (`symfony/ux-twig-component`): details

**Applies to:** Symfony UX 3.5

## Key features and concepts

- **Class components:** `#[AsTwigComponent]` registers a class as a component service. The public properties are the props, and the template reads them directly or through `this`. Entry point: `Symfony\UX\TwigComponent\Attribute\AsTwigComponent` (arguments `name`, `template`, `exposePublicProps`, `attributesVar`).
- **Names and template paths:** The name is the class name after the configured namespace, with `:` in place of `\`. `App\Twig\Components\Button\Primary` becomes `Button:Primary`, with the template `templates/components/Button/Primary.html.twig`. Entry point: `twig_component.defaults`.
- **Three render syntaxes:** The `component()` function, the HTML syntax and the `{% component %}` tag render a component. In the HTML syntax, a `:` prefix passes a Twig expression. For a boolean prop, the string `"false"` becomes `true`. To pass `false`, write `:withCloseButton="false"`. Entry point: `component('Alert', {type: 'danger'})`, `<twig:Alert :user="user.id" />`, `{% component Alert with {type: 'danger'} %}...{% endcomponent %}`.
- **Anonymous components:** A template in `templates/components/` without a PHP class is also a component. `{% props icon, type = 'primary' %}` declares its props, and a prop without a default value is required. Entry point: `{% props %}`, `twig_component.anonymous_template_directory`, `components/Menu/index.html.twig` for the `Menu` component.
- **Blocks:** The content between the tags goes into the `content` block, and `<twig:block name="footer">` fills another block. `outerBlocks` forwards the blocks of the outer template, and `outerScope` reads the variables of the parent template. A wrapper component passes its content and attributes to an inner component with `block(outerBlocks.content)` and `{{ ...attributes }}`. Inside nested components, do not mix `{% block %}` with the HTML syntax. Inside the content of a component, import a macro by its template path, because `_self` does not work there. Entry point: `{% block content %}{% endblock %}`, `<twig:block>`, `block(outerBlocks.content)`, `outerScope.this`.
- **Attributes:** Props that the component cannot mount become HTML attributes in the `attributes` variable. `defaults()` merges default attributes; for `class`, `data-controller` and `data-action`, it puts the default value before the passed value. `only()`, `without()`, `nested('title')` and `render('style')` select attributes. Entry point: `{{ attributes.defaults({class: 'btn'}) }}`, `Symfony\UX\TwigComponent\ComponentAttributes`.
- **Mount hooks:** The system calls `mount()` before it sets the props, so in `mount()`, the properties do not have the passed values yet. To read a prop in `mount()`, declare an argument with the same name. The system then does not set the prop on a property or add it to `attributes`. `#[PreMount]` changes or validates the props array before the system mounts it, and `#[PostMount]` runs after the system sets the properties. A hook with a higher `priority` runs first. Do not declare the component class or its public properties `readonly`, because the system sets props after the constructor. Entry point: `mount()`, `Symfony\UX\TwigComponent\Attribute\PreMount`, `Symfony\UX\TwigComponent\Attribute\PostMount`.
- **Services and lazy data:** A component is an autowired service, and each render gets a new instance. A `getProducts()` method runs only when the template reads `this.products`. `computed.products` keeps the result for the rest of the render. Entry point: constructor injection, `this.<name>`, `computed.<name>`.
- **Template variables:** `#[ExposeInTemplate]` makes a private property (with a getter) or a public method available as a template variable. `exposePublicProps: false` hides the public properties, and the template then uses `this.<name>`. Entry point: `Symfony\UX\TwigComponent\Attribute\ExposeInTemplate`.
- **Dynamic templates and names:** `template: new FromMethod('getTemplate')` selects the template before the component renders. `<twig:component is="{{ name }}">` and `{% component (prefix ~ i) %}` render a component whose name is in a variable. Entry point: `Symfony\UX\TwigComponent\Attribute\FromMethod`.
- **Shared state:** `provide('key', value)` in the template of a parent component publishes a value. `inject('key', default)` reads it in any descendant, so the components between them do not forward it. Values flow from parent to child only. Call `provide()` before `{% block content %}`, because a descendant sees a value only after `provide()` runs. Outside a component template, `provide()` throws a `LogicException`. Entry point: `provide()`, `inject()`.
- **Class variants (CVA):** `html_cva()` maps variant props such as `color` and `size` to CSS classes. `apply()` returns the classes for the passed values and adds extra classes, for example the `class` attribute of the caller. In a Symfony application, install `twig/extra-bundle` to get `html_cva()`. Entry point: `html_cva(base: ..., variants: ..., default_variant: ...)`, `button.apply({color, size}, attributes.render('class'))`.
- **Bundle components:** A bundle can ship anonymous components in its `templates/components/` directory. Render them with the Twig namespace of the bundle as a prefix, for example `<twig:Acme:Button>`. Entry point: `@Acme/components/Button.html.twig`.
- **Lifecycle events:** Event listeners can change all components. `PreRenderEvent` changes the template and the variables, and `PreCreateForRenderEvent` can return HTML and skip the render. Entry point: `Symfony\UX\TwigComponent\Event\PreMountEvent`, `PostMountEvent`, `PreCreateForRenderEvent`, `PreRenderEvent`, `PostRenderEvent`.
- **Test and debug tools:** `InteractsWithTwigComponents` mounts or renders a component in a `KernelTestCase`, and `crawler()` returns a DomCrawler `Crawler`. `debug:twig-component` lists all components, and the profiler panel shows each render. Entry point: `mountTwigComponent()`, `renderTwigComponent()`, `debug:twig-component`.

## Entry points

- Install: `composer require symfony/ux-twig-component`. The Flex recipe enables `TwigComponentBundle` and writes `config/packages/twig_component.yaml`. You must also enable TwigBundle.
- Attributes: `Symfony\UX\TwigComponent\Attribute\AsTwigComponent`, `Symfony\UX\TwigComponent\Attribute\PreMount`, `Symfony\UX\TwigComponent\Attribute\PostMount`, `Symfony\UX\TwigComponent\Attribute\ExposeInTemplate`, `Symfony\UX\TwigComponent\Attribute\FromMethod` (as `template: new FromMethod('method')`).
- Component class conventions: public properties for props, a `mount()` method, and public methods that the template reads through `this` or `computed`.
- Type to autowire: `Symfony\UX\TwigComponent\ComponentRendererInterface`; `createAndRender(string $name, array $props = []): string` renders a component to a string in PHP.
- Twig functions and tags: `component()`, `provide()`, `inject()`, `{% component Name with {...} %}...{% endcomponent %}`, `{% props %}`.
- HTML syntax: `<twig:Name prop="..." :prop="expression" />`, `<twig:block name="...">`, `<twig:component is="...">`, `{{ ...attributes }}` (spread).
- Template variables: `attributes` (`Symfony\UX\TwigComponent\ComponentAttributes` with `defaults()`, `only()`, `without()`, `nested()`, `render()`, `remove()`, `has()`, `all()`), `this`, `computed`, `outerScope`, `outerBlocks`.
- Config keys: `twig_component.defaults` (required; a map of a namespace that ends in `\` to a directory, or to `template_directory` and `name_prefix`), `twig_component.anonymous_template_directory` (required).
- Profiler config keys: `twig_component.profiler.enabled` (default `%kernel.debug%`), `twig_component.profiler.collect_components` (default `true`).
- Events: `Symfony\UX\TwigComponent\Event\PreMountEvent`, `PostMountEvent`, `PreCreateForRenderEvent`, `PreRenderEvent`, `PostRenderEvent`.
- Console commands: `debug:twig-component [name]`; `make:twig-component [name] [--live]` (MakerBundle); `config:dump-reference twig_component` (FrameworkBundle).
- Test helpers: `Symfony\UX\TwigComponent\Test\InteractsWithTwigComponents` (`mountTwigComponent(name, data)`, `renderTwigComponent(name, data, content, blocks)`), `Symfony\UX\TwigComponent\Test\RenderedComponent` (`crawler()`, `toString()`).
- Service tag: `twig.component`. Autoconfiguration adds it to each `#[AsTwigComponent]` class.

## Symbiotic packages

- [UX Live Component](../packages/ux-live-component.md): Live Component builds on this package, and `#[AsLiveComponent]` extends `AsTwigComponent`. Use Live Component when the component must re-render with Ajax as the user interacts with it.
- [StimulusBundle](../packages/stimulus-bundle.md): `{{ attributes.defaults(stimulus_controller('dropdown')) }}` attaches a Stimulus controller to the root element of a component.
- [TwigBundle](../packages/twig-bundle.md): This package needs TwigBundle, and its bundle extension throws a `LogicException` when the application does not register TwigBundle.
- [Twig Bridge](../packages/twig-bridge.md): The bridge gives `render(controller())` for embedded controllers. The Symfony docs prefer Twig components for reusable UI units, and keep embedded controllers for sub-requests, for example a fragment that ESI caches.
- [MakerBundle](../packages/maker-bundle.md): `make:twig-component` generates the component class and its template; the `--live` option generates a Live Component.
- [Symfony UX Turbo](../packages/ux-turbo.md): UX Turbo ships `<twig:Turbo:Frame>` and the `<twig:Turbo:Stream:*>` tags (for example `<twig:Turbo:Stream:Append>`) as anonymous Twig components of its bundle. These tags need this package.
- [UX Icons](../packages/ux-icons.md): When this package is installed, `<twig:ux:icon name="...">` renders an SVG icon in the HTML syntax.
- [UX Map](../packages/ux-map.md): The `<twig:ux:map>` component of UX Map needs this package.
- [Symfony UX Pagination](../packages/ux-pagination.md): The `<twig:ux:pagination>` syntax needs this package, and the `ux_pagination()` function works without it.
- [UX Toolkit](../packages/ux-toolkit.md): The experimental Toolkit copies ready-made Twig component recipes (for example `button` and `dialog`) into your templates. The recipes need this package at runtime. The Toolkit is a dev dependency, so add this package to `require` yourself. The `composer require` command that `ux:install` prints does not include it for most `bootstrap` and `common` recipes.
- [PropertyAccess](../packages/property-access.md): This package requires PropertyAccess to write the props to the component properties, also through setters such as `setMessage()`.
- [EventDispatcher](../packages/event-dispatcher.md): This package requires EventDispatcher to dispatch the mount and render events of each component.
- [OptionsResolver](../packages/options-resolver.md): A `#[PreMount]` hook uses `OptionsResolver` to validate props and set their default values.
- [FrameworkBundle test tools](../packages/framework-bundle-testing.md): `InteractsWithTwigComponents` works only in tests that extend `KernelTestCase`.
- [DomCrawler](../packages/dom-crawler.md): `RenderedComponent::crawler()` needs `symfony/dom-crawler`.
- [WebProfilerBundle](../packages/web-profiler-bundle.md): The "Twig Components" profiler panel shows the render count, the render time and the props of each component.
- [CssSelector](../packages/css-selector.md): CSS selectors such as `filter('ul li')` on the `crawler()` of a `RenderedComponent` need CssSelector.

## Changed in 3.0 to 3.5

- `cva({base: ..., compoundVariants: ..., defaultVariants: ...})` -> `html_cva(base: ..., compound_variants: ..., default_variant: ...)` from `twig/html-extra` (TwigComponent 3.0 removes `cva()`). Write `default_variant`, not `default_variants`, because the plural name throws an "Unknown argument" error.
- `attributes.add(stimulus_controller('...'))` -> `attributes.defaults(stimulus_controller('...'))` (TwigComponent 3.0 removes `add()`).
- `PreCreateForRenderEvent::getProps()` -> `PreCreateForRenderEvent::getInputProps()` (removed in TwigComponent 3.0).
- A `twig_component` config without `defaults` -> add `defaults`, for example `App\Twig\Components\: 'components/'` (required since TwigComponent 3.0).
- TwigComponent 3.0 needs PHP 8.4 or later and Symfony 7.4 or later; the 3.x line supports Symfony 8.
- Props that each level passes down by hand -> `provide()` in the parent and `inject()` in the descendant (new in TwigComponent 3.1).
- A component name in a variable, with blocks -> `{% component (prefix ~ i) %}` (new in 3.4) or `<twig:component is="{{ name }}">` (new in 3.5).
- TwigComponent 3.5 renders attributes through `html_attr()`. `true` renders `name=""` (`"true"` for `aria-*` and `data-*`), and `null` omits the attribute instead of an exception. On `aria-*`, `false` renders `"false"`. Update the HTML assertions in your tests.

## Docs

- https://symfony.com/bundles/ux-twig-component/current/index.html
- https://symfony.com/doc/current/templates.html
- https://ux.symfony.com/twig-component
- https://twig.symfony.com/doc/3.x/functions/html_cva.html
