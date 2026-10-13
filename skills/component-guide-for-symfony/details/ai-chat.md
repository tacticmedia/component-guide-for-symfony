# AI Chat (`symfony/ai-chat`): details

**Applies to:** Symfony AI 0.14

## Key features and concepts

- **Chat service:** `Chat` joins one agent and one message store. Its constructor accepts only a store that implements both `MessageStoreInterface` and `ManagedStoreInterface`. Entry point: `Symfony\AI\Chat\Chat` (type `Symfony\AI\Chat\ChatInterface`).
- **New conversation:** `initiate()` calls `drop()` on the store and saves the `MessageBag` that you give, for example with a system prompt. Entry point: `ChatInterface::initiate()`.
- **Send a message:** `submit()` loads the history, adds the user message and calls the agent. It adds the answer with the result metadata, saves the history and returns the `AssistantMessage`. Entry point: `ChatInterface::submit()`.
- **Stream an answer:** `stream()` returns a `\Generator` of `DeltaInterface` objects, for example `TextDelta`. After the last delta, it saves the user message and the full answer, with thinking blocks and signatures. If you stop the loop early, `stream()` saves nothing. Entry point: `ChatInterface::stream()`.
- **Saved history content:** the agent adds messages to the `MessageBag` that `Chat` gives it, and `Chat` saves this bag. So the history also keeps the tool calls, the tool results and the system prompt that the agent adds. If the history already has a system message, the agent does not add its `prompt`. To keep the tool messages out of the history, set `exclude_tool_messages: true` on the agent. To show the history, use `$store->load()->withoutSystemMessage()->withoutToolMessages()`. Entry points: `ai.agent.<name>.exclude_tool_messages`, `MessageBag::withoutToolMessages()`.
- **Store contract:** `save()` stores a `MessageBag` and `load()` returns it. `setup()` prepares the storage, for example a table, an index or a collection. `drop()` deletes the stored messages and keeps the storage. For the in-memory, Cache, Pogocache and Session stores, `setup()` also deletes the stored history. Entry points: `Symfony\AI\Chat\MessageStoreInterface`, `Symfony\AI\Chat\ManagedStoreInterface`.
- **One history for each store:** a store keeps one conversation under a fixed key, table, index or collection. `submit()` takes no conversation ID. With the AI Bundle, these names come from the configuration, so all users share the history of a persistent store. The Session store is the exception: it keeps one history for each user session. Entry point: constructor arguments such as `$cacheKey`, `$indexName` and `$sessionKey`.
- **In-memory store:** it keeps the history only in the current PHP process. With the AI Bundle, it has the `kernel.reset` tag, so Symfony clears it before each main request after the first one. Entry point: `Symfony\AI\Chat\InMemory\Store`.
- **Message store bridges:** there are 9 bridge packages, `symfony/ai-*-message-store`. They keep the history in a PSR-6 cache, Cloudflare KV, Doctrine DBAL, Meilisearch, MongoDB, Pogocache, Redis, the HttpFoundation session or SurrealDB. The section "Supported Message stores" of the Chat docs lists them, together with InMemory. The MongoDB and SurrealDB packages are `symfony/ai-mongo-db-message-store` and `symfony/ai-surreal-db-message-store`. Entry point: `Symfony\AI\Chat\Bridge\<Name>\MessageStore` with `<Name>` = `Cache`, `Cloudflare`, `Meilisearch`, `MongoDb`, `Pogocache`, `Redis`, `Session` or `SurrealDb`; for Doctrine, `Symfony\AI\Chat\Bridge\Doctrine\DoctrineDbalMessageStore`.
- **Session store:** it saves the `MessageBag` in the session of the current request under `$sessionKey` (default `messages`). If there is no current request with a session, for example in a console command, its constructor throws `Symfony\Component\HttpFoundation\Exception\SessionNotFoundException`. The docs do not recommend it with `stream()`. Entry point: `Symfony\AI\Chat\Bridge\Session\MessageStore`.
- **Cache store:** it saves the `MessageBag` in a PSR-6 pool under `$cacheKey`, with a TTL of 86400 seconds by default. Each `save()` sets the TTL again, so by default the history expires one day after the last save. Entry point: `Symfony\AI\Chat\Bridge\Cache\MessageStore`.
- **Message serialization:** all bridges except Cache and Session use `MessageNormalizer`. It keeps the message UUID, the metadata and the order of the text, thinking and tool-call parts. It also keeps text, image, audio, video, document and file content. Entry point: `Symfony\AI\Chat\MessageNormalizer`.
- **Setup and drop commands:** `ai:message-store:setup <store>` calls `setup()`, and `ai:message-store:drop <store> --force` calls `drop()`. With the AI Bundle, `<store>` is the service ID, for example `ai.message_store.cache.symfonycon`. Run the setup command only once, before the first chat call. Entry points: `Symfony\AI\Chat\Command\SetupStoreCommand`, `Symfony\AI\Chat\Command\DropStoreCommand`.
- **Profiler decorators:** `TraceableChat` records each `initiate()`, `submit()` and `stream()` call, and `TraceableMessageStore` records each `save()`. In debug mode, the AI Bundle decorates each chat and each message store with them. Entry points: `Symfony\AI\Chat\TraceableChat`, `Symfony\AI\Chat\TraceableMessageStore` (`getCalls()`).

## Entry points

- `composer require symfony/ai-chat`, and for a persistent store one bridge, for example `composer require symfony/ai-session-message-store`. The AI Bundle requires neither package.
- If `ai.chat` has exactly one chat, autowire `Symfony\AI\Chat\ChatInterface`. Else, use `#[Symfony\Component\DependencyInjection\Attribute\Target('<chat name>')] ChatInterface $chat`.
- If `ai.message_store` has exactly one store, autowire `Symfony\AI\Chat\MessageStoreInterface`. Else, use `#[Symfony\Component\DependencyInjection\Attribute\Autowire(service: 'ai.message_store.<type>.<name>')] MessageStoreInterface $store`.
- Config key `ai.chat.<name>` with `agent` and `message_store`, both service IDs (for example `ai.agent.youtube` and `ai.message_store.cache.youtube`). The bundle creates the service `ai.chat.<name>`.
- Config key `ai.message_store.<type>.<name>` with the types `cache`, `cloudflare`, `doctrine.dbal`, `meilisearch`, `memory`, `mongodb`, `pogocache`, `redis`, `session` and `surrealdb`. The service ID is `ai.message_store.<type>.<name>`, for example `ai.message_store.doctrine.dbal.<name>`.
- Console commands `ai:message-store:setup <store>` and `ai:message-store:drop <store> --force`. The AI Bundle registers them only if the configuration has a message store.
- The console command `ai:chat` is an alias of `ai:agent:call` from the AI Bundle. It keeps its own `MessageBag` and does not use this package.
- Without FrameworkBundle: `new Symfony\AI\Chat\Chat($agent, $store)` with a `Symfony\AI\Agent\AgentInterface` and a store, for example `new Symfony\AI\Chat\InMemory\Store()`. Call `$store->setup()` once. For a new conversation, call `$chat->initiate($messages)` before the first `submit()`.
- For one history for each conversation, create the store in your code, for example `new Chat($agent, new Symfony\AI\Chat\Bridge\Cache\MessageStore($cache, 'chat_'.$conversationId))`.
- Messages from AI Platform: `Symfony\AI\Platform\Message\Message::forSystem()`, `Message::ofUser()`, `Symfony\AI\Platform\Message\MessageBag`, and `AssistantMessage::asText()` for the answer text.
- Custom store: implement `Symfony\AI\Chat\MessageStoreInterface` and `Symfony\AI\Chat\ManagedStoreInterface`.
- Errors: `submit()` and `stream()` throw agent exceptions (`Symfony\AI\Agent\Exception\ExceptionInterface`) and platform exceptions (`Symfony\AI\Platform\Exception\ExceptionInterface`, for example `RateLimitExceededException`). `stream()` throws them in the `foreach` loop, because it starts the agent only when the loop starts. The exceptions of this package implement `Symfony\AI\Chat\Exception\ExceptionInterface`.

## Symbiotic packages

- [AI Agent](../packages/ai-agent.md): `Chat` sends the full history to an `AgentInterface` on each call; for user facts in the system prompt, use Agent memory (`MemoryInputProcessor`).
- [AI Platform](../packages/ai-platform.md): it provides the message classes that a chat stores (`MessageBag`, `UserMessage`, `AssistantMessage`) and the stream deltas, such as `TextDelta`, that `stream()` yields.
- [AI Bundle](../packages/ai-bundle.md): its `ai.chat` and `ai.message_store` keys create the chat and store services, and it registers the `ai:message-store:*` commands and the profiler decorators.
- [AI Store](../packages/ai-store.md): use it for documents and vectors (RAG), with its own `Symfony\AI\Store\ManagedStoreInterface` and `ai:store:*` commands; use a message store for the conversation history.
- [Cache](../packages/cache.md): the Cache message store saves the history in a PSR-6 pool; the AI Bundle uses `cache.app` by default.
- [HttpFoundation](../packages/http-foundation.md): the Session message store saves the history in the session of the current request, which it gets from `RequestStack`.
- [Serializer](../packages/serializer.md): all bridges except Cache and Session serialize messages with `MessageNormalizer`; the AI Bundle tags it `serializer.normalizer` and passes the `serializer` service to these bridges.
- [HttpClient](../packages/http-client.md): the Cloudflare, Meilisearch, Pogocache and SurrealDB message stores call their HTTP APIs through `HttpClientInterface`.
- [DependencyInjection](../packages/dependency-injection.md): `#[Target('<chat name>')]` selects one of several configured chats.
- [WebProfilerBundle](../packages/web-profiler-bundle.md): in debug mode, the AI toolbar item shows "Chats sent" and "Messages stored" (`save()` calls) for a request that calls a platform.

## Changed in 0.7 to 0.14 (with Symfony 8.1)

- `ChatStreamListener` (removed in 0.13) -> `Chat::stream()`, which saves the answer and its result metadata after the stream ends. Consume all deltas, else `stream()` saves nothing.
- 0.13: the answer that `stream()` saves keeps its `Thinking` parts. Code that reads the stored history must accept structured content, not only text.
- 0.9: `MessageNormalizer` writes an ordered `parts` field for assistant messages. Old stored data still loads, but without the order of text and tool calls. Normalize the stored history again.
- `$traceableChat->calls` and `$traceableMessageStore->calls` -> `getCalls()` (0.8).
- `Symfony\AI\AiBundle\Profiler\TraceableChat` -> `Symfony\AI\Chat\TraceableChat`, and the same for `TraceableMessageStore` (0.7).
- 0.7: `ChatInterface` has the method `stream()`. A custom implementation of `ChatInterface` must add it.
- `ChatInterface $youtube` without an attribute -> `#[Target('youtube')] ChatInterface $chat` (Symfony 8.1 deprecates the match by name only).
- 0.13, AI Bundle: `keep_tool_messages: true` -> `exclude_tool_messages: true`. Both settings keep the tool calls and the tool results out of the saved history.

## Status

- 0.x and experimental: the README says "This Component is experimental", and the Symfony backward compatibility promise does not cover it. Minor versions break the API, for example 0.8, 0.9 and 0.13. Before an update, read `UPGRADE.md` of symfony/ai.
- The package needs PHP 8.2 or higher. The Redis bridge needs the `redis` PHP extension. The MongoDB bridge needs `mongodb/mongodb`, which needs the `mongodb` PHP extension.
- Known issues in 0.14:
  - The AI Bundle gives the `meilisearch` message store arguments that do not match its constructor (the HTTP client is missing). If you need this store, define it as your own service.
  - `DoctrineDbalMessageStore::save()` adds a new row with the full history, and `load()` joins all rows. With `Chat`, the loaded history repeats earlier messages after two saves.

## Docs

- https://symfony.com/doc/current/ai/components/chat.html (main page; the section "Supported Message stores" lists the stores)
- https://symfony.com/doc/current/ai/bundles/ai-bundle.html (the `message_store` and `chat` configuration)
- https://github.com/symfony/ai-chat (README with the table of the 9 bridge packages)
- https://symfony.com/doc/current/ai/cookbook/chatbot-with-memory.html (Agent memory; it does not use this package)
- https://symfony.com/doc/current/contributing/code/bc.html (experimental features)
