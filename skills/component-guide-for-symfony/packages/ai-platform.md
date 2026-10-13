# AI Platform (`symfony/ai-platform`)

**Applies to:** Symfony AI 0.14

**Elevator pitch:** Use when PHP code must call an LLM API such as OpenAI, Anthropic, Gemini or Ollama for text, streams, structured data, embeddings or speech. It gives one API with typed results for many providers. For tool-call loops, see [AI Agent](ai-agent.md). To search your own documents, see [AI Store](ai-store.md). For configuration in an application, see [AI Bundle](ai-bundle.md).

**Details:** [../details/ai-platform.md](../details/ai-platform.md)

## Why it exists

Each LLM provider has its own HTTP API, request format, stream format and error codes. Code that calls one provider directly must change when the application moves to another provider. The package gives one call and typed results for all providers. A separate package for each provider converts the requests and the responses.

## When to use it

- Send a prompt or a conversation to an LLM provider and get the answer as text.
- Get structured output: the model answer as a PHP object that matches a JSON schema.
- Stream the model answer to the browser while the model generates it.
- Create embedding vectors from text or images, for example for semantic search.
- Send images, PDF documents, audio or video to a model, or convert text to speech.
- Enable the server tools of a provider, for example web search or code execution.
- Start an asynchronous job, for example a video generation or a batch request, and get the result later.
- Pass a provider job to a background worker that waits for the result.
- Test code that calls AI models without network access or API keys.

## Use it instead of

- `curl_init()` or `$httpClient->request('POST', 'https://api.openai.com/v1/chat/completions', ['json' => $body])` -> `PlatformInterface::invoke()` on a platform from `Factory::createPlatform()`.
- `json_decode($answer, true)` plus manual field checks, or a hand-written JSON schema array for each DTO -> the `response_format` option with the class name, then `asObject()`. `ResponseFormatFactory` builds the schema from the class.
- A loop that reads the `data:` lines of a server-sent event stream -> the `stream` option and `asTextStream()`.
- `base64_encode(file_get_contents($path))` in a hand-built `image_url` message part -> `Image::fromFile($path)` in `Message::ofUser()`.
- A hard-coded array of model names and model features -> the model catalog of the bridge, or `ModelsDev\ModelCatalog` with `symfony/models-dev`.
- A `while` loop with `sleep()` that polls the status URL of a provider job -> `asJob()` and `JobRunner::wait()`.
- `if (429 === $response->getStatusCode()) { sleep((int) $response->getHeaders(false)['retry-after'][0]); }` -> catch `RateLimitExceededException` and read `getRetryAfter()`. It can return `null`, because some bridges do not read the `Retry-After` header and others read only a value in seconds.
- A cache lookup with `md5($prompt)` around each model call -> `CachePlatform` with the `prompt_cache_key` option.
- Hand-written `'cache_control' => ['type' => 'ephemeral']` blocks in an Anthropic request -> the automatic prompt cache markers of the Anthropic bridge (`cacheRetention` argument of `Factory::createPlatform()`: `short`, `long` or `none`). The AI Bundle key is `ai.platform.anthropic.cache_retention`.
- A `MockHttpClient` with fake provider JSON in tests -> `InMemoryPlatform` or `MockPlatformFactory`.
