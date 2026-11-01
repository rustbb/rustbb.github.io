# Stability

From 1.0, RustBB keeps a public contract: what a forum's setup, scripts, links, dashboards and stylesheets rely on keeps working across every 1.x release. Anything that would break it waits for 2.0, and 2.0 will come with migration notes for each change.

## What stays stable

- **Settings:** every environment variable in [Configuration](configuration.md#configuration), with its meaning and its default. New variables may come; none is removed or renamed, and no default changes in a way that changes a forum's behaviour.
- **The command line:** every command and option in [Command line](command-line.md#commands-and-options), and what it does. New commands and options may come. Scripts may rely on exit status 0 for success; the wording of messages may change.
- **Upgrades:** any release from 0.2.0 on upgrades straight to any 1.x release, with the [automatic backup](upgrading.md#the-automatic-backup) before the database is migrated. Releases can be skipped.
- **Addresses:** the [public URLs](#public-urls) below. A page may move, but its old address then redirects to it.
- **Metrics:** every metric in [Monitoring](monitoring.md#metrics), with its type and labels. New metrics and new label values (a new route, say) may come.
- **Stylesheets:** the [class names](#class-names) and [colour variables](#colour-variables) below, which a stylesheet from `RUSTBB_CUSTOM_CSS` can rely on. They keep their meaning; which elements carry them may change as pages gain things.

`cargo test` holds each release to these lists: removing a variable, a command, an option, an address, a metric, a class or a colour variable fails it.

## What may change

- The database's tables. Use the command line, the [data export](privacy.md#a-copy-of-ones-data) and the [backup](command-line.md#command-line) instead of reading or writing the tables. Each migration is announced in the [changelog](changelog.md).
- The format of the data export: it may gain, move or drop fields.
- The HTML of the pages, other than the class names below: elements, their order and their ids.
- The wording of pages, bot messages, log lines and command output, and the translations.
- Forms and the addresses they post to (such as `/t/{id}/reply`): they are for RustBB's own pages.
- The files under `/static/` other than `/static/style.css`.
- Behaviour that is a bug, and limits that protect the forum, such as rate limits.

## Deprecations

A setting, command or option that is to go is deprecated first. It keeps working until 2.0. `rustbb check` and the log at start-up warn while it is in use and name what replaces it, and the [changelog](changelog.md) says so in the release that deprecates it.

## Fixes

Fixes, security fixes included, go into a new release of the newest 1.x version; there are no fixes for older 1.x versions. As upgrades within 1.x keep everything above, upgrading is the way to get them. [Upgrading](upgrading.md) explains how, and how to go back.

## Going back

There is no downgrade. A version refuses a database that a newer one migrated; [going back](upgrading.md#going-back) means putting the automatic backup in place, and losing what was posted since.

## Public URLs

These addresses keep working, for links, bookmarks, feed readers, search engines and sign-in providers. `{id}` is a number, `{slug}` the title in the address, which may change without breaking the link.

| Address | What it is |
| --- | --- |
| `/` | The front page |
| `/f/{id}`, `/f/{id}/{slug}` | A forum |
| `/t/{id}`, `/t/{id}/{slug}` | A topic |
| `/p/{id}` | A post, on its page of its topic |
| `/unread/{id}` | A topic's first unread post |
| `/u/{username}` | A member's profile |
| `/search` | Search, with the words in `q` |
| `/login` | The sign-in page |
| `/media/{name}` | An uploaded image or avatar |
| `/feed.atom`, `/feed.rss` | The forum's newest topics, as Atom and RSS feeds |
| `/f/{id}/feed.atom`, `/f/{id}/feed.rss` | A forum's newest topics |
| `/t/{id}/feed.atom`, `/t/{id}/feed.rss` | A topic's newest posts |
| `/sitemap.xml` | The sitemap, and the files it lists |
| `/robots.txt` | Rules for search engines |
| `/healthz` | `ok` while the server runs, for health checks |
| `/auth/telegram/callback` | Where the Telegram login returns |
| `/auth/oauth/{key}/callback` | The redirect address registered with an OpenID Connect provider or GitHub ([Sign-in](sign-in.md#sign-in)) |
| `/static/style.css` | RustBB's stylesheet |
| `/index.php`, `/viewforum.php`, `/viewtopic.php`, `/memberlist.php`, `/download/file.php` | phpBB's addresses, which redirect to the same forum, topic, post, member or image on a forum [imported from phpBB](importing.md#old-links) |

Lists of forums, topics and search results take the page number in `page`, such as `/f/2?page=3`.

## Class names

A custom stylesheet may use these classes. Each keeps its meaning across 1.x.

| Class | Meaning |
| --- | --- |
| `wrap` | The page's content column |
| `site` | The page header and footer |
| `brand` | The site name or logo in the header |
| `search` | The search form in the header |
| `skip` | The "skip to content" link |
| `crumbs` | The breadcrumb trail, or a page's heading in its place |
| `page-title` | A page's heading row |
| `site-description` | The forum's description on the front page |
| `panel` | A box with a heading: a list, a form or a section |
| `pad` | Padding inside a panel |
| `stack` | Content inside a panel, with space between its parts |
| `list` | A table of forums, topics, members or other entries |
| `title` | A search result's title |
| `desc` | The description under a forum's name |
| `num` | A column of numbers |
| `last` | The column with the last post |
| `meta` | The line above a post's text: when it was written, and its tools |
| `muted` | Secondary text |
| `small` | A smaller button |
| `short` | A shorter text box |
| `help` | Help text for a form |
| `tag` | A label beside a title, such as "New" or "Locked" |
| `new` | A label for something unread |
| `lock` | A label for something locked or restricted |
| `post` | A post |
| `post-body` | The text of a post |
| `author` | The column with a post's author |
| `avatar` | A member's picture |
| `name` | The author's name beside a post |
| `content` | A post's text and its tools, beside the author |
| `tools` | A post's buttons and links |
| `attachments` | The images attached to a post |
| `deleted` | A deleted post |
| `revision` | One version in a post's edit history |
| `snippet` | A search result's excerpt |
| `results` | The search results |
| `pager` | Links to other pages of a list |
| `cur` | The current page in a pager |
| `btn` | A button, or a link that looks like one |
| `secondary` | A less prominent button |
| `danger` | A button that deletes or bans |
| `on-dark` | A button on the header colour |
| `plain` | A compact list, such as the reports on a post |
| `actions` | A row of buttons |
| `inline-form` | A form inside a line of text |
| `inline` | Form fields side by side |
| `row-form` | A form laid out as a table row |
| `grow` | Takes the room left in its row |
| `tight` | Less space between parts |
| `check` | A checkbox with its label |
| `checks` | A group of checkboxes |
| `flash` | A message after an action, such as "Saved" |
| `error` | A message that something went wrong |
| `error-page` | The page shown for an error |
| `logo-preview` | The logo on the settings page |
| `sr-only` | Text only for screen readers |
| `w-xs`, `w-s`, `w-m`, `w-l`, `w-xl` | Widths of form fields, from extra small to extra large |

## Colour variables

RustBB's stylesheet sets its colours as CSS variables, for the light scheme and the dark one (`@media (prefers-color-scheme: dark)`). Redefining them is the simplest way to restyle a forum ([Look](configuration.md#look)).

| Variable | Colour of |
| --- | --- |
| `--bg` | The page background |
| `--panel` | Panels |
| `--text` | Text |
| `--muted` | Secondary text |
| `--line` | Borders and rules |
| `--field-line` | Borders of form fields |
| `--accent` | Links, buttons, panel headings and quotes |
| `--accent-bg` | The tint behind panel headings |
| `--on-accent` | Text on the accent colour |
| `--head` | The header bar |
| `--head-text` | Text in the header bar |
| `--danger` | Buttons that delete, and errors |
| `--danger-bg` | The background of errors |
| `--ok` | Success messages |
