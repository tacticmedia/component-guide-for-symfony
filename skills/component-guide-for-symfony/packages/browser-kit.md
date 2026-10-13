# BrowserKit (`symfony/browser-kit`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when PHP code must act like a browser without JavaScript: keep cookies, follow redirects, click links and submit forms. It sends real HTTP requests, for example for a scraper, and is the base of the in-process test client. For full application tests, see [FrameworkBundle test tools](framework-bundle-testing.md). For JavaScript, see [Panther](panther.md).

**Details:** [../details/browser-kit.md](../details/browser-kit.md)

## Why it exists

A plain HTTP client sends single requests. Code must then copy cookies, follow redirects, find link URLs and collect form values by hand. The package adds this browser behavior, and it also keeps a history. It sends real HTTP requests, or it sends each request into the application in the same PHP process for a test.

## When to use it

- Scrape a website that requires a login form and a session cookie.
- Submit an HTML form and keep its default and hidden field values.
- Simulate a user who clicks links and submits forms in a functional test.
- Keep the cookies of a website between HTTP requests.
- Stop at each redirect and check the response before the next request.
- Send a JSON request or an AJAX request with the correct headers in a test.
- Move back and forward in the browser history of a test or a scraper.
- Build your own browser client for another way to send requests, or for other request and response objects.

## Use it instead of

- `curl_init()` with `CURLOPT_COOKIEJAR`, `CURLOPT_FOLLOWLOCATION` and `CURLOPT_POSTFIELDS` to log in to a website -> `$browser = new HttpBrowser(HttpClient::create())`, `$browser->request('GET', 'https://example.com/login')` and `$browser->submitForm('Log in', ['_username' => $user, '_password' => $password])`.
- HttpClient calls that read `$response->getHeaders()['set-cookie']` and send a `Cookie` header on the next request -> `HttpBrowser`, which stores and sends cookies with its `CookieJar`.
- `preg_match('/name="_token" value="([^"]+)"/', $html, $matches)` to copy a hidden CSRF field into a POST body -> `$browser->submitForm('Save', ['post[title]' => 'Hello'])`, which keeps the hidden fields of the form.
- `preg_match_all('/<a href="([^"]+)"/', $html, $matches)` and string concatenation for relative URLs -> `$browser->clickLink('Next page')`, or `$crawler->selectLink('Next page')->link()->getUri()` for the absolute URL.
- A `while` loop that reads the `Location` header and sends a new request -> automatic redirects with `$browser->setMaxRedirects(5)`, or `followRedirects(false)` and `followRedirect()` for one step.
- `json_encode($data)` with the `CONTENT_TYPE` and `HTTP_ACCEPT` server keys in a test request -> `$client->jsonRequest('POST', '/api/orders', ['sku' => 'A1'])`.
- `json_decode($browser->getResponse()->getContent(), true)` -> `$browser->getResponse()->toArray()` with `HttpBrowser`, or `getInternalResponse()->toArray()` with any browser.
- The Goutte scraper library (`fabpot/goutte`) -> `HttpBrowser`. Packagist marks Goutte as abandoned and names `symfony/browser-kit` as the replacement. Goutte 4.0.3, the last version, requires Symfony 4.4 to 6.
