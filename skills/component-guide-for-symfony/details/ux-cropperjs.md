# Symfony UX Cropper.js (`symfony/ux-cropperjs`): details

**Applies to:** Symfony UX 3.5

## Key features and concepts

- **Crop factory:** `createCrop($filename)` returns a `Crop` object for an image file on the server (the source image). Autowire the interface. Its service `cropper` is private. Entry point: `Symfony\UX\Cropperjs\Factory\CropperInterface`.
- **Form type:** `CropperType` renders the crop field. `public_url` (required, string) is the browser URL of the same image, and `cropper_options` (default `[]`) holds the Cropper.js options. The field has no label by default, and its `data_class` is `Crop`. Entry point: `Symfony\UX\Cropperjs\Form\CropperType`.
- **Crop data:** Give the `Crop` object to the field as its data, for example `createFormBuilder(['crop' => $crop])`. On each Cropper.js `crop` event, the Stimulus controller writes the crop data as JSON into the hidden child `options`. With the default Cropper.js options, the JSON has the keys `x`, `y`, `width`, `height`, `rotate`, `scaleX` and `scaleY`. On submit, the form gives this JSON to `Crop::setOptions()`. The values use the natural pixel size of the image at `public_url`. So the image at `public_url` must have the same content and pixel size as the source image. `setDefaultOptions()` sets initial `x`, `y`, `width`, `height` and `rotate` values, but the Stimulus controller does not read them. To set the initial crop box in the browser, use the Cropper.js `data` option in `cropper_options`. Entry point: `$form->handleRequest($request)`.
- **Cropped image:** `getCroppedImage(string $format = 'jpg', int $quality = 80)` reads the source image and crops it to `x`, `y`, `width` and `height`. It returns the encoded image as a binary string. `$format` is a file extension, for example `jpg` or `png`. Entry point: `Crop::getCroppedImage()`.
- **Size limits and thumbnails:** After `setCroppedMaxSize(2000, 1500)`, `getCroppedImage()` scales down a larger result. `getCroppedThumbnail(200, 150)` scales down to the given limits for one call. Both keep the aspect ratio and do not enlarge a smaller image. Entry point: `Crop::setCroppedMaxSize()`, `Crop::getCroppedThumbnail()`.
- **Rotation:** Both methods turn the image clockwise by the `rotate` value, after the crop and after the size limits. So, after a 90-degree rotation, `getCroppedThumbnail(200, 150)` can return an image that is 150 pixels wide and 200 pixels high. Cropper.js measures `x`, `y`, `width` and `height` on the rotated image. Its README tells server code to rotate the image first and to crop it last. So, if `rotate` is not 0, the result does not match the crop box that the user sees. Cropper.js also sets `rotate` from the EXIF orientation of a JPEG file (option `checkOrientation`). The server ignores `scaleX` and `scaleY` (the flip values). Test the result with a rotated image and with a JPEG file that has an EXIF orientation. Entry point: `Crop::getCroppedImage()`.
- **No validation of the crop data:** The `Crop` model has no active validation constraints. Its `@Assert` docblock annotations have no effect, because Validator does not read annotations. So `$form->isValid()` does not check the crop data. Entry point: `Symfony\UX\Cropperjs\Model\Crop`.
- **Image drivers:** `cropperjs.driver` selects `gd` (default), `imagick` or `vips`. `cropperjs.driver_service` names a service that implements `Intervention\Image\Interfaces\DriverInterface`, and it has priority over `driver`. Both `vips` and `driver_service` need Intervention Image 3 or later. The `vips` driver also needs the `intervention/image-driver-vips` package. Entry point: `cropperjs.driver`, `cropperjs.driver_service`.
- **Stimulus controller:** The field puts the `@symfony/ux-cropperjs/cropper` controller (`symfony--ux-cropperjs--cropper`) on the hidden input. Its values are `public-url` (String) and `options` (Object). The controller adds an `<img class="cropperjs-image">` to the parent element of the input and calls `new Cropper(img, options)`. Entry point: `data-symfony--ux-cropperjs--cropper-options-value`.
- **JSON-only options:** `CropperType` encodes `cropper_options` with `json_encode()` into a data attribute. So use only JSON values there, for example `aspectRatio`, `viewMode`, `dragMode` or `preview` (a CSS selector). Put JavaScript callbacks such as `ready` or `cropend` in your own Stimulus controller. Give at least one option, for example `'viewMode' => 1`, which keeps the crop box inside the image. With an empty array, `json_encode()` writes `[]`. The controller then fails with a `TypeError`, and no crop box shows, because Stimulus accepts only a JSON object for the `options` value. The Cropper.js options go in `cropper_options`, not in top-level form options. Entry point: `cropper_options`.
- **JavaScript events:** Before it creates the cropper, the controller dispatches `cropperjs:pre-connect` with `options` and `img`. A listener can change `options` at this point. Then it dispatches `cropperjs:connect` with `cropper`, `options` and `img`. Both events bubble. To add your controller, set `'attr' => ['data-controller' => 'mycropper']`. `CropperType` moves this value to the hidden input, next to its own controller. Entry point: `cropperjs:pre-connect`, `cropperjs:connect`.
- **Cropper.js version 1:** The controller needs `cropperjs` ^1.5.9, which is Cropper.js 1. The npm `latest` tag is Cropper.js 2. So do not install `cropperjs` without a version constraint. The docs link to the 2.x README; the 1.x options are in the README of the `v1` branch. Entry point: `peerDependencies` in `assets/package.json` of the bundle.
- **Asset setup:** Flex adds the controller to `assets/controllers.json` with `enabled: true`, `fetch: eager` and two CSS `autoimport` entries (`cropperjs/dist/cropper.min.css`, `@symfony/ux-cropperjs/dist/style.min.css`). With AssetMapper, Flex runs `importmap:require` for `cropperjs@^1.5.9`. With Webpack Encore, Flex adds the packages to `package.json`. To load the cropper only when a crop field shows on the page, set `fetch` to `lazy`. To use your own CSS, set an `autoimport` entry to `false`. Do not remove the line, because Flex then adds it again. Entry point: `assets/controllers.json`.

## Entry points

- Service to autowire: `Symfony\UX\Cropperjs\Factory\CropperInterface` (`createCrop(string $filename): Crop`).
- Form type: `Symfony\UX\Cropperjs\Form\CropperType` (options `public_url` and `cropper_options`; block prefix `cropper`).
- Model: `Symfony\UX\Cropperjs\Model\Crop` (`getCroppedImage()`, `getCroppedThumbnail()`, `setCroppedMaxSize()`, `setDefaultOptions()`, `getOptions()`, `setOptions()`).
- Config keys in `config/packages/cropperjs.yaml`: `cropperjs.driver` (`gd`, `imagick` or `vips`; default `gd`), `cropperjs.driver_service` (a service ID; default `null`).
- Stimulus controller: `@symfony/ux-cropperjs/cropper` (HTML attribute `data-controller="symfony--ux-cropperjs--cropper"`), with the values `public-url` and `options`.
- JavaScript events: `cropperjs:pre-connect`, `cropperjs:connect`.
- `assets/controllers.json`: `controllers` -> `@symfony/ux-cropperjs` -> `cropper`, with `enabled`, `fetch` and `autoimport`.
- CSS classes: `cropperjs` (the field wrapper), `cropperjs-image` (the image).
- npm package: `@symfony/ux-cropperjs`. If you decouple the JavaScript dependencies from Composer, install it with the same version as the PHP package.
- Twig: `{{ form(form) }}` or `{{ form_row(form.crop) }}` shows the crop field. The package has no Twig functions, console commands or test helpers.

## Symbiotic packages

- [Form](../packages/form.md): `CropperType` is a compound form type with the `data_class` `Crop`, so the form writes the submitted crop data to the `Crop` object.
- [StimulusBundle](../packages/stimulus-bundle.md): The docs require StimulusBundle. It loads the `cropper` controller from `assets/controllers.json` under the name `symfony--ux-cropperjs--cropper`.
- [AssetMapper](../packages/asset-mapper.md): The bundle adds its `assets/dist` directory to `framework.asset_mapper.paths` as `@symfony/ux-cropperjs`, and Flex adds `cropperjs` 1.x to `importmap.php`.
- [WebpackEncoreBundle](../packages/webpack-encore-bundle.md): With Encore, Flex adds `@symfony/ux-cropperjs` and `cropperjs` to `package.json`. Then run `npm install --force`. Then restart Encore, for example with `npm run watch`.
- [Symfony Flex](../packages/flex.md): Flex registers the bundle (the package has no recipe) and updates `assets/controllers.json` and `importmap.php` or `package.json` for it. The bundle conflicts with Flex versions before 1.13.
- [Symfony UX Dropzone](../packages/ux-dropzone.md): Use `DropzoneType` (a `FileType` with drag and drop) to upload the image. When the image is on the server, use `CropperType` to crop it.

## Changed in 3.0 to 3.5

- `$crop->getCroppedImage('jpg', 80, true)` and `$crop->getCroppedThumbnail(200, 150, 'jpg', 80, true)` -> remove the `$applyRotation` argument (removed in 3.0). Both methods now always apply `rotate`, so remove any manual rotation of the result.
- 3.0 needs PHP 8.4 or later and Symfony 7.4 or later.
- No driver choice before 3.5 -> `cropperjs.driver` (`gd`, `imagick`, `vips`) and `cropperjs.driver_service` (new in 3.5). Before 3.5, the bundle had no configuration keys.
- 3.5 supports `intervention/image` 3 and 4. Version 2 still works, but it triggers PHP deprecations, and the docs recommend version 4.

## Status

To crop images on the server, the bundle needs a PHP image extension: `ext-gd` for the default `gd` driver, or `ext-imagick` for `imagick`. The `vips` driver needs `intervention/image-driver-vips`, the libvips library and `ext-ffi`.

## Docs

- https://symfony.com/bundles/ux-cropperjs/current/index.html
- https://ux.symfony.com/cropperjs (live demo with a 4:3 crop field and a thumbnail)
- https://raw.githubusercontent.com/fengyuanchen/cropperjs/v1/README.md (the Cropper.js 1.x options, methods and events)
