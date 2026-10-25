# SUS mail to Matrix

Nano runs `services.sus-mail` for `#sus-mail:autonomija.net`, using the dedicated
`@sus-mail:autonomija.net` account. The room must have encryption off. The bot
checks encryption before every message and stops forwarding if it is enabled.

The bot polls the `sus@anarhizam.org` INBOX every 15 seconds. This includes mail
for `kontakt@sus.autonomija.net`, `postmaster@sus.autonomija.net`, and
`abuse@sus.autonomija.net`. The first startup records existing read and unread
messages without forwarding them. Only subsequent arrivals are forwarded.
Junk and other folders are excluded; mail moved or deleted before the next poll
may not be captured.

Messages include From, To, Subject, Date, and plain text. HTML-only messages are
converted to text without loading remote content. Mail containing attachments,
an unreadable body, or more than 12,000 characters also includes the original
`message.eml`, preserving its attachments. Open or save this file with Thunderbird.

## Activate on Nano

With these changes present in Nano's checkout:

```sh
cd ~/nixos
sudo nixos-rebuild switch --flake path:.#nano
sudo sus-mail-setup
```

Setup registers the bot using Nano's local Matrix registration token and keeps
its password and access token under `/var/lib/sus-mail-secrets`, readable only by
root. It reuses the same identity and session when rerun. No mailbox password is
needed. If setup asks for an invitation, invite `@sus-mail:autonomija.net` to
`#sus-mail:autonomija.net`; the running service retries joining automatically.

```sh
systemctl status sus-mail.service
sudo journalctl -u sus-mail.service -n 30 --no-pager
```

After the log reports that the inbox baseline is initialized, send a new test
email to `kontakt@sus.autonomija.net`. Confirm it appears once in the Matrix room
and remains unread in Thunderbird. Also check an email with an attachment.

## Delivery state

The service reads only the SUS inbox through a read-only bind mount. The rest of
the mail storage tree is hidden from it. It never changes mail files or flags.

`/var/lib/sus-mail/outbox.sqlite` stores message keys and queued mail. Captured
mail survives deletion from the inbox and is retried with a growing delay up to
one hour. Stable Matrix transaction IDs prevent duplicate posts on retries.
Delivered mail content is removed from the queue; keys remain for deduplication
when Thunderbird changes flags or the service restarts. Keep this database and
the bot credentials in protected backups. Deleting the database resets the
baseline and loses pending deliveries.

Run the offline delivery tests with:

```sh
PYTHONDONTWRITEBYTECODE=1 nix shell nixpkgs#python3 -c python3 -m unittest discover -s modules/features/services/sus-mail -v
```
