# Sign-in

RustBB keeps no passwords. Members sign in with an account they already have, or with a passkey:

- **[Telegram](telegram.md)**, through the forum's bot.
- **OpenID Connect**: Google, Keycloak, Authentik, or any other provider that offers it.
- **GitHub**.
- **Passkeys**, added to an account under **Settings → Sign-in**.

Set up as many as you like; the login page shows each one. A member's first sign-in registers them, as [the registration mode](telegram.md#registration) allows, and they choose a forum username. Afterwards they can add more ways to sign in to the same account under **Settings → Sign-in**, and remove any but the last one. An account belongs to one forum member: the same Google or Telegram account cannot sign in to two.

`rustbb check` lists the redirect address to register with each provider, and asks each OpenID Connect provider whether it answers. As with [Telegram](telegram.md#the-bot), RustBB reaches providers over IPv6 and IPv4 side by side, so a broken route of one kind does not stop sign-in.

## OpenID Connect

Register the forum as a client (an "application") with the provider: a confidential client with a client secret, for the authorization code flow, with the redirect URI `https://forum.example.com/auth/oauth/NAME/callback`. NAME is a name of your choosing, in letters and digits, which also goes into the settings:

```sh
RUSTBB_OIDC_NAME_ISSUER=https://id.example.com
RUSTBB_OIDC_NAME_CLIENT_ID=...
RUSTBB_OIDC_NAME_CLIENT_SECRET=...
RUSTBB_OIDC_NAME_LABEL=Example ID     # optional: the button says "Sign in with Example ID"
```

Without a label, the button uses NAME with a capital letter. RustBB finds the provider's addresses in its discovery document (`ISSUER/.well-known/openid-configuration`) and asks for the scopes `openid profile email`. It suggests a forum username from the account's `preferred_username` or email, and shows the email to the member, so they can tell their accounts apart.

Members are recognized by the issuer and the account's `sub`, so NAME and the label can change later without anyone losing their sign-in. Changing the issuer address makes every account from that provider a stranger.

### Google

In the [Google Cloud console](https://console.cloud.google.com/apis/credentials), create an OAuth client ID of the type "Web application", with the redirect URI above (Google allows `http://` only for `localhost`). Set up the OAuth consent screen first if asked.

```sh
RUSTBB_OIDC_GOOGLE_ISSUER=https://accounts.google.com
RUSTBB_OIDC_GOOGLE_CLIENT_ID=1234-abc.apps.googleusercontent.com
RUSTBB_OIDC_GOOGLE_CLIENT_SECRET=...
```

### Keycloak

In the realm, create a client: OpenID Connect, "Client authentication" on, "Standard flow" on, with the redirect URI above as a valid redirect URI. The secret is on the client's Credentials tab. The issuer is the realm's address:

```sh
RUSTBB_OIDC_KEYCLOAK_ISSUER=https://sso.example.com/realms/community
RUSTBB_OIDC_KEYCLOAK_CLIENT_ID=forum
RUSTBB_OIDC_KEYCLOAK_CLIENT_SECRET=...
RUSTBB_OIDC_KEYCLOAK_LABEL=Community account
```

### Authentik

Create an OAuth2/OpenID provider (a confidential client, with the redirect URI above) and an application that uses it. The issuer is shown on the provider's page, and ends in the application's slug:

```sh
RUSTBB_OIDC_AUTHENTIK_ISSUER=https://auth.example.com/application/o/forum
RUSTBB_OIDC_AUTHENTIK_CLIENT_ID=...
RUSTBB_OIDC_AUTHENTIK_CLIENT_SECRET=...
```

## GitHub

GitHub's sign-in is OAuth 2 rather than OpenID Connect, so it has settings of its own. Create an OAuth app under **Settings → Developer settings → OAuth Apps** on GitHub, with the forum's address as the homepage and `https://forum.example.com/auth/oauth/github/callback` as the authorization callback URL. Generate a client secret there:

```sh
RUSTBB_GITHUB_CLIENT_ID=Ov23li...
RUSTBB_GITHUB_CLIENT_SECRET=...
```

RustBB asks GitHub for no scopes: it reads only the account's public id, login and name.

## Passkeys

Passkeys need nothing in the settings, but browsers allow them only on `https://` addresses (and on `localhost`), and the forum must have a domain name rather than an IP address. A passkey belongs to the domain in `RUSTBB_BASE_URL`: moving the forum to another domain leaves members' passkeys behind, so they need another way to sign in then.

A member adds a passkey under **Settings → Sign-in** after signing in another way. The device, a password manager or a security key keeps it; signing in then takes the device's screen lock, fingerprint or face. Registering with a passkey alone is not possible: a new member registers with one of the other methods first.

## The first administrator

`RUSTBB_ADMIN_TELEGRAM_ID` names the Telegram account that can always register and becomes administrator ([Telegram](telegram.md#the-first-administrator)). On a forum without Telegram, create an invitation on the server with `rustbb invite create`, register with it, and run `rustbb user role <name> admin`.

## How sign-in is checked

- **OpenID Connect and GitHub** use the authorization code flow with PKCE. The `state` sent to the provider is also kept in a cookie, so the answer is accepted only in the browser that asked, once, within ten minutes. The code is exchanged at the provider's token endpoint with the client secret. The ID token comes from that exchange, directly from the provider over HTTPS, so its signature is not checked separately; its issuer, audience, expiry and nonce are. The provider's addresses must be `https://`.
- **Passkeys** are checked with [ring](https://github.com/briansmith/ring): the signature over the authenticator's data and the challenge, the forum's origin and domain, and a use count that only goes up, which reveals a copied key. RustBB stores each passkey's public key, never anything secret.
- **Adding a method** started from Settings joins the account at once. A Telegram login that arrives while someone is signed in asks first, because anyone can send a browser to the Telegram callback.
- Logs never record query strings, so the codes and login payloads in callback addresses stay out of log files.
