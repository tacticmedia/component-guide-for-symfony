# VarDumper (`symfony/var-dumper`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when you must inspect a PHP variable while you debug, and var_dump or print_r output is hard to read. It shows any value as colored terminal text or as HTML that you can expand, and can send the dumps to another terminal. To export values as PHP code, see [VarExporter](var-exporter.md).

**Details:** [../details/var-dumper.md](../details/var-dumper.md)

## Why it exists

The PHP functions var_dump and print_r write raw text into the output. They also show every internal property of large objects, for example database entity proxies. The package copies any PHP value into a data object and shows it as colored text or as HTML that you can expand. In a full application, the dumps can go to the debug toolbar, so they do not change the page or the HTTP headers.

## When to use it

- Inspect a variable, an object or a database entity while you debug a controller, a class or a console command.
- Stop the script after a dump to check a value at one point in the code.
- Debug a JSON API or an AJAX request without a change to the response body.
- Collect the dumps of all requests and commands in one terminal or one HTML file.
- Debug a plain PHP script, a CLI tool or a worker without the framework.
- Dump a variable in a template, into the page or only to the debug toolbar.
- Get the dump of a value as a string for a log message, a file or a custom page.
- Show HTML dumps on a page that has a strict Content Security Policy.
- Compare a complex object with an expected text dump in a unit test.
- Show a custom view of your own classes in dumps, for example to hide internal properties.

## Use it instead of

- `var_dump($order); die;` or `print_r($order); exit;` -> `dd($order)`.
- `echo '<pre>'.print_r($items, true).'</pre>';` in a controller -> `dump($items)`; with DebugBundle, the dump goes to the web debug toolbar.
- `error_log(print_r($payload, true));` to debug a JSON API -> `dump($payload)` with `debug.dump_destination: php://stderr`.
- `file_put_contents('/tmp/debug.log', var_export($data, true), FILE_APPEND);` -> `dump($data)` with `debug.dump_destination: 'tcp://%env(VAR_DUMPER_SERVER)%'` and `php bin/console server:dump --format=html > dump.html`.
- `ob_start(); var_dump($value); $text = ob_get_clean();` -> `(new CliDumper())->dump((new VarCloner())->cloneVar($value), true)`.
- `$this->assertSame(print_r($expected, true), print_r($actual, true));` -> `$this->assertDumpEquals($expected, $actual)` with `use VarDumperTestTrait;`.
- `<pre>{{ user|json_encode(constant('JSON_PRETTY_PRINT')) }}</pre>` in a template -> `{{ dump(user) }}`, or `{% dump user %}` to keep the page unchanged.
- `PHP_SAPI === 'cli' ? print_r($x) : print('<pre>'.htmlspecialchars(print_r($x, true)).'</pre>');` -> `dump($x)`, which selects text or HTML.
