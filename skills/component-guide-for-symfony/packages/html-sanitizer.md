# HtmlSanitizer (`symfony/html-sanitizer`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when an application must show HTML that users write, for example rich text from a WYSIWYG editor, without XSS. It builds new HTML from the allowed elements, attributes and URLs only, and removes scripts, event attributes and unsafe URLs. For plain text, the template engine already escapes the output.

**Details:** [../details/html-sanitizer.md](../details/html-sanitizer.md)

## Why it exists

Templates escape output by default, so HTML that users write shows as text. Output without escaping sends any script in that HTML to the browser. The package builds new HTML that contains only the elements, attributes and URLs that you allow. The output also has a predictable format that your CSS can style.

## When to use it

- Show the HTML from a WYSIWYG editor field, for example a blog post or a comment, without an XSS risk.
- Sanitize the HTML that a form field receives, before the form maps it to your object.
- Print stored user HTML in a template safely, where you would otherwise turn off the escaping.
- Remove link and image URLs that point to hosts outside a trusted list.
- Add a rel attribute with noopener and noreferrer to every link in user content.
- Allow only a fixed set of tags, for example paragraphs, links and bold text.
- Use different sanitizer rules for different content, for example comments and articles.
- Sanitize HTML for use inside a head, title or textarea element.
- Sanitize HTML in a plain PHP script or a library, without the framework.

## Use it instead of

- `strip_tags($html, '<p><a><strong>')` -> `HtmlSanitizerInterface::sanitize()` with the elements and attributes that you allow in `HtmlSanitizerConfig` or in `allow_elements`
- `preg_replace('#<script.*?</script>#is', '', $html)` or a similar regular expression -> `HtmlSanitizerInterface::sanitize()`, which drops each element that no rule allows
- `{{ comment.body|raw }}` for HTML that users wrote -> `{{ comment.body|sanitize_html }}`
- A `FormEvents::PRE_SUBMIT` listener or a data transformer that cleans an HTML field -> the `sanitize_html` form option, and `sanitizer` for a named sanitizer
- `DOMDocument::loadHTML()` and a loop that removes `on*` attributes and `javascript:` URLs -> `HtmlSanitizer`, which builds new HTML from the allowed parts only
- `parse_url($url, PHP_URL_HOST)` and a comparison with a list of trusted hosts -> `allowLinkHosts()` and `allowMediaHosts()` (`allowed_link_hosts`, `allowed_media_hosts`)
- `str_replace('http://', 'https://', $html)` -> `forceHttpsUrls()` (`force_https_urls: true`)
- A regular expression that adds `rel="noopener noreferrer"` to `<a>` tags -> `forceAttribute('a', 'rel', 'noopener noreferrer')` (`force_attributes`)
