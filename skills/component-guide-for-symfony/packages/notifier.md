# Notifier (`symfony/notifier`)

**Applies to:** Symfony 8.1

**Elevator pitch:** Use when the application must alert users or administrators by SMS, chat, push or desktop notification. It sends each alert through providers such as Twilio, Vonage, Slack, Telegram or Microsoft Teams, with failover and channels per importance. For a plain email, see [Mailer](mailer.md).

**Details:** [../details/notifier.md](../details/notifier.md)

## Why it exists

Applications send alerts by SMS, chat, email, push, desktop and flash messages, and each provider has its own HTTP API. The package gives one API for all these channels. It configures each provider with a connection string, and it can select the channels of an alert by its importance.

## When to use it

- Send an SMS through a provider such as Twilio, Vonage or Brevo.
- Post a message to Slack, Telegram, Discord or Microsoft Teams.
- Send one notification to a user on several channels, for example email and SMS.
- Select the channels of a notification by its importance, for example SMS only for urgent alerts.
- Send a push notification through Expo, OneSignal or Ntfy.
- Show a desktop notification on the computer that runs the PHP code.
- Alert the administrators when a background job fails for the last time or when the application logs an error.
- Use a backup provider when the main provider fails, or rotate between providers.
- Receive the SMS delivery reports of Twilio, Vonage, LOX24, Smsbox or Sweego.
- Send no real messages in development, or write them to the log.

## Use it instead of

- `curl_init()` or `$httpClient->request('POST', ...)` to the Slack, Telegram or Teams API -> `ChatterInterface::send(new ChatMessage('...'))` with the provider DSN in `framework.notifier.chatter_transports`.
- A provider SDK or a hand-written call to the Twilio or Vonage SMS API -> `TexterInterface::send(new SmsMessage('+33612345678', 'Your code is 1234'))` with a `twilio://` or `vonage://` DSN in `texter_transports`.
- `if ($isUrgent) { $smsClient->send(...); } else { $this->addFlash('info', ...); }` -> `Notification::importance()` and `framework.notifier.channel_policy`.
- `try { $slack->send($text); } catch (\Throwable) { $telegram->send($text); }` -> the failover DSN `'%env(SLACK_DSN)% || %env(TELEGRAM_DSN)%'`.
- An event subscriber on `WorkerMessageFailedEvent` that mails the administrator -> `framework.notifier.notification_on_failed_messages: true` with `admin_recipients` and a `channel_policy` for `high`.
- A custom Monolog handler that sends an SMS or a chat message on errors -> the `notifier.monolog_handler` service as a MonologBundle handler (`type: service`, `id: notifier.monolog_handler`).
- `if ('dev' === $env) { return; }` around the send code -> `when@dev` with `null://null` or `fakesms+logger://default` DSNs.
- A controller that parses Twilio or Vonage status callbacks by hand -> `framework.webhook.routing` with `notifier.webhook.request_parser.twilio` and an `#[AsRemoteEventConsumer]` class that reads `SmsEvent`.
