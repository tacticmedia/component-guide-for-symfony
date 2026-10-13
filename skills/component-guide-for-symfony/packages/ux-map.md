# UX Map (`symfony/ux-map`)

**Applies to:** Symfony UX 3.5

**Elevator pitch:** Use when a page must show an interactive map with markers, popups or shapes, for example a store locator, a delivery zone or a route. You build the map in PHP, and Leaflet with OpenStreetMap or Google Maps draws it in the browser. To copy data between PHP objects, see [ObjectMapper](object-mapper.md).

**Details:** [../details/ux-map.md](../details/ux-map.md)

## Why it exists

Map libraries such as Leaflet and Google Maps need JavaScript code that reads coordinates from the page and creates the map objects. With this package, you build the map in PHP, and a bridge package draws it in the browser. To change the map library, you install the other bridge package and change one environment variable. The PHP and Twig code stays the same, except for the bridge options.

## When to use it

- Show the locations of database records as markers on an interactive map.
- Open an HTML info window when the user clicks a marker or a shape.
- Draw an area, a route or a radius around a point on a map.
- Use OpenStreetMap tiles without an API key, or Google Maps with an API key, through one PHP API.
- Add or remove markers, or change the center and the zoom, after a server action without a page reload. See [UX Live Component](ux-live-component.md).
- Customize the Leaflet or Google Maps objects in JavaScript, for example draggable markers or custom marker images.
- Group many points into clusters on the server for one zoom level.
- Calculate the distance between two coordinates, or convert decimal degrees to degrees, minutes and seconds.

## Use it instead of

- `<div id="map"></div>` with `<script>const map = L.map('map').setView([48.85, 2.35], 13); L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(map);</script>` -> `(new Map())->center(new Point(48.85, 2.35))->zoom(13)` in PHP, `{{ ux_map(map, {style: 'height: 400px'}) }}` in Twig and `UX_MAP_DSN=leaflet://default`
- `<script src="https://maps.googleapis.com/maps/api/js?key=…">` with `new google.maps.Map(document.getElementById('map'), {…})` -> `composer require symfony/ux-google-map` and `UX_MAP_DSN=google://%env(GOOGLE_MAPS_API_KEY)%@default`
- `data-locations="{{ locations|json_encode|e('html_attr') }}"` and a custom Stimulus controller that loops over the locations and calls `L.marker()` -> `$map->addMarker(new Marker(position: new Point($latitude, $longitude), title: $name))` for each record
- `marker.bindPopup('<b>' + name + '</b>')` in JavaScript -> `new Marker(…, infoWindow: new InfoWindow(headerContent: '<b>Lyon</b>', content: '…'))`
- Min and max calculations over all coordinates, or `map.fitBounds(bounds)` in JavaScript -> `$map->fitBoundsToMarkers()`
- A JSON endpoint and `fetch()` code that redraws the markers when a filter changes -> a live component with `ComponentWithMapTrait` and `$this->getMap()->addMarker(…)` in a `#[LiveAction]`
- `6371 * acos(sin($lat1) * sin($lat2) + cos($lat1) * cos($lat2) * cos($lng2 - $lng1))` in PHP -> `(new DistanceCalculator(unit: DistanceUnit::Kilometer))->calculateDistance($pointA, $pointB)`
- A loop that groups points by `round($latitude, 1).','.round($longitude, 1)` -> `(new GridClusteringAlgorithm())->cluster($points, zoom: 5.0)`
- `floor()` and `* 60` arithmetic to show degrees, minutes and seconds -> `CoordinateUtils::decimalToDMS(48.8588443)`
