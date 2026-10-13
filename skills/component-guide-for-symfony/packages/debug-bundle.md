# DebugBundle (`symfony/debug-bundle`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when debug dumps of variables must not break the HTML page, the JSON response or the HTTP headers of a web application. It sends the dumps to the debug toolbar, to the stored debug profile of the request, or to a dump server in a terminal. For the dump functions themselves, see [VarDumper](var-dumper.md).

**Details:** [../details/debug-bundle.md](../details/debug-bundle.md)

## Why it exists

In a web request, a plain dump writes to the PHP output, before the HTML page or the JSON data. This output can send the HTTP headers too early or corrupt the page. The package connects the dump functions to the request cycle, the debug toolbar and the templates. It sends the dumps to the toolbar or to a dump server.

## When to use it

- Inspect a variable in a controller or a class without a change to the HTML page.
- Show all dumps of a request in the debug toolbar and in the debug profile of the request.
- Dump template variables to the debug toolbar or into the page.
- Debug a JSON API without dump output in the response body.
- Collect the dumps of web requests, workers and console commands in one terminal.
- Limit the number of items and the string length of large dumps.
- Keep the dumps of a console command in its debug profile.
- Watch the application logs in real time in a second terminal.

## Use it instead of

- `var_dump($order); die;` or `echo '<pre>'.print_r($order, true).'</pre>';` in a controller -> `dump($order)`; the web debug toolbar and the profiler panel "Debug" show the dump (`data_collector.dump`).
- `error_log(print_r($payload, true));` or `file_put_contents('/tmp/debug.log', var_export($payload, true), FILE_APPEND);` in a worker or an API controller -> `dump($payload)` with `debug.dump_destination: 'tcp://%env(VAR_DUMPER_SERVER)%'` and `php bin/console server:dump` in a terminal.
- `$data['_debug'] = $query;` in the data of a JSON response -> `dump($query)` with `debug.dump_destination` set to `php://stderr` or to the dump server; the JSON body stays valid.
- `$output->writeln(print_r($data, true));` in a console command -> `dump($data)`; `DumpListener` sends it to the console, to the dump server or, with `--profile`, to the command profile.
- `<pre>{{ product|json_encode(constant('JSON_PRETTY_PRINT')) }}</pre>` in a Twig template -> `{% dump product %}` (web debug toolbar) or `{{ dump(product) }}` (inline), from `twig.extension.dump`.
- `tail -f var/log/dev.log | grep app` -> `php bin/console server:log --filter="level > 200 or channel in ['app', 'doctrine']"` with a MonologBundle `server_log` handler.
- `array_slice($rows, 0, 50)` or `substr($html, 0, 500)` before a dump -> `debug.max_items`, `debug.min_depth` and `debug.max_string_length`.
