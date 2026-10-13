# Mime (`symfony/mime`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when you build an email message, sign or encrypt it, or find the MIME type of a file. It handles attachments, inline images, multipart bodies, DKIM, S/MIME and file extensions. It builds messages. To send them, see [Mailer](mailer.md).

**Details:** [../details/mime.md](../details/mime.md)

## Why it exists

An email is a MIME message with encoded headers, nested multipart bodies, attachments and optional signatures. Hand-built MIME bodies and headers break easily. The package builds such messages from PHP objects and encodes them to the MIME standards. It also converts between MIME types and file extensions, and it guesses the MIME type of a file from its contents.

## When to use it

- Build an email with a sender, recipients, a subject, a text body and an HTML body.
- Attach a file, such as a PDF invoice, to an email.
- Show an image inside the HTML body of an email.
- Sign an outgoing email with DKIM or S/MIME, or encrypt it with S/MIME.
- Create the plain-text part of an HTML email from the HTML.
- Let a user download a draft email file that an email client opens.
- Find the file extensions of a MIME type, or the MIME types of a file extension.
- Guess the MIME type of a file, such as an upload, from its contents.
- Build a multipart form-data body with files for an HTTP request.

## Use it instead of

- A hand-built MIME body with `"--$boundary"` lines and `chunk_split(base64_encode(file_get_contents($pdf)))` -> `$email->attachFromPath('/path/to/invoice.pdf')` (`Symfony\Component\Mime\Email`).
- `<img src="data:image/png;base64,...">` in the HTML body of an email -> `$email->embedFromPath('/path/to/logo.png', 'logo')` with `<img src="cid:logo">`.
- `'"'.$name.'" <'.$email.'>'` as a `From` or `To` value -> `new Address($email, $name)` (`Symfony\Component\Mime\Address`), which escapes the name, removes its line breaks and rejects an address with control characters.
- A hand-written `['jpg' => 'image/jpeg', 'png' => 'image/png']` array -> `$mimeTypes->getMimeTypes('jpg')` and `$mimeTypes->getExtensions('image/png')` (`Symfony\Component\Mime\MimeTypesInterface`).
- `mime_content_type($path)` or `finfo_file(finfo_open(FILEINFO_MIME_TYPE), $path)` -> `$mimeTypes->guessMimeType($path)`, which also runs your tagged guessers.
- `->text(strip_tags($html))` on each email -> a `TemplatedEmail` with `htmlTemplate()` and without `text()`; the body renderer creates the text part with the configured `HtmlToTextConverterInterface`.
- `openssl_pkcs7_sign()` or `openssl_pkcs7_encrypt()` on temporary files, plus hand-built MIME headers -> `SMimeSigner::sign()` or `SMimeEncrypter::encrypt()` (`Symfony\Component\Mime\Crypto`).
- A hand-built `DKIM-Signature` header with `openssl_sign()` -> `DkimSigner::sign()` or the `framework.mailer.dkim_signer` configuration.
- A hand-built `multipart/form-data` string with `Content-Disposition: form-data; name="..."` lines -> `new FormDataPart(['file' => DataPart::fromPath($path)])`.
