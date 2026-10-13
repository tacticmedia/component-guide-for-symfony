# UX Toolkit (`symfony/ux-toolkit`): details

**Applies to:** Symfony UX 3.5

## Key features and concepts

- **A copy, not a runtime library:** `ux:install` copies the files of a recipe into the application. The application does not use the package at runtime. The installed files do not change when the package changes, and there is no upgrade path. Entry point: `php bin/console ux:install <recipe>`.
- **Recipes and kits:** A recipe is a pack of Twig components, Stimulus controllers and package dependencies. Its name is its directory name, for example `alert-dialog` or `date-picker`. A kit is a set of recipes with one design system. A recipe of type `block` is a page section; the other recipes have the type `component`. Entry point: `--kit=<kit>`.
- **The four official kits:** `shadcn` has 58 components and 2 login blocks and needs Tailwind CSS. `flowbite-4` has 22 components and needs Tailwind CSS and the Flowbite JavaScript. `bootstrap` has 25 components for the Bootstrap 5.3 CSS and JavaScript, with no Stimulus controllers. `common` has 5 unstyled recipes. Before the first recipe, do the steps in the `INSTALL.md` file of the kit. The command does not edit `assets/app.js` or `assets/styles/app.css`. For Bootstrap tooltips, popovers and hidden toasts, call `getOrCreateInstance()` in your own JavaScript. Entry point: `vendor/symfony/ux-toolkit/kits/<kit>/INSTALL.md`.
- **Kit selection:** Without `--kit`, the command searches the four official kits. If more than one kit has the recipe, the command asks which kit to use. Without arguments, it asks for the kit and then for the recipe. It matches recipe names case-insensitively and suggests close names. In a non-interactive run, always pass `--kit`. Without it, a recipe that is in more than one kit comes from `shadcn`, or the command fails. Entry point: `--kit` (`-k`).
- **Dependencies:** The command copies the recipes that a recipe needs in the same run, for example `dialog` also writes `button`. It does not install packages. Under "Next steps", it prints `composer require ...`, `npm install --save ...` and `php bin/console importmap:require ...` for the recipe and the kit. Run these commands yourself. Entry point: the output of `ux:install`.
- **Existing files:** If a file exists, the command asks before it overwrites the file. With `--no-interaction`, the answer is "no" and the command keeps the file. With `--force`, it overwrites the file without a question. If you answer "yes" without `--force`, the command keeps a file that is not older than the kit file, but lists it as installed. To update a recipe, commit your files first. Then run the command again with `--force`. Read the diff to keep your own changes. Entry point: `--force` (`-f`).
- **Destination:** The command writes relative to the current working directory. Run it from the project root, or give the project directory to `--destination`. Entry point: `--destination` (`-d`).
- **Twig components:** The templates go to `templates/components/` and become anonymous Twig components. This needs `twig_component.anonymous_template_directory: 'components/'`, as in the documented TwigComponent configuration. A subdirectory adds a `:` to the name: `templates/components/Dialog/Content.html.twig` is `<twig:Dialog:Content>`. A template declares its props with `{% props %}`; most templates merge your other HTML attributes through `attributes`. Entry point: `<twig:Name>`.
- **Trigger attributes:** A trigger component, for example `<twig:Dialog:Trigger>`, gives an attribute set for your own element. On a `<twig:...>` tag, spread it: `<twig:Button {{ ...dialog_trigger_attrs }}>`. On a plain HTML element, render it with `html_attr()`: `<button {{ html_attr(popover_trigger_attrs) }}>`. Entry point: `dialog_trigger_attrs`, `popover_trigger_attrs`, `tooltip_trigger_attrs`.
- **Stimulus controllers:** Some recipes of the `shadcn`, `flowbite-4` and `common` kits copy controllers to `assets/controllers/`, for example `dialog_controller.js`. StimulusBundle loads the controllers in this directory. Entry point: `data-controller="dialog"`, `data-action="clipboard#copy"`.
- **Template helpers:** The templates use `html_cva()`, `html_classes()` and `html_attr()` from `twig/html-extra`, `|tailwind_classes` from `tales-from-a-dev/twig-tailwind-extra` and `<twig:ux:icon>` from UX Icons. The printed `composer require` command adds these packages. Entry point: `html_cva()` in the `shadcn` and `flowbite-4` templates, for example `Button.html.twig`.
- **Runtime packages:** The toolkit is a dev dependency, but the copied templates need `symfony/ux-twig-component` in production. Most `bootstrap` and `common` recipe manifests do not list it. Add it to `require` yourself. Entry point: `composer require symfony/ux-twig-component`.
- **Recipe docs:** Each recipe has a `README.md` with usage, examples and accessibility notes. In a `{% props %}` tag, a `##` comment above each prop describes the prop. Live previews are on ux.symfony.com. Entry point: `vendor/symfony/ux-toolkit/kits/<kit>/<recipe>/README.md`.
- **Custom kits on GitHub:** `--kit=github.com/<user>/<repo>[:<branch>]` downloads a kit archive; the default branch is `main`. Put the kit `manifest.json` at the root of the repository. This feature needs `symfony/http-client` and the PHP `zip` extension. To check a kit, run `vendor/bin/ux-toolkit-kit-lint`. If you start a kit with `ux:toolkit:create-kit`, add `"type": "component"` to the generated recipe manifest. The recipe parser requires this key. Entry point: `--kit=github.com/<user>/<repo>`.
- **Questionnaire and form flow:** The `shadcn` recipe `questionnaire` with `:interactive="false"` renders the current step of a Symfony form flow and does not start its Stimulus controller. Its example uses the `form_flow_*()` Twig functions, which need Symfony 8.1. Entry point: `<twig:Questionnaire :interactive="false">`.

## Entry points

- Installation: `composer require --dev symfony/ux-toolkit`. Symfony Flex registers `Symfony\UX\Toolkit\UXToolkitBundle` for the `dev` and `test` environments with an auto-generated recipe. The bundle has no configuration.
- Console command: `php bin/console ux:install [<recipe>] [--kit|-k <kit>] [--destination|-d <dir>] [--force|-f]`.
- Kit names for `--kit`: `shadcn`, `flowbite-4`, `bootstrap`, `common`, or `github.com/<user>/<repo>[:<branch>]` (also with `https://`).
- Installed files: `templates/components/**/*.html.twig` (Twig components) and `assets/controllers/*_controller.js` (Stimulus controllers).
- Twig: the installed components, for example `<twig:Button>`, `<twig:Dialog id="...">`, `<twig:Modal id="...">`, `<twig:LogoutLink>` and `<twig:PostLink href="...">`.
- Docs on disk: `vendor/symfony/ux-toolkit/kits/<kit>/INSTALL.md` and `vendor/symfony/ux-toolkit/kits/<kit>/<recipe>/README.md`.
- Kit authoring: `vendor/bin/ux-toolkit-kit-lint [<kit-path>] [--fail-on-warning]` runs the command `ux:toolkit:lint-kit`, which the bundle does not register. The scripts `vendor/bin/ux-toolkit-kit-create` and `vendor/bin/ux-toolkit-kit-debug` run the hidden commands `ux:toolkit:create-kit` and `ux:toolkit:debug-kit [<kit-path>]`. The JSON schemas for the `manifest.json` files are `schema-kit-v1.json` and `schema-kit-recipe-v1.json`.

## Symbiotic packages

- [UX Twig Component](../packages/ux-twig-component.md): Each copied template is an anonymous component that you render with `<twig:Name>`; to write a new component, use UX Twig Component alone.
- [StimulusBundle](../packages/stimulus-bundle.md): StimulusBundle loads the controllers that the `shadcn`, `flowbite-4` and `common` recipes copy to `assets/controllers/`; the recipe manifests do not list it.
- [UX Icons](../packages/ux-icons.md): The `shadcn` and `flowbite-4` templates render `lucide:` and `flowbite:` icons with `<twig:ux:icon>`, and these recipes list `symfony/ux-icons`.
- [AssetMapper](../packages/asset-mapper.md): For front-end packages, such as `flowbite`, `bootstrap` or `embla-carousel`, the command prints a `php bin/console importmap:require` command.
- [WebpackEncoreBundle](../packages/webpack-encore-bundle.md): If you build the assets with Encore, run the printed `npm install --save` command instead of `importmap:require`.
- [Security](../packages/security-bundle.md): The `common` recipe `logout-link` sends a POST request to `logout_path()` with a `logout` CSRF token; its README requires a POST-only logout route and `enable_csrf: true`.
- [Security CSRF](../packages/security-csrf.md): The `common` recipe `post-link` adds a hidden `_csrf_token` field with `csrf_token()` and `data-controller="csrf-protection"` when you set `csrfTokenId`.
- [HttpClient](../packages/http-client.md): The command downloads a kit from GitHub with HttpClient; without the package, `--kit=github.com/...` throws a `LogicException`.
- [Form](../packages/form.md): The `questionnaire` recipe with `:interactive="false"` renders the current step of a form flow (`AbstractFlowType`), with the `form_flow_*()` Twig functions of Symfony 8.1.
- [Twig Bridge](../packages/twig-bridge.md): To style Symfony forms, use a form theme such as `bootstrap_5_layout.html.twig`; the `shadcn` recipe `form` gives only layout wrappers.
- [UX Autocomplete](../packages/ux-autocomplete.md): For a form field that loads choices through Ajax, use UX Autocomplete; the `combobox` recipe filters a fixed `choices` list in the browser.
- [Symfony UX Pagination](../packages/ux-pagination.md): The `pagination` recipes render link markup with no page logic; UX Pagination paginates the data, builds the page URLs and accepts your theme template.
- [Symfony Flex](../packages/flex.md): A Flex recipe configures a Composer package at install time; a UX Toolkit recipe is a set of UI files that `ux:install` copies.
- [Symfony UX Calendar Link](../packages/ux-calendar-link.md): the shadcn `Calendar` and `Date Picker` recipes select dates; for "Add to calendar" links, use UX Calendar Link.

## Changed in 3.0 to 3.5

- 3.0: The package needs PHP 8.4 or later and Symfony 7.4 or later.
- 3.4: New kits: `bootstrap` (Bootstrap 5.3) and `common` (`clipboard`, `closeable`, `logout-link`, `post-link`, `tooltip`).
- 3.5: New recipe type `block`: `ux:install login-01 --kit=shadcn` or `login-02` installs a `LoginForm` page section. Both write `templates/components/LoginForm.html.twig`, so install only one. The form has no `method`, `action`, field names or CSRF token; add them yourself.
- 3.5: New `shadcn` recipes, for example `calendar`, `date-picker`, `dropdown-menu`, `form`, `questionnaire`, `sheet`, `sidebar` and `slider`.
- 3.5: The Flowbite v4 Stimulus controller `modal` is now `flowbite-modal`, for example `click->flowbite-modal#open`.
- 3.5: `|tailwind_merge` -> `attributes.defaults({class: '...'|tailwind_classes})`. Your classes now override the component variants.
- 3.5: `{# @prop #}` and `{# @block #}` -> a `## <type> <description>` comment above each prop in `{% props %}` and a `{##- <description> -#}` comment above each block (Twig 3.29).
- 3.5: The `shadcn` recipe `typography` is removed.

## Status

Experimental. The docs and the README say that the package "is likely to change, or even change drastically". The installed recipes have no backward-compatibility guarantee, and a new install can give a different version. Kits from GitHub need the PHP `zip` extension.

## Docs

- https://symfony.com/bundles/ux-toolkit/current/index.html
- https://ux.symfony.com/toolkit
- https://ux.symfony.com/toolkit/kits/shadcn
- https://ux.symfony.com/toolkit/kits/flowbite-4 (the Flowbite link on the docs page fails; use this page)
- https://ux.symfony.com/toolkit/kits/bootstrap
- https://ux.symfony.com/toolkit/kits/common
- https://symfony.com/doc/current/form/form_flow.html (for the `questionnaire` recipe)
