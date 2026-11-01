# Privacy

What RustBB stores about the people who use a forum, why, for how long, and how members get a copy of it or delete it. Operators can use this page to write their forum's privacy notice; under the GDPR, the operator of a forum is the controller of its data, and RustBB is software they run.

## What is stored

Everything is in the one SQLite database (`RUSTBB_DATABASE_PATH`), and in the backups made of it.

### Members

| Data | Where it comes from | Why | Kept until |
| --- | --- | --- | --- |
| For each account they sign in with ([Sign-in](sign-in.md)): the provider (Telegram, GitHub, or an OpenID Connect provider's address) and the account's id there | The provider, at sign-in | Recognizing the member at the next sign-in | They remove it under Settings → Sign-in, or the account is deleted |
| With it, a name to tell the account by: the Telegram or GitHub username, or for OpenID Connect the email address (or else the provider's username), if the provider gives one; when it was added and last used | The provider, at every sign-in | Shown to the member under Settings → Sign-in, and to administrators; invitations for a Telegram username | As above |
| Passkeys: the public key, its id, a use count, the browser and system it was made on, when it was added and last used | The member's device, when they add it | Signing in with it; spotting a copied key | They remove it under Settings → Sign-in, or the account is deleted |
| Forum username | Chosen at registration | Shown with their posts and on their profile | The account is deleted |
| Role; a ban, with its reason, who set it, when, and when it ends | Administrators | Permissions; telling a banned member why | The ban is lifted or ends (an ended ban is cleared at their next sign-in), or the account is deleted |
| "About me" text | The member, under Settings | Their public profile | They change it, or the account is deleted |
| Their language, if they chose one | The member, under Settings | Pages and bot messages in it | They change it, or the account is deleted |
| When they registered, when they last signed in, when Telegram signed their last login | The forum | Profiles ("Joined", "Last seen"); refusing a replayed Telegram login | The account is deleted (the registration date stays, without anything else) |
| Topics and posts, with their times and edits | The member | The forum's content | Deleted by a moderator or with the account (see below) |
| What they have read: up to which post, in each topic they opened, in each forum they marked read, and overall | The forum, as they read | Showing what is new to them | Replaced as they read on; "mark read" removes the marks it covers; deleting the account removes them |
| Their avatar, and images they attach to posts: the image only, decoded and encoded again, so the original file's EXIF (where a photo was taken, the camera and its serial number), comments and anything else in it are gone; its size and when it was added | The member | Showing them | They remove the avatar or the image (editing the post), or the post is erased; the avatar goes with the account |
| A search index of topic titles and post text | Built from the topics and posts | Search | With the text it indexes: an edited post is indexed again, an erased one leaves the index |
| The earlier versions of their edited posts, who wrote each and when | The member, or a moderator who edited the post | Edit history, for the author and the forum's moderators | With the post; erasing their posts erases these too |
| Reports they made: the post, the reason, when, and the outcome | The member | The report queue; moderators see who reported | Deleting the account removes them; otherwise kept with the forum's records |
| The moderation log: what moderators and administrators did, to which topic, post or member, and a reason where there is one | The forum | Moderators checking each other's work | Kept with the forum's records; a deleted account in it shows as "deleted account" |
| Which forums a member moderates | Administrators | Moderation | Changed by an administrator, or the account is deleted |
| Which bot notifications they want, and the topics they watch | The member, under Settings and with the Watch button | Sending [notifications](telegram.md#notifications) | They change it, stop watching, or the account is deleted |
| Each notification: whose post in which topic it is about, when it was queued, sent or given up, and why it failed | The member, under Settings; the forum, when someone replies | Sending [notifications](telegram.md#notifications) through the Telegram bot | 30 days after it was sent or given up, or the account is deleted |
| Sessions: a random token; the browser and system, such as "Firefox on Linux"; the address (IP) it started from; when it started, was last used (to within five minutes) and expires | The forum, at sign-in; the browser's `User-Agent` header, of which only that summary is kept | Keeping them signed in; showing them where they are signed in, under Settings → Sessions; the address lets administrators ban it along with an abusive account | Sign-out, ending it under Settings → Sessions, expiry (`RUSTBB_SESSION_DAYS`; expired ones are removed at the member's next sign-in), a ban, or deleting the account |
| Invitations they created | The member, if allowed | Registration by invitation | Kept with the forum's records; the creator becomes a deleted account |

RustBB never receives a password. It receives an email address only from an OpenID Connect provider, as above, and sends nothing to it. The Telegram login also sends the member's first and last name and a profile photo address: RustBB checks them as part of Telegram's signature and does not store them. OpenID Connect providers and GitHub send a name too, used only to greet the member at registration and not stored. A passkey's private key never leaves the member's device. The address members connect from is kept only with their sessions, as above, and the member sees it on their Sessions page.

### People who ask for an invitation

| Data | Why | Kept until |
| --- | --- | --- |
| Telegram account id, username, first and last name | Showing administrators who is asking; the bot message after approval | They register and delete their account; or an administrator removes it in the database |
| Their note, the answer, and when | Deciding the request | As above |

A declined request is kept so that the same Telegram account cannot ask again.

### Members of a forum imported from phpBB

[`rustbb import phpbb`](importing.md) carries over from phpBB, for each member: the username (in Latin letters, with the original in their "About me"), the signature (as "About me"), the role, a ban in force with its reason, when they registered and last visited, an uploaded avatar, their topics and posts with their times and edits, and attached images. It does not read passwords, email addresses, IP addresses, private messages or anything else. These are stored as in the table above, and the member gets a copy or deletes them the same way once they have claimed the account.

| Data | Why | Kept until |
| --- | --- | --- |
| A claim code for an imported account: who made it, when, and when it expires | The member taking over the account | It is used, replaced by a new one, or the account is deleted; an expired one stays until then, unusable |
| Which phpBB member number and attachment number became which account and image | Redirecting phpBB's old links | Kept with the forum's records |

Posts by phpBB's guests keep the name the guest gave, and belong to an account called `guest`.

### Banned addresses

Administrators can ban an address or a range of addresses (Admin → Bans, or `rustbb ip ban`). The address, the reason, who banned it and when the ban ends are kept until the ban is lifted or ends. Nobody from a banned address can use the forum.

### Not in the database

- **Cookies:** `rustbb_session`, holding the session token, only after sign-in; and `rustbb_oauth`, for the ten minutes of a sign-in through an OpenID Connect provider or GitHub, holding a random value that ties the provider's answer to the browser. Both are needed for signing in, so they need no consent banner. There are no analytics or third-party cookies.
- **Telegram:** the login button on the sign-in page is loaded from `telegram.org`, so Telegram sees visitors of that page. The forum's bot sends messages through `api.telegram.org`: notifications (the title of the member's topic, the name of who replied and a link) and invitation requests and approvals. Telegram therefore sees them.
- **Other sign-in providers:** a member who signs in with an OpenID Connect provider or GitHub goes through that provider's pages, so it learns that they use the forum.
- **Memory:** to limit how often someone can sign in, register or post, the server keeps visitors' IP addresses and member ids in memory, with the times of their attempts in the last hour at most. While someone registers, the account they signed in with waits in memory for up to thirty minutes. None of this is written to disk, and it is gone at a restart.
- **Logs:** each request's method and path, never its query string; and events such as a new registration (account id, username, role and the provider), a sign-in method added, or an invitation request (Telegram id). Where the logs go and how long they are kept is the operator's choice: [Monitoring](monitoring.md#logs).
- **Metrics,** when enabled, contain counts only, nothing about a person: [Monitoring](monitoring.md#metrics).

## A copy of one's data

Signed-in members download everything above about themselves under **Settings → Your data**, as a JSON file: their account, avatar and attached images, the accounts and passkeys they sign in with, sessions, notifications, watched topics, reports they made, what they have read, topics, posts (including ones a moderator deleted), the invitations they created and their invitation request.

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
- removes every account and passkey it signed in with, its avatar, its notifications, watched topics, reports, forum moderation and reading marks, the "About me" text, the chosen language and the sign-in times, and replaces the username with `deleted-<number>`, shown as "deleted account";
- removes their invitation request and any invitation meant for them;
- frees the username, and lets the same Telegram or other account register again as a new member.

Their posts stay, shown as by a deleted account, so that discussions still make sense. With **Also erase all my posts** (or `--erase-posts`), the text and images of every post they wrote are erased, and topics in which nobody else wrote are removed. The titles of topics they started that others replied to stay; a moderator can remove those.

The only administrator cannot delete their account: another member must be made administrator first.

Posts in forums that visitors may read are also in the forum's feeds and sitemap, which feed readers and search engines fetch. A deleted post or account leaves them at once, but copies already fetched are outside the forum's control.

RustBB overwrites deleted data in the database file (SQLite's `secure_delete`). Copies made before the deletion still have it: the [backups](deployment.md#backups) the operator keeps, and the automatic copy taken before each upgrade. They go when the operator deletes those files.
