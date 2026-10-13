# UX Toolkit (`symfony/ux-toolkit`)

**Applies to:** Symfony UX 3.5

**Elevator pitch:** Use when a web application needs ready-made UI components, such as dialogs, dropdowns or date pickers, in Shadcn UI, Flowbite or Bootstrap style. An experimental command copies their Twig templates and JavaScript into your project, and you then own the code. To build your own reusable components, see [UX Twig Component](ux-twig-component.md).

**Details:** [../details/ux-toolkit.md](../details/ux-toolkit.md)

## Why it exists

An application often needs UI components, such as buttons, dialogs and dropdowns, that follow one design system. The package gives ready-made component sets for Shadcn UI, Flowbite 4 and Bootstrap 5.3, plus unstyled ones. A command copies the Twig templates and the JavaScript of a component into the application. You then edit and commit these files.

## When to use it

- Add a dialog, a dropdown menu, tabs, a tooltip or another UI component in Shadcn UI, Flowbite or Bootstrap style.
- Add a date picker, a calendar, a combobox, a carousel, a slider or toast notifications without your own JavaScript.
- Start a page section, such as a login form, from a ready-made block.
- Add a logout link that sends a POST request with a CSRF token.
- Submit a link as a POST or DELETE form, with a CSRF token and a confirmation prompt.
- Copy text to the clipboard, remove a dismissible element or show a tooltip with small unstyled scripts.
- Show the steps of a multi-step form as a questionnaire.
- Share your own design system between applications as a kit in a GitHub repository.

## Use it instead of

- Bootstrap modal markup copied into each template (`<div class="modal fade" id="confirm" tabindex="-1"><div class="modal-dialog">...`) -> `php bin/console ux:install modal --kit=bootstrap`, then `<twig:Modal id="confirm">` with `<twig:Modal:Header>`, `<twig:Modal:Body>` and `<twig:Modal:Footer>`.
- A `<dialog>` element with `onclick="document.getElementById('confirm').showModal()"` and your own close and focus code -> `ux:install dialog --kit=shadcn`, then `<twig:Dialog id="...">`, `<twig:Dialog:Trigger>` and `<twig:Dialog:Content>`.
- Tailwind classes chosen with Twig conditions, for example `class="{{ variant == 'outline' ? 'border bg-background' : 'bg-primary text-primary-foreground' }}"` -> the `shadcn` recipe `button`: `<twig:Button variant="outline" size="sm">`.
- `<a href="{{ path('app_logout') }}">Logout</a>` (a GET request without a CSRF token) -> `ux:install logout-link --kit=common`, then `<twig:LogoutLink>`.
- `<form method="post" action="..."><input type="hidden" name="_method" value="DELETE"><input type="hidden" name="_csrf_token" value="{{ csrf_token('delete-post') }}"><button>Delete</button></form>` -> `<twig:PostLink href="..." method="DELETE" csrfTokenId="delete-post" confirm="Are you sure?">` from the `post-link` recipe. A method other than POST needs `framework.http_method_override: true`.
- `onclick="navigator.clipboard.writeText(this.dataset.text)"` -> the `clipboard` recipe: `data-controller="clipboard"`, a `data-clipboard-target="source"` element and `data-action="clipboard#copy"`.
- A calendar popup that you write in JavaScript for a date field -> `ux:install date-picker --kit=shadcn`, then `<twig:DatePicker>` with `<twig:Calendar mode="single" name="date">`, which submits a `Y-m-d` value.
- A toast `<div>` that your JavaScript adds to `document.body` and removes with `setTimeout()` -> the `sonner` recipe: `<twig:Sonner>` with `<twig:Toast type="success" title="...">`, or a button with `data-action="click->sonner#fire"`.
