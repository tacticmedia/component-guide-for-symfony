# MCP Bundle (`symfony/mcp-bundle`): details

**Applies to:** Symfony AI 0.14

## Key features and concepts

- **Named servers:** each entry under `mcp.servers` is one MCP server. Each server has its own identity, transports, HTTP route, session store and services `mcp.server.<name>.*`. Entry point: `mcp.servers.<name>`.
- **Registry:** a server exposes only the services that its required `registry` matches. An entry is a service id, a class name, a namespace prefix with a trailing backslash, or `*`. A pattern other than `*` that matches no service stops the container compilation. Entry point: `mcp.servers.<name>.registry` (one list, or a map with `tools`, `prompts`, `resources`, `resource_templates` and `apps`).
- **Tools:** `#[McpTool]` on a method, or on a class with `__invoke()`, makes an action that the model can call. The bundle generates the JSON input schema from the parameter types, the `@param` PHPDoc and `#[Schema]`. If a tool returns an associative array, the client also gets it as `structuredContent`. Set `outputSchema` to declare its shape. Entry point: `Mcp\Capability\Attribute\McpTool`, `Mcp\Capability\Attribute\Schema`.
- **Tool errors:** if a tool throws `ToolCallException`, the model gets the message as a tool result with `isError: true`. Other exceptions become a generic JSON-RPC internal error. Entry point: `Mcp\Exception\ToolCallException`.
- **Prompts:** `#[McpPrompt]` marks a method that returns a list of messages. The only message roles are `user` and `assistant`. Entry point: `Mcp\Capability\Attribute\McpPrompt`.
- **Resources and resource templates:** `#[McpResource]` serves data at one fixed URI (`uri` is required). `#[McpResourceTemplate]` serves data for a URI template with `{variable}` parts, for example `time://{timezone}`. Entry point: `Mcp\Capability\Attribute\McpResource`, `Mcp\Capability\Attribute\McpResourceTemplate`.
- **Completions:** `#[CompletionProvider]` on a parameter of a prompt or a resource template suggests argument values. It takes `values`, an `enum` class or a `provider` that implements `ProviderInterface`. Entry point: `Mcp\Capability\Attribute\CompletionProvider`.
- **Request context:** a handler parameter with the type `RequestContext` receives the current request and session. It also gives the client gateway (`elicit()`, `progress()`) and the client logger. Do not use `_session` or `_request` as tool parameter names. Entry point: `Mcp\Server\RequestContext`.
- **Transports:** HTTP (`transports.http`, default `true`) serves the SDK `StreamableHttpTransport` on the route `_mcp_endpoint_<name>` with the default path `/mcp/<name>`. STDIO (`transports.stdio`, default `false`) runs with `bin/console mcp:server <name>` and serves only the handshake era. With STDIO, do not write to STDOUT in a handler, because STDOUT carries the JSON-RPC messages. Entry point: `mcp.servers.<name>.transports`, `mcp.servers.<name>.http.path`.
- **DNS rebinding protection:** by default, the HTTP endpoint accepts only `localhost`, `127.0.0.1` and `[::1]` in the `Origin` or `Host` header. For a public server, set a host list. Behind a proxy that validates `Host`, set `false`. Entry point: `mcp.servers.<name>.http.allowed_hosts`.
- **Sessions:** handshake-era clients keep a session. The store is `file` (default, `%kernel.cache_dir%/mcp-sessions/<name>`), `memory`, `cache` (a PSR-16 pool) or `framework` (the session handler of the application). For HTTP, use a persistent store: `memory` keeps the sessions only in the current PHP process. Entry point: `mcp.servers.<name>.session.store`.
- **Protocol revision 2026-07-28:** each HTTP server also serves this revision without sessions on the same endpoint. Options narrow the revisions, sign multi-round-trip state (a key of at least 32 bytes), set cache hints and deliver `subscriptions/listen` notifications. Entry point: `protocol_versions`, `request_state`, `cache` and `subscriptions` under `mcp.servers.<name>`; `Mcp\Server\Subscription\NotificationBusInterface`.
- **MCP Apps:** `#[AsMcpApp]` on a class registers a `ui://` HTML resource. If the class has the handler method (`render` by default), it also registers a linked tool. The host shows the HTML in a sandboxed iframe. `#[AsMcpAppTool]` adds follow-up tools. Templates need `symfony/twig-bundle`. Entry point: `Symfony\AI\McpBundle\Attribute\AsMcpApp`, `Symfony\AI\McpBundle\Attribute\AsMcpAppTool`, `mcp.servers.<name>.registry.apps`.
- **MCP client:** each entry under `mcp.clients` is a group of remote servers that the application reaches over `stdio` (a child process) or `http`. A connection opens at its first request and closes at kernel reset. Entry point: `Symfony\AI\McpBundle\Client\McpClientInterface`, `Symfony\AI\McpBundle\Client\ServerConnectionInterface::callTool()`.
- **Debug, profiler and logs:** `debug:mcp` lists what each server exposes and the attributed services that no server exposes. In debug mode, the profiler panel "MCP Capabilities" shows the elements of each server. The bundle logs on the Monolog channel `mcp`. Entry point: `debug:mcp`, the data collector `mcp`.

## Entry points

- Server config: `mcp.servers.<name>` with `name`, `version`, `description`, `icons`, `website_url`, `pagination_limit`, `instructions`, `transports.stdio`, `transports.http`, `http.path`, `http.allowed_hosts`, `protocol_versions`, `request_state.key`, `request_state.ttl`, `cache.ttl_ms`, `cache.scope`, `cache.methods`, `subscriptions.bus`, `subscriptions.cache_pool`, `subscriptions.lifetime`, `session.store`, `session.directory`, `session.cache_pool`, `session.prefix`, `session.ttl` and `registry`.
- Client config: `mcp.clients.<name>` with `client_info`, `protocol_version`, `capabilities.roots_list_changed`, `roots`, `sampling`, `elicitation`, `forward_server_logs`, `init_timeout`, `request_timeout`, `max_retries` and `servers.<server>` (`transport`, `command`, `cwd`, `env`, `inherit_env`, `max_buffer_size`, `url`, `headers`, `http_client`, `max_sse_buffer_bytes`, and the overrides `init_timeout`, `request_timeout`, `max_retries`).
- Routing: the entry `mcp: { resource: ., type: mcp }` in `config/routes.yaml`; one route `_mcp_endpoint_<name>` (GET, POST, DELETE, OPTIONS) for each HTTP server.
- Attributes from `mcp/sdk`: `Mcp\Capability\Attribute\McpTool`, `Mcp\Capability\Attribute\McpPrompt`, `Mcp\Capability\Attribute\McpResource`, `Mcp\Capability\Attribute\McpResourceTemplate`, `Mcp\Capability\Attribute\Schema`, `Mcp\Capability\Attribute\CompletionProvider`.
- Attributes from the bundle: `Symfony\AI\McpBundle\Attribute\AsMcpApp`, `Symfony\AI\McpBundle\Attribute\AsMcpAppTool`.
- Handler argument: `Mcp\Server\RequestContext` (`getRequest()`, `getSession()`, `getClientGateway()`, `getClientLogger()`).
- Autowiring (with `Symfony\Component\DependencyInjection\Attribute\Target`): `#[Target('<name>Server')] Mcp\Server $server`; `#[Target('<name>NotificationBus')] Mcp\Server\Subscription\NotificationBusInterface $bus` (only when `subscriptions.bus` is not `none`); `#[Target('<client>')] Symfony\AI\McpBundle\Client\McpClientInterface $client` (with one client, the plain type is enough); `Symfony\AI\McpBundle\App\McpAppRenderer` (only with TwigBundle). Symfony 8.1 deprecates the match on the argument name alone (`Mcp\Server $<name>Server` without `#[Target]`).
- Autoconfigured interfaces: `Mcp\Capability\Registry\Loader\LoaderInterface` (tag `mcp.loader`), `Mcp\Server\Handler\Request\RequestHandlerInterface` (tag `mcp.request_handler`), `Mcp\Server\Handler\Notification\NotificationHandlerInterface` (tag `mcp.notification_handler`).
- Client callbacks (service ids for `roots`, `sampling`, `elicitation`): `Mcp\Client\Handler\Request\RootsCallbackInterface`, `Mcp\Client\Handler\Request\SamplingCallbackInterface`, `Mcp\Client\Handler\Request\ElicitationCallbackInterface`. The roots and sampling interfaces are deprecated (SEP-2577).
- Exceptions: `Mcp\Exception\ToolCallException`, `Mcp\Exception\ResourceReadException`, `Mcp\Exception\PromptGetException`; on the client side `Symfony\AI\McpBundle\Exception\ConnectionException` and `Symfony\AI\McpBundle\Exception\RemoteCallException` (both implement `Symfony\AI\McpBundle\Exception\ExceptionInterface`).
- Events: `Mcp\Event\ToolListChangedEvent`, `Mcp\Event\PromptListChangedEvent`, `Mcp\Event\ResourceListChangedEvent`, `Mcp\Event\ResourceTemplateListChangedEvent`. The registry does not dispatch them while it loads the configured elements. For handshake-era traffic, the server also dispatches `Mcp\Event\RequestEvent`, `Mcp\Event\ResponseEvent`, `Mcp\Event\ErrorEvent` and `Mcp\Event\NotificationEvent`. Put `#[AsEventListener]` on the listener method: on a class without a `method` argument, it calls `__invoke()`.
- Console commands: `mcp:server [<name>]` (only when a server enables STDIO); `debug:mcp [<element>] [--server=<name>] [--clients] [--client=<client>]`. `<element>` is a tool or prompt name, a resource URI or a resource template.
- Twig: the base template `@Mcp/app/base.html.twig` with the blocks `title`, `head`, `style`, `body` and `app_script`; the HTML attributes `data-call`, `data-arg-*` and `data-open`.
- Profiler and logs: the data collector `mcp` (only when `kernel.debug` is `true` and a server is configured); the Monolog channel `mcp`.

## Symbiotic packages

- [AI Bundle](../packages/ai-bundle.md): the agent tool entry `{ mcp_server: '<client>.<server>' }` gives an agent the tools of a connection from `mcp.clients` and needs `symfony/ai-mcp-tool`.
- [AI Agent](../packages/ai-agent.md): `symfony/ai-mcp-tool` (`McpToolbox`, `ClientToolset`) gives an agent the tools of a remote MCP server; the MCP Bundle does not expose `#[AsTool]` tools to MCP clients.
- [AI Platform](../packages/ai-platform.md): if the OpenAI servers must call a remote MCP server, use the OpenAI server tool `['type' => 'mcp']`, not this bundle.
- [AI Mate](../packages/ai-mate.md): Mate is a development CLI for coding agents with `#[MateTool]` attributes, and since 0.13 it runs no MCP server.
- [FrameworkBundle](../packages/framework-bundle.md): the bundle requires it, `session.store: framework` uses its `session.handler` service, and the default PSR-16 pools wrap `cache.app`.
- [Security](../packages/security-bundle.md): a firewall or an `access_control` rule protects the server path; for OAuth 2.1, the firewall validates bearer tokens, and a dedicated OAuth server issues them.
- [MonologBundle](../packages/monolog-bundle.md): the server, the client traffic and the forwarded logs of remote servers use the channel `mcp`.
- [WebProfilerBundle](../packages/web-profiler-bundle.md): it shows the panel "MCP Capabilities" with the tools, prompts, resources and resource templates of each server.
- [TwigBundle](../packages/twig-bundle.md): the `template` and `toolTemplate` options of `#[AsMcpApp]` and the `McpAppRenderer` service need it.
- [PSR-7 Bridge](../packages/psr-http-message-bridge.md): the bundle requires it to convert the HttpFoundation request into the PSR-7 request that `StreamableHttpTransport` reads.
- [HttpClient](../packages/http-client.md): it supplies the PSR-18 client `psr18.http_client` for client connections with `transport: http`.
- [Cache](../packages/cache.md): `Psr16Cache` pools store sessions (`session.store: cache`) and notifications (`subscriptions.bus: cache`).
- [Routing](../packages/routing.md): the route loader type `mcp` adds one route `_mcp_endpoint_<name>` for each HTTP server.
- [Console](../packages/console.md): it runs `mcp:server` for STDIO clients and `debug:mcp`.
- [EventDispatcher](../packages/event-dispatcher.md): when an element changes after the initial load, the server registry dispatches `Mcp\Event\ToolListChangedEvent` or another list-change event through `event_dispatcher`.
- [UX Live Component](../packages/ux-live-component.md): the docs compare `#[AsMcpApp]` to a Live Component, but an MCP App appears only in the MCP host, not in your pages.

## Changed in 0.12 to 0.14

- 0.12: `mcp.discovery` (`scan_dirs`, `exclude_dirs`) -> removed. Autoconfiguration registers each service with an MCP attribute. Register other classes as services, or load them with a `LoaderInterface` service (tag `mcp.loader`).
- 0.13: top-level server options -> `mcp.servers.<name>.*`: `app` -> `name`, `client_transports` -> `transports` (`http` now defaults to `true`), `http.session` -> `session`, `apps.enabled` -> `registry.apps`; `version`, `description`, `instructions`, `pagination_limit` and `http` move without a new name.
- 0.13: every attributed element on the one server -> the required `registry`; `registry: '*'` keeps the old behavior.
- 0.13: default `http.path` `/_mcp` -> `/mcp/<name>`, and route `_mcp_endpoint` -> `_mcp_endpoint_<name>`; set `http.path: /_mcp` to keep the old URL.
- 0.13: services `mcp.server`, `mcp.registry`, `mcp.server.controller` -> `mcp.server.<name>`, `mcp.server.<name>.registry`, `mcp.server.<name>.controller`; autowire `#[Target('<name>Server')] Mcp\Server $server`.
- 0.13: the MCP client (`mcp.clients`, `McpClientInterface`) is new. Autowire `#[Target('research')] McpClientInterface $client`, not `$researchClient`. Use `clients.<name>.roots` (a `RootsCallbackInterface` service), not `capabilities.roots`. Both old names come from development versions before 0.13.0.
- 0.13: the HTTP endpoint also serves revision 2026-07-28, where `$gateway->sample()` and `$gateway->listRoots()` fail; pass the data as tool arguments, or set `protocol_versions: ['2025-11-25']`.
- 0.14: the MCP Bundle has no configuration or API change; the AI Bundle adds the agent tool entry `mcp_server` (package `symfony/ai-mcp-tool`). Since 0.14.1, a `%...%` span in the text of an MCP attribute stays literal. Do not escape it as `%%`.

## Status

- 0.x and experimental: symfony/mcp-bundle (v0.14.1) and mcp/sdk (v0.8.1) have no 1.0 release. The bundle README says "This Bundle is experimental", so the Symfony backward compatibility promise does not cover it. Minor versions break the API, for example 0.12 and 0.13. Before an update, read `UPGRADE.md` of symfony/ai. mcp/sdk is experimental before 1.0, and its public API can change without a deprecation period.
- `symfony/mcp-sdk` (namespace `Symfony\AI\McpSdk\`) has no tagged release on Packagist, only `dev-main`. Packagist marks it abandoned and names `mcp/sdk` as the replacement. The owner archived its GitHub repository on 2026-09-05. Do not install it. Use `mcp/sdk` (namespace `Mcp\`), which the bundle requires as `^0.8.1`. The mcp/sdk README names PHP-MCP and the Symfony AI initiative as its starting point.
- mcp/sdk needs the PHP extension `fileinfo`.
- Protocol revision 2026-07-28 deprecates roots, sampling and MCP logging (SEP-2577, earliest removal 2027-07-28). mcp/sdk 0.8 triggers a deprecation for each configured client handler of these features. Because `forward_server_logs` is `true` by default, set it to `false` to remove the logging deprecation.

## Docs

- https://symfony.com/doc/current/ai/bundles/mcp-bundle.html
- https://symfony.com/doc/current/ai/cookbook/build-an-mcp-server.html
- https://php.sdk.modelcontextprotocol.io/
- https://php.sdk.modelcontextprotocol.io/servers/tools/
- https://php.sdk.modelcontextprotocol.io/servers/prompts/
- https://php.sdk.modelcontextprotocol.io/servers/resources/
- https://php.sdk.modelcontextprotocol.io/servers/resource-templates/
- https://php.sdk.modelcontextprotocol.io/servers/completions/
- https://php.sdk.modelcontextprotocol.io/servers/schemas/
- https://php.sdk.modelcontextprotocol.io/run/stdio/
- https://php.sdk.modelcontextprotocol.io/run/http/
- https://php.sdk.modelcontextprotocol.io/protocol-versions/
- https://github.com/modelcontextprotocol/php-sdk
- https://packagist.org/packages/symfony/mcp-bundle
- https://packagist.org/packages/mcp/sdk
- https://packagist.org/packages/symfony/mcp-sdk
- https://github.com/symfony/mcp-sdk
