# AI Agent (`symfony/ai-agent`): details

**Applies to:** Symfony AI 0.14

## Key features and concepts

- **Agent and `call()`:** `Agent` combines a `PlatformInterface`, a model name, input and output processors and an optional toolbox. `call()` accepts a string, a `UserMessage` or a `MessageBag`. The options go to the platform, for example `stream` and `response_format`. Some options also control the agent, for example `tools`. The agent adds the configured system prompt, the memory and the tool messages to the `MessageBag` that you give. It does not add the final answer. To continue the conversation, add `Message::ofAssistant($execution->getResult())`. Entry point: `new Agent($platform, 'gpt-4o-mini', toolbox: $toolbox)`, `AgentInterface::call()`.
- **Lazy execution:** `call()` returns a lazy `Execution`. The agent runs only when code reads the result or iterates the execution. Thus, exceptions occur at `getResult()`, `getContent()` or in the loop, not at the `call()` line. Code can read the result many times, but it can iterate the execution only once. Entry point: `Symfony\AI\Agent\Execution\Execution` with `getResult()`, `asText()` and `asObject()`.
- **Progress, streaming and cancellation:** iteration yields `Progress` updates of the stages `model_request`, `tool_call`, `delta` and `handoff`, then a `Result` update. `onProgress()` and `onResult()` register callbacks for the same updates. With the option `['stream' => true]`, `asTextStream()` yields the text deltas. `cancel()` stops the active HTTP response, and `getResult()` then throws a `RuntimeException`. Entry point: `Symfony\AI\Agent\Execution\Update\Progress`, `Execution::cancel()`.
- **Tools with `#[AsTool]`:** the attribute gives a class method a tool name, a description and optional metadata. The attribute is repeatable, so one class can supply several tools through the `method` argument. The JSON schema comes from the parameter types, the PHPDoc `@param` text, backed enums, `#[Schema]` and the Validator constraints of DTO properties. `#[Schema(provider: ...)]` adds a schema fragment from a `SchemaProviderInterface` service at runtime, for example the allowed values from a database. A `Stringable` result becomes a string, and the agent encodes other non-string results as JSON. Entry point: `Symfony\AI\Agent\Toolbox\Attribute\AsTool`.
- **Argument checks and DTO mapping:** `#[Schema]` alone only describes a parameter to the model. Before the tool runs, `ValidateToolCallArgumentsListener` validates object arguments with their Validator constraints and scalar or array arguments with their `#[Schema]` keywords. It throws `InvalidToolCallArgumentsException` for invalid arguments. `#[MapToolArguments]` maps the flat tool-call payload onto one DTO parameter. Entry point: `Symfony\AI\Agent\Toolbox\EventListener\ValidateToolCallArgumentsListener`, `Symfony\AI\Agent\Toolbox\Attribute\MapToolArguments`.
- **Toolboxes and tool factories:** `Toolbox` executes the tool objects that you give it. `FaultTolerantToolbox` returns an error text to the model instead of an exception. `ChainToolbox` offers the tools of several toolboxes. If two toolboxes offer the same tool name, `ChainToolbox` throws `ToolConfigurationException`. `MemoryToolFactory` registers a class without `#[AsTool]`, and `ChainFactory` combines tool factories. Entry point: `Symfony\AI\Agent\Toolbox\ToolboxInterface`.
- **Ready-made tools:** 14 packages `symfony/ai-*-tool` supply tools. They cover web search (Brave, Ollama, SerpApi, Tavily), web scraping (Firecrawl, Scraper), Wikipedia, geocoding (Mapbox) and weather (Open-Meteo). Other packages cover YouTube transcripts, files, the clock, MCP servers and similarity search. The docs page "Built-in Tools" lists all 14 packages. Entry point: for example `composer require symfony/ai-wikipedia-tool`.
- **Loop control:** `maxToolCalls` stops the loop with `MaxIterationsExceededException` after 50 tool rounds by default, and `null` removes the limit. The option `['tools' => ['tavily_search']]` limits the tools of one call. `excludeToolMessages: true` keeps the tool messages out of the message bag that you give. `includeSources: true` puts the sources of `HasSourcesInterface` tools into the result metadata `sources`. Entry point: the `Agent` constructor arguments.
- **Tool events and human-in-the-loop:** a toolbox with an event dispatcher dispatches `ToolCallRequested`, `ToolCallArgumentsResolved`, `ToolCallSucceeded` and `ToolCallFailed`. A `ToolCallRequested` listener calls `deny($reason)` to block the call, or `setResult()` to skip the tool. The agent dispatches `ToolCallsExecuted` through its own `eventDispatcher` argument. A `setResult()` call on that event skips the next model request. Entry point: `Symfony\AI\Agent\Toolbox\Event\ToolCallRequested`.
- **Tool executors:** `SequentialToolExecutor` is the default and runs the tool calls one after the other. `FiberToolExecutor` starts each tool call in a PHP fiber. A tool that calls `suspend()` from `SuspendableTrait` lets the other tool calls wait for their responses at the same time. In the AI Bundle, set `tools.execution_strategy` to `fiber`. Entry point: the `toolExecutor` argument of `Agent`.
- **Input and output processors:** an input processor changes the messages, the model or the options once per `call()`. An output processor changes the final result. `SystemPromptInputProcessor` adds a system prompt from a string, a `File`, a `Template` or a translatable message, and it can append the tool list. It does nothing when the message bag already has a system message. With `ModelOverrideInputProcessor` in the input processors, the option `['model' => 'gpt-4o']` selects another model for one call. Entry point: `Symfony\AI\Agent\InputProcessorInterface`, `Symfony\AI\Agent\OutputProcessorInterface`.
- **Memory:** `MemoryInputProcessor` collects `Memory` entries from `MemoryProviderInterface` services and puts them into the system message. `StaticMemoryProvider` holds fixed facts. `EmbeddingProvider` searches a vector store with the last user message and needs `symfony/ai-store`. The option `['use_memory' => false]` disables memory for one call. Entry point: `Symfony\AI\Agent\Memory\MemoryInputProcessor`.
- **Multi-agent orchestration:** `MultiAgent` asks an orchestrator agent for a structured `Decision` that names the specialist agent. The orchestrator prompt lists the name of each `Handoff` agent with its `when` keywords. Give each specialist `Agent` a unique `name` argument, because the `Decision` refers to that name. The selected agent receives only the first user message of the message bag. If the `Decision` names no agent or an unknown agent, the fallback agent answers. The `Decision` is structured output. Without the AI Bundle, register `PlatformSubscriber` on the event dispatcher of the platform. Entry point: `Symfony\AI\Agent\MultiAgent\MultiAgent`, `Symfony\AI\Agent\MultiAgent\Handoff`.
- **Agent as a tool:** `Subagent` wraps an agent as a tool of another agent, and the calling agent keeps control of the conversation. `Subagent` has no `#[AsTool]` attribute, so register it with `MemoryToolFactory::addTool()`. Entry point: `Symfony\AI\Agent\Toolbox\Tool\Subagent`.
- **Speech and test doubles:** `SpeechAgent` decorates an agent: it transcribes audio input to text and converts the answer to audio. `MockAgent` returns a fixed answer for the text of the last user message and records each call. It has assertions such as `assertCallCount()` and `assertCalledWith()`. Entry point: `Symfony\AI\Agent\SpeechAgent`, `Symfony\AI\Agent\MockAgent`.

## Entry points

- Install: `composer require symfony/ai-agent`. In a Symfony application, install `symfony/ai-bundle` and `symfony/ai-agent`.
- Without FrameworkBundle: `new Agent($platform, 'gpt-4o-mini', toolbox: $toolbox)` with a `Toolbox` of your tool objects. For the tool events, give the toolbox an event dispatcher. For `MultiAgent`, register `PlatformSubscriber` on the event dispatcher of the platform.
- Autowire `Symfony\AI\Agent\AgentInterface` when the application configures one agent. For one of several agents or for a multi-agent, use `#[Target('<name>')] AgentInterface $agent`. Symfony 8.1 deprecates a match on the argument name alone. The service IDs are `ai.agent.<name>` and `ai.multi_agent.<name>`.
- Classes `Symfony\AI\Agent\Agent`, `Symfony\AI\Agent\Execution\Execution`, `Symfony\AI\Agent\Execution\Update\Progress` and `Symfony\AI\Agent\Execution\Update\Result`.
- Tool attributes `Symfony\AI\Agent\Toolbox\Attribute\AsTool` and `Symfony\AI\Agent\Toolbox\Attribute\MapToolArguments`, plus `Symfony\AI\Platform\Contract\JsonSchema\Attribute\Schema` and `Symfony\AI\Platform\Contract\JsonSchema\Provider\SchemaProviderInterface` from AI Platform.
- Processor attributes `Symfony\AI\Agent\Attribute\AsInputProcessor` and `Symfony\AI\Agent\Attribute\AsOutputProcessor`, which the AI Bundle reads. Without the `agent` argument, the processor applies to every agent except multi-agents. The `agent` argument must be the service ID, for example `ai.agent.support`, not the short name `support`.
- Toolboxes `Symfony\AI\Agent\Toolbox\Toolbox`, `FaultTolerantToolbox`, `ChainToolbox`, `AbstractToolbox` and `ToolboxInterface`. Tool factories `Symfony\AI\Agent\Toolbox\ToolFactory\MemoryToolFactory`, `ChainFactory` and `ReflectionToolFactory`.
- Tool executors `Symfony\AI\Agent\Toolbox\SequentialToolExecutor`, `FiberToolExecutor`, `ToolExecutorInterface` and the trait `SuspendableTrait`.
- Events `Symfony\AI\Agent\Toolbox\Event\ToolCallRequested`, `ToolCallArgumentsResolved`, `ToolCallSucceeded`, `ToolCallFailed` and `ToolCallsExecuted`. Listener `Symfony\AI\Agent\Toolbox\EventListener\ValidateToolCallArgumentsListener`.
- Processors `Symfony\AI\Agent\InputProcessorInterface`, `Symfony\AI\Agent\OutputProcessorInterface`, `Symfony\AI\Agent\Input`, `Symfony\AI\Agent\Output`, `Symfony\AI\Agent\InputProcessor\SystemPromptInputProcessor`, `Symfony\AI\Agent\InputProcessor\ModelOverrideInputProcessor`, `Symfony\AI\Agent\AgentAwareInterface` and `Symfony\AI\Agent\AgentAwareTrait`.
- Memory `Symfony\AI\Agent\Memory\MemoryInputProcessor`, `MemoryProviderInterface`, `Memory`, `StaticMemoryProvider` and `EmbeddingProvider`.
- Multi-agent `Symfony\AI\Agent\MultiAgent\MultiAgent`, `Symfony\AI\Agent\MultiAgent\Handoff` and `Symfony\AI\Agent\MultiAgent\Handoff\Decision`. Agent as a tool: `Symfony\AI\Agent\Toolbox\Tool\Subagent`.
- Tool sources `Symfony\AI\Agent\Toolbox\Source\HasSourcesInterface`, `HasSourcesTrait` and `Source`.
- Speech `Symfony\AI\Agent\SpeechAgent` and `Symfony\AI\Agent\Speech\SpeechConfiguration`.
- Exceptions `Symfony\AI\Agent\Exception\MaxIterationsExceededException`, `Symfony\AI\Agent\Toolbox\Exception\ToolExecutionExceptionInterface`, `InvalidToolCallArgumentsException` and `ToolNotFoundException`.
- Test helpers `Symfony\AI\Agent\MockAgent` and `Symfony\AI\Agent\MockResponse`. With the AI Bundle: `Symfony\AI\AiBundle\Test\AiAssertionsTrait` with `assertToolCalled()`, `assertToolCallCount()` and `assertToolRegistered()`.
- AI Bundle configuration `ai.agent.<name>` with the keys `platform`, `model`, `prompt`, `memory`, `tools`, `max_tool_calls`, `fault_tolerant_toolbox`, `exclude_tool_messages`, `include_sources` and `speech`. Tools are opt-in: set `tools: true` for all services with the tag `ai.tool`, or give a list. A list entry is a tool `service`, an `agent` with a `name` and a `description` (agent as a tool), or an `mcp_server`.
- AI Bundle configuration `ai.multi_agent.<name>` with the keys `orchestrator`, `handoffs` and `fallback`.
- Console command `ai:agent:call <agent>` (alias `ai:chat`) from the AI Bundle starts an interactive chat with a configured agent.
- The package has no Twig functions.

## Symbiotic packages

- [AI Platform](../packages/ai-platform.md): the agent sends each model request through `PlatformInterface` and uses its messages, results and tool definitions. For a single request without a tool loop, use AI Platform alone.
- [AI Bundle](../packages/ai-bundle.md): it configures agents under `ai.agent` and `ai.multi_agent`, tags `#[AsTool]` classes with `ai.tool`, and registers the processors and the argument validation listener.
- [AI Store](../packages/ai-store.md): `EmbeddingProvider` and the `symfony/ai-similarity-search-tool` package read documents from a vector store for memory and RAG.
- [AI Chat](../packages/ai-chat.md): `Chat` wraps an `AgentInterface` and keeps the conversation in a message store. Use AI Chat when the history must persist between requests.
- [MCP Bundle](../packages/mcp-bundle.md): in the AI Bundle, an `mcp_server` tool entry gives an agent the tools of a remote MCP server. The entry needs `symfony/ai-mcp-tool` and an `mcp.clients` connection. To expose your own tools to external MCP clients, use the MCP Bundle and `#[McpTool]`.
- [AI Mate](../packages/ai-mate.md): Mate is a development assistant with its own `#[MateTool]` attribute, which is not related to `#[AsTool]`. For tools of your application agents, use the Agent component.
- [EventDispatcher](../packages/event-dispatcher.md): the toolbox dispatches the tool call events, and the agent dispatches `ToolCallsExecuted`. Human-in-the-loop checks and argument validation need a dispatcher.
- [Validator](../packages/validator.md): constraints on the properties of a DTO tool parameter add schema keywords, and `ValidateToolCallArgumentsListener` validates the DTO before the tool runs.
- [Serializer](../packages/serializer.md): `ToolCallArgumentResolver` denormalizes the tool arguments into objects, enums and dates, and `ToolResultConverter` encodes the tool results as JSON.
- [HttpClient](../packages/http-client.md): ten tool packages, for example Brave, Tavily and Wikipedia, call their web APIs through `HttpClientInterface`.
- [Clock](../packages/clock.md): `symfony/ai-clock-tool` gives the model the current date and time from a Symfony clock.
- [Translation](../packages/translation.md): `SystemPromptInputProcessor` translates a `TranslatableInterface` system prompt with a translator.
- [Stopwatch](../packages/stopwatch.md): `TraceableAgent` and `TraceableToolbox` time each agent run and each tool call for the profiler timeline.
- [Security](../packages/security-bundle.md): with the AI Bundle, `#[IsGrantedTool]` checks a security attribute before a tool runs.
- [DomCrawler](../packages/dom-crawler.md): `symfony/ai-scraper-tool` requires DomCrawler to read the visible text and the title of a web page.
- [Filesystem](../packages/filesystem.md): `symfony/ai-filesystem-tool` uses the Filesystem component for file operations below a fixed base path.

## Changed in 0.10 to 0.14

- **0.13:** `Toolbox\AgentProcessor` is removed. Old: `new Agent($platform, $model, [$processor], [$processor])`. New: `new Agent($platform, $model, toolbox: $toolbox, maxToolCalls: 75, includeSources: true)`.
- **0.13:** `call()` returns a lazy `Execution` instead of a `ResultInterface`. Before `instanceof TextResult`, call `getResult()`. Input processors now run once per `call()`, not once per tool round.
- **0.13:** `Toolbox\StreamListener` and the `StreamResult` return value are removed. To stream, iterate `getContent()` or `asTextStream()` of the execution.
- **0.13, AI Bundle:** the agent option `keep_tool_messages` is now `exclude_tool_messages`.
- **0.12:** `call()` accepts a `string`, a `UserMessage` or a `MessageBag`. A custom `AgentInterface` class must widen its `call()` signature.
- **0.11:** on the tool call events, `getMetadata()` is now `getDefinition()`.
- **0.10:** the tool loop stops after 50 rounds by default. The agent changes the `MessageBag` that you give, so pass `clone $messages` to keep the original. In the AI Bundle, tools are opt-in (`tools: true`).
- **0.14:** new `Execution::cancel()`, `ChainToolbox`, `FiberToolExecutor` with `SuspendableTrait`, `#[MapToolArguments]` and the `symfony/ai-mcp-tool` package. For a missing or invalid tool argument, `ToolCallArgumentResolver` now throws `InvalidToolCallArgumentsException` instead of `ToolException`.

## Status

- 0.x and experimental: the README says "This Component is experimental", and the Symfony backward compatibility promise does not cover it. Minor versions break the API, for example 0.13. Before an update, read `UPGRADE.md` of symfony/ai.
- The package needs PHP 8.2 or higher and the `fileinfo` PHP extension.
- Some features need packages that `symfony/ai-agent` does not require: `EmbeddingProvider` needs `symfony/ai-store`, `ValidateToolCallArgumentsListener` needs `symfony/validator`, and the tool events need an event dispatcher.

## Docs

- https://symfony.com/doc/current/ai/components/agent.html
- https://symfony.com/doc/current/ai/components/agent/tools.html
- https://symfony.com/doc/current/ai/cookbook/tool-calling-with-agents.html
- https://symfony.com/doc/current/ai/cookbook/human-in-the-loop.html
- https://symfony.com/doc/current/ai/cookbook/multi-agent-orchestration.html
- https://symfony.com/doc/current/ai/cookbook/chatbot-with-memory.html
- https://symfony.com/doc/current/ai/cookbook/dynamic-tools.html
- https://symfony.com/doc/current/ai/cookbook/context-compression.html
- https://symfony.com/doc/current/ai/cookbook/runtime-driven-tool-parameters.html
- https://symfony.com/doc/current/ai/cookbook/generator-reviewer-loop.html
- https://symfony.com/doc/current/ai/cookbook/rag-implementation.html
- https://symfony.com/doc/current/ai/cookbook/ai-bundle-fast-track.html
- https://symfony.com/doc/current/ai/bundles/ai-bundle.html
