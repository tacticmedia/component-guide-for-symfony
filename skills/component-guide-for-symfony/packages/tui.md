# Tui (`symfony/tui`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when a PHP command-line program needs an interactive terminal UI with text input, select lists, spinners, Markdown and key bindings. It draws widgets with CSS-like styles. The package is experimental. If the program only needs arguments, questions, tables or progress bars, see [Console](console.md).

**Details:** [../details/tui.md](../details/tui.md)

## Why it exists

An interactive terminal program must put the terminal in raw mode and parse key sequences. It must also measure the display width of Unicode text and redraw only the changed part of the screen. The package does this work. It gives widgets, CSS-like styles, key bindings and events on a non-blocking event loop.

## When to use it

- Build an interactive terminal interface for a command-line command.
- Ask the user for a single-line value or for a multi-line text.
- Let the user select an item from a list or change a list of settings with the keyboard.
- Show a spinner, a cancellable loader or a progress bar while background work runs.
- Show Markdown with syntax-highlighted code blocks in the terminal.
- Define keyboard shortcuts for actions and let the application or a widget change them.
- Style terminal output with CSS-like rules, utility classes, borders and large ASCII-art text.
- Send HTTP requests, wait for timers or run subprocesses without freezing the interface.
- Test a terminal interface in an automated test without a real terminal.

## Use it instead of

- `shell_exec('stty raw -echo')` and a `fread(STDIN, 8)` loop that compares bytes with `"\e[A"` -> `Tui::run()` with an `InputEvent` listener and `Keybindings::matches()`.
- `echo "\r".$frames[$i++ % 10]; usleep(80000);` -> `LoaderWidget` with `start()`, or `CancellableLoaderWidget` to let the user cancel with Escape or Ctrl+C.
- `"\033[1;36m"` color codes and boxes from `str_repeat('─', $width)` -> `Style` (`color`, `bold`, `border`) in a `StyleSheet`, or `TailwindStylesheet` classes.
- A `readline()` loop that collects lines until an empty line -> `EditorWidget` with `onSubmit()` and `getText()`.
- An arrow-key menu that redraws the list with ANSI codes -> `SelectListWidget` with `onSelect()` and `getSelectedItem()`.
- `str_pad()` with `mb_strwidth()` on colored strings -> `ContainerWidget` with `Style` `padding` and `textAlign`; in a custom widget, `AnsiUtils::visibleWidth()` and `AnsiUtils::truncateToWidth()`.
- `sleep(1)` or `file_get_contents('https://…')` while the interface is open -> `Amp\delay()` or `AmpHttpClient` in `Amp\async()`, checked in `Tui::onTick()`.
