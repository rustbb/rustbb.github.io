# Privacy

What RustBB stores about the people who use a forum, why, for how long, and how members get a copy of it or delete it. Operators can use this page to write their forum's privacy notice; under the GDPR, the operator of a forum is the controller of its data, and RustBB is software they run.

## What is stored

Everything is in the one SQLite database (`RUSTBB_DATABASE_PATH`), and in the backups made of it.

### Members

| Data | Where it comes from | Why | Kept until |
| --- | --- | --- | --- |
| Telegram account id | Telegram, at sign-in | Recognizing the member at the next sign-in | The account is deleted |
| Telegram username (`@name`), if they have one | Telegram, at every sign-in | Invitations for a username; shown to administrators | The account is deleted |
| Forum username | Chosen at registration | Shown with their posts and on their profile | The account is deleted |
| Role; a ban, with its reason, who set it, when, and when it ends | Administrators | Permissions; telling a banned member why | The ban is lifted or ends (an ended ban is cleared at their next sign-in), or the account is deleted |
| "About me" text | The member, under Settings | Their public profile | They change it, or the account is deleted |
| When they registered, when they last signed in, when Telegram signed their last login | The forum | Profiles ("Joined", "Last seen"); refusing a replayed login | The account is deleted (the registration date stays, without anything else) |
| Topics and posts, with their times and edits | The member | The forum's content | Deleted by a moderator or with the account (see below) |
| Sessions: a random token; the browser and system, such as "Firefox on Linux"; the address (IP) it started from; when it started, was last used (to within five minutes) and expires | The forum, at sign-in; the browser's `User-Agent` header, of which only that summary is kept | Keeping them signed in; showing them where they are signed in, under Settings → Sessions; the address lets administrators ban it along with an abusive account | Sign-out, ending it under Settings → Sessions, expiry (`RUSTBB_SESSION_DAYS`; expired ones are removed at the member's next sign-in), a ban, or deleting the account |
| Invitations they created | The member, if allowed | Registration by invitation | Kept with the forum's records; the creator becomes a deleted account |

RustBB never receives a password or an email address. The Telegram login also sends the member's first and last name and a profile photo address: RustBB checks them as part of Telegram's signature and does not store them. The address members connect from is kept only with their sessions, as above, and the member sees it on their Sessions page.

### People who ask for an invitation

| Data | Why | Kept until |
| --- | --- | --- |
| Telegram account id, username, first and last name | Showing administrators who is asking; the bot message after approval | They register and delete their account; or an administrator removes it in the database |
| Their note, the answer, and when | Deciding the request | As above |

A declined request is kept so that the same Telegram account cannot ask again.

### Banned addresses

Administrators can ban an address or a range of addresses (Admin → Bans, or `rustbb ip ban`). The address, the reason, who banned it and when the ban ends are kept until the ban is lifted or ends. Nobody from a banned address can use the forum.

### Not in the database

- **Cookies:** one, `rustbb_session`, holding the session token, only after sign-in. It is needed for signing in, so it needs no consent banner. There are no analytics or third-party cookies.
- **Telegram:** the login button on the sign-in page is loaded from `telegram.org`, so Telegram sees visitors of that page. The forum's bot sends messages through `api.telegram.org` (invitation requests and approvals).
- **Memory:** to limit how often someone can sign in, register or post, the server keeps visitors' IP addresses and member ids in memory, with the times of their attempts in the last hour at most. They are never written to disk and are gone at a restart.
- **Logs:** each request's method and path, never its query string; and events such as a new registration (account id, username, role) or an invitation request (Telegram id). Where the logs go and how long they are kept is the operator's choice: [Monitoring](monitoring.md#logs).
- **Metrics,** when enabled, contain counts only, nothing about a person: [Monitoring](monitoring.md#metrics).

## A copy of one's data

Signed-in members download everything above about themselves under **Settings → Your data**, as a JSON file: their account, Telegram id and username, sign-ins, topics, posts (including ones a moderator deleted), the invitations they created and their invitation request.

For someone who cannot sign in, such as a banned member, the operator makes the same file on the server:

```sh
rustbb user export alice > alice.json
```

## Deleting an account

Members delete their own account under **Settings → Delete account**, by typing their username again. On the server:

```sh
rustbb user delete alice                 # posts stay, by "deleted account"
rustbb user delete alice --erase-posts   # their posts' text is erased too
```

Deleting an account at once:

- ends all its sessions;
- removes the Telegram id and username, the "About me" text and the sign-in times, and replaces the username with `deleted-<number>`, shown as "deleted account";
- removes their invitation request and any invitation meant for them;
- frees the username, and lets the same Telegram account register again as a new member.

Their posts stay, shown as by a deleted account, so that discussions still make sense. With **Also erase all my posts** (or `--erase-posts`), the text of every post they wrote is erased, and topics in which nobody else wrote are removed. The titles of topics they started that others replied to stay; a moderator can remove those.

The only administrator cannot delete their account: another member must be made administrator first.

RustBB overwrites deleted data in the database file (SQLite's `secure_delete`). Copies made before the deletion still have it: the [backups](deployment.md#backups) the operator keeps, and the automatic copy taken before each upgrade. They go when the operator deletes those files.
