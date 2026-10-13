# AI Store (`symfony/ai-store`): details

**Applies to:** Symfony AI 0.14

## Key features and concepts

- **Documents and metadata:** a `TextDocument` has an id, a text and a `Metadata` object. The id is an `int` or a `string`, for example `Uuid::v7()->toRfc4122()`. If the file that creates the document has `declare(strict_types=1)`, a `Uuid` object as the id causes a `TypeError`. `Metadata` is an `ArrayObject` with the reserved keys `_text`, `_source`, `_parent_id`, `_title`, `_summary` and `_depth`. Entry point: `Symfony\AI\Store\Document\TextDocument`, `Symfony\AI\Store\Document\Metadata`.
- **Vectorizer:** `Vectorizer` sends documents or strings to an embedding model of AI Platform. It returns a `VectorDocument` for each document and a `Vector` for each string. For an array, it sends one batched request. With `includeText: true`, it copies each text into the `_text` key, which text search and reranking read. The default is `false`, and the AI Bundle vectorizer has no option for it. Entry point: `Symfony\AI\Store\Document\Vectorizer`.
- **Indexers:** `DocumentProcessor` filters and transforms the documents, then vectorizes and stores them in batches of 50. `DocumentIndexer` indexes the documents that you give. `SourceIndexer` gets the documents from a loader, for one source or a list of sources. `ConfiguredSourceIndexer` adds a default source. The `chunk_size` option of `index()` sets the batch size of the vectorizer, not the size of the text chunks. Entry point: `Symfony\AI\Store\IndexerInterface::index()`.
- **Loaders:** nine loaders read sources: `TextFileLoader`, `MarkdownLoader`, `CsvLoader`, `JsonFileLoader` (JsonPath expressions), `RssFeedLoader`, `RstLoader`, `RstToctreeLoader` (follows `toctree` entries), `DirectoryLoader` (one loader for each file extension) and `InMemoryLoader`. Entry point: `Symfony\AI\Store\Document\LoaderInterface`.
- **Transformers and filters:** `TextSplitTransformer` cuts long texts into chunks of 1000 characters with an overlap of 200 by default. Each chunk gets a new id, the `_parent_id` key and the `_text` key. Other transformers trim text, replace text, add an LLM summary (`SummaryGeneratorTransformer`) or pause between batches for API rate limits (`ChunkDelayTransformer`). `TextContainsFilter` removes the documents that contain a given text. Entry point: `Symfony\AI\Store\Document\TransformerInterface`, `Symfony\AI\Store\Document\FilterInterface`.
- **Stores and query types:** `StoreInterface` adds, removes, clears, counts and queries vector documents. A query is a `VectorQuery`, a `TextQuery` or a `HybridQuery` with a `semanticRatio` from 0.0 to 1.0 (default 0.5). The in-memory, Cache, Postgres and SQLite stores support the three types, but 19 of the 24 bridges support only `VectorQuery`. Before you send a `TextQuery` or a `HybridQuery`, call `supports()`. If the store does not support the query type, `query()` throws `UnsupportedQueryTypeException` (ClickHouse: `InvalidArgumentException`). Entry point: `Symfony\AI\Store\StoreInterface::query()`.
- **Retriever:** `Retriever::retrieve()` turns a query string into documents. With a vectorizer, it embeds the string and sends a `HybridQuery` if the store supports it, else a `VectorQuery`. The text part of a query searches the `_text` key. On Postgres, a `HybridQuery` returns only the documents whose `_text` matches a word of the query. Without a vectorizer, or if the store does not support `VectorQuery`, it sends a `TextQuery`. The option `semanticRatio` sets the weight of the vector part. The retriever gives all options to the store. Entry point: `Symfony\AI\Store\RetrieverInterface`.
- **Number of results:** the query option that limits the number of results depends on the store. The in-memory, Cache and SQLite stores read `maxItems`. Postgres, MariaDB, Redis, MongoDB, ClickHouse, ChromaDB, Milvus, Qdrant and Supabase read `limit`, and Postgres returns 5 results by default. Elasticsearch, OpenSearch, ManticoreSearch, Typesense and Vektor read `k`, and Pinecone and S3 Vectors read `topK`. `ai:store:retrieve --limit` sends `maxItems`, so on Postgres the command shows max 5 results. Entry point: the `$options` argument of `StoreInterface::query()` and `RetrieverInterface::retrieve()`.
- **In-memory store and distances:** `InMemory\Store` keeps the vectors in a PHP array and accepts a `filter` callable. `DistanceCalculator` uses the cosine distance by default, or the angular, Euclidean, Manhattan or Chebyshev distance. The in-memory store returns the distance as the score, so a lower score is a better match. It keeps the documents only in the current PHP process, so a web request does not see the documents that a console command indexed. Entry point: `Symfony\AI\Store\InMemory\Store`, `Symfony\AI\Store\Distance\DistanceStrategy`.
- **Hybrid search with two stores:** `CombinedStore` sends the vector part of a `HybridQuery` to one store and the text part to a second store. It merges the two result lists with reciprocal rank fusion (`rrfK`, default 60). Entry point: `Symfony\AI\Store\CombinedStore`.
- **Query events and reranker:** if the `Retriever` has an event dispatcher, it dispatches `PreQueryEvent` before the search and `PostQueryEvent` after it. A listener can change the query, the options or the results. `RerankerListener` with `Reranker` scores the results again with a reranking model and keeps the best 5 by default. The reranker reads the `_text` key, or `_source` if `_text` is not set. `Reranker` sends the keys `query` and `texts`. The reranking models of Cohere, Hugging Face, OpenRouter and Together accept them, but Fireworks needs `documents`. The AI Bundle gives each retriever the `event_dispatcher` service. Register `RerankerListener` as a listener of `PostQueryEvent`, because the bundle does not register it. Entry point: `Symfony\AI\Store\EventListener\RerankerListener`, `Symfony\AI\Store\Event\PreQueryEvent`.
- **Managed stores:** `ManagedStoreInterface::setup()` creates the table, index or collection, and `drop()` deletes it with all data. `StoreInterface::clear()` deletes all documents but keeps the structure, so the store is ready for a new index run. 22 of the 24 bridges are managed stores: Azure AI Search and Supabase are not. If a store uses the Doctrine DBAL connection, exclude its table from the Doctrine schema tools with `doctrine.dbal.schema_filter`. Entry point: `Symfony\AI\Store\ManagedStoreInterface`.
- **Store bridges:** each backend has its own package `symfony/ai-<name>-store`, for example `symfony/ai-postgres-store`. The docs page "Store Bridges" lists the 24 bridge packages and the in-memory store of this package. Do not confuse them with the nine `symfony/ai-*-message-store` packages of AI Chat. Entry point: `composer require symfony/ai-postgres-store`.
- **RAG with an agent:** the `SimilaritySearch` tool (`similarity_search`) of `symfony/ai-similarity-search-tool` calls a retriever and sends the metadata of each found document to the model as JSON. The model sees only the metadata, so put the text into it, for example with `includeText: true` or `TextSplitTransformer`. The tool passes no options, so the store default sets the number of results: the in-memory store returns all documents. In the AI Bundle, register the tool as a service with the argument `$retriever: '@ai.retriever.<name>'`. Then add the tool to the `tools` list of the agent, or set `tools: true` for all tools. Entry point: `Symfony\AI\Agent\Bridge\SimilaritySearch\SimilaritySearch`.
- **Profiler and tests:** `TraceableStore` records the `add()`, `query()`, `remove()` and `clear()` calls with their arguments and the call time for the AI profiler panel. The AI Bundle adds it to each store in debug mode. `AbstractStoreIntegrationTestCase` tests a custom store against the `StoreInterface` contract. Entry point: `Symfony\AI\Store\TraceableStore`, `Symfony\AI\Store\Test\AbstractStoreIntegrationTestCase`.

## Entry points

- Install: `composer require symfony/ai-store`. For a backend other than the in-memory store, also install its bridge package, for example `symfony/ai-postgres-store`. In a Symfony application, also install `symfony/ai-bundle`.
- Without FrameworkBundle: index with `new DocumentIndexer(new DocumentProcessor($vectorizer, $store))`, or with `new SourceIndexer($loader, new DocumentProcessor($vectorizer, $store))` for a loader. Search with `new Retriever($store, $vectorizer)`. For `RerankerListener`, give the `Retriever` an event dispatcher.
- Autowire `Symfony\AI\Store\StoreInterface` when the application configures one store. For one of several stores, add `#[Target('<type>_<name>')]`, for example `#[Target('memory_main')] StoreInterface $store`. The service ID is `ai.store.<type>.<name>`. `#[Target('<name>')]` also works, but if two store types use the same name, the argument gets the store that the configuration lists last. Symfony 8.1 deprecates an argument name without `#[Target]`, for example `StoreInterface $memoryMain`.
- Autowire `Symfony\AI\Store\IndexerInterface` or `Symfony\AI\Store\RetrieverInterface` when the application configures one indexer or one retriever. If the application configures more than one, add `#[Target('<name>')]`. The service IDs are `ai.indexer.<name>` and `ai.retriever.<name>`. For a vectorizer, use `#[Target('<name>')]` or the service ID `ai.vectorizer.<name>`.
- Classes `Symfony\AI\Store\Retriever`, `Symfony\AI\Store\Document\Vectorizer`, `Symfony\AI\Store\Indexer\DocumentProcessor`, `Symfony\AI\Store\Indexer\DocumentIndexer`, `Symfony\AI\Store\Indexer\SourceIndexer`, `Symfony\AI\Store\Indexer\ConfiguredSourceIndexer`, `Symfony\AI\Store\CombinedStore` and `Symfony\AI\Store\InMemory\Store`.
- Documents `Symfony\AI\Store\Document\TextDocument`, `VectorDocument`, `VectorDocumentInterface`, `EmbeddableDocumentInterface` and `Metadata`.
- Queries `Symfony\AI\Store\Query\VectorQuery`, `TextQuery`, `HybridQuery` and `QueryInterface`.
- Interfaces for your own implementations: `Symfony\AI\Store\StoreInterface`, `Symfony\AI\Store\ManagedStoreInterface`, `Symfony\AI\Store\Document\LoaderInterface`, `Symfony\AI\Store\Document\TransformerInterface`, `Symfony\AI\Store\Document\FilterInterface`, `Symfony\AI\Store\Document\VectorizerInterface` and `Symfony\AI\Store\Reranker\RerankerInterface`.
- Loaders in `Symfony\AI\Store\Document\Loader\`, transformers in `Symfony\AI\Store\Document\Transformer\` and the filter `Symfony\AI\Store\Document\Filter\TextContainsFilter`.
- Events `Symfony\AI\Store\Event\PreQueryEvent` and `Symfony\AI\Store\Event\PostQueryEvent`, the listener `Symfony\AI\Store\EventListener\RerankerListener` and `Symfony\AI\Store\Reranker\Reranker`.
- Distances `Symfony\AI\Store\Distance\DistanceCalculator` and `Symfony\AI\Store\Distance\DistanceStrategy` (`cosine`, `angular`, `euclidean`, `manhattan`, `chebyshev`).
- AI Bundle configuration `ai.store.<type>.<name>` with 25 types, for example `memory` (key `strategy`), `postgres` or `chromadb`. For a Doctrine DBAL connection, `postgres` takes its service ID in `dbal_connection`, and `mariadb` and `sqlite` take its name, for example `default`, in `connection`. `ai.vectorizer.<name>` has the keys `platform` and `model`. `ai.retriever.<name>` has the keys `vectorizer` and `store`.
- AI Bundle configuration `ai.indexer.<name>` with the keys `loader`, `source`, `transformers`, `filters`, `vectorizer` and `store`. The values of `loader`, `transformers` and `filters` are service IDs. The bundle does not register the loader, transformer and filter classes, so register them as services. Without `loader`, the bundle creates a `DocumentIndexer`. Set `vectorizer` on each indexer and retriever, because the bundle has no `VectorizerInterface` alias. The default of `store` works only if the application has exactly one store.
- Console commands in `Symfony\AI\Store\Command\`, which the AI Bundle registers: `ai:store:setup <store>`, `ai:store:drop <store> --force`, `ai:store:clear <store> --force`, `ai:store:index <indexer> [--source=...]` and `ai:store:retrieve <retriever> [query] [--limit=10]`. The `<store>` argument is the service ID, for example `ai.store.chromadb.default`. The `<indexer>` and `<retriever>` arguments are the configured names.
- Test helpers: `Symfony\AI\Store\Test\AbstractStoreIntegrationTestCase` for a custom store, `count($store)` and `assertCount()` on each store, and `InMemory\Store` as a test store. With the AI Bundle: `Symfony\AI\AiBundle\Test\AiAssertionsTrait::assertToolCalled('similarity_search')`.
- Profiler: `Symfony\AI\Store\TraceableStore::getCalls()`.
- The package has no attributes and no Twig functions.

## Symbiotic packages

- [AI Platform](../packages/ai-platform.md): `Vectorizer`, `Reranker` and `SummaryGeneratorTransformer` call the embedding, reranking and chat models through `PlatformInterface`.
- [AI Agent](../packages/ai-agent.md): the `SimilaritySearch` tool (`symfony/ai-similarity-search-tool`) and the `EmbeddingProvider` memory read from a store, so an agent answers from your documents.
- [AI Bundle](../packages/ai-bundle.md): it configures stores, vectorizers, indexers and retrievers under `ai`, registers the `ai:store:*` commands and adds `TraceableStore` in debug mode.
- [AI Chat](../packages/ai-chat.md): its message stores (`symfony/ai-*-message-store`, `ai:message-store:setup`) keep chat history. Use AI Store for documents and embeddings, and AI Chat for conversations.
- [EventDispatcher](../packages/event-dispatcher.md): the `Retriever` dispatches `PreQueryEvent` and `PostQueryEvent` only with a dispatcher, so `RerankerListener` needs one.
- [Console](../packages/console.md): the five `ai:store:*` commands need the Console component, which `symfony/ai-store` does not require.
- [Uid](../packages/uid.md): `TextFileLoader`, `MarkdownLoader`, the RST loaders, `CsvLoader` without an id column, `TextSplitTransformer` and `SummaryGeneratorTransformer` create UUID v4 ids, and `RssFeedLoader` creates stable UUID v5 ids.
- [Clock](../packages/clock.md): `ChunkDelayTransformer` waits through `ClockInterface`, and `TraceableStore` records the time of each call.
- [HttpClient](../packages/http-client.md): `RssFeedLoader` fetches the feeds, and many bridges call their backend API through `HttpClientInterface`.
- [Finder](../packages/finder.md): `DirectoryLoader` needs the Finder component to walk a directory.
- [JsonPath](../packages/json-path.md): `JsonFileLoader` needs JsonPath to read the id, the content and the metadata from JSON files.
- [DomCrawler](../packages/dom-crawler.md): `RssFeedLoader` needs DomCrawler to parse RSS feeds.
- [String](../packages/string.md): `MarkdownLoader` needs the String component.
- [Filesystem](../packages/filesystem.md): `MarkdownLoader` needs the Filesystem component.
- [Cache](../packages/cache.md): the bridge `symfony/ai-cache-store` keeps all vectors in one item of a Symfony cache pool, for example `cache.app`. Its `drop()` method clears the whole pool, so give the store its own pool.
- [WebProfilerBundle](../packages/web-profiler-bundle.md): the AI profiler panel shows the store calls that `TraceableStore` records.

## Changed in 0.4 to 0.14

- **0.4:** `new Indexer($loader, $vectorizer, $store, $source)` -> `new SourceIndexer($loader, new DocumentProcessor($vectorizer, $store))` and `index($source)`. For documents without a loader, use `new DocumentIndexer(new DocumentProcessor($vectorizer, $store))`.
- **0.4:** `ConfiguredIndexer` -> `Indexer\ConfiguredSourceIndexer`, and `withSource($source)->index()` -> `index($source)`.
- **0.4:** `$store->query($vector)` -> `$store->query(new VectorQuery($vector))`. Public properties such as `$document->vector` -> getters such as `getVector()`.
- **0.4:** `new TextDocument(Uuid::v4(), ...)` -> a `string` or `int` id, for example `Uuid::v4()->toString()`.
- **0.4 and 0.7:** `new Retriever($vectorizer, $store, $logger)` -> `new Retriever($store, $vectorizer, logger: $logger)`. The third argument is now the event dispatcher.
- **0.7:** `new SimilaritySearch($vectorizer, $store)` -> `new SimilaritySearch(new Retriever($store, $vectorizer))`.
- **0.11 and 0.14:** a custom store must implement `clear()` (0.11) and `count()` (0.14), and type its documents with `VectorDocumentInterface` (0.14).
- **0.7 to 0.14:** the `Store` constructors of many HTTP-based bridges no longer accept an endpoint or an API key -> the `StoreFactory::create()` method of the bridge. The Meilisearch option `['q' => 'keyword']` -> `new HybridQuery($vector, 'keyword', 0.5)`.

## Status

- 0.x and experimental: the README says "This Component is experimental", and the Symfony backward compatibility promise does not cover it. Minor versions break the API, for example 0.14 adds `count()` to `StoreInterface`. Before an update, read `UPGRADE.md` of symfony/ai.
- Packagist has no v0.14.1 of `symfony/ai-store`: v0.14.0 is the latest release. Some bridges have their own patch releases, for example `symfony/ai-elasticsearch-store` v0.14.1.
- The package needs PHP 8.2 or higher and the `fileinfo` PHP extension.
- Some loaders need packages that `symfony/ai-store` does not require: `DirectoryLoader` needs `symfony/finder`, `JsonFileLoader` needs `symfony/json-path`, `RssFeedLoader` needs `symfony/dom-crawler`, and `MarkdownLoader` needs `symfony/string` and `symfony/filesystem`.
- The in-memory, Cache and SQLite `Store` classes load all vectors into PHP memory for a vector query. Use them only if the data fits into the PHP memory limit.

## Docs

- https://symfony.com/doc/current/ai/components/store.html
- https://symfony.com/doc/current/ai/components/store/bridges.html
- https://symfony.com/doc/current/ai/components/store/local.html
- https://symfony.com/doc/current/ai/components/store/sqlite.html
- https://symfony.com/doc/current/ai/components/store/mongodb.html
- https://symfony.com/doc/current/ai/components/store/s3-vectors.html
- https://symfony.com/doc/current/ai/components/store/supabase.html
- https://symfony.com/doc/current/ai/cookbook/rag-implementation.html
- https://symfony.com/doc/current/ai/cookbook/ai-bundle-fast-track.html
- https://symfony.com/doc/current/ai/bundles/ai-bundle.html
- https://github.com/symfony/ai
