# Emoji (`symfony/emoji`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when code must replace emojis with their names, remove emojis from text, or convert emojis to and from short codes. It covers 164 locales of the Unicode CLDR data and the GitHub, GitLab and Slack codes. It also gives a template filter for short codes, and it can write emoji names into URL slugs.

**Details:** [../details/emoji.md](../details/emoji.md)

## Why it exists

To convert or remove emojis, code needs large lookup tables. The package contains up to 3,938 CLDR emoji names for each of 164 locales, and the GitHub, GitLab and Slack short codes. One subclass of the PHP intl transliterator reads these tables. The template filter and the emoji slugs use this class.

## When to use it

- Replace each emoji in a text with its name in a given language.
- Remove all emojis from a text, for example from a user name or a subject line.
- Convert GitHub, GitLab or Slack short codes to emojis, or emojis to short codes.
- Show short codes as emojis in an HTML template.
- Create URL slugs that keep the meaning of emojis, for example the word pizza for a pizza emoji.
- Make the vendor directory of Composer smaller for a deployment with a size limit.
- Replace old code that uses the emoji transliterator of [Intl](intl.md), which Symfony 8.0 removed.

## Use it instead of

- `preg_replace('/[\x{1F300}-\x{1FAFF}]/u', '', $text)` or a similar range to remove emojis -> `EmojiTransliterator::create('strip')->transliterate($text)`
- A hand-written array that maps each emoji to a name, or `IntlChar::charName()` -> `EmojiTransliterator::create('fr')->transliterate($text)`
- `str_replace([':thumbsup:', ':tada:'], ['👍', '🎉'], $text)` -> `EmojiTransliterator::create('github-emoji')->transliterate($text)` (or `slack-emoji`, `gitlab-emoji`, `text-emoji`)
- `json_decode(file_get_contents('https://api.github.com/emojis'), true)` to build a short-code table at runtime -> `EmojiTransliterator::create('emoji-github')` and `create('github-emoji')`
- A custom Twig filter that replaces short codes such as `:wave:` with emojis -> the `emojify` filter: `{{ comment|emojify }}`
- `strtolower(trim(preg_replace('/[^A-Za-z0-9]+/', '-', $title), '-'))`, which removes emojis from a slug -> `(new AsciiSlugger('en'))->withEmoji()->slug($title)->lower()`
