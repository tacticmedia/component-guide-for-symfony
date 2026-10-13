# AI Store (`symfony/ai-store`)

**Applies to:** Symfony AI 0.14

**Elevator pitch:** Use when an LLM must answer from your own documents with RAG, or when code must find similar text in a vector database. It loads and splits the documents, creates their embeddings, keeps them in memory or in a database, and finds the closest matches. For chat history, see [AI Chat](ai-chat.md).

**Details:** [../details/ai-store.md](../details/ai-store.md)

## Why it exists

An LLM knows only its training data, so it cannot answer questions about your own documents. Code that does this by hand must split texts, call an embeddings API, store the vectors and compute the similarity. The package does these steps. One interface covers an in-memory store and 24 backend packages, so your code stays the same when you change the database.

## When to use it

- Let an LLM agent answer questions from your own documents with RAG.
- Split text, Markdown, CSV, JSON, RSS or reStructuredText sources into chunks and create their embeddings.
- Keep embeddings in Postgres with pgvector, MariaDB, SQLite, Elasticsearch, Qdrant, Pinecone or another vector database.
- Find the documents that are most similar to a question or a search phrase.
- Combine vector search with keyword search, and rerank the results with a reranking model.
- Fill a vector store from the command line, and clear it before you index the documents again.
- Test RAG code with the in-memory store, without a database server.

## Use it instead of

- A PHP loop that computes the cosine similarity for each stored `float[]` embedding, then `usort()` -> `$store->query(new VectorQuery($vector))` on `InMemory\Store` or a database bridge.
- A `mb_substr()` loop that cuts long texts into overlapping chunks -> `new TextSplitTransformer(chunkSize: 1000, overlap: 200)` in the transformers of `DocumentProcessor`.
- One embeddings request per document with `curl_init()` or `HttpClientInterface` -> `Vectorizer::vectorize($documents)`, which sends one batched `PlatformInterface::invoke()` call.
- Hand-written pgvector SQL such as `ORDER BY embedding <=> :vector LIMIT 5` -> `symfony/ai-postgres-store` with `distance: cosine` and `$store->query(new VectorQuery($vector), ['limit' => 5])`.
- A migration that runs `CREATE TABLE` and `CREATE INDEX` for the vector table -> `php bin/console ai:store:setup ai.store.postgres.<name>` or `ManagedStoreInterface::setup()`.
- A custom console command that reads files, creates embeddings and inserts rows -> an `ai.indexer.<name>` configuration and `php bin/console ai:store:index <name> --source=<path>`.
- A manual merge of a `LIKE '%term%'` result and a vector result -> `new HybridQuery($vector, 'term', 0.5)` on a store that supports it, or `CombinedStore`.
- All documents pasted into the system prompt -> the `SimilaritySearch` tool with `new Retriever($store, $vectorizer)`, so the model searches the store when it needs facts.
- `DELETE FROM documents` before you index again -> `$store->clear()` or `php bin/console ai:store:clear <store> --force`.
