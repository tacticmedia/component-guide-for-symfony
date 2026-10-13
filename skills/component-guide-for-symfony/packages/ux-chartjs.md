# UX Chart.js (`symfony/ux-chartjs`)

**Applies to:** Symfony UX 3.5

**Elevator pitch:** Use when a page or a dashboard must show a line, bar or pie chart from PHP data, with no custom JavaScript. You build the Chart.js chart in PHP, and the package draws it on a canvas element in the browser. To update the chart in place when the user changes a filter, see [UX Live Component](ux-live-component.md).

**Details:** [../details/ux-chartjs.md](../details/ux-chartjs.md)

## Why it exists

Chart.js draws charts in the browser from a JavaScript configuration object. By hand, you write JavaScript that reads the data from the page and creates the chart. With this package, you build the chart in PHP. The package renders an HTML canvas element, and its JavaScript creates and destroys the chart on it.

## When to use it

- Show a line, bar, pie, doughnut, radar, polar area, bubble or scatter chart with data from PHP.
- Set Chart.js options, for example the scale limits, the legend or the title, in a PHP array.
- Register a Chart.js plugin, for example the zoom plugin, one time for all charts of the application.
- Add JavaScript callbacks, for example a tick formatter or a click handler, to a chart that PHP builds.
- Update a chart without a page reload when the user changes a filter.
- Load Chart.js only on the pages that show a chart.

## Use it instead of

- `<canvas id="sales"></canvas><script>new Chart(document.getElementById('sales'), {{ config|json_encode|raw }});</script>` -> `$chartBuilder->createChart(Chart::TYPE_LINE)` in PHP and `{{ render_chart(chart) }}` in Twig
- `<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>` in `base.html.twig` -> `composer require symfony/ux-chartjs`, after which Flex adds `chart.js` to `importmap.php` or `package.json`
- A custom Stimulus controller that calls `JSON.parse(this.element.dataset.config)`, `new Chart()` and `chart.destroy()` -> the `@symfony/ux-chartjs/chart` controller that `render_chart()` adds
- A JSON endpoint plus `fetch()` code that sets `chart.data` and calls `chart.update()` when a filter changes -> a live component with `#[LiveProp(writable: true)]` filters and `{{ render_chart(chart) }}` in its template
- `Chart.register(zoomPlugin)` in the script of each page -> one `chartjs:init` listener in `assets/app.js`
- `'<canvas class="'.$cssClass.'">'` built as a PHP string -> `render_chart(chart, {'class': 'sales-chart'})`
