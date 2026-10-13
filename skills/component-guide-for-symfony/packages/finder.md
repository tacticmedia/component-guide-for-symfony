# Finder (`symfony/finder`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when PHP must find files or directories in a directory tree by name, path, content, size, date or depth. It also skips hidden files and the files that Git ignores, and sorts the results. To copy, write or delete files, see [Filesystem](filesystem.md). To find an executable program, see [Process](process.md).

**Details:** [../details/finder.md](../details/finder.md)

## Why it exists

A recursive file search with several criteria needs nested directory loops or SPL directory iterators, plus one filter for each criterion. The package wraps these iterators in one object with chainable criteria. Each result also knows its path relative to the search directory. By default, it skips version control directories and hidden files.

## When to use it

- Find all files that match a name pattern, for example all PHP files or all templates, in a directory tree.
- Find the files with a modification time after a date, or the files that are larger than a size limit.
- Search the files of a directory for a string or a regular expression in their content.
- List the files of a Git project, but skip the files that the Git ignore rules exclude.
- List only the direct children of a directory, or only the entries in a depth range.
- Sort the found files by name, natural order, extension, size, type or modification time.
- Select the files that [Filesystem](filesystem.md) must delete or copy, for example all old temporary files.
- Iterate over the files on FTP, Amazon S3 or another PHP stream wrapper.
- Scan the files of a project from a command-line tool or a build script.

## Use it instead of

- `glob('src/*.php')` plus a recursive function with `scandir()` and `is_dir()` -> `Finder::create()->files()->in('src')->name('*.php')`
- `new RecursiveIteratorIterator(new RecursiveDirectoryIterator($dir))` with `if` checks in the loop -> the criteria methods of `Finder`, for example `files()`, `name()`, `depth()` and `exclude()`
- `filemtime($path) > strtotime('-1 day')` in a loop -> `->date('since 1 day ago')`
- `filesize($path) < 100 * 1024` in a loop -> `->size('< 100Ki')`
- `str_contains(file_get_contents($path), 'TODO')` for each file -> `->contains('TODO')`
- A hand-written `.gitignore` parser with `fnmatch()` -> `->ignoreVCSIgnored(true)`
- `usort($files, fn ($a, $b) => filemtime($a) <=> filemtime($b))` -> `->sortByModifiedTime()`
- `str_replace('\\', '/', $file->getRelativePathname())` on each result for Windows -> `->useUnixPaths()`
- A `foreach` loop with `unlink()` over a `glob()` result -> `$filesystem->remove(Finder::create()->files()->in($dir)->name('*.tmp'))`
- `count(glob($pattern)) > 0` -> `$finder->hasResults()`
