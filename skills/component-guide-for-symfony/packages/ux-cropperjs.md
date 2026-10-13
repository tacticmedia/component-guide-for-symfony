# Symfony UX Cropper.js (`symfony/ux-cropperjs`)

**Applies to:** Symfony UX 3.5

**Elevator pitch:** Use when users must crop an uploaded image, such as an avatar, a banner or a thumbnail, in an HTML form. It shows a Cropper.js crop box in a form field, then crops and scales down a copy of the file on the server. To upload the image, see [UX Dropzone](ux-dropzone.md).

**Details:** [../details/ux-cropperjs.md](../details/ux-cropperjs.md)

## Why it exists

An image crop needs a JavaScript crop widget and a form field that sends the crop box to the server. It also needs server code that crops the file. The package connects Cropper.js to a form field and to a PHP crop object. This object uses Intervention Image to crop, rotate and scale down a copy of the source image on the server.

## When to use it

- Let a user select the visible area of a profile photo before you save it.
- Crop an uploaded image to a fixed aspect ratio, for example 16:9 for a banner.
- Crop the source image on the server, so that the browser sends only the crop box.
- Create a thumbnail of the selected image area with a maximum width and height.
- Limit the pixel size of a cropped image before you store it.
- Add Cropper.js callbacks or extra event listeners to a crop field with your own JavaScript.
- Select the image library that crops the images on the server: GD, Imagick or libvips.

## Use it instead of

- A hand-written `<img>`, `new Cropper(image, {...})` and a `crop` listener that fills a hidden input -> `CropperType` with `cropper_options`.
- `json_decode($request->request->get('crop'), true)` to read the crop box -> the `Crop` object that `$form->handleRequest($request)` fills.
- `imagecrop($gd, ['x' => $x, 'y' => $y, 'width' => $w, 'height' => $h])` -> `$crop->getCroppedImage()`.
- `imagescale()` or `imagecopyresampled()` with a manual aspect-ratio calculation -> `$crop->setCroppedMaxSize(2000, 1500)` or `$crop->getCroppedThumbnail(200, 150)`.
- `new ImageManager(...)` from Intervention Image in your own crop service -> `CropperInterface::createCrop()` and the `cropperjs.driver` option.
- `cropper.getCroppedCanvas().toBlob()` plus a second upload with `FormData` -> `Crop`, which crops the source image on the server. The browser sends only the crop data.
