# UX Chart.js (`symfony/ux-chartjs`): details

**Applies to:** Symfony UX 3.5

## Key features and concepts

- Chart builder: autowire the builder interface. Call `createChart()` with a chart type. The method returns a new `Chart` object. The service ID is `chartjs.builder`. `Symfony\UX\Chartjs\Builder\ChartBuilderInterface::createChart(string $type): Chart`
- Chart types: the `Chart` class has eight type constants: `TYPE_LINE`, `TYPE_BAR`, `TYPE_RADAR`, `TYPE_PIE`, `TYPE_DOUGHNUT`, `TYPE_POLAR_AREA`, `TYPE_BUBBLE` and `TYPE_SCATTER`. The type is a string, and the bundle does not validate it. For a horizontal bar chart, use `TYPE_BAR` with `setOptions(['indexAxis' => 'y'])`. Chart.js has no `horizontalBar` type, and the `Chart` class has no `TYPE_BAR_HORIZONTAL` constant. `Symfony\UX\Chartjs\Model\Chart`
- Data and options: `setData()` and `setOptions()` take PHP arrays. The bundle gives them to Chart.js as they are, so the Chart.js documentation applies. Write the options in the Chart.js 3 or 4 format, for example `'scales' => ['y' => ['suggestedMin' => 0]]`. Each setter returns the chart. `Chart::setData()`, `Chart::setOptions()`
- Twig function: `render_chart(chart)` renders a `<canvas>` element with the `symfony--ux-chartjs--chart` Stimulus controller. A `view` value on the element holds the JSON of `type`, `data` and `options`. The second argument adds HTML attributes to the canvas, for example `{'class': 'my-chart'}`. A `true` value gives a boolean attribute, and a `false` value removes the attribute. `render_chart(chart, attributes)`
- Stimulus controller: when the canvas connects, the controller calls `new Chart()` on it. When the canvas disconnects, the controller destroys the chart. The controller registers the Chart.js `registerables` (all built-in chart types, elements, plugins and scales), so you do not register them yourself. If the element is not a `<canvas>`, the controller throws an error. `@symfony/ux-chartjs/chart`
- JavaScript events: the controller dispatches bubbling events with the `chartjs:` prefix. `chartjs:init` occurs one time, before the controller creates the first chart (`event.detail.Chart`). `chartjs:pre-connect` occurs before `new Chart()` (`event.detail.config`, `event.detail.options`). `chartjs:connect` gives the new chart (`event.detail.chart`). `chartjs:view-value-change` occurs before an update (`event.detail.data`, `event.detail.options`). `chartjs:disconnect` occurs before `destroy()` (`event.detail.chart`). The docs describe only `init`, `pre-connect` and `connect`.
- Global plugins: install the plugin package, for example with `npm install chartjs-plugin-zoom -D`. With AssetMapper, use `php bin/console importmap:require` instead of npm. Then, in `assets/app.js`, listen to `chartjs:init`. In the listener, call `event.detail.Chart.register(zoomPlugin)`. Configure the plugin in `setOptions()`, for example `'plugins' => ['zoom' => [...]]`. Use the same event for other global changes, for example a custom tooltip positioner. `chartjs:init`
- Custom controller: add your Stimulus controller to the canvas with `render_chart(chart, {'data-controller': 'mychart'})` or with `Chart::setAttributes()`. `render_chart()` puts your controller before the chart controller in `data-controller`. In your controller, listen to `chartjs:pre-connect` to change `event.detail.config`, or to `chartjs:connect` to use the `Chart` instance. Use this for JavaScript functions, for example tick callbacks, because the PHP options become JSON. `chartjs:pre-connect`, `chartjs:connect`
- Live Component update: if the `view` value changes, the controller puts the new `data` and `options` on the existing chart and calls `chart.update()`. The chart type does not change. In a live component, a re-render morphs the new attribute value onto the canvas, so the chart updates in place. Build the chart in a component method, for example `getChart()` with `#[ExposeInTemplate]`. Put `{{ render_chart(chart) }}` in the component template. Stimulus callback `viewValueChanged()`
- Callbacks after an update: an update replaces `chart.options` with the new options from the server. The chart then loses the callbacks that you added in `chartjs:pre-connect` or `chartjs:connect`. To add them again, change `event.detail.options` in a `chartjs:view-value-change` listener. `chartjs:view-value-change`
- Asset installation: no Flex recipe exists. Flex registers `ChartjsBundle` and reads the `symfony` key in the `assets/package.json` file of the package. With AssetMapper, Flex runs `importmap:require` for `chart.js` (`^3.4.1 || ^4.0`) and `@hotwired/stimulus` if they are missing or their version does not match. The bundle maps its `assets/dist` directory as `@symfony/ux-chartjs`. With Webpack Encore, Flex adds `@symfony/ux-chartjs` (`file:vendor/symfony/ux-chartjs/assets`) and `chart.js` to `package.json`. In both cases, Flex adds the `chart` controller to `assets/controllers.json`. `assets/controllers.json`
- Lazy controller: if few pages show a chart, set `"fetch": "lazy"` for the `chart` controller in `assets/controllers.json`. Then the browser loads the controller and Chart.js only when a chart canvas appears on the page. `assets/controllers.json`

## Entry points

- Autowire `Symfony\UX\Chartjs\Builder\ChartBuilderInterface` (service ID `chartjs.builder`, class `Symfony\UX\Chartjs\Builder\ChartBuilder`): `createChart(string $type): Chart`.
- Class `Symfony\UX\Chartjs\Model\Chart`: the `TYPE_*` constants, `setData()`, `setOptions()`, `setAttributes()`, `getType()`, `getData()`, `getOptions()`, `getAttributes()`, `getDataController()` and `createView()`.
- Twig function `render_chart(chart, attributes = {})` from `Symfony\UX\Chartjs\Twig\ChartExtension` (service ID `chartjs.twig_extension`).
- Stimulus controller `@symfony/ux-chartjs/chart` (HTML name `symfony--ux-chartjs--chart`), with the `view` value (attribute `data-symfony--ux-chartjs--chart-view-value`).
- JavaScript events: `chartjs:init`, `chartjs:pre-connect`, `chartjs:connect`, `chartjs:view-value-change`, `chartjs:disconnect`.
- `assets/controllers.json` entry: `"@symfony/ux-chartjs": {"chart": {"enabled": true, "fetch": "eager"}}`.
- Installation: `composer require symfony/ux-chartjs`. With Webpack Encore, also run `npm install --force` and `npm run watch`. The npm package `@symfony/ux-chartjs` is for advanced setups only, and its version must be the same as the version of the PHP package.
- Bundle class `Symfony\UX\Chartjs\ChartjsBundle`. The bundle has no configuration keys, console commands or PHP attributes.

## Symbiotic packages

- [StimulusBundle](../packages/stimulus-bundle.md): this bundle requires StimulusBundle; `render_chart()` builds the canvas attributes with `StimulusHelper`, and with AssetMapper, StimulusBundle loads the chart controller from `assets/controllers.json`.
- [UX Live Component](../packages/ux-live-component.md): put `render_chart()` in a live component template; each re-render changes the `view` value, and the chart updates in place.
- [UX Twig Component](../packages/ux-twig-component.md): a reusable component can build the chart in a `getChart()` method that `#[ExposeInTemplate]` exposes as `chart`.
- [AssetMapper](../packages/asset-mapper.md): the bundle maps its JavaScript as `@symfony/ux-chartjs`, and Flex adds `chart.js` to `importmap.php`, so no build step is necessary.
- [WebpackEncoreBundle](../packages/webpack-encore-bundle.md): with Webpack Encore, Flex adds the package and `chart.js` to `package.json`, and you run `npm install --force` and restart Encore.
- [Symfony Flex](../packages/flex.md): no recipe exists, so Flex registers the bundle with an auto-generated recipe and uses the controller and importmap settings of `assets/package.json`.
- [TwigBundle](../packages/twig-bundle.md): TwigBundle collects the services with the `twig.extension` tag, which makes `render_chart()` available in templates.

## Changed in UX 2.0 to 3.5

- Chart.js 3 (UX 2.0) and Chart.js 4 (UX 2.14): write `'scales' => ['y' => ['min' => 0]]`, not the Chart.js 2 format `'scales' => ['yAxes' => [['ticks' => ['min' => 0]]]]`. The `Chart::setOptions()` docblock still shows the old format.
- 2.8: the chart updates when the `view` value changes, so `render_chart()` works in a live component.
- 2.9: AssetMapper works without npm, and the bundle requires `symfony/stimulus-bundle`.
- 2.17: listen to `chartjs:view-value-change` to change `data` or `options` before an update.
- 2.23: the controller destroys the chart on the Stimulus `disconnect`. You do not need to call `chart.destroy()`.
- 3.0: the bundle requires PHP 8.4 and Symfony 7.4 or later. It no longer uses the `StimulusTwigExtension` of WebpackEncoreBundle 1.x; it uses the `StimulusHelper` of StimulusBundle.

## Docs

- https://symfony.com/bundles/ux-chartjs/current/index.html
- https://ux.symfony.com/chartjs
- https://ux.symfony.com/demos/live-component/chartjs (Live Component demo: `DinoChart`)
- https://symfony.com/bundles/StimulusBundle/current/index.html (controller loading, `controllers.json`, lazy controllers)
- https://symfony.com/bundles/ux-live-component/current/index.html (re-render and morphing)
- https://www.chartjs.org/docs/latest/ (Chart.js data and options)
