# AI Chat (`symfony/ai-chat`)

**Applies to:** Symfony AI 0.14

**Elevator pitch:** Use when an AI chatbot must remember the earlier messages of a conversation between HTTP requests. It sends the history to the agent with each new message, and saves the history in the session, a cache, Redis or a database. To add only facts about the user to each prompt, see the memory of [AI Agent](ai-agent.md).

**Details:** [../details/ai-chat.md](../details/ai-chat.md)

## Why it exists

A multi-turn chat must send the earlier messages to the model with each new user message. Without the package, each controller loads the messages from the session, adds the new message, calls the agent and saves the messages again. The package does these steps in one call, also for a streamed answer. It keeps the history in the session, a cache, a database or a key-value store.

## When to use it

- Keep the conversation history of an AI chatbot between HTTP requests.
- Send a user message to an agent together with the earlier messages of the conversation.
- Stream the answer of an agent and save the full answer when the stream ends.
- Start a new conversation with a system prompt and delete the old messages.
- Save the conversation history in the session, a cache pool, Redis or a database.
- Save messages with images, tool calls and thinking blocks in a database or a key-value store.
- Create the table, index or collection of a message store, or delete its messages, from the command line.
- Configure several chats, each with an agent and a message store, in the application configuration.

## Use it instead of

- `$session->get('chat', new MessageBag())`, `$messages->add(Message::ofUser($text))`, `$agent->call($messages)` and `$session->set('chat', $messages)` in a controller -> `ChatInterface::submit()` with `Symfony\AI\Chat\Bridge\Session\MessageStore`.
- `new MessageBag(Message::forSystem($prompt), Message::ofUser($text))` on each request, so the agent never sees the earlier messages -> `ChatInterface::initiate()` once, then `ChatInterface::submit()` for each user message.
- A Redis key for each conversation, with `json_encode()` of the messages on write and `json_decode()` on read -> `new Symfony\AI\Chat\Bridge\Redis\MessageStore($redis, 'chat_'.$conversationId)`, which stores JSON through `MessageNormalizer`. For a new key, call `setup()` or `ChatInterface::initiate()` first.
- `$cache->get('chat_'.$userId, ...)` with `serialize()` of the message list -> `Symfony\AI\Chat\Bridge\Cache\MessageStore` with one `$cacheKey` for each conversation and a TTL.
- A `foreach` over `$agent->call($messages, ['stream' => true])->getContent()` that saves the joined text after the loop -> `ChatInterface::stream()`, which saves the full answer after the last delta.
- A custom normalizer for `UserMessage` and `AssistantMessage` with images, tool calls and thinking blocks -> `Symfony\AI\Chat\MessageNormalizer`.
- A console command with `CREATE TABLE` or `DELETE FROM` for the chat history -> `ai:message-store:setup <store>` and `ai:message-store:drop <store> --force`.
