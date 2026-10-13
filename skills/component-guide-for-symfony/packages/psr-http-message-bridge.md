# PSR-7 Bridge (`symfony/psr-http-message-bridge`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when your application must exchange HTTP requests and responses with a library that accepts or returns only PSR-7 objects. It converts both directions with PSR-17 factories, and controllers can take a PSR-7 request or return a PSR-7 response. For a PSR-18 HTTP client, see [HttpClient](http-client.md).

**Details:** [../details/psr-http-message-bridge.md](../details/psr-http-message-bridge.md)

## Why it exists

The [HttpFoundation](http-foundation.md) package models HTTP messages with its own request and response classes, and PSR-7 defines a different set of HTTP message interfaces. Code for one model cannot use the objects of the other model. Hand-written conversion code must copy the query, the cookies, the uploaded files and the parsed body one by one. The bridge converts the objects in both directions, and it connects PSR-7 objects to controllers.

## When to use it

- Give the current HTTP request to a library that accepts only a PSR-7 server request.
- Send the PSR-7 response of a library to the client as a normal application response.
- Get a PSR-7 server request as a controller argument.
- Return a PSR-7 response from a controller.
- Convert a PSR-7 server request into an [HttpFoundation](http-foundation.md) request for code that expects it.
- Convert a streamed response or a file download response into a PSR-7 response.

## Use it instead of

- `new \Nyholm\Psr7\ServerRequest($request->getMethod(), $request->getUri(), $request->headers->all(), $request->getContent())` and more calls to copy the query, the cookies and the files -> `$httpMessageFactory->createRequest($request)` with `HttpMessageFactoryInterface`.
- `new Response((string) $psrResponse->getBody(), $psrResponse->getStatusCode(), $psrResponse->getHeaders())` -> `$httpFoundationFactory->createResponse($psrResponse)` with `HttpFoundationFactoryInterface`, which also converts the `Set-Cookie` headers into `Cookie` objects.
- `json_decode($request->getContent(), true)` and `$psrRequest->withParsedBody($data)` -> `PsrHttpFactory::createRequest()`, which sets the parsed body for a JSON request.
- A loop over `$request->files->all()` that calls `$psr17Factory->createUploadedFile()` -> `PsrHttpFactory::createRequest()`, which converts nested uploaded files.
- `$psrRequest = $this->psrHttpFactory->createRequest($request);` at the start of each controller action -> a `ServerRequestInterface $request` argument with the `PsrServerRequestResolver` service.
- `return $this->httpFoundationFactory->createResponse($psrResponse);` at the end of each controller action -> `return $psrResponse;` with the `PsrResponseListener` service.
- `ob_start()`, `$streamedResponse->sendContent()` and `ob_get_clean()` to read a `StreamedResponse` for PSR-7 code -> `PsrHttpFactory::createResponse($streamedResponse)`.
