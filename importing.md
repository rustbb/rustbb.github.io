# Moving from phpBB or SMF

`rustbb import phpbb` brings a phpBB 3.2 or 3.3 forum into a new RustBB forum: its members, categories and forums, topics, posts, polls and attached images, and if you ask for them, private messages. Forums, topics and posts keep their numbers, so phpBB's old links lead to the same pages. Members get their accounts back with a claim code, because RustBB has no passwords. `rustbb import smf` does the same for SMF 2.0 and 2.1: see [Moving from SMF](#moving-from-smf).

## What comes over

| From phpBB | In RustBB |
| --- | --- |
| Members who are active, or posted at least once | Accounts with the same role: founders and the Administrators group become administrators, Global moderators become moderators. A name RustBB cannot take as it is (letters other than Latin, spaces, fewer than 3 characters, or taken) is written in Latin letters, with `_` for anything else and a number if needed: `Иван Петров` becomes `Ivan_Petrov`. Their "About me" then says what the name was. |
| Signatures | "About me" |
| Uploaded avatars | Avatars, decoded and encoded again like members' own uploads |
| Bans of accounts that are in force | Bans, with the reason that was shown to the member and the end date |
| Categories, and the forums in them | Categories and forums, in the same order. A forum inside another forum is named after both ("News › Archive"); forums outside any category go into one called "Forums". Links are left out. |
| Who may read and post in each forum | From what the Guests and Registered users groups may do there: read by visitors, by members only, or by staff only; post topics, only reply, or neither. A locked forum takes posts from staff only. |
| Forum moderators | Moderators of those forums ([Moderation](moderation.md)) |
| Topics: sticky, announcements, locked | Topics: pinned, locked |
| Posts, with their formatting, quotes, code, lists and links | Posts in Markdown. Images from other sites become links, as RustBB shows no images from elsewhere. Colours, sizes and fonts are dropped; the text stays. |
| Edits | The time of the last edit and who made it |
| Soft-deleted posts | Deleted posts, which moderators still see |
| Posts by guests and by deleted members | Posts by one account called `guest`, each starting with the name the guest gave |
| Attached images (JPEG, PNG, GIF, WebP) | Images attached to the posts |
| Polls | [Polls](moderation.md#polls) with their options in the same order, how many each member may choose, and their end. Members' votes come over; votes by guests and by accounts left out do not, so counts can be lower than phpBB showed. Votes stay anonymous. A poll keeps more than ten options, or an end further away than 90 days, if it had them. |
| Private messages, only with `--messages` | [Conversations](moderation.md#private-messages), one for each pair of members. A message to several members is in the sender's conversation with each of them. It comes over for every member who still had it in phpBB, and for everyone it went to while its sender still had it. A subject starts the message in bold, unless it only replies to the one before ("Re: …"). Messages to or from accounts left out stay behind. |
| Foes | Blocks: neither can write to the other, as in phpBB |
| "Allow users to send you private messages" turned off | Private messages turned off under **Settings → Private messages** |

Left out: passwords and email addresses, IP addresses, private messages unless `--messages` asks for them, drafts, friends, attachments that are not images, unapproved topics and posts, inactive accounts that never posted, bots, ranks, groups other than the two above, permissions given to single members, and bans of addresses and email addresses ([ban addresses](command-line.md#commands-and-options) again with `rustbb ip ban`). phpBB 3.0 and 3.1 stored posts differently: their posts come over as plain text, without formatting.

Everything imported counts as read, for everyone, private messages too.

Private messages are what members wrote to each other in confidence. Bring them over only if you have told the members you will, the way you tell them about the move; without `--messages` they stay in phpBB's dump.

## 1. Export phpBB

Dump phpBB's database, with phpBB stopped or in its board-disabled mode so that nothing changes meanwhile:

```sh
mysqldump --default-character-set=utf8mb4 --single-transaction phpbb > phpbb.sql
```

Use the name of phpBB's database in place of `phpbb`; `mariadb-dump` takes the same options. A dump from phpMyAdmin (SQL format) works too. If phpBB's tables do not start with `phpbb_`, give the prefix with `--prefix`.

For avatars and attached images, also copy phpBB's directory, or at least its `files/` and `images/avatars/upload/` directories, keeping their places.

## 2. Try it

Import into a forum that has no forums or topics yet: a new one, before you set it up. The forum's administrator may already exist; their account stays as it is. Stop the forum while importing.

A dry run reads and checks everything, then changes nothing:

```sh
rustbb import phpbb phpbb.sql --files /path/to/phpbb --messages --dry-run
```

```text
412 members (37 renamed; 1890 inactive accounts that never posted left out)
3 categories and 14 forums (2 not open to visitors)
5210 topics and 61873 posts (204 more deleted)
38 polls with 1204 votes (57 by guests or members left out)
8812 private messages in 1630 conversations (95 to or from members left out)
21 foes, now blocked
2318 attached images and 96 avatars (41 files left out)
dry run: nothing was changed
```

The names it makes up, "Forums" and "wrote:" in quotes, are in the forum's language (**Admin → Settings**).

## 3. Import

The same without `--dry-run`. The import is one transaction: it happens completely, or not at all. Run it with the forum's settings, like every [command](command-line.md); with systemd, copy the dump and phpBB's directory under `/var/lib/rustbb/` first, so the service's user can read them:

```sh
sudo cp -r phpbb.sql phpbb /var/lib/rustbb/
sudo chmod -R a+rX /var/lib/rustbb/phpbb.sql /var/lib/rustbb/phpbb
rustbb import phpbb /var/lib/rustbb/phpbb.sql --files /var/lib/rustbb/phpbb    # the alias from Command line
sudo rm -r /var/lib/rustbb/phpbb.sql /var/lib/rustbb/phpbb
```

In Docker, copy them into the container's volume and run `docker exec rustbb rustbb import phpbb ...` the same way.

Then start the forum, and check the forums' permissions under **Admin → Categories & forums**.

## 4. Members claim their accounts

Imported accounts have no way to sign in. To take over theirs, a member needs a claim code from an administrator:

- Under **Admin → Users**, an imported account nobody has claimed says so, with a **Claim code** button; or
- `rustbb user claim <username>`.

A code works once, for 30 days; a new one replaces it. Send it to the member the way you reach them, such as phpBB's email or private messages before you switch. The member signs in to the forum with any way it offers (Telegram, an OpenID Connect provider, GitHub), and on the registration page enters the code under **Had an account on the old forum?** From then on that is how they sign in to their old account, with its name, posts and role; they can add more ways under **Settings → Sign-in**. Claiming works whatever the registration mode, even when registration is closed.

## Old links

These phpBB addresses redirect to the same pages, permanently, so that search engines move their links over:

| phpBB | RustBB |
| --- | --- |
| `/viewtopic.php?t=12`, `/viewtopic.php?p=345` | `/t/12`, `/p/345` |
| `/viewforum.php?f=3` | `/f/3` |
| `/memberlist.php?mode=viewprofile&u=7` | the member's profile |
| `/download/file.php?id=9` | the attached image |
| `/index.php` | the front page |

If phpBB was at the same address as the new forum, nothing else is needed. If it was in a directory, such as `https://example.com/forum/`, have the web server pass that directory's addresses to RustBB without the directory; with Caddy, `handle_path /forum/* { reverse_proxy 127.0.0.1:8080 }`, and with Nginx, `location /forum/ { proxy_pass http://127.0.0.1:8080/; }`. On another domain, redirect the old domain's addresses to the new one, path and query string included.

## Moving from SMF

`rustbb import smf` brings a Simple Machines Forum 2.0 or 2.1 into a new RustBB forum, as `rustbb import phpbb` does for phpBB, boards in windows-1251 included. Trying it, importing and claiming accounts go as above: [Try it](#2-try-it), [Import](#3-import) and [Members claim their accounts](#4-members-claim-their-accounts), with `smf` in place of `phpbb`.

### What comes over from SMF

| From SMF | In RustBB |
| --- | --- |
| Members who are activated, or posted at least once | Accounts, named after their display name (written in Latin letters when RustBB cannot take it, as for phpBB). The Administrator group, as the main or an additional group, makes administrators; Global Moderator, moderators. |
| Signatures, uploaded avatars | "About me", avatars |
| Bans of accounts, in full ("cannot access the forum"), that are in force | Bans, with their reason and end |
| Categories and boards | Categories and forums, in the same order. A child board is named after its parents ("News › Archive"). Redirect boards and the recycle bin are left out, topics in it too. |
| Who may see each board, and what members may do in its permission profile | Read by visitors (Guests may see it), by members only (Regular members may), or by staff only; post topics ("Post new topics"), only reply ("Post replies to any topic"), or neither |
| Board moderators, and 2.1's moderator groups | Moderators of those forums |
| Topics: sticky, locked | Topics: pinned, locked. A topic's title is its first post's subject; other posts' subjects ("Re: …") are dropped. |
| Posts, with their BBCode | Posts in Markdown, as for phpBB. SMF's default smileys become emoji in posts that had smileys on. Tags SMF does not know, such as those mods add (`[spoiler]`), and tags never closed stay as they were typed. |
| Edits | The time of the last edit and who made it |
| Posts by guests and by deleted members | Posts by the `guest` account, each starting with the name the guest gave |
| Attached images, in every attachment directory | Images attached to the posts |
| Polls | Polls, as for phpBB; a poll whose voting was locked closes at its topic's last post, and one with fewer than two options is left out |
| Private messages, only with `--messages` | Conversations, as for phpBB |
| Ignore lists | Blocks. A member who ignored everyone, or (2.1) took messages only from buddies or administrators, has private messages turned off. |

Left out, besides what phpBB leaves out: unapproved topics and posts, the recycle bin, karma and likes, buddy lists, and SMF 1.1's boards, whose tables differ (ask if you need them).

### Character sets

SMF before 2.1 stored text in the language's character set: a Russian board installed with the `russian` language (not `russian-utf8`) is in windows-1251, usually in tables MySQL calls `latin1`. RustBB reads such a board however it was dumped:

- `mysqldump --default-character-set=latin1` keeps the bytes as they are, which is the cleanest dump of such tables;
- `--default-character-set=utf8mb4` turns each byte into a character, so the dump shows `Ïðèâåò` where SMF showed `Привет`: RustBB turns it back.

A board in UTF-8 (every 2.1 board, and 2.0 boards installed with UTF-8) needs nothing special. SMF 2.0 says nothing about its character set unless it is UTF-8, so RustBB takes text that is not UTF-8 for windows-1251; for a Western board in windows-1252 (ISO-8859-1), add `--charset windows-1252`. A dry run says which it used, shows a few names and titles, and warns when text still looks garbled:

```text
text read as windows-1251; for example: Иван Петров, Мария, Olga, Новости, Привет, мир
3 unapproved posts and 12 topics in the recycle bin left out
```

### Exporting SMF

```sh
mysqldump --default-character-set=latin1 --single-transaction smf > smf.sql     # SMF 2.0 in windows-1251
mysqldump --default-character-set=utf8mb4 --single-transaction smf > smf.sql    # a board in UTF-8
```

Copy SMF's `attachments` directory too, with any others **Admin → Configuration → Attachments** lists, and `custom_avatar` if avatars were kept there; give SMF's directory with `--files`. RustBB looks for each directory where SMF had it, then under `--files` by its name.

### SMF's old links

SMF's addresses go through `/index.php`, which RustBB answers for both forums. They redirect permanently:

| SMF | RustBB |
| --- | --- |
| `/index.php?topic=12.0`, `?topic=12.40` | `/t/12` |
| `/index.php?topic=12.msg345#msg345`, `?msg=345` | `/p/345` |
| `/index.php?board=3.0` | `/f/3` |
| `/index.php?action=profile;u=7` | the member's profile |
| `/index.php?action=dlattach;topic=12.0;attach=9` | the attached image |
| `/index.php/topic,12.0.html`, `/index.php/board,3.0.html` | the same, from SMF's search-engine-friendly addresses |
| anything else on `/index.php` | the front page |

As for phpBB, have the web server pass SMF's old directory, or its old domain, to RustBB.
