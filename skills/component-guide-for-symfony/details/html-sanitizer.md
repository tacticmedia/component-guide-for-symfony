# HtmlSanitizer (`symfony/html-sanitizer`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- Body context: `sanitize()` parses the input and builds new HTML from the allowed parts only. It always removes HTML comments. If the input is not valid UTF-8, it returns an empty string. `HtmlSanitizerInterface::sanitize()`
- Other contexts: `sanitizeFor('head', $html)` keeps only the allowed elements that are valid in `<head>`. For `title` and `textarea`, it escapes the input, so no element stays. For other element names, it applies the body rules. `HtmlSanitizerInterface::sanitizeFor()`
- Immutable configuration: each `allow*()`, `block*()`, `drop*()`, `force*()`, `with*()` and `defaultAction()` method of `HtmlSanitizerConfig` returns a new object. Chain the calls or assign the result. A call such as `$config->allowElement('p');` alone changes nothing. `HtmlSanitizerConfig`
- Baselines: `allowSafeElements()` keeps the elements and attributes that the W3C reference list marks as safe. It does not allow `<style>`, `<form>`, `<input>`, `<select>`, `<textarea>` or the `style`, `class` and `hidden` attributes. `allowStaticElements()` also allows `<form>`, `<input>`, `style` and `class`, so CSS injection stays possible. No baseline allows `<script>`, `<iframe>`, `<object>` or `on*` event attributes. `allowSafeElements()`, `allowStaticElements()`
- Element rules: `allowElement($element, $attributes)` keeps the element with the listed attributes only. Without a list, the element keeps no attributes. With `'*'`, it keeps all 210 attributes of the W3C list, also `style` and `class`. A second call for the same element replaces its list. `blockElement()` removes the tag but keeps its children. `dropElement()` removes the tag and its children. `allowElement()`, `blockElement()`, `dropElement()`
- Default action: the sanitizer drops each element that no rule names, together with its children. `HtmlSanitizerAction::Block` keeps the children of these elements. `HtmlSanitizerAction::Allow` keeps the elements, but without attributes. `Allow` also keeps `<script>` elements. If you use `Allow`, drop the dangerous elements with `dropElement()` or `drop_elements`. `HtmlSanitizerConfig::defaultAction()`, `default_action`
- Attribute rules: `allowAttribute($attribute, $elements)` adds the attribute only to elements that are already allowed. It also removes the attribute from the allowed elements that are not in the list. Pass `'*'` to add the attribute to all allowed elements. `dropAttribute($attribute, $elements)` removes the attribute from the listed elements. `allowAttribute()`, `dropAttribute()`
- Forced attributes: `forceAttribute('a', 'rel', 'noopener noreferrer')` sets this value on each `<a>` element that the sanitizer keeps. The forced value replaces the value from the input. The sanitizer does not check forced values, so use only trusted values. `forceAttribute()`
- Link URLs: the URL attributes of `<a>` and `<area>`, the `action`, `formaction` and `cite` attributes, and `<meta http-equiv="refresh">` URLs use the link rules. The default schemes are `http`, `https`, `mailto` and `tel`. The sanitizer removes an attribute with a relative URL, unless you allow relative URLs. An allowed host also allows its subdomains. `allowLinkSchemes()`, `allowLinkHosts()`, `allowRelativeLinks()`
- Media URLs: all other URL attributes use the media rules: `src`, `href`, `lowsrc`, `background`, `ping`, `poster`, `data`, `codebase`, `archive` and `longdesc`. The default schemes are `http`, `https` and `data`. `forceHttpsUrls()` changes `http` URLs to `https` in links and media. `allowMediaSchemes()`, `allowMediaHosts()`, `allowRelativeMedias()`, `forceHttpsUrls()`
- Input length limit: to prevent DoS attacks, the sanitizer cuts the input after 20,000 bytes in all contexts. `withMaxInputLength(-1)` and `max_input_length: -1` remove the limit. In the framework config, the default `max_input_length: 0` keeps the 20,000-byte limit. `withMaxInputLength()`, `max_input_length`
- Custom attribute sanitizers: a class that implements `AttributeSanitizerInterface` changes the values of the attributes that it supports. It runs only on attributes that the rules allow. If it returns `null`, the sanitizer removes the attribute. `AttributeSanitizerInterface`, `withAttributeSanitizer()`, `with_attribute_sanitizers`
- Named sanitizers: each key under `framework.html_sanitizer.sanitizers` creates the service `html_sanitizer.sanitizer.<name>`. A named sanitizer starts from an empty `HtmlSanitizerConfig`, not from `allowSafeElements()`. To keep elements, add `allow_safe_elements: true` or `allow_elements`. Select it with `#[Target('<name>')]`, the Twig filter argument or the `sanitizer` form option. A sanitizer with the name `default` replaces the configuration of the `html_sanitizer` service. `framework.html_sanitizer.sanitizers`
- Twig filter: `{{ post.body|sanitize_html }}` uses the default sanitizer, and `sanitize_html('app.post_sanitizer')` uses a named sanitizer. Twig does not escape the result again. `sanitize_html`
- Form options: on `TextType` and its child types, `'sanitize_html' => true` sanitizes the submitted string in a `PRE_SUBMIT` listener. The `sanitizer` option selects a named sanitizer. The form uses `sanitize()`, so the body rules apply. `sanitize_html`, `sanitizer`

## Entry points

- `Symfony\Component\HtmlSanitizer\HtmlSanitizerInterface`: autowire it to get the default sanitizer, the `html_sanitizer` service. Its configuration is `allowSafeElements()` with the component defaults.
- `#[Symfony\Component\DependencyInjection\Attribute\Target('<name>')]` on a `HtmlSanitizerInterface` argument: inject the named sanitizer `html_sanitizer.sanitizer.<name>`.
- `framework.html_sanitizer`: the root config key. If `symfony/html-sanitizer` is installed, FrameworkBundle enables it by default.
- `framework.html_sanitizer.sanitizers.<name>`: the keys `default_action`, `allow_safe_elements`, `allow_static_elements`, `allow_elements`, `block_elements`, `drop_elements`, `allow_attributes`, `drop_attributes`, `force_attributes`, `force_https_urls`, `allowed_link_schemes`, `allowed_link_hosts`, `allow_relative_links`, `allowed_media_schemes`, `allowed_media_hosts`, `allow_relative_medias`, `with_attribute_sanitizers`, `without_attribute_sanitizers` and `max_input_length`. FrameworkBundle applies them in this order, not in the order of your file.
- Without FrameworkBundle: create a sanitizer with `Symfony\Component\HtmlSanitizer\HtmlSanitizer` and `Symfony\Component\HtmlSanitizer\HtmlSanitizerConfig`, for example `new HtmlSanitizer((new HtmlSanitizerConfig())->allowSafeElements())`.
- `Symfony\Component\HtmlSanitizer\HtmlSanitizerAction`: the `Drop`, `Block` and `Allow` cases for `HtmlSanitizerConfig::defaultAction()`.
- `Symfony\Component\HtmlSanitizer\Visitor\AttributeSanitizer\AttributeSanitizerInterface`: implement it for a custom attribute sanitizer. Put the service ID in `with_attribute_sanitizers`.
- The Twig filter `sanitize_html`: `{{ html|sanitize_html }}` or `{{ html|sanitize_html('<name>') }}`. TwigBundle registers it when the `html_sanitizer` service exists.
- The form options `sanitize_html` (boolean, default `false`) and `sanitizer` (a sanitizer name; `null` selects `default`) on `TextType` and its child types, for example `TextareaType`.
- The service IDs `html_sanitizer` (an alias of `html_sanitizer.sanitizer.default`), `html_sanitizer.sanitizer.<name>` and `html_sanitizer.config.<name>`.
- `php bin/console debug:autowiring HtmlSanitizerInterface`: list the sanitizers that you can autowire.

## Symbiotic packages

- [FrameworkBundle](../packages/framework-bundle.md): FrameworkBundle reads `framework.html_sanitizer` and registers the default sanitizer, the named sanitizers and their autowiring aliases.
- [Form](../packages/form.md): the `sanitize_html` and `sanitizer` options of `TextType` and its child types sanitize the submitted string. If `framework.html_sanitizer` is disabled, FrameworkBundle removes this form type extension.
- [Twig Bridge](../packages/twig-bridge.md): TwigBridge defines the `sanitize_html` filter in `HtmlSanitizerExtension`. The filter marks its output as safe HTML, so it replaces `|raw` for HTML from users.
- [TwigBundle](../packages/twig-bundle.md): TwigBundle registers the `sanitize_html` filter only when the `html_sanitizer` service exists.
- [DependencyInjection](../packages/dependency-injection.md): the `#[Target('<name>')]` attribute selects a named sanitizer. Since 8.1, Symfony deprecates a match on the argument name alone.
- [DomCrawler](../packages/dom-crawler.md): often confused with HtmlSanitizer. Use DomCrawler to read and navigate HTML. Use HtmlSanitizer to remove unsafe content before output.

## Changed in 8.0/8.1

- 8.1: `HtmlSanitizerConfig::defaultAction()` in PHP code only -> the `default_action` key (`drop`, `block` or `allow`) under `framework.html_sanitizer.sanitizers.<name>`.
- 8.1: a named sanitizer injected by the argument name only (`HtmlSanitizerInterface $appPostSanitizer`) -> `#[Target('app.post_sanitizer')] HtmlSanitizerInterface $sanitizer`.
- 8.0: `new HtmlSanitizer($config, new MastermindsParser())` -> `new HtmlSanitizer($config)`. The default `NativeParser` uses the HTML5 parser of PHP 8.4.
- 8.0: a custom `ParserInterface::parse(string $html)` -> add the argument `string $context = 'body'`. Since 7.4, the method can also return a `\Dom\Node`.
- 8.0 (also 6.4.28 and 7.3.6): `allowElement('iframe', '*')` no longer keeps `srcdoc` -> add `allowAttribute('srcdoc', 'iframe')` and `forceAttribute('iframe', 'sandbox', '')`.
- 8.0: fluent config builder calls such as `$framework->htmlSanitizer()->sanitizer('app.post_sanitizer')` -> YAML, or a PHP array in `App::config([...])`. The "Default Action" section of the docs shows the fluent form.
- 8.0.13, 8.1.0, 6.4.41 and 7.4.13: a custom attribute sanitizer for URLs in `action`, `poster`, `data`, `longdesc` or meta refresh -> the built-in URL check. It now covers these attributes.

## Status

Needs the PHP `dom` extension (`ext-dom`) and PHP 8.4.1 or later. The default parser, `NativeParser`, uses the `\Dom\HTMLDocument` class of PHP 8.4.

## Docs

- https://symfony.com/doc/current/html_sanitizer.html
- https://symfony.com/doc/current/reference/configuration/framework.html
- https://symfony.com/doc/current/reference/forms/types/text.html
- https://symfony.com/doc/current/reference/forms/types/textarea.html
- https://symfony.com/doc/current/reference/twig_reference.html
- https://symfony.com/doc/current/service_container/autowiring.html
- https://symfony.com/doc/current/templates.html
