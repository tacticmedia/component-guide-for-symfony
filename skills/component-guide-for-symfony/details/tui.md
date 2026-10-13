# Tui (`symfony/tui`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Application object.** `Tui` owns the terminal and a root container. `add()` puts a widget on the screen, and `run()` blocks until `stop()`. The Tui hides the cursor and enables raw mode. `run()` restores the terminal when it returns, also after an exception. Tui has no default quit key. To quit, add an `InputEvent` listener that calls `stop()`. Entry point: `Symfony\Component\Tui\Tui`.
- **Widgets.** `TextWidget` shows text, and `ContainerWidget` groups other widgets. `InputWidget` edits one line, and `EditorWidget` edits multi-line text. `SelectListWidget` selects one item, and `SettingsListWidget` changes `SettingItem` values. `LoaderWidget`, `CancellableLoaderWidget` and `ProgressBarWidget` show activity and progress. `MarkdownWidget` shows Markdown. A new `LoaderWidget` shows nothing until you call `start()`. Entry point: the classes in `Symfony\Component\Tui\Widget`.
- **Layout.** The Tui draws its output below the cursor, at the height of the content. It does not use the alternate screen, so the last frame stays visible after `stop()`. To fill the terminal height, call `expandVertically(true)` on a `ContainerWidget` or an `EditorWidget`. A `verticalAlign` style on `:root` also fills the height. A `ContainerWidget` stacks its children vertically, or side by side with the `Direction::Horizontal` style. Entry point: `Symfony\Component\Tui\Widget\ContainerWidget`.
- **Events.** Widgets have listener methods such as `onSubmit()`, `onCancel()`, `onChange()` and `onSelect()`. `Tui::addListener()` adds a global listener and gets the event class from the type of the first parameter. `getTarget()` returns the widget that sent the event. The Tui dispatches `InputEvent` before focus navigation and before the focused widget. To consume the input, call `stopPropagation()`. Entry points: `Symfony\Component\Tui\Event\InputEvent` and the other classes in `Symfony\Component\Tui\Event`.
- **Focus.** Only the focused widget receives keys. The first focusable widget that you add gets the focus. If two or more widgets can get the focus, F6 and Shift+F6 move it. `Tui::setFocus()` moves it directly. Entry point: `Symfony\Component\Tui\Widget\FocusableInterface`.
- **Keybindings.** `Keybindings` maps action names to key IDs such as `'ctrl+c'`, `'shift+enter'` or `Key::ENTER`. `matches()` compares raw input with an action. A widget merges three layers: its defaults, then the `Tui` keybindings, then its own keybindings. In `EditorWidget`, Enter submits, Shift+Enter inserts a new line and Escape cancels. Ctrl+C does not cancel the editor. Entry points: `Symfony\Component\Tui\Input\Keybindings`, `Symfony\Component\Tui\Input\Key`.
- **Styles.** `Style` is an immutable value object with padding, border, colors, text attributes, direction, gap, alignment and a FIGlet font. A `null` property inherits its value. For the `padding` and `border` arguments, use `Padding::all(1)` and `Border::all(1, 'rounded')`. Entry point: `Symfony\Component\Tui\Style\Style`.
- **Stylesheets.** `StyleSheet` applies `Style` rules to CSS-like selectors: `*`, a widget class name, `.class`, `:root`, `:focus` and `::element`. `addBreakpoint()` adds rules for a minimum terminal width. Give the stylesheet to `new Tui($styleSheet)`. The `Tui` keeps a copy of it. To add rules later, use `Tui::addStyleSheet()`. Entry point: `Symfony\Component\Tui\Style\StyleSheet`.
- **Utility classes.** `TailwindStylesheet` converts classes such as `p-2`, `bg-red-500`, `border-rounded` and `font-big` into styles. Add each class with `addStyleClass()`. For a rounded border, add `border` and `border-rounded`. Give the stylesheet to the constructor: `new Tui(new TailwindStylesheet())`. If you give it to `Tui::addStyleSheet()` instead, the Tui copies only its rules, and the utility classes have no effect. Entry point: `Symfony\Component\Tui\Style\TailwindStylesheet`.
- **FIGlet text.** The `font` style property or the `font-big` utility class shows `TextWidget` text as large ASCII art. The bundled fonts are big, small, slant, standard and mini. To add a font, call `FontRegistry::register()`. Then give the registry to `new Tui(fontRegistry: $registry)`. Entry point: `Symfony\Component\Tui\Widget\Figlet\FontRegistry`.
- **Tick loop.** `Tui::onTick()` registers a callback that receives a `TickEvent`. Return `true` while work runs (10 ms ticks), `false` when idle (no polling), or nothing for a 250 ms poll. `TickEvent::setBusy()` gives the same hint. Entry point: `Symfony\Component\Tui\Event\TickEvent`.
- **Non-blocking work.** The Tui runs on the Revolt event loop in one thread. A blocking call such as `sleep()`, `Process::run()` or a PDO query freezes input and rendering. Use Amp instead: `amphp/process`, `Amp\delay()`, `Amp\async()`, and `AmpHttpClient` for HTTP. If you start work with `Amp\async()`, check its future in the tick callback. Entry point: `Symfony\Component\HttpClient\AmpHttpClient`.
- **Custom widgets.** Extend `AbstractWidget`. Implement `render(RenderContext $context): array`, which returns one string for each terminal row. If a line is wider than `$context->getColumns()`, the renderer can throw a `RenderException`. For keyboard input, implement `FocusableInterface` with `FocusableTrait` and `KeybindingsTrait`. Then write the `handleInput()` method. Entry point: `Symfony\Component\Tui\Widget\AbstractWidget`.
- **Untrusted text.** Some widgets print text as-is, with its ANSI escape codes. This applies to `TextWidget`, `SelectListWidget` items, `SettingItem` labels and descriptions, and `InputWidget::setPrompt()`. If the text comes from users or other untrusted sources, remove the control bytes first. Entry point: `Symfony\Component\Tui\Widget\TextWidget`.
- **Tests.** `VirtualTerminal` records the output and simulates input and resize events. `ScreenBuffer` converts the raw output into the visible screen. In a test, create `new Tui(terminal: new VirtualTerminal(40, 10))`. Then call `start()` and `processRender()`. Read the result with `getOutput()`. Entry points: `Symfony\Component\Tui\Terminal\VirtualTerminal`, `Symfony\Component\Tui\Terminal\ScreenBuffer`.

## Entry points

- `Symfony\Component\Tui\Tui`: `new Tui()` with the optional `styleSheet`, `terminal`, `keybindings`, `fontRegistry` and `eventDispatcher` arguments. Methods: `add()`, `remove()`, `getById()`, `setFocus()`, `addListener()`, `onTick()`, `addStyleSheet()`, `requestRender()`, `run()`, `stop()`.
- Widgets in `Symfony\Component\Tui\Widget`: `TextWidget`, `ContainerWidget`, `InputWidget`, `EditorWidget`, `SelectListWidget`, `SettingsListWidget`, `SettingItem`, `LoaderWidget`, `CancellableLoaderWidget`, `ProgressBarWidget`, `MarkdownWidget`.
- Custom widgets: `Symfony\Component\Tui\Widget\AbstractWidget`, `Symfony\Component\Tui\Widget\FocusableInterface`, `Symfony\Component\Tui\Widget\FocusableTrait`, `Symfony\Component\Tui\Widget\KeybindingsTrait`, `Symfony\Component\Tui\Render\RenderContext`, `Symfony\Component\Tui\Ansi\AnsiUtils`.
- Keys: `Symfony\Component\Tui\Input\Keybindings`, `Symfony\Component\Tui\Input\Key`.
- Events in `Symfony\Component\Tui\Event`: `InputEvent`, `SubmitEvent`, `CancelEvent`, `ChangeEvent`, `SelectEvent`, `SelectionChangeEvent`, `SettingChangeEvent`, `FocusEvent`, `TickEvent`.
- Styles in `Symfony\Component\Tui\Style`: `Style`, `StyleSheet`, `TailwindStylesheet`, `Padding`, `Border`, `Color`, `Direction`, `Align`, `VerticalAlign`, `TextAlign`.
- Fonts: `Symfony\Component\Tui\Widget\Figlet\FontRegistry`.
- Test helpers: `Symfony\Component\Tui\Terminal\VirtualTerminal`, `Symfony\Component\Tui\Terminal\ScreenBuffer`.
- Without FrameworkBundle: `new Tui()`, then `add()` and `run()`. Tui is a standalone library.
- Tui has no bundle, configuration key, service ID, console command, attribute or Twig function. Create the `Tui` object yourself, for example in `Command::execute()`.

## Symbiotic packages

- [Console](../packages/console.md): A command runs the `Tui` in `execute()` and writes the result with `$output` after `run()`; Console alone covers questions, tables and progress bars.
- [EventDispatcher](../packages/event-dispatcher.md): Tui requires it and sends all input, widget and tick events through one dispatcher, which you can give to the `Tui` constructor.
- [String](../packages/string.md): Tui requires it and uses `UnicodeString::width()` for the terminal width of a grapheme with two or more code points, such as an emoji sequence.
- [Symfony Polyfill](../packages/polyfill.md): Tui requires `symfony/polyfill-intl-grapheme`, so the `grapheme_str_split()` and `grapheme_extract()` calls of Tui work without the `intl` extension.
- [HttpClient](../packages/http-client.md): While a Tui runs, send HTTP requests with `AmpHttpClient`, which needs `amphp/http-client` and does not block the event loop.
- [Process](../packages/process.md): While a Tui runs, start subprocesses with `amphp/process`, because `Process::run()` and `Process::wait()` block the event loop.

## Changed in 8.0/8.1

- New in 8.1: `symfony/tui` is a new component, and it is experimental. Older Symfony versions do not have it.

## Status

- Experimental. The README says "This Component is experimental", and each class has the `@experimental` tag. The backward compatibility promise does not cover it, so a minor version can break the API. The CHANGELOG then explains the change and the upgrade. The `tui/` docs pages do not mention this status.
- Tui requires PHP 8.4.1 or later.
- Tui is a standalone library without a bundle, a service or a configuration key. Create `new Tui()` yourself.
- Raw mode needs the `stty` command through `shell_exec()`. On Windows, `Terminal` does not call `stty` and does not enable raw mode.
- `MarkdownWidget` needs `league/commonmark` and `tempest/highlight`. Tui lists them only in `require-dev`, so add them to your project with Composer.
- FIGlet fonts in ZIP archives need the `zip` extension.
- The docs describe some features that the component does not have: editor autocomplete, a tabs widget, an animated image widget and a tab change event. Some docs examples also differ from the source. The docs also show `Compositor`, `Layer` and `PeriodicStepper`, which are `@internal`.

## Docs

- https://symfony.com/doc/current/tui/index.html
- https://symfony.com/doc/current/tui/getting_started.html
- https://symfony.com/doc/current/tui/widgets/index.html
- https://symfony.com/doc/current/tui/style/index.html
- https://symfony.com/doc/current/tui/style/tailwind.html
- https://symfony.com/doc/current/tui/topics/index.html
- https://symfony.com/doc/current/tui/topics/events.html
- https://symfony.com/doc/current/tui/topics/keybindings.html
- https://symfony.com/doc/current/tui/topics/tick_loop.html
- https://symfony.com/doc/current/tui/integrations/symfony_console.html
- https://symfony.com/doc/current/tui/integrations/revolt.html
- https://symfony.com/doc/current/tui/cheat_sheet.html
- https://symfony.com/doc/current/contributing/code/bc.html
