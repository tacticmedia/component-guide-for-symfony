# Symfony UX Native (`symfony/ux-native`)

**Applies to:** Symfony UX 3.5

**Elevator pitch:** Use when a web application must ship as an iOS or Android app with Hotwire Native, which shows the web pages in a native shell. It detects requests from the app, serves the JSON path configuration that the app reads, and generates bridge components for the page and the app. The package is experimental. For browser notifications, see [UX Notify](ux-notify.md).

**Details:** [../details/ux-native.md](../details/ux-native.md)

## Why it exists

Hotwire Native apps for iOS and Android show the pages of a web application inside a native shell. By hand, you write code to detect the app requests and to create the JSON path configuration for the app. The package does these tasks. It also generates the JavaScript bridge components for Hotwire Native Bridge.

## When to use it

- Ship a PHP web application as an iOS or Android app with Hotwire Native.
- Hide the web navigation bar, the footer or other web-only HTML when the page shows in the native app.
- Check in PHP code or in a template if the request comes from a Hotwire Native app.
- Define the Hotwire Native path configuration in PHP, not in a hand-written JSON file. It holds the path rules, the modal screens and the pull-to-refresh settings.
- Write the path configuration JSON files to the public web directory during the deployment.
- Create a bridge component so that the web page and the native shell can communicate.

## Use it instead of

- `str_contains($request->headers->get('User-Agent', ''), 'Hotwire Native')` in each controller, or `{% if 'Hotwire Native' in app.request.headers.get('User-Agent') %}` in Twig -> `{% if ux_is_native() %}` in Twig, or `$request->attributes->get(NativeListener::NATIVE_ATTRIBUTE, false)` in PHP.
- A controller action with `#[Route('/config/ios_v1.json')]` that returns `new JsonResponse(['settings' => [...], 'rules' => [...]])` -> a method with `#[AsNativeConfiguration('/config/ios_v1.json')]` that returns `new Configuration(settings: [...], rules: [new Rule(...)])`.
- A hand-edited `public/config/ios_v1.json` file -> `Configuration` and `Rule` objects in PHP that the bundle serves live in debug mode.
- A deployment script with `file_put_contents('public/config/ios_v1.json', json_encode($config, JSON_PRETTY_PRINT))` -> `php bin/console ux:native:build-configs`.
- A `BridgeComponent` class that you copy into `assets/controllers/` from an example -> `php bin/console make:native-bridge-controller`.
- A manual `php bin/console importmap:require @hotwired/hotwire-native-bridge` -> `composer require symfony/ux-native` with Flex, which adds the JavaScript packages.
