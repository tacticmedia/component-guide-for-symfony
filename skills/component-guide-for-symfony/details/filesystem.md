# Filesystem (`symfony/filesystem`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- Exceptions instead of warnings: each failed disk operation throws an `IOException`. `getPath()` returns the path that caused the failure, or `null`. If the source file of `copy()` or `hardlink()` does not exist, the method throws `FileNotFoundException`, a subclass of `IOException`. `Exception\IOExceptionInterface`, `Exception\IOException`, `Exception\FileNotFoundException`
- Lists of paths: `mkdir()`, `exists()`, `touch()`, `remove()`, `chmod()`, `chown()` and `chgrp()` accept one path, an array or a `Traversable`, for example a `Finder`. `exists()` returns `true` only if all paths exist. `Filesystem::exists()`
- Directories: `mkdir()` creates the parent directories and ignores directories that exist. The default mode is `0777`, minus the umask. `remove()` deletes files, symbolic links and complete directory trees, and it ignores paths that do not exist. `Filesystem::mkdir()`, `Filesystem::remove()`
- File copy: `copy()` copies one file and creates the target directory. If the target exists, the method copies the file only when the source is newer, unless the third argument is `true`. For a local source file, the copy gets the source mode, minus the umask, and the source modification time. `Filesystem::copy()`
- Rename: `rename()` throws an `IOException` if the target exists, unless the third argument is `true`. If PHP cannot rename a directory, the method copies it with `mirror()` and then removes the origin. `Filesystem::rename()`
- Directory copy: `mirror()` copies a directory tree. The `override` option also replaces newer target files. The `delete` option deletes the target files that the origin does not have. The `follow_symlinks` option copies the files that links point to, not the links. An iterator in the third argument, for example a `Finder`, selects the files to copy. `Filesystem::mirror()`
- Links: `symlink()` creates the parent directory and replaces a link that points to a different target. On Windows, its third argument makes a copy of the directory instead of a link. `hardlink()` creates hard links. `readlink($path, true)` returns the absolute final target, or `null` if the path does not exist. `Filesystem::symlink()`, `Filesystem::hardlink()`, `Filesystem::readlink()`
- Atomic write: `dumpFile()` writes a temporary file in the same directory, then renames it to the target. A reader sees the complete old file or the complete new file. The method creates missing directories and accepts a string or a stream resource. It keeps the mode of an existing file, and it writes through a symbolic link to its target. `Filesystem::dumpFile()`
- Append and read: `appendToFile()` creates the file and its directory. If the third argument is `true`, the method holds an exclusive lock (`LOCK_EX`) during the write. `readFile()` returns the contents as a string. It throws an `IOException` if the path is a directory or if PHP cannot read the file. `Filesystem::appendToFile()`, `Filesystem::readFile()`
- Temporary files: `tempnam()` creates a file with a unique name, the given prefix and an optional suffix, and returns its path. The file mode is `0600`. The directory can also use a stream wrapper scheme. If the suffix is empty and the directory does not exist, the method creates the file in the system temporary directory. `Filesystem::tempnam()`
- Metadata: `touch()` creates a missing file and sets the modification time and the access time. `chmod()`, `chown()` and `chgrp()` change the mode, the owner and the group. A `true` last argument applies the change recursively. `chown()` and `chgrp()` always throw an exception on Windows. `Filesystem::touch()`, `Filesystem::chmod()`, `Filesystem::chown()`, `Filesystem::chgrp()`
- Canonical paths: `Path::canonicalize()` removes `.` segments and resolves `..` segments. It keeps a scheme such as `phar://` and replaces a leading `~` with the home directory. The path does not need to exist. `Path::join()` joins segments, ignores empty segments and canonicalizes the result. `Path::canonicalize()`, `Path::join()`, `Path::normalize()`
- Absolute, relative and base paths: `Path::makeAbsolute()` and `Path::makeRelative()` convert a path against a base path. `Path::isBasePath()` compares canonical strings, so `/var/uploads/../../etc` and `/var/uploads-old` are not inside `/var/uploads`. It does not resolve symbolic links. `Filesystem::makePathRelative()` needs two absolute paths and adds a trailing slash, unless the end path is an existing file. `Path::makeAbsolute()`, `Path::makeRelative()`, `Path::isAbsolute()`, `Path::isRelative()`, `Path::isBasePath()`, `Path::getLongestCommonBasePath()`, `Path::getDirectory()`, `Path::getRoot()`, `Filesystem::makePathRelative()`
- Other `Path` helpers (the docs page does not show them): `getExtension()`, `hasExtension()` and `changeExtension()` read, test and replace the file extension. `getFilenameWithoutExtension()` returns the file name without the directory and the extension. `isLocal()` returns `false` for an empty path and for a path that contains `://`. `getHomeDirectory()` returns the home directory of the user. `Path::getExtension()`, `Path::hasExtension()`, `Path::changeExtension()`, `Path::getFilenameWithoutExtension()`, `Path::isLocal()`, `Path::getHomeDirectory()`
- Operating system rules: on UNIX, `Path` treats a backslash as a file name character, and `C:` is not a root. On Windows, a backslash is a separator. The docs examples with `C:\` show the Windows results only. `Path::isAbsolute()`, `Filesystem::isAbsolutePath()`

## Entry points

- `Symfony\Component\Filesystem\Filesystem`: autowire this class in a service, a controller or a command. The private service ID is `filesystem`. `ServicesBundle` registers it, and FrameworkBundle and ConsoleBundle require `ServicesBundle`. Outside a container, use `new Filesystem()`.
- Without FrameworkBundle: create the object with `new Filesystem()`, and call the static methods of `Path`. A console application with `ConsoleBundle` can also autowire `Filesystem`.
- `Symfony\Component\Filesystem\Path`: a final class with static methods only. Do not create an instance, because the constructor is private.
- `Symfony\Component\Filesystem\Exception\IOExceptionInterface`: catch it around disk operations. `getPath()` gives the path. `IOException` and `FileNotFoundException` implement it.
- `Symfony\Component\Filesystem\Exception\ExceptionInterface`: catch it to catch all exceptions of the package. This includes the `InvalidArgumentException` of `Path` and `makePathRelative()`, and the `RuntimeException` of `Path::getHomeDirectory()`.
- The package has no configuration key, console command, attribute, Twig function or test helper.

## Symbiotic packages

- [Finder](../packages/finder.md): Finder searches for files by name, size, date or contents, and Filesystem changes them. To delete the files that a `Finder` finds, pass it to `remove()`. To copy only these files, pass it as the third argument of `mirror()`, as the `assets:install` command does.
- [Config](../packages/config.md): `ConfigCache::write()` saves a generated file with `dumpFile()`. In debug mode, `isFresh()` returns `false` when a tracked resource changes. For a cache file that depends on configuration files, use `ConfigCache`.
- [DependencyInjection](../packages/dependency-injection.md): the `ServicesBundle` of DependencyInjection registers the `filesystem` service and the `Filesystem` autowiring alias.
- [FrameworkBundle](../packages/framework-bundle.md): FrameworkBundle requires `symfony/filesystem` and `ServicesBundle`, so each full-stack application can autowire `Filesystem`. The `cache:clear` and `assets:install` commands use this service.
- [Console](../packages/console.md): `ConsoleBundle` requires `ServicesBundle`, so a console application without FrameworkBundle can also autowire `Filesystem`.
- [FrameworkBundle test tools](../packages/framework-bundle-testing.md): if the tests run with debug mode off, clear `var/cache/test` with `remove()` in `tests/bootstrap.php`.
- [Lock](../packages/lock.md): the lock of `appendToFile()` covers one write only. To keep other processes out of a longer read, change and write sequence, use Lock.
- [Cache](../packages/cache.md): to store computed values with a lifetime, use a cache pool instead of `dumpFile()`. The `FilesystemAdapter` of Cache stores the items as files.
- [HttpFoundation](../packages/http-foundation.md): to store an uploaded file, use `UploadedFile::move()` instead of `rename()`.

## Changed in 8.0/8.1

- 8.1: `mirror($originDir, $targetDir, null, ['copy_on_windows' => true])` -> `['follow_symlinks' => true]`. The old option name triggers a deprecation.
- 8.0.9 (also in 7.4.9), fix #63909: on UNIX, `Path` keeps a backslash as a file name character, and `C:` is not a root. `Path::isAbsolute('C:\Windows')` and `Filesystem::isAbsolutePath('C:\Windows')` now return `false` on UNIX. Older versions convert `\` to `/` and return `true` on all systems. Do not use `Path` to convert Windows separators on UNIX.

## Docs

- https://symfony.com/doc/current/components/filesystem.html
- https://symfony.com/doc/current/configuration/front_controllers_and_kernel.html
- https://symfony.com/doc/current/console.html
- https://symfony.com/doc/current/service_container.html
- https://symfony.com/doc/current/testing.html
