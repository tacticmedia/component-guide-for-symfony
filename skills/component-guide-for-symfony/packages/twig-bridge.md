# Twig Bridge (`symfony/twig-bridge`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when Twig templates need route URLs, file URLs, translations, permission checks, CSRF tokens or forms with Bootstrap or Tailwind CSS styles. It also renders HTML and text emails from Twig templates, and checks template syntax in CI. In a full application, install [TwigBundle](twig-bundle.md), which sets up this package.

**Details:** [../details/twig-bridge.md](../details/twig-bridge.md)

## Why it exists

Twig templates cannot use the routing, security, form and translation parts of an application without an integration layer. Without it, each controller must pass URLs, tokens and translated text to the templates. The package adds Twig functions, filters, tests and tags for these parts, for file URLs and for other components. It also adds email templates, form themes, a controller attribute that renders a template, a Twig syntax validator and commands that check and list templates.

## When to use it

- Render an HTML form in Twig with a Bootstrap, Tailwind CSS, daisyUI or Foundation form theme.
- Send an email whose HTML and text parts come from Twig templates.
- Render a template from a controller action that returns an array, with a PHP attribute.
- Use route URLs, file URLs, CSRF tokens and permission checks in Twig templates.
- Translate text in Twig templates so that the message extraction command finds the messages.
- Validate Twig code that users submit before you store it.
- Check all Twig templates for syntax errors in a CI pipeline.
- Use [Form](form.md), [Translation](translation.md) or [Mailer](mailer.md) with Twig outside a full-stack Symfony application.

## Use it instead of

- `$email->html($twig->render('emails/signup.html.twig', $vars))` and `->text(strip_tags($html))` -> `new TemplatedEmail()` with `htmlTemplate()` and `context()`; Mailer renders the HTML part and the text part (`Symfony\Bridge\Twig\Mime\TemplatedEmail`).
- `new Response($twig->render('product/edit.html.twig', ['form' => $form->createView()]), $form->isSubmitted() && !$form->isValid() ? 422 : 200)` -> `#[Template('product/edit.html.twig')]` and `return ['form' => $form];` (`Symfony\Bridge\Twig\Attribute\Template`).
- Hand-written `<input name="user[email]" value="{{ user.email }}">` plus error markup for each field -> `{{ form_row(form.email) }}`, or `field_name()` and `field_value()` for custom HTML (`FormExtension`).
- Bootstrap or Tailwind CSS classes that you copy into each form template -> `twig.form_themes: ['bootstrap_5_layout.html.twig']` or `{% form_theme form 'tailwind_2_layout.html.twig' %}`.
- `{% if 'ROLE_ADMIN' in app.user.roles %}` -> `{% if is_granted('ROLE_ADMIN') %}`, which asks the authorization checker and its voters (`SecurityExtension`).
- `bin2hex(random_bytes(32))` in `$_SESSION` and in a hidden field -> `{{ csrf_token('delete-item') }}` in the template and `$this->isCsrfTokenValid('delete-item', $token)` in the controller.
- `strip_tags()` or a regular expression on user HTML before `|raw` -> `{{ post.body|sanitize_html }}` (`HtmlSanitizerExtension`).
- `$translator->trans('cart.title')` in the controller for each template string -> `{{ 'cart.title'|trans }}`, `{% trans %}` or `t()`; `translation:extract` then finds the messages.
- `$twig->createTemplate($code)` in a `try`/`catch (SyntaxError $e)` block to check user template code -> the `#[Twig]` constraint on the property (`Symfony\Bridge\Twig\Validator\Constraints\Twig`).
- Hard-coded links such as `<a href="/blog/{{ post.slug }}">` -> `{{ path('blog_show', {slug: post.slug}) }}` or `url()` (`RoutingExtension`).
