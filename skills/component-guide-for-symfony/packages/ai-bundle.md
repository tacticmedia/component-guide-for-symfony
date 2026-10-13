# AI Bundle (`symfony/ai-bundle`)

**Applies to:** Symfony AI 0.14

**Elevator pitch:** Use when an application must call LLMs such as OpenAI, Anthropic or Ollama, with providers, agents, vector stores and chat history set in configuration. It creates these objects from one YAML file, with console commands, a debug panel and test assertions. To serve your own tools to MCP clients, see [MCP Bundle](mcp-bundle.md).

**Details:** [../details/ai-bundle.md](../details/ai-bundle.md)

## Why it exists

The AI libraries are plain PHP classes, and an application must otherwise create and connect their objects by hand. The package reads one configuration and creates the provider clients, agents, tools, vector stores and chat stores. It also adds console commands, role checks for tools, a debug panel for each model call and test assertions.

## When to use it

- Call an LLM such as OpenAI, Anthropic, Gemini, Mistral or a local Ollama model from application code.
- Build a chatbot or an assistant with a system prompt, memory and a stored conversation history.
- Let the model call PHP methods of your application as tools, with a role check for each tool.
- Build RAG: index documents in a vector store, and let an agent answer questions about them with a similarity search.
- Send each user request to one of several specialist agents.
- Give an agent the tools of a remote MCP server.
- Cache LLM results, or call a second provider when the call to the first provider throws an exception.
- Assert in a functional test which model an agent called and which tools it used.
- Chat with an agent, or send one prompt to a model, from the terminal.
- Index documents into a vector store from the command line.

## Use it instead of

- `$httpClient->request('POST', 'https://api.openai.com/v1/chat/completions', ['auth_bearer' => $key, 'json' => [...]])` in a service -> `ai.platform.openai.api_key` plus `AgentInterface::call()`.
- `new Agent(Factory::createPlatform($_ENV['OPENAI_API_KEY'], HttpClient::create()), 'gpt-4o-mini')` in a constructor or a manual service definition -> an `ai.agent.<name>` entry and `#[Target('<name>')] AgentInterface $agent`.
- A loop over `$response['choices'][0]['message']['tool_calls']` that calls PHP methods and sends the results back -> `#[AsTool]` with `tools: true`, plus `max_tool_calls` and `fault_tolerant_toolbox`.
- `if (!$this->authorizationChecker->isGranted('ROLE_ADMIN')) { return 'Access denied'; }` at the start of each tool -> `#[IsGrantedTool('ROLE_ADMIN')]`.
- A console command that reads files, calls an embeddings endpoint and inserts vectors with PDO -> `ai.vectorizer`, `ai.indexer` and `ai.store` entries, with `ai:store:setup` and `ai:store:index`.
- `$session->set('chat_history', $messages)` and a manual rebuild of the message list -> an `ai.message_store.session.<name>` entry with `identifier` (the session key) and `ai.chat.<name>` with `ChatInterface::submit()`. Only the `session` type keeps one history for each user session.
- `file_get_contents('prompts/system.txt')` with `str_replace('{name}', ...)` -> `prompt.file` with `{placeholder}` markers and the `template_vars` call option.
- `$cache->get(md5($prompt), fn () => $platform->invoke(...))` -> the `cache` platform (`ai.platform.cache.<name>`) with the `prompt_cache_key` call option and a tag-aware pool.
- `try { $openAi->invoke(...); } catch (\Throwable) { $ollama->invoke(...); }` -> the `failover` platform with a `rate_limiter`.
- `$logger->debug(json_encode($payload))` around each model call -> the "Symfony AI" profiler panel, and `AiAssertionsTrait` in functional tests.
