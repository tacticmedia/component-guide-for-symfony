# Finder (`symfony/finder`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- Stateful search object: each criteria method changes the `Finder` object and returns it, so you can chain the calls. To run a second search with the same base criteria, clone the object first. `new Finder()`, `Finder::create()`, `clone $finder`
- Search location: `in()` takes one or more directories, `*` glob patterns and stream wrapper URLs such as `ftp://` or `s3://`. If a path matches no directory, `in()` throws `DirectoryNotFoundException`. `exclude('cache')` skips each directory with that name at any depth, and Finder does not enter it. A value with `/`, such as `var/cache`, matches that sub-path at any depth. Without `ignoreUnreadableDirs()`, an unreadable directory causes an `AccessDeniedException`. With it, Finder lists the directory but does not enter it. `Finder::in()`, `Finder::exclude()`, `Finder::ignoreUnreadableDirs()`
- Entry type and paths: by default, the results contain files and directories. `files()` keeps only files, and `directories()` keeps only directories. `followLinks()` makes Finder enter symbolic links to directories. With `useUnixPaths()`, the result paths use `/` below the `in()` directory, also on Windows. Finder does not change the separators in the `in()` path itself. `Finder::files()`, `Finder::directories()`, `Finder::followLinks()`, `Finder::useUnixPaths()`
- Name filter: `name()` and `notName()` take globs, plain strings or regular expressions, and they compare only the file name, not the path. If you give several `name()` patterns, a match on one pattern is enough. A match on one `notName()` pattern removes the result. A glob such as `*.php` does not match a name that starts with a dot. `Finder::name()`, `Finder::notName()`
- Path filter: `path()` and `notPath()` take plain strings or regular expressions. They match the path relative to the `in()` directory, with `/` as the separator on all platforms. A plain string matches anywhere in that path, so `path('data')` also matches `metadata.xml`. `notPath()` only removes results, and Finder still enters the directories. `Finder::path()`, `Finder::notPath()`
- Content filter: `contains()` and `notContains()` read each file and match plain strings or regular expressions. If you give several `contains()` patterns, a match on one pattern is enough. A match on one `notContains()` pattern removes the file. Both methods also remove directories, unreadable files, empty files and files that contain only `0`. `Finder::contains()`, `Finder::notContains()`
- Size and date filters: `size('< 1.5K')` compares the file size and keeps all directories. The units `k`, `m` and `g` are powers of 1000, and `ki`, `mi` and `gi` are powers of 1024. `date('since yesterday')` compares the last modification time with a date string that `strtotime()` accepts. The operators are `>`, `>=`, `<`, `<=`, `==` and `!=`. `date()` also accepts `since` and `after` for `>`, and `until` and `before` for `<`. Without an operator, both methods use `==`, so `size('1M')` keeps only files of exactly 1000000 bytes. A prefix from the `find` command, such as `+50K`, causes an `\InvalidArgumentException`. For the last 24 hours, use `date('since 1 day ago')`, because `yesterday` means 00:00 of the previous day. `Finder::size()`, `Finder::date()`
- Depth filter: `depth('== 0')` keeps only the direct children of the `in()` directory, and `depth(['>= 1', '< 3'])` sets a range. Do not use `!=` with `depth()`, because Finder treats it like `==`. `Finder::depth()`
- VCS directories and hidden files: by default, Finder skips the directories of Git, Mercurial, Subversion, CVS, Bazaar and other VCS tools. It also skips each entry whose path below the `in()` directory contains a name that starts with a dot. `ignoreVCS(false)` and `ignoreDotFiles(false)` turn these rules off. To list `.git` itself, call both methods. `Finder::addVCSPattern()` adds a directory name to the VCS list of all `Finder` objects. `Finder::ignoreVCS()`, `Finder::ignoreDotFiles()`, `Finder::addVCSPattern()`
- `.gitignore` rules: `ignoreVCSIgnored(true)` removes the paths that `.gitignore` files exclude, with nested `.gitignore` files and negated patterns. Finder reads the `.gitignore` files from the repository root down to each file. The repository root is the nearest directory, at or above the `in()` directory, that contains a `.git` directory or file. Without a repository root, Finder starts at the `in()` directory. The docs page says that Finder always starts at the `in()` directory, which is not correct. This filter does not prune, so Finder still enters the ignored directories. If an ignored directory is large, for example `vendor`, also call `exclude('vendor')`. `Finder::ignoreVCSIgnored()`
- Custom filter: `filter()` takes a closure that receives each `SplFileInfo`, and a `false` return removes the entry. If the second argument is `true`, Finder prunes each directory for which the closure returns `false`, `null` or another empty value. Finder removes a pruned directory from the results and does not enter it. In this case, return `true` for each entry to keep. `Finder::filter()`
- Sort order: `sortByName()`, `sortByCaseInsensitiveName()`, `sortByExtension()`, `sortBySize()`, `sortByType()` (directories first), `sortByAccessedTime()`, `sortByChangedTime()`, `sortByModifiedTime()` and `sort($closure)` set the order. For natural order (`file2` before `file10`), pass `true` to `sortByName()` or `sortByCaseInsensitiveName()`. Only the last sort call counts, and `reverseSorting()` reverses the order. To sort the results, Finder first reads all of them into memory. The name sorts compare the full path. `Finder::sortByName()`, `Finder::reverseSorting()`
- Result objects: each result is a `Symfony\Component\Finder\SplFileInfo`, which extends the PHP `SplFileInfo` class. It adds `getRelativePath()`, `getRelativePathname()`, `getFilenameWithoutExtension()` and `getContents()`. `getContents()` throws a `\RuntimeException` if PHP cannot read the file. `SplFileInfo::getContents()`
- Iteration and appended results: `Finder` implements `IteratorAggregate` and `Countable`, and the iterator keys are the path names. If you give `in()` several locations, use `iterator_to_array($finder, false)`, because equal keys overwrite each other. Without `in()` or `append()`, the iteration throws a `\LogicException`. `append()` adds another `Finder`, an iterator or an array of paths, and the criteria methods do not filter these entries. `count($finder)`, `Finder::hasResults()`, `Finder::append()`
- Pattern helpers: `Glob::toRegex()` converts a glob such as `**/*.php` or `*.{jpg,png}` into a regular expression. `Gitignore::toRegex()` converts the content of a `.gitignore` file into one regular expression. Use these helpers to match path strings without a directory scan. `Symfony\Component\Finder\Glob`, `Symfony\Component\Finder\Gitignore`

## Entry points

- `Symfony\Component\Finder\Finder`: create it with `new Finder()` or `Finder::create()`. FrameworkBundle registers no `Finder` service, so do not autowire it.
- Without FrameworkBundle: `new Finder()` and `Finder::create()` work the same way, because the package needs no container and no configuration.
- `Symfony\Component\Finder\SplFileInfo`: the type of each result.
- `Symfony\Component\Finder\Exception\DirectoryNotFoundException`: `in()` throws it for a missing directory. It extends `\InvalidArgumentException`.
- `Symfony\Component\Finder\Exception\AccessDeniedException`: the iteration throws it for an unreadable directory. It extends `\UnexpectedValueException`.
- `Symfony\Component\Finder\Glob::toRegex()` and `Symfony\Component\Finder\Gitignore::toRegex()`: convert patterns into regular expressions.
- The package has no config key, console command, attribute, Twig function or test helper.

## Symbiotic packages

- [Filesystem](../packages/filesystem.md): Finder selects files, and Filesystem changes them. `Filesystem::remove()` accepts a `Finder`, and `Filesystem::mirror()` takes a `Finder` as its third argument to select the files to copy. If you work with one known path, use `Filesystem` and `Path` without Finder.
- [Process](../packages/process.md): the Process classes `ExecutableFinder` and `PhpExecutableFinder` have names like Finder, but they find programs, not files. To find a program in the `PATH` directories, use `ExecutableFinder`. To find the PHP binary, use `PhpExecutableFinder`.
- [FrameworkBundle](../packages/framework-bundle.md): FrameworkBundle requires `symfony/finder`, so each full-stack application has it. FrameworkBundle uses Finder to find the translation files. When `assets:install` copies assets, it passes a `Finder` to `Filesystem::mirror()` to skip VCS files.
- [Config](../packages/config.md): the config loaders resolve glob imports with `GlobResource`. `GlobResource` needs Finder for extended glob patterns such as `/**/`, and it throws a `LogicException` when Finder is missing.
- [Translation](../packages/translation.md): `TranslationReader` uses Finder to find the translation files of a locale in a directory. `PhpAstExtractor` needs Finder to scan directories, and it throws a `LogicException` when Finder is missing.
- [Routing](../packages/routing.md): the migration guide shows a custom route loader that uses Finder to create one route for each legacy PHP script.

## Changed in 8.0/8.1

- 8.1: `str_replace('\\', '/', $file->getRelativePathname())` for portable result paths -> `$finder->useUnixPaths()`.

## Docs

- https://symfony.com/doc/current/components/finder.html
- https://symfony.com/doc/current/components/using_components.html
- https://symfony.com/doc/current/components/filesystem.html
- https://symfony.com/doc/current/components/process.html
- https://symfony.com/doc/current/migration.html
