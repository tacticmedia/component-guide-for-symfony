# Mailer (`symfony/mailer`): details

**Applies to:** Symfony 8.1

## Key features and concepts

- **Transport DSN.** One DSN string selects the transport and its options. The built-in transports are `smtp://`, `smtps://`, `sendmail://default`, `native://default` and `null://null`. Prefer `sendmail://default` to `native://default`. Put SMTP options in the query string: `verify_peer`, `peer_fingerprint`, `auto_tls`, `require_tls`, `source_ip`, `local_domain`, `restart_threshold`, `restart_threshold_sleep`, `ping_threshold` and `max_per_second`. URL-encode special characters in the user name and the password. Entry point: `framework.mailer.dsn`, set from the `MAILER_DSN` environment variable.
- **Provider bridges.** A bridge package adds the transports of one provider. The scheme suffix selects the protocol, for example `mailgun+smtp://`, `mailgun+https://` or `mailgun+api://`. A bare scheme, such as `mailgun://`, selects the default protocol of the bridge. The `+https` and `+api` transports need `symfony/http-client`. Entry point: the bridge packages in the list under "Entry points".
- **Asynchronous delivery.** If a Messenger bus exists, `MailerInterface::send()` dispatches a `SendEmailMessage` to `messenger.default_bus`. Messenger handles it synchronously until you route `SendEmailMessage` to an async transport. Then a `messenger:consume` worker renders and sends the email. Keep the `TemplatedEmail` context serializable, or render the email before `send()` with `BodyRendererInterface::render()`. To skip the bus, set `framework.mailer.message_bus` to `false`. Entry point: `Symfony\Component\Mailer\Messenger\SendEmailMessage`.
- **Synchronous delivery with a result.** `TransportInterface::send()` sends at once, also when Messenger is installed. It returns a `SentMessage` with `getMessageId()` and `getDebug()`, or `null` if a listener rejects the email. Both `send()` methods throw `TransportExceptionInterface` if the transport does not accept the email. Entry point: `Symfony\Component\Mailer\Transport\TransportInterface`.
- **Failover and round-robin.** `failover(dsn1 dsn2)` sends through the first transport and uses the next transport if it fails. `roundrobin(dsn1 dsn2)` starts at a random transport and rotates for each email. Mailer skips a failed transport for 60 seconds. To change this period, add `?retry_period=<seconds>` after the closing parenthesis. Entry point: `MAILER_DSN="failover(postmark+api://ID@default sendgrid+smtp://KEY@default)"`.
- **Named transports.** `framework.mailer.transports` defines several named DSNs, and the first one is the default. To select another transport for one email, add an `X-Transport` header with its name. Mailer removes the header before delivery. Do not set `dsn` and `transports` together. Entry point: `framework.mailer.transports`.
- **Twig email templates.** `TemplatedEmail` adds `htmlTemplate()`, `textTemplate()`, `context()` and `locale()` to `Email`. A Mailer event listener renders the templates before delivery. The templates get an `email` variable with helpers such as `email.image('@images/logo.png')`, which embeds an image. If the text part is missing, Mailer creates it from the HTML part. Do not put an `email` key in the context. Entry point: `Symfony\Bridge\Twig\Mime\TemplatedEmail`.
- **CSS inlining, Markdown and Inky.** Some email clients, such as Gmail, ignore the styles in a `<style>` block. To copy the CSS rules into `style` attributes, wrap the HTML template in `{% apply inline_css %}`. To inline a CSS file, use `inline_css(source('@styles/email.css'))` with a `styles` namespace in `twig.paths`. The `markdown_to_html` and `inky_to_html` filters convert Markdown and Inky layout tags to HTML. Install `twig/extra-bundle` and the package of each filter: `twig/cssinliner-extra`, `twig/markdown-extra` with a library such as `league/commonmark`, or `twig/inky-extra`. Entry point: the Twig filter `inline_css`.
- **Global envelope and headers.** `framework.mailer.envelope.sender` sets the envelope sender (`MAIL FROM`) of all emails. `framework.mailer.headers` adds headers such as `From`, `Bcc` or `X-Custom-Header` to all emails. A global `From` or `To` applies only when the email has no such header. Mailer adds global `Cc`, `Bcc` and `Reply-To` addresses to the existing addresses. Entry point: `framework.mailer.headers`.
- **Safe delivery in development.** `framework.mailer.envelope.recipients` sends every email to fixed addresses. `allowed_recipients` takes regular expressions, and original recipients that match one also get the email. Only the envelope changes, so the `To` header stays the same. To disable delivery, use the `null://null` DSN. The Flex recipe adds a Mailpit email catcher to the Docker Compose configuration. Entry point: `framework.mailer.envelope.recipients` in a `when@dev` block.
- **Signatures and encryption.** `framework.mailer.dkim_signer` and `framework.mailer.smime_signer` sign all outgoing emails. `framework.mailer.smime_encrypter` encrypts each email that has an `X-SMime-Encrypt` header, with certificates from your `SmimeCertificateRepositoryInterface` service. If one recipient has no certificate, Mailer sends the email unencrypted. These features need the OpenSSL PHP extension. Entry point: `framework.mailer.dkim_signer`.
- **Mailer events.** `MessageEvent` lets a listener change the email or its envelope, or call `reject()` to cancel the email. With a Messenger bus, Mailer dispatches this event twice: before the bus, with `isQueued()` true, and again before delivery. Call `addStamp()` only when `isQueued()` is true. `SentMessageEvent` and `FailedMessageEvent` give the result. Entry point: `Symfony\Component\Mailer\Event\MessageEvent`.
- **Tags and metadata.** `TagHeader` and `MetadataHeader` add tags and key-value metadata to an email. The Mailgun, Mailtrap, Mandrill and Postmark transports support both, and so do the Brevo and SendGrid API transports. AhaSend, MailPace and the Resend API transport support only tags. Amazon SES supports only metadata. Other transports send them as `X-Tag` and `X-Metadata-<key>` headers. Entry point: `Symfony\Component\Mailer\Header\TagHeader`.
- **Provider webhooks.** Twelve bridges include a webhook request parser that turns provider callbacks into `MailerDeliveryEvent` (received, delivered, deferred, dropped, bounce) or `MailerEngagementEvent` (open, click, spam, unsubscribe). Map the parser service to a routing name in `framework.webhook.routing`. Consume the events in a class with `#[AsRemoteEventConsumer('<routing name>')]`. Always set the routing `secret` in production. Entry point: `mailer.webhook.request_parser.<provider>`.
- **Test assertions.** `KernelTestCase` and `WebTestCase` include `MailerAssertionsTrait`. Use `assertEmailCount()` for sent emails and `assertQueuedEmailCount()` for emails queued with Messenger. Get an email with `getMailerMessage()`. Check its content with `assertEmailHtmlBodyContains()` or `assertEmailHeaderSame()`. If the controller redirects after it sends the email, do not follow the redirect before the assertions. Entry point: `Symfony\Bundle\FrameworkBundle\Test\MailerAssertionsTrait`.

## Entry points

- `Symfony\Component\Mailer\MailerInterface`: autowire it to send an email. `send()` returns nothing and uses the Messenger bus when one exists.
- `Symfony\Component\Mailer\Transport\TransportInterface`: autowire it to send at once. `send()` returns a `Symfony\Component\Mailer\SentMessage`, or `null` if a listener rejects the email.
- `Symfony\Component\Mime\Email` and `Symfony\Component\Mime\Address`: build the email (see [Mime](../packages/mime.md)).
- `Symfony\Bridge\Twig\Mime\TemplatedEmail`: an `Email` with Twig templates for the HTML part and the text part.
- `Symfony\Component\Mime\BodyRendererInterface`: autowire it to render a `TemplatedEmail` before `send()`.
- `Symfony\Component\Mailer\Exception\TransportExceptionInterface`: catch it when the transport does not accept the email. `getDebug()` returns debug information, such as the HTTP calls.
- `Symfony\Component\Mailer\Messenger\SendEmailMessage`: route it in `framework.messenger.routing` to send emails from a worker.
- `Symfony\Component\Mailer\Event\MessageEvent`, `Symfony\Component\Mailer\Event\SentMessageEvent` and `Symfony\Component\Mailer\Event\FailedMessageEvent`: listen to them to change, reject or log emails.
- `Symfony\Component\Mailer\Header\TagHeader` and `Symfony\Component\Mailer\Header\MetadataHeader`: add provider tags and metadata.
- Special headers: `X-Transport` (a named transport), `X-Bus-Transport` (comma-separated Messenger transport names, only for queued emails) and `X-SMime-Encrypt` (global S/MIME encryption). Mailer removes `X-Transport` before delivery, and the `smime_encrypter` listener removes `X-SMime-Encrypt`. The `X-Bus-Transport` header stays in the sent email.
- `Symfony\Component\Mailer\EventListener\SmimeCertificateRepositoryInterface`: implement `findCertificatePathFor()` for `framework.mailer.smime_encrypter.repository`.
- `Symfony\Component\Mailer\Transport\TransportFactoryInterface`, `Symfony\Component\Mailer\Transport\AbstractTransportFactory` and `Symfony\Component\Mailer\Transport\Dsn`: add a transport for a custom DSN scheme. Tag the factory service with `mailer.transport_factory`, because Symfony does not autoconfigure this tag.
- Without FrameworkBundle: `Symfony\Component\Mailer\Transport::fromDsn()` and `new Symfony\Component\Mailer\Mailer($transport)`.
- Configuration: `framework.mailer.dsn`, `framework.mailer.transports`, `framework.mailer.message_bus`, `framework.mailer.envelope.sender`, `framework.mailer.envelope.recipients`, `framework.mailer.envelope.allowed_recipients`, `framework.mailer.headers`, `framework.mailer.dkim_signer` (`key`, `domain`, `select`, `passphrase`, `options`), `framework.mailer.smime_signer` (`key`, `certificate`, `passphrase`, `extra_certificates`, `sign_options`), `framework.mailer.smime_encrypter` (`repository`, `cipher`), `twig.mailer.html_to_text_converter` and `framework.webhook.routing`.
- Environment variable: `MAILER_DSN`. The Flex recipe sets it to `null://null`.
- Console command: `mailer:test <to>` with the options `--from`, `--subject`, `--body` and `--transport`. It uses the transport directly, without Messenger.
- Twig: the `email` variable in `TemplatedEmail` templates (`Symfony\Bridge\Twig\Mime\WrappedTemplatedEmail`), with `email.image()`, `email.attach()` and `email.toName`.
- Twig filters for email HTML: `inline_css` (`twig/cssinliner-extra`), `markdown_to_html` (`twig/markdown-extra`) and `inky_to_html` (`twig/inky-extra`). With `twig/extra-bundle`, Symfony enables each installed extension.
- Test helpers: `Symfony\Bundle\FrameworkBundle\Test\MailerAssertionsTrait`, which `KernelTestCase` and `WebTestCase` use: `assertEmailCount()`, `assertQueuedEmailCount()`, `assertEmailIsQueued()`, `assertEmailAttachmentCount()`, `assertEmailTextBodyContains()`, `assertEmailHtmlBodyContains()`, `assertEmailHasHeader()`, `assertEmailHeaderSame()`, `assertEmailAddressContains()`, `assertEmailSubjectContains()`, their negative forms such as `assertEmailHeaderNotSame()`, `getMailerMessage()`, `getMailerMessages()`, `getMailerEvent()` and `getMailerEvents()`.
- `Symfony\Component\Mailer\Test\AbstractTransportFactoryTestCase` and `Symfony\Component\Mailer\Test\IncompleteDsnTestTrait`: test a custom transport factory.
- Webhooks: the parser services `mailer.webhook.request_parser.ahasend`, `.brevo`, `.mailchimp`, `.mailersend`, `.mailgun`, `.mailjet`, `.mailomat`, `.mailtrap`, `.postmark`, `.resend`, `.sendgrid` and `.sweego`. The events are `Symfony\Component\RemoteEvent\Event\Mailer\MailerDeliveryEvent` and `Symfony\Component\RemoteEvent\Event\Mailer\MailerEngagementEvent`. Put `Symfony\Component\RemoteEvent\Attribute\AsRemoteEventConsumer` on a `Symfony\Component\RemoteEvent\Consumer\ConsumerInterface` class.
- Service IDs: `mailer.mailer` (alias `mailer`), `mailer.transports` and `mailer.default_transport`.
- Provider bridges. Install one package, then use one of its DSN schemes. "Bare" gives the protocol of the scheme without a suffix. "Webhook" marks a bridge with a webhook parser.
  - `symfony/aha-send-mailer` (AhaSend): `ahasend+smtp://`, `ahasend+api://` (bare: SMTP). Webhook.
  - `symfony/amazon-mailer` (Amazon SES): `ses+smtp://`, `ses+smtps://`, `ses+https://`, `ses+api://` (bare: HTTPS).
  - `symfony/azure-mailer` (Microsoft Azure): `azure+api://` (bare: API).
  - `symfony/brevo-mailer` (Brevo): `brevo+smtp://`, `brevo+api://` (bare: SMTP). Webhook.
  - `symfony/google-mailer` (Gmail): `gmail+smtp://`, `gmail+smtps://` (bare: SMTP). Use it only for development.
  - `symfony/infobip-mailer` (Infobip): `infobip+smtp://`, `infobip+smtps://`, `infobip+api://KEY@BASE_URL` with a required host (bare: SMTP).
  - `symfony/mail-pace-mailer` (MailPace): `mailpace+smtp://`, `mailpace+smtps://`, `mailpace+api://` (bare: SMTP).
  - `symfony/mailchimp-mailer` (Mandrill): `mandrill+smtp://`, `mandrill+smtps://`, `mandrill+https://`, `mandrill+api://` (bare: HTTPS). Webhook.
  - `symfony/mailer-send-mailer` (MailerSend): `mailersend+smtp://USERNAME:PASSWORD@default`, `mailersend+api://` (bare: SMTP). Webhook. The error message for a missing bridge names `symfony/mailersend-mailer`, which does not exist on Packagist.
  - `symfony/mailgun-mailer` (Mailgun): `mailgun+smtp://`, `mailgun+smtps://`, `mailgun+https://`, `mailgun+api://` (bare: HTTPS). Webhook.
  - `symfony/mailjet-mailer` (Mailjet): `mailjet+smtp://`, `mailjet+smtps://`, `mailjet+api://` with an optional `?sandbox=true` (bare: SMTP). Webhook.
  - `symfony/mailomat-mailer` (Mailomat): `mailomat+smtp://`, `mailomat+smtps://`, `mailomat+api://` (bare: SMTP). Webhook.
  - `symfony/mailtrap-mailer` (Mailtrap): `mailtrap+smtp://`, `mailtrap+smtps://`, `mailtrap+api://`, `mailtrap+sandbox://TOKEN@default?inboxId=INBOX_ID` (bare: SMTP). Webhook.
  - `symfony/microsoft-graph-mailer` (Microsoft Graph): only `microsoftgraph+api://CLIENT_APP_ID:CLIENT_APP_SECRET@default?tenantId=TENANT_ID`.
  - `symfony/postal-mailer` (Postal): `postal+api://API_TOKEN@BASE_URL` (bare: API).
  - `symfony/postmark-mailer` (Postmark): `postmark+smtp://`, `postmark+smtps://`, `postmark+api://` (bare: SMTP). Webhook.
  - `symfony/resend-mailer` (Resend): `resend+smtp://resend:API_KEY@default`, `resend+api://` (bare: SMTP). Webhook.
  - `symfony/scaleway-mailer` (Scaleway): `scaleway+smtp://`, `scaleway+smtps://`, `scaleway+api://` (bare: API).
  - `symfony/sendgrid-mailer` (SendGrid): `sendgrid+smtp://`, `sendgrid+smtps://`, `sendgrid+api://` (bare: SMTP). Webhook.
  - `symfony/sweego-mailer` (Sweego): `sweego+smtp://LOGIN:PASSWORD@HOST:PORT`, `sweego+api://` (bare: SMTP). Webhook.

## Symbiotic packages

- [Mime](../packages/mime.md): Mime builds the `Email`, `Address` and attachment objects that Mailer sends, and Mailer requires it.
- [Twig Bridge](../packages/twig-bridge.md): Twig Bridge provides `TemplatedEmail`, `NotificationEmail` and `BodyRenderer`, which render email bodies from Twig templates.
- [TwigBundle](../packages/twig-bundle.md): TwigBundle registers the listener that renders each `TemplatedEmail`, and it adds the `twig.mailer.html_to_text_converter` option.
- [Messenger](../packages/messenger.md): Mailer dispatches `SendEmailMessage` to the Messenger bus; route it to an async transport so that a worker sends the emails.
- [HttpClient](../packages/http-client.md): The `+https` and `+api` provider transports send their requests with HttpClient.
- [Notifier](../packages/notifier.md): Notifier sends its email notifications through Mailer; use Notifier for SMS, chat or push, and Mailer for direct emails.
- [Webhook](../packages/webhook.md): The webhook controller receives provider callbacks and parses them with the Mailer bridge parsers `mailer.webhook.request_parser.<provider>`.
- [RemoteEvent](../packages/remote-event.md): The Mailer webhook parsers produce `MailerDeliveryEvent` and `MailerEngagementEvent` objects for an `#[AsRemoteEventConsumer]` class.
- [EventDispatcher](../packages/event-dispatcher.md): Mailer dispatches `MessageEvent`, `SentMessageEvent` and `FailedMessageEvent`, and its listeners render, sign and redirect the emails.
- [FrameworkBundle](../packages/framework-bundle.md): FrameworkBundle creates the Mailer services from the `framework.mailer` configuration and registers the `mailer:test` command.
- [FrameworkBundle test tools](../packages/framework-bundle-testing.md): `KernelTestCase` and `WebTestCase` include `MailerAssertionsTrait`, which asserts sent and queued emails.
- [WebProfilerBundle](../packages/web-profiler-bundle.md): The profiler shows the emails of each request in its mailer panel, with data from the `mailer.data_collector` service.
- [Monolog Bridge](../packages/monolog-bridge.md): `MailerHandler` sends log records as emails through `MailerInterface`.
- [MonologBundle](../packages/monolog-bundle.md): The `symfony_mailer` handler type configures `MailerHandler`, for example to email errors in production.
- [Translation](../packages/translation.md): The Twig body renderer uses the Translation `LocaleSwitcher` to render a `TemplatedEmail` in the locale that `locale()` sets.
- [Symfony Contracts](../packages/contracts.md): the HttpClient contracts also have a `TransportExceptionInterface`; around `MailerInterface::send()`, catch the Mailer interface, not the HttpClient contract.

## Changed in 8.0/8.1

- Custom transport factory tests: `extends TransportFactoryTestCase` -> `extends AbstractTransportFactoryTestCase`, plus `use IncompleteDsnTestTrait;` for incomplete DSN cases. Symfony 8.0 removed `TransportFactoryTestCase`.
- `config/packages/mailer.xml` with `<framework:mailer>` -> `config/packages/mailer.yaml` or a PHP config array. Symfony 8.0 removed the XML configuration format. The framework configuration reference shows an XML example for `allowed_recipients`.
- `static function (FrameworkConfig $framework) { $framework->mailer()->envelope()->recipients([...]); }` -> `return App::config(['framework' => ['mailer' => ['envelope' => ['recipients' => [...]]]]]);`. Symfony 8.0 removed the fluent PHP configuration format. The framework configuration reference shows the fluent form for `allowed_recipients`.
- A plain `smtp://` DSN to reach Amazon SES on port 587 -> `ses+smtp://USERNAME:PASSWORD@default:587?region=REGION` (new in 8.1). Ports 465 and 2465 use implicit TLS, and other ports require STARTTLS.
- A delayed job that sends a SendGrid email later -> `$email->getHeaders()->addDateHeader('Send-At', new \DateTimeImmutable('+3 hours'));` with a `sendgrid+api://` DSN (new in 8.1).

## Docs

- https://symfony.com/doc/current/mailer.html
- https://symfony.com/doc/current/reference/configuration/framework.html (section `mailer`)
- https://symfony.com/doc/current/reference/configuration/twig.html (section `mailer`)
- https://symfony.com/doc/current/webhook.html (section "Mailer Webhooks")
- https://symfony.com/doc/current/testing.html (section "Mailer Assertions")
- https://symfony.com/doc/current/notifier.html (section "Email Channel")
- https://symfony.com/doc/current/logging/monolog_email.html
- https://github.com/symfony/mailer (package README)
- Bridge READMEs, with the DSN formats and options of each provider:
  - https://github.com/symfony/symfony/blob/8.1/src/Symfony/Component/Mailer/Bridge/AhaSend/README.md
  - https://github.com/symfony/symfony/blob/8.1/src/Symfony/Component/Mailer/Bridge/Amazon/README.md
  - https://github.com/symfony/symfony/blob/8.1/src/Symfony/Component/Mailer/Bridge/Azure/README.md
  - https://github.com/symfony/symfony/blob/8.1/src/Symfony/Component/Mailer/Bridge/Brevo/README.md
  - https://github.com/symfony/symfony/blob/8.1/src/Symfony/Component/Mailer/Bridge/Google/README.md
  - https://github.com/symfony/symfony/blob/8.1/src/Symfony/Component/Mailer/Bridge/Infobip/README.md
  - https://github.com/symfony/symfony/blob/8.1/src/Symfony/Component/Mailer/Bridge/MailPace/README.md
  - https://github.com/symfony/symfony/blob/8.1/src/Symfony/Component/Mailer/Bridge/Mailchimp/README.md
  - https://github.com/symfony/symfony/blob/8.1/src/Symfony/Component/Mailer/Bridge/MailerSend/README.md
  - https://github.com/symfony/symfony/blob/8.1/src/Symfony/Component/Mailer/Bridge/Mailgun/README.md
  - https://github.com/symfony/symfony/blob/8.1/src/Symfony/Component/Mailer/Bridge/Mailjet/README.md
  - https://github.com/symfony/symfony/blob/8.1/src/Symfony/Component/Mailer/Bridge/Mailomat/README.md
  - https://github.com/symfony/symfony/blob/8.1/src/Symfony/Component/Mailer/Bridge/Mailtrap/README.md
  - https://github.com/symfony/symfony/blob/8.1/src/Symfony/Component/Mailer/Bridge/MicrosoftGraph/README.md
  - https://github.com/symfony/symfony/blob/8.1/src/Symfony/Component/Mailer/Bridge/Postal/README.md
  - https://github.com/symfony/symfony/blob/8.1/src/Symfony/Component/Mailer/Bridge/Postmark/README.md
  - https://github.com/symfony/symfony/blob/8.1/src/Symfony/Component/Mailer/Bridge/Resend/README.md
  - https://github.com/symfony/symfony/blob/8.1/src/Symfony/Component/Mailer/Bridge/Scaleway/README.md
  - https://github.com/symfony/symfony/blob/8.1/src/Symfony/Component/Mailer/Bridge/Sendgrid/README.md
  - https://github.com/symfony/symfony/blob/8.1/src/Symfony/Component/Mailer/Bridge/Sweego/README.md
