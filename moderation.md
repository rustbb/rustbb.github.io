# Moderation

Who can moderate, and the tools they have: reports from members, edit history, and a log of what moderators and administrators did.

## Moderators

Under **Admin → Users**, an administrator gives a member a role:

- **Moderator** moderates every forum.
- **Administrator** moderates every forum and runs the site (settings, forums, members, bans).

A member can also moderate some forums only: under **Admin → Categories & forums**, each forum has a field for its moderators' usernames, separated by commas. They can then do in those forums what a moderator does: lock, unlock, pin and unpin topics; move them between forums they moderate; edit and delete anyone's posts; delete topics; reply in locked topics; see deleted posts and edit history; and deal with reports. Elsewhere they are members.

## Who may read and post

Each forum has two settings, under **Admin → Categories & forums**. Staff, below, are the forum's moderators, the moderators everywhere and the administrators.

| Read | |
| --- | --- |
| Everyone, visitors too | The default. |
| Signed-in members | Visitors are asked to log in. |
| Staff only | For everyone else the forum does not exist: it is not listed, its topics answer "Not found", search does not find them, profiles do not list them, and nobody else gets notifications about them. |

| Post | |
| --- | --- |
| Members start topics and reply | The default. |
| Staff start topics, members reply | Announcements: members can answer. |
| Staff only | Read-only for members. |

Only forums everyone may read have [feeds](deployment.md#feeds-and-search-engines) and are in the sitemap. Locked topics stay closed to members whatever the forum allows. The front page and the forum's page show tags such as "Staff only" and "Read-only". A forum made staff-only later stops notifications to members who watched its topics.

## Reports

Signed-in members can report someone else's post with **Report**, saying what is wrong with it. The report goes to the moderators of that forum (and the moderators everywhere), with the member's username; the post's author does not see it. A member can report a post once.

Moderators see **Reports (N)** in the header while posts wait, and the queue at `/mod/reports` (also linked from Admin). For each reported post: its text, who reported it and why, and two ways out:

- **Dismiss: nothing wrong** closes its reports.
- Deleting the post (on the post itself; the topic, for a topic's first post) closes them too.

Moderators who sign in with Telegram also get a message from the bot about each new report, unless they turn that off under **Settings → Notifications**. See [Telegram](telegram.md#notifications).

## Edit history

When a post is edited, its earlier text is kept. The post's author and the forum's moderators see **history** next to "edited", with every version, newest first. Other members only see that the post was edited, and when.

## The log

`/mod/log` (Reports → Moderation log, or Admin) lists what moderators and administrators did, newest first: locking, pinning, moving and deleting topics; editing and deleting other people's posts; dismissing reports; changing roles and forum moderators; and banning members and addresses. Moderators everywhere see all of it; forum moderators see their forums' entries.

An entry keeps who did it, what, when, and enough to read it later (a topic's title, a ban's reason) even after the topic or post is gone. Entries are kept as long as the forum; the [Privacy](privacy.md) page says what that means for members.

## On the command line

`rustbb user role <name> moderator` and `rustbb user ban` do what Admin → Users does; see [Command line](command-line.md). They are not in the log, which records what was done in the browser.
