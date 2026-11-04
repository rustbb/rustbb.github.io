# Moderation

Who can moderate, and the tools they have: reports from members, edit history, reactions, polls, private messages, and a log of what moderators and administrators did.

## Moderators

Under **Admin → Users**, an administrator gives a member a role:

- **Moderator** moderates every forum.
- **Administrator** moderates every forum and runs the site (settings, forums, members, bans).

A member can also moderate some forums only: under **Admin → Categories & forums**, each forum has a field for its moderators' usernames, separated by commas. They can then do in those forums what a moderator does: lock, unlock, pin and unpin topics; move them between forums they moderate; edit and delete anyone's posts; delete topics; reply in locked topics; see deleted posts and edit history; remove members' reactions; add, close and delete polls; and deal with reports. Elsewhere they are members.

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

Reported [private messages](#private-messages) go to the moderators everywhere and the administrators only, not to forum moderators, in a section of the same queue: the reported message, up to five before it in the conversation, and who reported it and why. Nothing else of the conversation is shown. **Dismiss** closes their reports; messages cannot be deleted, so for abuse, ban the sender under **Admin → Users**.

## Edit history

When a post is edited, its earlier text is kept. The post's author and the forum's moderators see **history** next to "edited", with every version, newest first. Other members only see that the post was edited, and when.

## Reactions

Under each post, signed-in members can react with 👍 Like, ❤️ Love, 😂 Funny, 😮 Wow, 😢 Sad or 👎 Dislike: each of them once, and a second press takes it back. **React** shows all six. Anyone who may read the forum may react, also where they may not reply and in locked topics, but not to their own posts and not while banned. A ban keeps the reactions a member left. Reactions do not send bot notifications.

Visitors see how many left each reaction. Signed-in members also see who: the names are in each button's description, and **Who reacted** lists them all. On that list the forum's moderators can **Remove** a member's reaction, which the log records. Reactions to a deleted post are hidden with it.

## Polls

Whoever starts a topic can add a poll to it on the New topic form, under **Add a poll**: a question, 2 to 10 options (one a line), how many options each member may choose (1, or up to all of them), and how many days it stays open (up to 90, or 0 for no end). The poll appears above the topic's posts, and the forum's list marks the topic **Poll**. Moderators can add a poll to a topic that has none, with **Add a poll** at the top of the topic.

Members who may reply in the forum vote, the poll's author too; voting stops when the topic is locked, and in forums where members may not reply. They can change or withdraw their vote until the poll closes. Votes are anonymous: everyone, moderators too, sees only how many chose each option, and only after voting, when they cannot vote, or once the poll has closed. Visitors see the counts once it closes.

Until someone votes, the poll's author and the forum's moderators can change it, or delete it; its author only while the topic is not locked, as with their posts, and they cannot delete a topic whose poll has others' votes. After that it stays as it is: its author (in a topic that is not locked) and the moderators can close it early, and only moderators can delete it. The log records what moderators do to other members' polls.

## Private messages

Members write to each other in private conversations, one for each pair of members: with **Send a message** on someone's profile, **New message** under **Messages** in the header, or in a conversation they have. The header shows **Messages (N new)** while conversations have unread messages. Messages use the same Markdown as posts, without images, and mentions in them notify nobody.

Starting a conversation takes a first post on the forum, and a member can start at most five an hour; moderators, forum moderators and administrators are spared both. Messages cannot be edited or deleted once sent. **Remove from my list** hides a conversation; a new message brings it back with what came before, and once both members have removed it, it is deleted, unless a report of it is open.

A member who does not want someone's messages blocks them, on the profile or in the conversation: neither can write to the other, and the blocked member is only told that the other "does not take messages from you", the same as when someone turns private messages off under **Settings → Private messages**. That page also lists whom they blocked.

Nobody else reads conversations, moderators and administrators included, except a message one of the two reports, as above. The operator of the server can read the database, as with everything else; [Privacy](privacy.md) says what is kept.

## The log

`/mod/log` (Reports → Moderation log, or Admin) lists what moderators and administrators did, newest first: locking, pinning, moving and deleting topics; editing and deleting other people's posts; dismissing reports (of posts and of private messages); removing reactions; adding, changing, closing and deleting other members' polls; changing roles and forum moderators; and banning members and addresses. Moderators everywhere see all of it; forum moderators see their forums' entries.

An entry keeps who did it, what, when, and enough to read it later (a topic's title, a ban's reason) even after the topic or post is gone. Entries are kept as long as the forum; the [Privacy](privacy.md) page says what that means for members.

## On the command line

`rustbb user role <name> moderator` and `rustbb user ban` do what Admin → Users does; see [Command line](command-line.md). They are not in the log, which records what was done in the browser.
