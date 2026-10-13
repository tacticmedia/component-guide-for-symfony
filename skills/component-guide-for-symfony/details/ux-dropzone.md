# Symfony UX Dropzone (`symfony/ux-dropzone`): details

**Applies to:** Symfony UX 3.5

## Key features and concepts

- **Form type**: `DropzoneType` has `FileType` as its parent type. It accepts the `FileType` options and submits the same data: one `UploadedFile`, or an array of `UploadedFile` objects with `multiple`. `form_start()` adds `enctype="multipart/form-data"`. Entry point: `Symfony\UX\Dropzone\Form\DropzoneType`.
- **Not Dropzone.js**: The package does not integrate the Dropzone.js JavaScript library. Its controller imports only `@hotwired/stimulus` and keeps the files in the native `<input type="file">`.
- **Placeholder text**: The default `attr` option is `['placeholder' => 'Drag and drop or browse']`. The form theme translates the placeholder with the `translation_domain` of the form. If you set `attr`, also set `placeholder`. Your `attr` array replaces the default array, and the zone then shows no text.
- **Single-file preview**: After a selection, the zone hides the placeholder and shows the file name. If the MIME type of the file contains `image`, the zone also shows a thumbnail from a `FileReader` data URL. The clear button (`×`) empties the input. When the user drags a file over a filled zone, the zone accepts a replacement file.
- **Multiple files**: With `'multiple' => true`, the zone adds each new selection to the earlier files. It skips a file with the same name, size and modification time. A list shows the name, a remove button and, for an image, a thumbnail for each file. The controller writes the list back into the `<input>`, so the browser sends all files when the user submits the form.
- **Remove-button label**: `remove_label` (string, default `'Remove'`) sets the accessible name of each remove button in `multiple` mode: the label, then the file name. The form theme translates the label with the `translation_domain` of the form. The `×` on the button comes from the default stylesheet.
- **Browser events**: The controller dispatches `dropzone:connect`, `dropzone:change`, `dropzone:clear` (single-file mode) and `dropzone:remove` (`multiple` mode) on the container `<div>`. The events bubble. In `dropzone:change`, `event.detail` is a `File` in single-file mode and a `FileList` in `multiple` mode. In `dropzone:remove`, `event.detail` is the removed `File`. When the user removes a file, the controller dispatches `dropzone:change` with the new `FileList`, then `dropzone:remove`. In single-file mode, the controller also dispatches `dropzone:clear` at each connect, before `dropzone:connect`.
- **Custom Stimulus controller**: Put the name of your controller in `attr['data-controller']`, for example `mydropzone` for `assets/controllers/mydropzone_controller.js`. The form theme moves the name to the container `<div>`, before `symfony--ux-dropzone--dropzone`. Add the event listeners in `connect()`. Remove them in `disconnect()`. Other `attr` entries, for example Stimulus values, stay on the `<input>`. If a handler uses `this`, bind it in `initialize()`, as the Dropzone controller does.
- **Default stylesheet**: The `autoimport` entry in `assets/controllers.json` loads `@symfony/ux-dropzone/dist/style.min.css`. To use your own CSS, set this entry to `false`. Do not delete the line, because Flex adds a missing entry again with the value `true`.
- **CSS classes**: The form theme renders `.dropzone-container` (and `.dropzone-container-multiple`), `.dropzone-input`, `.dropzone-placeholder`, `.dropzone-preview`, `.dropzone-preview-button`, `.dropzone-preview-image`, `.dropzone-preview-filename` and `.dropzone-preview-list`. The controller adds `.dropzone-preview-list-item` and `.dropzone-preview-list-remove` elements. The default CSS puts the transparent `.dropzone-input` over the full zone, so a click or a drop reaches the native input. If you use your own CSS, give the clear and remove buttons visible content, because they contain no text.
- **Form theme**: If the kernel registers TwigBundle, the bundle adds `@Dropzone/form_theme.html.twig` to `twig.form_themes`, before the themes of the application. To change the HTML, define a `dropzone_widget` block in your own form theme. Keep the `data-symfony--ux-dropzone--dropzone-target` attributes, because the controller uses these targets. If a `form_theme` tag uses `only`, add `@Dropzone/form_theme.html.twig` to its list, because `only` ignores the global themes.
- **Asset setup**: With AssetMapper, the bundle maps its `assets/dist` folder to `@symfony/ux-dropzone`, and no npm step is necessary. With Webpack Encore, run `npm install --force`. Then restart Encore. Flex registers the bundle and adds the `dropzone` controller to `assets/controllers.json`. To download the controller only on pages that use it, set `fetch` to `lazy`.
- **Server side**: The bundle has no configuration options and no upload endpoint. The files arrive in the same request as the other form fields. Validate the files with the `File` constraint. In `multiple` mode, put this constraint in an `All` constraint. Store each file with `UploadedFile::move()`.

## Entry points

- `Symfony\UX\Dropzone\Form\DropzoneType`: block prefix `dropzone`, service `form.dropzone` (tag `form.type`). Options: `remove_label` (new), `attr` (new default with `placeholder`), and the inherited `multiple`, `required`, `mapped` and other `FileType` and `FormType` options.
- `Symfony\UX\Dropzone\DropzoneBundle`: install with `composer require symfony/ux-dropzone`. Flex registers the bundle with an auto-generated recipe.
- Twig form theme `@Dropzone/form_theme.html.twig` with the block `dropzone_widget`. The bundle adds it to `twig.form_themes`.
- Stimulus controller `@symfony/ux-dropzone/dropzone` (identifier `symfony--ux-dropzone--dropzone`). Targets: `input`, `placeholder`, `preview`, `previewClearButton`, `previewFilename`, `previewImage`, `previewList`. Values: `multiple`, `removeLabel`.
- Browser events: `dropzone:connect`, `dropzone:change`, `dropzone:clear`, `dropzone:remove`.
- `assets/controllers.json`: `controllers["@symfony/ux-dropzone"].dropzone` with `enabled`, `fetch` (`eager` or `lazy`) and `autoimport["@symfony/ux-dropzone/dist/style.min.css"]`.
- npm package `@symfony/ux-dropzone`: only for setups that keep JavaScript dependencies apart from PHP dependencies. Its version must be the same as the version of the PHP package.
- Config: none. The bundle prepends `twig.form_themes` and, with AssetMapper, `framework.asset_mapper.paths`.
- Tests: the package has no test helper.

## Symbiotic packages

- [Form](../packages/form.md): `DropzoneType` has `FileType` as its parent type, so the submitted data, the `multiple` option and the form validation do not change.
- [StimulusBundle](../packages/stimulus-bundle.md): the Dropzone docs require it, but `composer.json` does not; it starts Stimulus and loads the controllers from `assets/controllers.json` and `assets/controllers/`.
- [TwigBundle](../packages/twig-bundle.md): the bundle adds its form theme to `twig.form_themes` only when the kernel registers TwigBundle.
- [AssetMapper](../packages/asset-mapper.md): the bundle maps its `assets/dist` folder to the `@symfony/ux-dropzone` namespace, so no npm step is necessary.
- [WebpackEncoreBundle](../packages/webpack-encore-bundle.md): with Encore, Flex adds `@symfony/ux-dropzone` (`file:vendor/symfony/ux-dropzone/assets`) to `package.json`, so the Encore build reads the controller from `vendor/` after `npm install --force`.
- [Symfony Flex](../packages/flex.md): registers `DropzoneBundle`, writes the controller entry in `assets/controllers.json` and keeps an `autoimport` value of `false`.
- [Validator](../packages/validator.md): the `File` and `Image` constraints validate the uploaded files; in `multiple` mode, put the constraint in `All`.
- [HttpFoundation](../packages/http-foundation.md): each submitted file is an `UploadedFile`: `move()` stores it, and `guessExtension()` gives a safe extension instead of the client extension.
- [String](../packages/string.md): `SluggerInterface::slug()` makes a safe file name from the client file name, as the upload docs show.
- [Symfony UX Cropper.js](../packages/ux-cropperjs.md): another form type from Symfony UX; `CropperType` crops an image that the server already stores, and `DropzoneType` collects the files to upload.

## Changed in UX 3.0 to 3.5

- UX 3.5: `'multiple' => true` keeps earlier selections, previews each file and adds a remove button for each file. Up to 3.4, the controller showed only the first file. Do not rebuild `input.files` with `DataTransfer` in your own JavaScript.
- UX 3.5: In `multiple` mode, `dropzone:change` carries a `FileList`. Up to 3.4, it carried only the first `File`. The new `dropzone:remove` event carries the removed `File`.
- UX 3.5: The new `remove_label` option sets the label of the remove button for each file.
- UX 3.0: The package requires PHP 8.4 and Symfony 7.4 or 8.x.

## Docs

- https://symfony.com/bundles/ux-dropzone/current/index.html
- https://symfony.com/bundles/StimulusBundle/current/index.html
- https://symfony.com/doc/current/reference/forms/types/file.html
- https://symfony.com/doc/current/controller/upload_file.html
- https://symfony.com/doc/current/form/form_themes.html
- https://symfony.com/doc/current/reference/forms/types.html (lists `DropzoneType`; its link goes to the README of the unmaintained 2.x branch)
- https://symfony.com/bundles/ux-cropperjs/current/index.html
