# Mailer (`symfony/mailer`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when the application must send email through SMTP, sendmail or a provider such as Amazon SES, Mailgun, Postmark or SendGrid. It adds HTML email templates, background sending, failover, DKIM signatures and test assertions. For SMS, chat or alerts on several channels, see [Notifier](notifier.md).

**Details:** [../details/mailer.md](../details/mailer.md)

## Why it exists

Each email delivery service has its own protocol, API and credentials. The package sends each email through a delivery method that one connection string selects, for example SMTP, sendmail or the API of a provider. The code that sends the email stays the same when you change the provider, add failover or move delivery to a background worker.

## When to use it

- Send a transactional email, such as an order confirmation or a password-reset link, from an HTML template.
- Send email through Amazon SES, Mailgun, Postmark, SendGrid or another provider, over SMTP or the provider API.
- Queue emails and send them later from a background worker.
- Use a second email provider automatically when the first provider fails.
- Send all emails to one safe address in development.
- Sign all outgoing emails with DKIM or S/MIME.
- Receive delivery, bounce, open and click events from the email provider through a webhook.
- Assert in a functional test that the application sent or queued an email with a given subject or body.
- Send a test email from the command line to check the delivery settings.
- Send email from a command-line tool or a plain PHP script without the full framework.

## Use it instead of

- `mail($to, $subject, $message, $headers)`, or `fsockopen('smtp.example.com', 587)` with hand-written `EHLO`, `STARTTLS` and `AUTH LOGIN` commands -> `MailerInterface::send()` with an `Email` object and a DSN such as `MAILER_DSN=smtp://user:pass@smtp.example.com:587` (`Symfony\Component\Mailer\MailerInterface`).
- `curl_init('https://api.sendgrid.com/v3/mail/send')` with a hand-built JSON payload -> `composer require symfony/sendgrid-mailer` and `MAILER_DSN=sendgrid+api://KEY@default`.
- `try { $primary->send($email); } catch (\Exception $e) { sleep(5); $backup->send($email); }` -> `MAILER_DSN="failover(postmark+api://ID@default sendgrid+smtp://KEY@default)"`.
- An `email_queue` database table and a cron script that sends the pending rows -> `SendEmailMessage` routed to a Messenger transport, and a `messenger:consume` worker.
- `str_replace('{name}', $name, file_get_contents('welcome.html'))` -> `new TemplatedEmail()->htmlTemplate('emails/welcome.html.twig')->context(['name' => $name])` (`Symfony\Bridge\Twig\Mime\TemplatedEmail`).
- `style="color: #333"` attributes on each tag of an HTML email, or a `DOMDocument` loop that copies `<style>` rules into them -> `{% apply inline_css %}` in the Twig template (`twig/cssinliner-extra`).
- A hand-built MIME body with `"--$boundary"` lines and `chunk_split(base64_encode($pdf))` -> `Email::attachFromPath('/path/to/file.pdf')` or `addPart(new DataPart(new File($path)))` from [Mime](mime.md).
- `if ('dev' === $env) { $to = 'me@example.com'; }` before each `send()` -> `framework.mailer.envelope.recipients` in a `when@dev` block.
- A fake mailer class that records sent emails in tests -> `assertEmailCount()` and `getMailerMessage()` (`Symfony\Bundle\FrameworkBundle\Test\MailerAssertionsTrait`).
- A controller that decodes the provider webhook JSON and checks its signature -> `mailer.webhook.request_parser.<provider>` and a consumer class with `#[AsRemoteEventConsumer]`.
