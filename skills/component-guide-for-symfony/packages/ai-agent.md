# AI Agent (`symfony/ai-agent`)

**Applies to:** Symfony AI 0.14

**Elevator pitch:** Use when an LLM must call functions of your PHP code as tools and use the results in its answer. It runs the tool loop, and adds memory, routing to specialist agents and human approval of tool calls. For a single model request, see [AI Platform](ai-platform.md). For a chat history that persists between requests, see [AI Chat](ai-chat.md).

**Details:** [../details/ai-agent.md](../details/ai-agent.md)

## Why it exists

An LLM cannot run your PHP code. It can only ask for a tool call. Without the package, code must send the messages, run the requested tools, send back the results and repeat until the model answers. The package runs this loop on top of [AI Platform](ai-platform.md), and adds memory, multi-agent routing, tool events and processing of the input and the output.

## When to use it

- Let an LLM call methods of your PHP classes as tools, and use the tool results in its answer.
- Give an LLM web search, web scraping, weather, geocoding, file access or MCP server tools from a ready-made package.
- Ask a person to approve or deny a tool call before the tool runs.
- Add a system prompt, stored facts or retrieved documents to each model request.
- Send each user question to the correct specialist agent.
- Show the progress of an agent run to a user, stream the answer and stop the run on request.
- Answer questions from the documents in a vector store with a similarity search tool, for RAG.
- Replace an agent with a test double that returns fixed answers.

## Use it instead of

- A `while (true)` loop around `$platform->invoke()` that reads `asToolCalls()`, calls the matching PHP method and adds `Message::ofToolCall()` -> `$agent->call($messages)` on `new Agent($platform, $model, toolbox: new Toolbox([$tool]))`.
- A hand-written schema array such as `'tools' => [['type' => 'function', 'function' => ['name' => 'get_weather', 'parameters' => [...]]]]` -> `#[AsTool('get_weather', 'Returns the weather')]` on the class, with typed method parameters.
- `json_decode($arguments, true)` plus `isset()` and type checks in each tool -> typed parameters, a DTO with `#[MapToolArguments]` and `ValidateToolCallArgumentsListener`.
- A `try`/`catch` in each tool that returns an error string to the model -> `FaultTolerantToolbox` and an exception that implements `ToolExecutionExceptionInterface::getToolCallResult()`.
- `if (++$rounds > 10) { break; }` in a custom tool loop -> the `maxToolCalls` argument and `MaxIterationsExceededException`.
- `readline('Run this tool? [y/n]')` inside a tool method -> a `ToolCallRequested` listener that calls `$event->deny('Awaiting human confirmation.')`.
- A system message that you prepend to each `MessageBag` before each request -> `SystemPromptInputProcessor`, or the `prompt` key of an AI Bundle agent.
- `if (str_contains($question, 'invoice')) { $agent = $billingAgent; }` -> `MultiAgent` with one `Handoff` per specialist and a fallback agent.
- A tool class that calls the Wikipedia, Tavily or Open-Meteo API with `curl_init()` -> a ready-made package, for example `symfony/ai-wikipedia-tool` with `Symfony\AI\Agent\Bridge\Wikipedia\Wikipedia`.
- A fake `AgentInterface` class with hard-coded answers in tests -> `new MockAgent(['What time is it?' => 'It is noon.'])` and `assertCalledWith()`.
