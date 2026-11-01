# Moving from phpBB

`rustbb import phpbb` brings a phpBB 3.2 or 3.3 forum into a new RustBB forum: its members, categories and forums, topics, posts and attached images. Forums, topics and posts keep their numbers, so phpBB's old links lead to the same pages. Members get their accounts back with a claim code, because RustBB has no passwords.

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

Left out: passwords and email addresses, IP addresses, private messages, polls, attachments that are not images, unapproved topics and posts, inactive accounts that never posted, bots, ranks, groups other than the two above, permissions given to single members, and bans of addresses and email addresses ([ban addresses](command-line.md#commands-and-options) again with `rustbb ip ban`). phpBB 3.0 and 3.1 stored posts differently: their posts come over as plain text, without formatting.

Everything imported counts as read, for everyone.

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
rustbb import phpbb phpbb.sql --files /path/to/phpbb --dry-run
```

```text
412 members (37 renamed; 1890 inactive accounts that never posted left out)
3 categories and 14 forums (2 not open to visitors)
5210 topics and 61873 posts (204 more deleted)
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
