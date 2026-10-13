# MCP Bundle (`symfony/mcp-bundle`)

**Applies to:** Symfony AI 0.14

**Elevator pitch:** Use when AI clients such as Claude Desktop or Cursor must use the tools, prompts and data of your PHP application over MCP. It serves MCP over HTTP or STDIO, and it also calls remote MCP servers. To give tools to your own LLM agents, see [AI Agent](ai-agent.md). For development tools for a coding agent, see [AI Mate](ai-mate.md).

**Details:** [../details/mcp-bundle.md](../details/mcp-bundle.md)

## Why it exists

AI clients such as Claude Desktop use the Model Context Protocol, MCP, to find and call the tools, prompts and resources of a server. A hand-written server must parse JSON-RPC messages, build a JSON schema for each tool, keep sessions and protect the endpoint. The package uses the official PHP SDK and turns PHP methods with MCP attributes into tools, prompts and resources. It serves them over HTTP or STDIO, and it connects the application to remote MCP servers.

## When to use it

- Let Claude Desktop, Cursor or another MCP client call PHP methods of the application as tools.
- Give an AI client read access to application data through fixed URIs or URI templates.
- Publish reusable prompt templates to MCP clients.
- Serve an MCP server over HTTP from the web application, or over STDIO for a local client.
- Expose several MCP servers with different tools, paths and access rules from one application.
- Show an interactive HTML view in the AI client as the result of a tool call, with MCP Apps.
- Call the tools of a remote MCP server, for example GitHub or a filesystem server, from PHP code or from an LLM agent.
- Check which tools, prompts and resources each server exposes.

## Use it instead of

- A controller with `json_decode($request->getContent(), true)` and `match ($payload['method']) { 'tools/list' => …, 'tools/call' => … }` -> `#[McpTool]` on a service, the `registry` of a server and the route import `type: mcp`.
- A hand-written JSON Schema array for each tool (`['type' => 'object', 'properties' => …]`) -> the input schema that the bundle generates from typed parameters, `@param` PHPDoc and `#[Schema]`.
- A console command with a `while (false !== $line = fgets(STDIN))` loop that answers JSON-RPC -> `transports.stdio: true` and `bin/console mcp:server <name>`.
- Your own controller with `Server::builder()->setDiscovery(…)`, `PsrHttpFactory` and `new StreamableHttpTransport($psrRequest)` -> the `mcp.servers.<name>` configuration (the bundle wires the controller, route, session store and logger).
- An event listener that compares `$request->getHost()` with a list -> `mcp.servers.<name>.http.allowed_hosts`.
- A bearer-token check inside each tool method -> a Symfony Security firewall or an `access_control` rule on the server path, for example `{ path: ^/mcp/editors, roles: ROLE_EDITOR }`.
- `proc_open(['npx', …])` or `$httpClient->request('POST', $url, ['json' => ['jsonrpc' => '2.0', 'method' => 'tools/call', …]])` -> `mcp.clients.<name>.servers.<server>` and `$client->get('<server>')->callTool($name, $arguments)`.
- An iframe page with a hand-written `postMessage` bridge for a tool result -> `#[AsMcpApp]` with a template that extends `@Mcp/app/base.html.twig`.
