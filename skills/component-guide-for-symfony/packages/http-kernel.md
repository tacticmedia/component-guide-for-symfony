# HttpKernel (`symfony/http-kernel`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when JSON, query or upload data must reach a controller as typed and validated arguments, or exceptions must become HTTP status codes. It turns each request into a response and runs hooks around the controller. It caches responses with HTTP headers, a PHP reverse proxy and ESI. To cache application data, see [Cache](cache.md).

**Details:** [../details/http-kernel.md](../details/http-kernel.md)

## Why it exists

A web application must convert each HTTP request into a response, also when the code throws an exception. Without a common request cycle, each controller parses its input, sets its own headers and catches its own errors. The package finds the controller, resolves its arguments, and converts exceptions and return values into a response. It dispatches an event at each step, so listeners can add features such as the HTTP cache and controller attributes.

## When to use it

- Map a JSON body, query parameters, headers or uploaded files to validated DTOs and typed controller arguments.
- Set the HTTP status code and the log level for an exception class.
- Run code before or after each controller, with an event listener or a PHP attribute on the controller.
- Add Cache-Control, ETag or Last-Modified headers to a controller response.
- Cache full pages or page fragments with a reverse proxy written in PHP and ESI.
- Send a sub-request to another controller, or embed its response in a page.
- Limit the number of requests that a client can send to a controller.
- Reject a request when its URL signature is missing, not valid or expired.
- Serialize the return value of a controller to JSON or to another request format.
- Send test requests through the application without a web server.

## Use it instead of

- `json_decode($request->getContent(), true)` plus manual checks -> `#[MapRequestPayload] CreateUserDto $dto` (the Serializer creates the DTO, and the Validator validates it).
- `(int) $request->query->get('page', 1)` -> `#[MapQueryParameter] int $page = 1`, or `#[MapQueryString] SearchQuery $query` for many parameters.
- `$request->headers->get('Accept-Language')` -> `#[MapRequestHeader] string $acceptLanguage`.
- `$request->files->get('avatar')` plus manual MIME type and size checks -> `#[MapUploadedFile(constraints: new Assert\File(maxSize: '2M', extensions: ['jpg', 'png']))] UploadedFile $avatar`.
- A `try`/`catch` block that returns `new Response('Not found', 404)` -> throw `NotFoundHttpException`, or put `#[WithHttpStatus(404)]` on the exception class.
- `$response->headers->set('Cache-Control', 'public, max-age=3600')` -> `#[Cache(public: true, maxage: 3600)]` on the controller.
- `new Response($serializer->serialize($data, 'json'), 201, ['Content-Type' => 'application/json'])` -> `#[Serialize(code: 201)]` on the controller method.
- `$limiter->create($request->getClientIp())->consume()` plus a manual 429 response -> `#[RateLimit('api')]`.
- `if (!$uriSigner->checkRequest($request)) { throw $this->createNotFoundException(); }` -> `#[IsSignatureValid]`.
- A `kernel.controller` listener that reads attributes with `ReflectionMethod::getAttributes()` -> a listener for `kernel.controller_arguments.App\Attribute\MyAttribute` that receives a `ControllerAttributeEvent`.
