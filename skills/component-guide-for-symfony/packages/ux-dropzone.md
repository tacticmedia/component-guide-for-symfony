# Symfony UX Dropzone (`symfony/ux-dropzone`)

**Applies to:** Symfony UX 3.5

**Elevator pitch:** Use when a file upload field in an HTML form must accept drag and drop, or must preview the chosen files before the submit. It replaces the plain file field with a drop zone that keeps several selections and lets users remove single files, with no custom JavaScript. To crop an uploaded image, see [UX Cropper.js](ux-cropperjs.md).

**Details:** [../details/ux-dropzone.md](../details/ux-dropzone.md)

## Why it exists

A plain file field renders the native file input of the browser. This input shows no preview, and each new selection replaces the earlier files. The package renders the field as a drop zone that shows each chosen file. The files still arrive in the same request as the other form fields.

## When to use it

- Let users drag and drop a file onto a form field.
- Show the file name and an image thumbnail before the user submits the form.
- Collect files over several selections and let the user remove single files before the upload.
- Replace a plain file upload field with a drop zone that needs no custom JavaScript.
- Run custom JavaScript when the user selects, clears or removes a file in a drop zone.
- Change the design, the placeholder text or the remove-button label of a file drop zone.

## Use it instead of

- `dragover` and `drop` listeners on a custom `<div>` that copy `event.dataTransfer.files` into a hidden file input -> `$builder->add('photo', DropzoneType::class)` (`Symfony\UX\Dropzone\Form\DropzoneType`).
- `const reader = new FileReader(); reader.readAsDataURL(file);` and an `<img>` element to preview the chosen image -> the built-in preview of `DropzoneType`.
- `const dataTransfer = new DataTransfer(); dataTransfer.items.add(file); input.files = dataTransfer.files;` to keep earlier selections and remove single files -> `DropzoneType` with `'multiple' => true`.
- A drop-zone library from a CDN that posts each file to a separate `/upload` route -> `DropzoneType` in the normal form and `$form->get('photos')->getData()`.
- `<input type="file" name="photos[]" multiple>` in Twig and `$request->files->get('photos')` in the controller -> `DropzoneType` with `'multiple' => true` and `new Assert\All([new Assert\File(...)])` in `constraints`.
- An inline `<script>` that listens to `change` on `#product_photo` -> a Stimulus controller in `attr['data-controller']` that listens to `dropzone:change`.
