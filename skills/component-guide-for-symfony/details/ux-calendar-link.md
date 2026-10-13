# Symfony UX Calendar Link (`symfony/ux-calendar-link`): details

**Applies to:** Symfony UX 3.5

## Key features and concepts

- **Event object**: `CalendarEvent` holds the `title`, `start`, `end`, `description`, `location`, `allDay`, `url`, `recurrence`, `reminders` and `uid` of one event. The constructor accepts any `\DateTimeInterface` and stores `\DateTimeImmutable` copies. It throws `InvalidArgumentException` for an empty title or for an end before the start. Entry point: `new CalendarEvent(title: ..., start: ..., end: ...)`.
- **One link in Twig**: `ux_calendar_link(event, provider)` returns a `CalendarLink` with the properties `provider`, `label` and `url`. The provider names are `google`, `outlook`, `office365` and `ics`. For an unknown name, the registry throws `UnknownProviderException`, and its message lists the available names. `CalendarLink` implements `\Stringable`, so `{{ link }}` prints the same URL as `{{ link.url }}`.
- **All links in Twig**: `ux_calendar_links(event)` returns an array of `CalendarLink` objects, keyed by provider name. With the built-in providers, the order is `google`, `outlook`, `office365`, `ics`. Loop over the array and print `link.url` and `link.label`.
- **Built-in providers**: The labels are "Google Calendar", "Outlook.com", "Office 365" and "iCalendar (.ics)". The `google`, `outlook` and `office365` URLs are deep links to `calendar.google.com`, `outlook.live.com` and `outlook.office.com`. The `ics` URL is a `data:text/calendar;charset=utf-8;base64,...` URI with `METHOD:PUBLISH` calendar data. The package has no route or controller that serves an `.ics` file.
- **Field support**: A provider ignores each field that its URL format cannot carry, with no error. Recurrence goes to `google` and `ics` only. Reminders and the event `url` go to `ics` only.
- **Recurrence**: `CalendarRecurrence::daily()`, `weekly()`, `monthly()`, `yearly()` and `minutely()` accept `interval`, `count` and `until`. Do not use `count` and `until` together, because this throws `InvalidArgumentException`. The factories write only `FREQ`, `INTERVAL`, `COUNT` and `UNTIL` (in UTC). There is no `BYDAY` rule and no `hourly()` or `secondly()` factory. The constructor is private, so you cannot pass a custom `RRULE`. Use `minutely()` only with the `ics` provider.
- **Reminders**: `CalendarReminder::before()` takes `weeks`, `days`, `hours`, `minutes` and an optional `description`, and adds the units together. The total must be greater than zero. In the `.ics` output, each reminder is a `VALARM` block with `ACTION:DISPLAY`.
- **All-day events**: Set `allDay: true`. Set `end` to the last day of the event, for example the same date as `start` for a one-day event. The `google` and `ics` providers add one day to make the end exclusive. The Outlook providers send both dates with `allday=true`.
- **Time zones**: The `google`, `outlook` and `office365` links send the times in UTC. The `.ics` output writes a time in a region zone (for example `Europe/Paris`) as local time with `TZID` and a `VTIMEZONE` block. Thus a weekly 09:00 event stays at 09:00 after a DST change. For `UTC` and for a fixed offset such as `+02:00`, the `.ics` output writes UTC times. The `VTIMEZONE` rules start one to two years after the event. A client that uses only this block can show a time that is one hour wrong.
- **Abbreviation zones fail**: A date parsed from a string that ends in `Z` (for example `'2026-05-14T09:00:00Z'` or a JavaScript `toISOString()` value) has an abbreviation zone. Strings that end in `EST`, `CEST` or `GMT` give the same zone type. For such a date, the `ics` provider throws a `TypeError`, so `ux_calendar_links()` fails too. Before you create the event, call `->setTimezone(new \DateTimeZone('UTC'))` or set a region zone. Branch 3.x has a fix, but no release contains it.
- **Stable `.ics` UID**: By default, the `UID` is a UUID v5 that the package derives from the title, start, end and location. Thus the same event always gets the same UID, and a second import does not add a duplicate. If the title, time or location can change, pass a stored `Uuid` as `uid`. Then calendar clients update the event.
- **Fixed `DTSTAMP` in tests**: The `.ics` builder takes `DTSTAMP` from the `clock` service. For a known value, use `ClockSensitiveTrait` in the test class. Call `self::mockTime()` in the test. The `clock` service reads the global clock that `mockTime()` sets, so this works at any time. In a kernel test, you can also set a `MockClock` as the `clock` service. Do this before the first calendar link, because the container creates the `.ics` builder together with the registry.
- **Registry in PHP**: Autowire `CalendarLinkProviderRegistry` to build links outside Twig, for example for a JSON response. Its methods are `has()`, `get()`, `all()`, `generate($event, $provider)` and `generateAll($event)`.
- **Custom provider**: Implement `CalendarLinkProviderInterface` with `getName()`, `getLabel()` and `generate()`. Tag the service with `ux_calendar_link.provider`: put `#[AutoconfigureTag('ux_calendar_link.provider')]` on the class, or use `tags:` or `_instanceof` in `config/services.yaml`. The bundle does not autoconfigure this interface. The docs do not describe this extension point; the source does.
- **Server side only**: The bundle has no configuration keys and no JavaScript or Stimulus controller. The Twig functions build the links on the server when the template renders.

## Entry points

- Install: `composer require symfony/ux-calendar-link`. The package has no Flex recipe, but Flex adds `Symfony\UX\CalendarLink\UXCalendarLinkBundle` to `config/bundles.php` with an auto-generated recipe. The extension alias is `ux_calendar_link`, and it has no configuration keys.
- Value objects: `Symfony\UX\CalendarLink\CalendarEvent`, `Symfony\UX\CalendarLink\CalendarRecurrence` (`minutely()`, `daily()`, `weekly()`, `monthly()`, `yearly()`), `Symfony\UX\CalendarLink\CalendarReminder::before()`.
- Twig functions: `ux_calendar_link(event, provider)` and `ux_calendar_links(event)`. Both return `Symfony\UX\CalendarLink\CalendarLink` objects (`provider`, `label`, `url`).
- Autowire: `Symfony\UX\CalendarLink\Registry\CalendarLinkProviderRegistry` (alias of the service `ux_calendar_link.registry`).
- Extension point: `Symfony\UX\CalendarLink\Provider\CalendarLinkProviderInterface` and the service tag `ux_calendar_link.provider`.
- Exceptions: `Symfony\UX\CalendarLink\Exception\InvalidArgumentException` and `Symfony\UX\CalendarLink\Exception\UnknownProviderException`. Both implement `Symfony\UX\CalendarLink\Exception\ExceptionInterface`.
- Service IDs: `ux_calendar_link.provider.google`, `ux_calendar_link.provider.outlook`, `ux_calendar_link.provider.office365`, `ux_calendar_link.provider.ics`, `ux_calendar_link.twig.runtime`, `ux_calendar_link.twig.extension`. The service `ux_calendar_link.ics.builder` has the class `Symfony\UX\CalendarLink\Ics\IcsBuilder`, which is `@internal`.
- Test helpers: `Symfony\Component\Clock\Test\ClockSensitiveTrait` (call `self::mockTime()` in the test class), or `Symfony\Component\Clock\MockClock` as the `clock` service.

## Symbiotic packages

- [TwigBundle](../packages/twig-bundle.md): TwigBundle is a required dependency and loads `ux_calendar_link()` and `ux_calendar_links()` through the `twig.extension` and `twig.runtime` tags of the package services.
- [FrameworkBundle](../packages/framework-bundle.md): FrameworkBundle is a required dependency and supplies the `clock` service that the `.ics` builder uses (in 8.1, through its required `ServicesBundle`).
- [Clock](../packages/clock.md): Clock is a required dependency since 3.5: the `.ics` builder takes `DTSTAMP` from the `clock` service, and `ClockSensitiveTrait` or `MockClock` freezes it in tests.
- [Uid](../packages/uid.md): Uid is a required dependency: `CalendarEvent::$uid` takes a `Uuid`, and the default `.ics` UID comes from `UuidFactory::nameBased()` (UUID v5).
- [Mailer](../packages/mailer.md): For an email invitation, attach your own iCalendar data with Mailer as a `DataPart` of type `text/calendar; charset=utf-8; method=REQUEST`, in `8bit` encoding.
- [UX Toolkit](../packages/ux-toolkit.md): The shadcn `Calendar` and `Date Picker` recipes (3.5) of UX Toolkit render a widget that selects dates, not an "Add to calendar" link.
- [DependencyInjection](../packages/dependency-injection.md): A custom provider service needs the `ux_calendar_link.provider` tag (`#[AutoconfigureTag]`, `tags:` or `_instanceof`), because the bundle does not autoconfigure `CalendarLinkProviderInterface`.

## Changed in 3.1 to 3.5

- 3.1 (May 2026): The package is new. Older code builds Google, Outlook and `.ics` links by hand. Use `ux_calendar_link()` and `ux_calendar_links()` instead.
- 3.5: `IcsBuilder` is internal. Do not create or inject it (service `ux_calendar_link.ics.builder`). Use the `ics` provider: `ux_calendar_link(event, 'ics')` or `$registry->generate($event, 'ics')`.
- 3.5: `CalendarEvent` accepts `uid` (a `Uuid`). The `.ics` `UID` now comes from the event content, not from a random value. If the event can change, pass a stored `uid`.
- 3.5: The `.ics` output writes region-zone times as local time with `TZID` and `VTIMEZONE` (before: always UTC). Create recurring events in a region zone. This change also causes the abbreviation-zone `TypeError` of v3.5.1.
- 3.5: `DTSTAMP` comes from the `clock` service, and `symfony/clock` is a new required dependency. Use `MockClock` or `ClockSensitiveTrait` for a fixed `DTSTAMP` in tests.

## Status

- **Experimental**: The README and the docs mark the package as EXPERIMENTAL. They say that it "is likely to change, or even change drastically". The same docs page also claims the Symfony backward-compatibility promise. In 3.5, `IcsBuilder` became internal with no deprecation. Expect API changes in minor versions.
- **Needs the `mbstring` PHP extension**: The `.ics` builder calls `mb_strcut()` for each line longer than 75 octets, for example an 80-character description. `symfony/polyfill-mbstring` does not provide `mb_strcut()`, and `composer.json` does not require `ext-mbstring`.
- **Versions**: The package requires PHP 8.4 or later and Symfony 7.4 or 8.x. It follows the Symfony UX 3.x version line, not the Symfony 8.1 line.

## Docs

- https://symfony.com/bundles/ux-calendar-link/current/index.html
- https://ux.symfony.com/calendar-link
- https://symfony.com/doc/current/mailer.html (section "Calendar Invitations")
- https://symfony.com/doc/current/service_container/tags.html
