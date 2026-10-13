# Twig Bridge (`symfony/twig-bridge`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **`app` global variable**: The variable gives every template the current user, token, request, session, flash messages, environment, debug flag, locale, enabled locales, route name and route parameters. `app.flashes()` reads and removes flash messages. Entry: `Symfony\Bridge\Twig\AppVariable` (`app.user`, `app.flashes('notice')`, `app.current_route`).
- **URL functions**: `path()` returns the URL of a route without the scheme and host, and `url()` returns the absolute URL. `absolute_url()` and `relative_path()` convert a path that you already have. Entry: `path()`, `url()`, `absolute_url()`, `relative_path()`.
- **Security functions**: `is_granted()` checks a role or a voter attribute for the current user, and `is_granted_for_user()` checks another user. `access_decision()` and `access_decision_for_user()` return an `AccessDecision` object with the result (`isGranted`) and the voter message (`message`). Other functions create impersonation links and logout links. Entry: `is_granted()`, `access_decision()`, `impersonation_path()`, `impersonation_exit_path()`, `logout_path()`.
- **CSRF tokens for plain HTML forms**: `csrf_token('delete-item')` returns a token value from the CSRF token manager. The controller checks the submitted value with the same token ID. Entry: `csrf_token()`.
- **Form functions**: `form()`, `form_start()`, `form_row()`, `form_label()`, `form_widget()`, `form_help()`, `form_errors()`, `form_rest()` and `form_end()` render a form or parts of a field with the active form theme. Entry: `Symfony\Bridge\Twig\Extension\FormExtension` (also `form_parent()` and the tests `selectedchoice` and `rootform`).
- **Form themes**: The bridge contains `form_div_layout.html.twig` (default), `form_table_layout.html.twig`, `bootstrap_3_layout.html.twig`, `bootstrap_3_horizontal_layout.html.twig`, `bootstrap_4_layout.html.twig`, `bootstrap_4_horizontal_layout.html.twig`, `bootstrap_5_layout.html.twig`, `bootstrap_5_horizontal_layout.html.twig`, `foundation_5_layout.html.twig`, `foundation_6_layout.html.twig`, `tailwind_2_layout.html.twig` and `daisyui_5_layout.html.twig`. A later theme overrides the blocks of an earlier theme. Entry: `twig.form_themes` (all forms) or `{% form_theme form 'bootstrap_5_layout.html.twig' %}` (one template).
- **Field helpers**: `field_name()`, `field_id()`, `field_value()`, `field_label()`, `field_help()`, `field_errors()` and `field_choices()` return raw values. Use them to write custom HTML without a form theme. Entry: the `field_*()` functions.
- **Multi-step form state**: The `form_flow_*()` functions return the current step, the step names, the step index, the number of steps and the navigation state of a form flow. If the form is not part of a flow, they return `null` or `false`. Entry: `form_flow_current_step()`, `form_flow_steps()`, `form_flow_total_steps()`, `form_flow_can_move_next()`.
- **`#[Template]` attribute**: The action returns an array, and a view listener renders the template or one `block` into the response. Form objects become views, and an invalid submitted form sets the status code 422. Entry: `Symfony\Bridge\Twig\Attribute\Template` (`stream: true` returns a `StreamedResponse`).
- **Templated emails**: `TemplatedEmail` holds the Twig template names, the context and the locale. Mailer renders the templates when it sends the message. If the email has no text part, the renderer creates it from the HTML. In the template, `email.image()` embeds an image and `email.attach()` attaches a file. Do not use `email` as a context key. If Messenger sends the email later, the context must be serializable, or you render the email first with `BodyRendererInterface`. Entry: `Symfony\Bridge\Twig\Mime\TemplatedEmail` (`htmlTemplate()`, `textTemplate()`, `context()`, `locale()`).
- **Notification emails**: `NotificationEmail` is a styled `TemplatedEmail` with an importance level, an action button, Markdown or raw content and an exception attachment. It needs `twig/inky-extra` and `twig/cssinliner-extra`, and `markdown()` also needs `twig/markdown-extra`. Entry: `Symfony\Bridge\Twig\Mime\NotificationEmail` (`importance()`, `action()`, `markdown()`, `content()`, `exception()`).
- **Translation in templates**: The `trans` filter and the `{% trans %}` tag translate text, and `{% trans_default_domain %}` sets the default domain of the current template. `t()` creates a `TranslatableMessage` for the `trans` filter. `TwigExtractor` lets `translation:extract` find these messages. Twig does not escape the output of the `trans` tag. Entry: `Symfony\Bridge\Twig\Extension\TranslationExtension`, `Symfony\Bridge\Twig\Translation\TwigExtractor`.
- **Other component integrations**: The functions `asset()`, `importmap()`, `render()`, `render_esi()`, `controller()`, `preload()`, `link()`, `workflow_can()`, `expression()` and `dump()` connect templates to other components. The filters are `sanitize_html`, `serialize`, `emojify`, `yaml_encode` and `yaml_dump`, and the tags are `{% dump %}` and `{% stopwatch %}`. If the package of a function is missing, the Twig error shows the `composer require` command. Entry: the `Symfony\Bridge\Twig\Extension\*Extension` classes.
- **Template checks**: The `Twig` constraint checks that a string contains valid Twig syntax. `lint:twig` checks template files and writes the result in the `txt`, `json` or `github` format. `debug:twig` lists the functions, filters, tests, globals and loader paths. Entry: `Symfony\Bridge\Twig\Validator\Constraints\Twig`, `lint:twig`, `debug:twig`.
- **Twig error pages**: If debug is off, `TwigErrorRenderer` renders `@Twig/Exception/error<status code>.html.twig` or `@Twig/Exception/error.html.twig`. The template gets `exception`, `status_code` and `status_text`. To override them, put `error404.html.twig` or `error.html.twig` in `templates/bundles/TwigBundle/Exception/`. Entry: `Symfony\Bridge\Twig\ErrorRenderer\TwigErrorRenderer`.

## Entry points

- `Symfony\Bridge\Twig\Attribute\Template`: controller attribute, `#[Template('product/index.html.twig', vars: null, stream: false, block: null)]`.
- `Symfony\Bridge\Twig\Mime\TemplatedEmail`: email that Mailer renders from Twig templates.
- `Symfony\Bridge\Twig\Mime\NotificationEmail`: styled notification email (also used by the Notifier email channel).
- `Symfony\Component\Mime\BodyRendererInterface`: autowire it to render a `TemplatedEmail` before `$mailer->send()`; TwigBundle aliases it to `Symfony\Bridge\Twig\Mime\BodyRenderer`.
- `Symfony\Bridge\Twig\Validator\Constraints\Twig`: validation constraint attribute (`message`, `skipDeprecations`).
- `Symfony\Bridge\Twig\AppVariable`: the `app` global variable in templates.
- `Symfony\Bridge\Twig\ErrorRenderer\TwigErrorRenderer`: error page renderer.
- Without FrameworkBundle: set up these classes without TwigBundle: `Symfony\Bridge\Twig\Extension\FormExtension`, `Symfony\Bridge\Twig\Form\TwigRendererEngine`, `Symfony\Bridge\Twig\Extension\TranslationExtension`, `Symfony\Bridge\Twig\Mime\BodyRenderer`.
- Config keys (defined by TwigBundle): `twig.form_themes`, `twig.mailer.html_to_text_converter`.
- Console commands: `lint:twig` (`--format=txt|json|github`, `--show-deprecations`, `--excludes`, `-` reads STDIN), `debug:twig` (`--filter`, `--format=txt|json`, optional template name).
- Twig functions for routing and URLs: `path()`, `url()`, `absolute_url()`, `relative_path()`.
- Twig functions for security: `is_granted()`, `is_granted_for_user()`, `access_decision()`, `access_decision_for_user()`, `impersonation_path()`, `impersonation_url()`, `impersonation_exit_path()`, `impersonation_exit_url()`, `logout_path()`, `logout_url()`, `csrf_token()`.
- Twig functions for forms: `form()`, `form_start()`, `form_end()`, `form_row()`, `form_label()`, `form_widget()`, `form_help()`, `form_errors()`, `form_rest()`, `form_parent()`, `field_name()`, `field_id()`, `field_value()`, `field_label()`, `field_help()`, `field_errors()`, `field_choices()`.
- Twig functions for form flows: `form_flow_current_step()`, `form_flow_steps()`, `form_flow_step_index()`, `form_flow_total_steps()`, `form_flow_first_step()`, `form_flow_last_step()`, `form_flow_next_step()`, `form_flow_previous_step()`, `form_flow_is_first_step()`, `form_flow_is_last_step()`, `form_flow_can_move_back()`, `form_flow_can_move_next()`.
- Other Twig functions: `asset()`, `asset_version()`, `importmap()`, `render()`, `render_*()` (for example `render_esi()`, `render_ssi()`), `controller()`, `fragment_uri()`, `t()`, `link()`, `preload()`, `dns_prefetch()`, `preconnect()`, `prefetch()`, `prerender()` (deprecated web hint), `workflow_can()`, `workflow_transitions()`, `workflow_transition()`, `workflow_has_marked_place()`, `workflow_marked_places()`, `workflow_metadata()`, `workflow_transition_blockers()`, `expression()`, `dump()`.
- Twig filters: `trans`, `sanitize_html`, `serialize`, `emojify`, `yaml_encode`, `yaml_dump`, `humanize`, `form_encode_currency`.
- Twig tests: `selectedchoice`, `rootform`.
- Twig tags: `form_theme`, `trans` / `endtrans`, `trans_default_domain`, `dump`, `stopwatch` / `endstopwatch`.
- Email template variable: `email` (`email.image()`, `email.attach()`, `email.toName`).
- Test helper: `Symfony\Bridge\Twig\Test\FormLayoutTestCase` (implement `getTemplatePaths()`, `getTwigExtensions()` and `getThemes()`).
- Not in this package: the attributes `Twig\Attribute\AsTwigFilter`, `Twig\Attribute\AsTwigFunction` and `Twig\Attribute\AsTwigTest` come from `twig/twig` 3.21 or later. TwigBundle autoconfigures a service class whose methods have them. Do not use them in a class that extends `AbstractExtension` or implements `ExtensionInterface`.

## Symbiotic packages

- [TwigBundle](../packages/twig-bundle.md): TwigBundle requires this bridge, registers its extensions, the `app` global and the commands, and defines the `twig.*` configuration.
- [Form](../packages/form.md): `FormExtension` and `TwigRendererEngine` render `FormView` objects with form themes, and the `form_flow_*()` functions read the `FormFlowCursor` of a multi-step form.
- [Mailer](../packages/mailer.md): Mailer renders a `TemplatedEmail` when it sends it, through the `MessageListener` and the `BodyRenderer` that TwigBundle registers.
- [Mime](../packages/mime.md): `TemplatedEmail` extends `Symfony\Component\Mime\Email`, and `BodyRenderer` implements `Symfony\Component\Mime\BodyRendererInterface`.
- [Notifier](../packages/notifier.md): The Notifier email channel sends `NotificationEmail` messages, which need `twig/inky-extra` and `twig/cssinliner-extra`.
- [Translation](../packages/translation.md): The `trans` filter and the `trans` tags use the translator, `t()` creates a `TranslatableMessage`, and `TwigExtractor` gives the template messages to `translation:extract`.
- [Security](../packages/security-bundle.md): SecurityBundle registers `SecurityExtension` and `LogoutUrlExtension` (`is_granted()`, `access_decision()`, `impersonation_path()`, `logout_path()`), and `app.user` reads its token storage.
- [Security CSRF](../packages/security-csrf.md): `csrf_token()` gets a token value from the CSRF token manager for plain HTML forms.
- [Routing](../packages/routing.md): `path()` and `url()` call the URL generator, and `app.current_route` returns the route name of the request.
- [HttpKernel](../packages/http-kernel.md): `render()`, `render_esi()`, `render_ssi()` and `controller()` embed controller responses as fragments, and `#[Template]` acts on the view event.
- [HttpFoundation](../packages/http-foundation.md): `absolute_url()` and `relative_path()` use `UrlHelper`, and `app.request`, `app.session` and `app.flashes()` read the request stack.
- [Asset](../packages/asset.md): `asset()` and `asset_version()` return the public URL and the version of a file from the asset packages.
- [AssetMapper](../packages/asset-mapper.md): `importmap()` renders the import map, the module shim and the preload links for the JavaScript entrypoints.
- [WebLink](../packages/web-link.md): `preload()`, `link()`, `dns_prefetch()`, `preconnect()` and `prefetch()` add `Link` HTTP headers to the response.
- [Workflow](../packages/workflow.md): The `workflow_*()` functions show the enabled transitions, marked places, transition blockers and metadata of an object in a template.
- [HtmlSanitizer](../packages/html-sanitizer.md): The `sanitize_html` filter cleans untrusted HTML with the default sanitizer or a named sanitizer before output.
- [Serializer](../packages/serializer.md): The `serialize` filter encodes data (JSON by default), for example for `data-*` attributes.
- [Emoji](../packages/emoji.md): The `emojify` filter changes text codes such as `:kiwi:` into emoji characters and needs `symfony/emoji`.
- [Yaml](../packages/yaml.md): The `yaml_encode` and `yaml_dump` filters dump values as YAML with the Yaml component.
- [ExpressionLanguage](../packages/expression-language.md): The `expression()` function creates an `Expression` object in a template.
- [DebugBundle](../packages/debug-bundle.md): DebugBundle registers `DumpExtension`, so `{% dump %}` sends dumps to the debug toolbar and `{{ dump() }}` dumps inline; the Flex recipe enables DebugBundle only in `dev`.
- [VarDumper](../packages/var-dumper.md): The `dump()` function and the `dump` tag use VarDumper and work only in `dev`; in `test`, debug mode has only the Twig core `dump()`, and in `prod`, `dump()` and `{% dump %}` cause an error.
- [Stopwatch](../packages/stopwatch.md): The `{% stopwatch 'name' %}` tag measures a template section as a Stopwatch event that the profiler shows.
- [WebProfilerBundle](../packages/web-profiler-bundle.md): WebProfilerBundle defines the `file_excerpt`, `abbr_class`, `format_file` and other code filters from the Twig reference; this bridge does not define them.
- [Validator](../packages/validator.md): The `Twig` constraint and `TwigValidator` check that a string contains valid Twig syntax.
- [ErrorHandler](../packages/error-handler.md): `TwigErrorRenderer` implements `ErrorRendererInterface` and uses `HtmlErrorRenderer` in debug mode or when no error template exists.
- [UX Twig Component](../packages/ux-twig-component.md): Use Twig components, not `render(controller())`, for reusable template parts such as alerts or sidebars.
- [UX Live Component](../packages/ux-live-component.md): Use live components, not `render_hinclude()` with hinclude.js, for content that updates through Ajax.

## Changed in 8.0/8.1

- 8.1: The new `form_flow_*()` functions read the state of a multi-step form flow. Use them for progress bars and step lists.
- 8.1: The new `daisyui_5_layout.html.twig` form theme renders forms with daisyUI 5 classes.
- 8.0: `debug:twig` does not accept `--format=text`. Use `--format=txt`.
- 8.0: The `FormThemeNode` constructor does not accept a tag argument. Use `new FormThemeNode($form, $resources, $lineno, $only)`.

## Docs

- https://symfony.com/doc/current/templates.html
- https://symfony.com/doc/current/reference/twig_reference.html
- https://symfony.com/doc/current/form/form_themes.html
- https://symfony.com/doc/current/form/form_customization.html
- https://symfony.com/doc/current/form/form_flow.html
- https://symfony.com/doc/current/form/bootstrap5.html
- https://symfony.com/doc/current/form/tailwindcss.html
- https://symfony.com/doc/current/form/unit_testing.html
- https://symfony.com/doc/current/forms.html
- https://symfony.com/doc/current/mailer.html
- https://symfony.com/doc/current/notifier.html
- https://symfony.com/doc/current/reference/attributes.html
- https://symfony.com/doc/current/reference/constraints/Twig.html
- https://symfony.com/doc/current/controller/error_pages.html
- https://symfony.com/doc/current/reference/configuration/twig.html
- https://twig.symfony.com/doc/3.x/advanced.html
