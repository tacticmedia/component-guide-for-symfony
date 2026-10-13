# Symfony UX Calendar Link (`symfony/ux-calendar-link`)

**Applies to:** Symfony UX 3.5

**Elevator pitch:** Use when an event page needs "Add to calendar" links for Google Calendar, Outlook.com, Office 365 or an iCalendar file. It builds each link from one PHP event object, with optional recurrence and reminders. To pick dates in a form, see [UX Toolkit](ux-toolkit.md). To send email invitations, see [Mailer](mailer.md).

**Details:** [../details/ux-calendar-link.md](../details/ux-calendar-link.md)

## Why it exists

An event page often needs "Add to calendar" buttons. Each web calendar has its own URL format. An iCalendar file has rules for text escapes, a line length of 75 octets and time zones. The package builds all these links from one event object, and two Twig functions give them to the template.

## When to use it

- Add "Add to Google Calendar", "Add to Outlook" and "Add to Office 365" links to an event page.
- Offer an iCalendar file link for Apple Calendar, Outlook desktop and Thunderbird.
- Show one list of "Add to calendar" links for all providers with one Twig loop.
- Let users add a daily, weekly, monthly or yearly recurring event to their calendar.
- Add a reminder, for example 15 minutes before the start, to the iCalendar file of an event.
- Create an "Add to calendar" link for an all-day event, such as a public holiday.
- Add a calendar provider that the package does not supply.
- Build the links in PHP code outside a template, for example for a JSON response.

## Use it instead of

- `'https://calendar.google.com/calendar/render?action=TEMPLATE&text='.urlencode($title).'&dates='.$start->format('Ymd\THis\Z').'/'.$end->format(...)` -> `ux_calendar_link(event, 'google')`
- `'https://outlook.live.com/calendar/0/deeplink/compose?'.http_build_query(['subject' => $title, 'startdt' => ...])` -> `ux_calendar_link(event, 'outlook')` or `ux_calendar_link(event, 'office365')`
- `"BEGIN:VCALENDAR\r\nVERSION:2.0\r\n..."` concatenated by hand, with `str_replace()` escapes for `,` and `;` and a manual 75-octet line fold -> `ux_calendar_link(event, 'ics')`
- A hand-written `RRULE:FREQ=WEEKLY;COUNT=10` line, or a `recur=RRULE:...` query parameter for Google -> `CalendarRecurrence::weekly(count: 10)`
- A hand-written `BEGIN:VALARM` ... `TRIGGER:-PT15M` ... `END:VALARM` block -> `CalendarReminder::before(minutes: 15)`
- `'UID:'.uniqid()` or `'UID:'.Uuid::v4()` in an `.ics` file, which adds a duplicate event on each import -> the default UID of the `ics` provider (from the event content), or `new CalendarEvent(..., uid: $storedUuid)`
- `$end->modify('+1 day')->format('Ymd')` for an all-day event, and `->setTimezone(new \DateTimeZone('UTC'))->format('Ymd\THis\Z')` for each provider -> `allDay: true` and the date formats of the providers
- A hard-coded list of provider links in each template -> `{% for link in ux_calendar_links(event) %}<a href="{{ link.url }}">{{ link.label }}</a>{% endfor %}`
