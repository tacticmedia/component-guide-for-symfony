# HttpFoundation (`symfony/http-foundation`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when PHP code must read the incoming HTTP request, such as query, form and JSON data, uploads, the client IP, cookies and the session. It also builds JSON, redirect, file, streamed and Server-Sent Events responses and signed URLs. For outgoing HTTP requests, see [HttpClient](http-client.md).

**Details:** [../details/http-foundation.md](../details/http-foundation.md)

## Why it exists

PHP gives the request data in superglobal arrays, and it sends output with echo and with the header and cookie functions. Such code is hard to test, and each script must handle proxies, cookies and cache headers by hand. The package replaces them with request, response and session objects that apply the HTTP rules for proxies, cookies, cache headers and file downloads. Code can also create a request without the PHP globals, for example in a test.

## When to use it

- Read query parameters, form fields, a JSON body, headers, cookies or uploaded files from the current request.
- Return a JSON response, a redirect, a file download, a streamed response or a Server-Sent Events stream.
- Stream a large JSON list part by part, so that it uses less memory.
- Set the Cache-Control, ETag and Last-Modified headers so that browsers and proxies can cache a response.
- Keep user data or a one-time flash message in the session between two requests.
- Store the sessions in Redis, Valkey, Memcached, a PDO database or MongoDB instead of PHP files.
- Get the real client IP, host and scheme behind a load balancer or a reverse proxy.
- Anonymize an IP address before you log or store it.
- Create a signed URL that expires, for example a download link or an email confirmation link.
- Check if a request or an IP address matches a path, a host, a method or a private IP range.
- Make an absolute URL from a path, also in a command-line command that has no request.

## Use it instead of

- `$_GET['page'] ?? 1` or `(int) $_POST['qty']` -> `$request->query->getInt('page', 1)` and `$request->request->getInt('qty')`, which throw `BadRequestException` (HTTP 400) for invalid input
- `json_decode(file_get_contents('php://input'), true)` -> `$request->toArray()`, or `$request->getPayload()` for a form body or a JSON body
- `new Response(json_encode($data), 200, ['Content-Type' => 'application/json'])` -> `new JsonResponse($data)`, or `$this->json($data)` in a controller
- `readfile($path)` with manual `Content-Type` and `Content-Disposition` headers -> `new BinaryFileResponse($path)` with `setContentDisposition()`, or `$this->file($path, 'report.pdf')` in a controller
- `$_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR']` -> `$request->getClientIp()` with `framework.trusted_proxies` and `framework.trusted_headers`
- `ip2long()` with bit masks to test a CIDR range -> `IpUtils::checkIp($ip, ['10.0.0.0/8', '2001:db8::/32'])` or `IpUtils::isPrivateIp($ip)`
- `session_start()` and `$_SESSION['cart'] = $cart` -> `$requestStack->getSession()->set('cart', $cart)`
- `setcookie('theme', 'dark', ['httponly' => true])` -> `$response->headers->setCookie(Cookie::create('theme', 'dark'))`
- A `hash_hmac()` token and a manual expiry check in a URL -> `$uriSigner->sign($url, new \DateInterval('PT1H'))` and `$uriSigner->verify($request)`, or `#[IsSignatureValid]` (HttpKernel)
- An `echo "data: ...\n\n"; flush();` loop -> an `EventStreamResponse` with a callback that yields `ServerEvent` objects
