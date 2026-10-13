# Filesystem (`symfony/filesystem`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when PHP must create, copy, move, link or delete files and whole directory trees, with an exception for each failure. It also writes files atomically, creates temporary files, and joins, cleans and converts paths without disk access. To search for files, see [Finder](finder.md).

**Details:** [../details/filesystem.md](../details/filesystem.md)

## Why it exists

PHP file functions report a failure with a warning and a false return value. The package wraps them in methods that throw an exception with the failing path, create missing parent directories and work recursively. Its path helper works only on path strings for UNIX and Windows, and it does not access the disk.

## When to use it

- Write a cache, configuration or export file so that a reader never sees a partly written file.
- Create a directory tree, or delete a directory with all of its contents.
- Copy a directory tree to a different location, and optionally delete the target files that the source does not have.
- Copy, rename or link one file, and get an exception with the path when the operation fails.
- Append lines to a CSV or text file with an exclusive lock for each write.
- Create a unique temporary file with a prefix and a file extension in a given directory.
- Join path segments, or convert a path between the absolute and the relative form.
- Make sure that a user-supplied path stays inside an allowed base directory.
- Change files from a command-line tool or a plain PHP script, without the framework.

## Use it instead of

- `file_put_contents($cacheFile, $phpCode)` for a file that other requests read at the same time -> `$filesystem->dumpFile($cacheFile, $phpCode)`
- `if (!is_dir($dir)) { mkdir($dir, 0777, true); }` -> `$filesystem->mkdir($dir)`
- A `RecursiveIteratorIterator` loop with `unlink()` and `rmdir()`, or `exec('rm -rf '.$dir)` -> `$filesystem->remove($dir)`
- A recursive loop with `mkdir()` and `copy()`, or `exec('cp -R ...')` -> `$filesystem->mirror($originDir, $targetDir)`
- A `RecursiveDirectoryIterator` loop that calls `unlink()` for each `*.tmp` file -> `$filesystem->remove(Finder::create()->files()->name('*.tmp')->in($dir))`
- `$data = @file_get_contents($path); if (false === $data) { ... }` -> `$filesystem->readFile($path)` in a `try` block that catches `IOExceptionInterface`
- `rtrim($dir, '/').'/'.ltrim($file, '/')` -> `Path::join($dir, $file)`
- `realpath($path)` to remove `..` segments, which returns `false` for a path that does not exist -> `Path::canonicalize($path)`
- `str_starts_with($path, $uploadDir)` to check that a path is inside a directory -> `Path::isBasePath($uploadDir, $path)`
- `$dir.'/'.uniqid('export_').'.csv'` followed by `touch()` -> `$filesystem->tempnam($dir, 'export_', '.csv')`
